//
//  TCPClient.swift
//  MobileSocket
//
//  Created by Aditya on 20/01/25.

import Foundation
import Network
import CryptoKit
import CommonCrypto
//import LoggingFramework
import AppKit

/// This Protocl use for handle tcp Connection send and recieve response.
protocol TCPConnectionDelegate {
    func TcpConnectionState(state: String)
    func receivedData(response: String)
    func handleErrors(error: String)
}

/// This Class Used for TCP Connection.
class TCPNetworkService: NSObject {
    
    var delegate:TCPConnectionDelegate?
    var didStopCallback: ((Error?) -> Void)? = nil
    
    var inputDelegate: StreamDelegate?
    var outputDelegate: StreamDelegate?
    
    var counter = 0
    var timer = Timer()
    weak var inputStream: InputStream?
    weak var outputStream: OutputStream?
    var handlePathChanges: ((NWPath.Status) -> Void)?
    var isSSLON: Bool = false
    
    lazy var connection: NWConnection = {
        // Create the connection
        //        Utils.printLog("Before Creating connection Host Address: \(CommonDefine.hostAddress), port is \(CommonDefine.ipPort)", logtype: .Debug)
        let connection = NWConnection(host: NWEndpoint.Host(CommonDefine.hostAddress), port: NWEndpoint.Port("\(CommonDefine.ipPort)") ?? 0000, using: self.parames)
        connection.stateUpdateHandler = self.listenStateUpdate(to:)
        connection.pathUpdateHandler = self.updateTcpMonitoring(to:)
        return connection
    }()
    
    lazy var parames: NWParameters = {
        let parames = NWParameters(tls: tlsOptions, tcp: self.tcpOptions)
        if let isOption = parames.defaultProtocolStack.internetProtocol as? NWProtocolIP.Options {
            isOption.version = .any
        }
        //        parames.preferNoProxies = true
        parames.expiredDNSBehavior = .allow
        parames.multipathServiceType = .disabled
        parames.serviceClass = .background
        return parames
    }()
    
    
    lazy var tlsOptions: NWProtocolTLS.Options = {
        let options = NWProtocolTLS.Options()
        return options
    }()
    
    lazy var tcpOptions: NWProtocolTCP.Options = {
        let options = NWProtocolTCP.Options()
        options.noDelay = true
        options.enableKeepalive = true
        options.connectionTimeout = 10000 // 100 this change is on previous build v.1.0.0.2 build 1...7
        options.connectionDropTime = 10
        options.enableFastOpen = true
        options.keepaliveIdle = 45
        options.keepaliveCount = 6
        options.keepaliveInterval = 60//10
        return options
    }()
    
    let queue = DispatchQueue(label: CommonDefine.hostAddress, qos: .background,attributes: [], autoreleaseFrequency: .workItem)//DispatchQueue(label: CommonDefine.hostAddress, attributes: .concurrent)
    let serialQueue = DispatchQueue(label: "com.queue.serial", attributes: .concurrent)
    
    private func listenStateUpdate(to state: NWConnection.State) {
        // Set the state update handler
        switch state {
        case .setup:
            //            Utils.printLog("TCP Connection In Setup State", logtype: .Information)
            Logger.shared.writeLog(.debug, "TCP Connection In Setup State")
            break
            // init state
        case .waiting(let error):
            Logger.shared.writeLog(.error, "Tcp connection waiting for server:\(CommonDefine.hostAddress), port: \(CommonDefine.ipPort) with this error: \(error)")
            self.delegate?.TcpConnectionState(state: "Disconnected")
            break
        case .preparing:
            Logger.shared.writeLog(.debug, "Tcp connection in preparing State")
            break
            //            Utils.printLog("Tcp connection preparing", logtype: .Debug)
        case .ready:
            Logger.shared.writeLog(.info, "The connection is established, and ready to send and receive data.")
            Logger.shared.writeLog(.info,"Connection Success with \(CommonDefine.hostAddress) \(CommonDefine.ipPort)")
            self.receiveData()
            self.delegate?.TcpConnectionState(state: "Connected")
            //            self.sendHeartbeat()
        case .failed(let error):
            self.delegate?.TcpConnectionState(state: "Disconnected")
            print("TCP failed: The connection has disconnected or encountered server:\(CommonDefine.hostAddress), port: \(CommonDefine.ipPort) with this error: \(error)")
            
            if error.localizedDescription.contains("Network is down") {
                self.delegate?.handleErrors(error: CommonDefine.strNoNetworkMsg)
            } else {
                self.delegate?.handleErrors(error: CommonDefine.strDefaultConnErrorMsg)
            }
        case .cancelled:
            self.delegate?.TcpConnectionState(state: "Cancelled")
            Logger.shared.writeLog(.debug, "The connection has been canceled.")
            delegate?.handleErrors(error: CommonDefine.strDefaultConnErrorMsg)
        default:
            Logger.shared.writeLog(.debug, "listenStateUpdate Default state.")
            break
        }
    }
    
