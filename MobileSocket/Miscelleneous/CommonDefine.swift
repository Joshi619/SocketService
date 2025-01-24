//
//  Constants.swift
//  MobileSocket
//
//  Created by Aditya on 20/01/25.
//

import Foundation
#if os(macOS)
    import AppKit
#else
    import UIKit
#endif
import Combine

/// this class will have the const and non const value required throughout the project
class CommonDefine {
    
    static let shared = CommonDefine()
    /// Host address
    var hostAddress = ""
    var isCurrentUserAdmin = false
    /// port number
    var ipPort = 0//8585
    
    /// App name string
    let appName = "Mobile Socket"
    
    /// TCP connection state
    @Published var appState = ConnectionType.conencting
    

    // Display Size
    #if os(macOS)
    let screenWidth = Int(NSScreen.main?.frame.width ?? 0.0)
    let screenHeight = Int(NSScreen.main?.frame.height ?? 0.0)
    #else
    let screenWidth = Int(UIScreen.main.bounds.width)
    let screenHeight = Int(UIScreen.main.bounds.height)
    #endif
        
    // MARK: - DialogMessages
    let strReconnectPromptMsg = "You have been disconnected from the server. Would you like to reconnect?"
    let strReqSupportFailedMsg = "Error while trying to create support request."
    let strRegFailedMsg = "Error while registering with server."
    let strDisConnMsg = "Disconnected from server."
    let strConnectionTimedOut = "Lost connection to server. Keep alive packets not received in time"
    let strNoNetworkMsg = "Unable to connect to server. Please check your internet connection or try again later."
    let strDefaultConnErrorMsg = "Unable to connect to server."
    let strAPIConnErrorMsg = "Unable to connect to the API server."
    let strAuthErrorMsg = "Client authentication failure."
    let strNoConfigErrorMsg = "No config found."
    let strConfigRespErrorMsg = "Unable to get config from server.Server responded with status "
    let strLocalConfErrorMsg = "Error in getting local configuration."
    let strLocalConfUpdateErrorMsg = "Error in updating local configuration."
    let streamErrorMessage = "Unknown Error. Kindly, contact MobileSocket Administrator."
    let hostEmptyMsg = "Host name cannot be empty."
    let ipEmptyMsg = "IP address cannot be empty."
    let configureSuccess = "server configured successfully"

    // MARK: - API Handler Message
    let invalidTokenMessage = "Invalid token in request"
}

struct UserDefaultKeys {
    static let userKey = "UserKey"
    static let isConfigured = "IsConfigured"
}

enum ConnectionType: String {
    case conencting
    case connected
    case disconnected
    case notConnected
    
    var title: String {
        switch self {
        case .conencting: return "Connecting..."
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .notConnected: return "Not Connected"
        }
    }
}
