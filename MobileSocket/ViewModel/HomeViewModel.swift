//
//  HomeViewModel.swift
//  MobileSocket
//
//  Created by Aditya on 20/01/25.
//

import Foundation
import Cocoa
import Network

class HomeViewModel: ObservableObject {
    
    @Published var host = "localhost"
    @Published var port = "8080"
    var timer: Timer?
    @Published var connectionStatus: ConnectionType? = .notConnected
    let queue = OperationQueue()
    var tcpNetwork: TCPNetworkService?
    @Published var errorMessage = ""
    @Published var showErrorAlert = false
    
    func startConnection() {
        CommonDefine.hostAddress = host
        CommonDefine.ipPort = Int(port) ?? 8080
        queue.maxConcurrentOperationCount = 1
        tcpNetwork = TCPNetworkService()
        tcpNetwork?.delegate = self
        tcpNetwork?.connect()

    }
    
//    func keepAlive() {
//        timer = Timer.init(fire: .now, interval: 60, repeats: true, block: { timer in
//            self.socket.sendHashMessagesData(input: "Hello server at \(Date().formatted())")
//        })
//        queue.async {
//            RunLoop.current.add(self.timer!, forMode: .default)
//            RunLoop.current.run()
//        }
//    }
    
    func configFileRead() -> [String: Any]? {
        let url = Bundle.main.path(forResource: "SocketConfig", ofType: "txt")
         do
         {
             guard let data = NSData(contentsOfFile: url ?? "") else {
                 print("connectTORDPS -> Fileread path not found")
                 return nil
             }
             let json = try JSONSerialization.jsonObject(with: data as Data, options: []) as? [String: Any]
             print("File read ARCONTCPDetails -> success ")
             return json
         }
         catch
         {
             print("File read ARCONTCPDetails -> Error: \(error.localizedDescription)")
         }
            return nil
    }
}

// MARK: - TCPConnectionDelegate
extension HomeViewModel: TCPConnectionDelegate {
    func TcpConnectionState(state: String) {
        DispatchQueue.main.async {
            self.connectionStatus = ConnectionType(rawValue: state)
            switch state {
            case "Connected":
                self.connectionStatus = .connected
                CommonDefine.appState = .connected
//                self.register()
//                self.makeTimerForGRAStatusEPM()
            case "Disconnected":
                self.connectionStatus = .notConnected
                CommonDefine.appState = .notConnected
//                self.retriveConfiguration()
//                if self.isAlreadyConfigured() == true && self.allPermissionGranted == true {
//                    if self.sessionId != "" {
//                        self.registerClientAuth(registerId: self.sessionId)
//                    }
//                }
            case "Waiting":
                self.connectionStatus = .conencting
                CommonDefine.appState = .conencting
            default:
                self.connectionStatus = .conencting
                CommonDefine.appState = .conencting
            }
            Logger.shared.writeLog(.debug, "connectionState: \(state)")
        }
    }
    
    func showAlertOnScreen(reconnectionType: ConnectionType) {
        
    }
    
    func receivedData(response: String) {

    }
    
    func handleErrors(error: String) {
        Logger.shared.writeLog(.error, "Handler Error: \(error)")
        showErrorAlert.toggle()
        errorMessage = error
    }
}
