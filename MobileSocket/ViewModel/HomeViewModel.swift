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
    @Published var successMessage = ""
    @Published var showErrorAlert = false
    @Published var showSuccessAlert = false
    var alertType: SocketAlertType = .banner
    
    enum SocketAlertType {
        case banner
        case alert
        case side
        case hudProgress
    }
    
    enum SocketResult {
        case success
        case failure
    }
    
    func startConnection() {
        CommonDefine.shared.hostAddress = host
        CommonDefine.shared.ipPort = Int(port) ?? 8080
        queue.maxConcurrentOperationCount = 1
        tcpNetwork = TCPNetworkService()
        tcpNetwork?.delegate = self
        tcpNetwork?.connect()

    }
    
    func stopConnection() {
        tcpNetwork?.close()
        tcpNetwork = nil
    }
    
    func intialSetup() {
        guard let networkRechablity = Reachability(hostname: "www.google.com") else {
            return
        }
        do {
            try networkRechablity.startNotifier()
        } catch {
            Logger.shared.writeLog(.error, "NetworkRechability: \(error.localizedDescription)")
        }
        
        networkRechablity.whenReachable = { reachability in
            Logger.shared.writeLog(.info, "NetworkRechability whenReachable")
            if CommonDefine.shared.appState != .connected && UserDefaults.standard.bool(forKey: UserDefaultKeys.isConfigured) == true {
                self.startConnection()
            }
        }
        
        networkRechablity.whenUnreachable = { reachability in
            Logger.shared.writeLog(.warning, "NetworkRechability whenUnreachable")
            CommonDefine.shared.appState = .disconnected
            self.tcpNetwork?.closeStreams()
            self.errorMessage = CommonDefine.shared.strNoNetworkMsg
            self.showErrorAlert.toggle()
        }
    }
    
    func validationForConnection() {
        if host.isEmpty {
            showErrorAlert = true
            errorMessage = CommonDefine.shared.hostEmptyMsg
        } else if port.isEmpty {
            showErrorAlert = true
            errorMessage = CommonDefine.shared.ipEmptyMsg
        } else {
            connectionStatus = .conencting
            startConnection()
        }
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
                CommonDefine.shared.appState = .connected
                self.appNotification(message: CommonDefine.shared.configureSuccess, alertType: .alert, result: .success)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                    AppDelegate.shared.hideDockIcon()
//                })
            case "Disconnected":
                self.connectionStatus = .disconnected
                CommonDefine.shared.appState = .disconnected
                self.appNotification(message: CommonDefine.shared.strDefaultConnErrorMsg, alertType: .alert, result: .failure)
            case "Waiting":
                self.connectionStatus = .conencting
                CommonDefine.shared.appState = .conencting
                self.appNotification(message: CommonDefine.shared.strDefaultConnErrorMsg, alertType: .alert, result: .failure)
            default:
                self.connectionStatus = .conencting
                CommonDefine.shared.appState = .conencting
            }
            Logger.shared.writeLog(.debug, "connectionState: \(state)")
            AppDelegate.shared.updateStatus()
        }
    }
    
    func showAlertOnScreen(reconnectionType: ConnectionType) {
        
    }
    
    func receivedData(response: String) {

    }
    
    func handleErrors(error: String) {
        Logger.shared.writeLog(.error, "Handler Error: \(error)")
        DispatchQueue.main.async {
            self.showErrorAlert = true
            self.errorMessage = error
            self.appNotification(message: error,alertType: .alert, result: .failure)
        }
    }
    
    func appNotification(message: String, alertType: SocketAlertType, result: SocketResult) {
        if NSApplication.shared.isHidden {
            if result == .failure {
                LocalNotificationCenter.shared.sendLocalNotification(subtitle: "Error", body: message, completion: {_ in })
            } else {
                LocalNotificationCenter.shared.sendLocalNotification(subtitle: "Success", body: message, completion: {_ in })
            }
        } else {
            DispatchQueue.main.async {
                self.alertType = alertType
                if result == .failure {
                    self.errorMessage = message
                    self.showErrorAlert = true
                } else {
                    self.successMessage = message
                    self.showSuccessAlert = true
                }
            }
        }
    }
}