    private func updateTcpMonitoring(to path: NWPath) {
        handlePathChanges?(path.status)
        switch path.status {
        case .satisfied:
            // Networking connection restored
            Logger.shared.writeLog(.debug,"Satisfied path for tcp")
            break
        case .unsatisfied:
            Logger.shared.writeLog(.debug, "Unsatisfied path for tcp")
        case .requiresConnection:
            Logger.shared.writeLog(.debug, "RequiresConnection path for tcp")
        default:
            Logger.shared.writeLog(.debug, "Unknow path for tcp")
            break
            // There's no connection available
        }
    }
    
    //
    private func CreateCertificateFromFile(filename: String, ext: String) -> SecCertificate? {
        var cert: SecCertificate!
        
        if let path = Bundle.main.path(forResource: filename, ofType: ext) {
            
            let data = NSData(contentsOfFile: path)!
            
            cert = SecCertificateCreateWithData(kCFAllocatorDefault, data)
        }
        else {
            print("Invalid path for authenticate server")
        }
        
        return cert
    }
    
    // MARK: - Socket I/O
    func connect() {
        // Start the connection
        self.connection.start(queue: queue)
        Stream.getStreamsToHost(withName: CommonDefine.hostAddress, port: CommonDefine.ipPort, inputStream: &self.inputStream, outputStream: &self.outputStream)
        
        inputDelegate = self
        outputDelegate = self
        if let input = inputStream, let outPut = outputStream {
            input.delegate = inputDelegate
            outPut.delegate = outputDelegate
            
            input.schedule(in: .current, forMode: RunLoop.Mode.common)
            outPut.schedule(in: .current, forMode: RunLoop.Mode.common)
            
            let sslSettings = [
                NSString(format: kCFStreamPropertySocketSecurityLevel): kCFStreamSocketSecurityLevelNegotiatedSSL,
                NSString(format: kCFStreamSSLValidatesCertificateChain): kCFBooleanFalse as Any,
                //                    NSString(format: kCFStreamSSLPeerName): CommonDefine.hostAddress,
                //                    NSString(format: kCFStreamSSLCertificates): certs,
                NSString(format: kCFStreamSSLIsServer): kCFBooleanFalse as Any
            ] as [NSString : Any]
            
            if isSSLON {
                // Enable SSL/TLS on the streams
                input.setProperty(kCFStreamSocketSecurityLevelNegotiatedSSL, forKey: Stream.PropertyKey.socketSecurityLevelKey)
                outPut.setProperty(kCFStreamSocketSecurityLevelNegotiatedSSL, forKey: Stream.PropertyKey.socketSecurityLevelKey)
                
                input.setProperty(sslSettings, forKey:  kCFStreamPropertySSLSettings as Stream.PropertyKey)
                outPut.setProperty(sslSettings, forKey: kCFStreamPropertySSLSettings as Stream.PropertyKey)
            }
            Logger.shared.writeLog(.info, "isSSLON: \(isSSLON)")
            input.open()
            outPut.open()
        } else {
            print("input and output stream is not found.")
        }
    }
    
    private func receiveData() {
        self.connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { [weak self] (data, context, isComplete, error) in
            guard let weakSelf = self else { return }
            if weakSelf.connection.state == .ready && isComplete == false, var data = data, !data.isEmpty {
                Logger.shared.writeLog(.debug, "TCP ReceivedData Called: \(String(data: data, encoding: .utf8))")
            }
        }
    }
    
    func sendHashMessagesData(input: String) {
        var finalArray = [UInt8]()
        // MARK: - convert string to bytes array [UInt8]
        serialQueue.async {
            if let outPut = self.outputStream {
                let returnWrite = outPut.write(finalArray, maxLength: finalArray.count)
                Logger.shared.writeLog(.debug, " sendHashMessagesData returnWrite = '\(returnWrite.description)'")
            } else {
                Logger.shared.writeLog(.error, " sendHashMessagesData returnWrite error")
            }
        }
    }
    
    
    private func connectionDidEnd() {
        Logger.shared.writeLog(.debug, "connection  did end")
    }
    
    private func connectionDidFail(error: Error) {
        Logger.shared.writeLog(.error, "connection did fail, error: \(error)")
    }
}


