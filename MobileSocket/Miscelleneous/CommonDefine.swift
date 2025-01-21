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

/// this class will have the const and non const value required throughout the project
class CommonDefine {
    /// Host address
    public static var hostAddress = ""
    
    /// port number
    public static var ipPort = 0//8585
    
    /// App name string
    public static let appName = "Mobile Socket"
    
    /// TCP connection state
    public static var appState = ConnectionType.conencting
    
    
    /// Contain per session logs.
    public static var sessionLogList = [String]()

    // Display Size
    #if os(macOS)
    public static let screenWidth = Int(NSScreen.main?.frame.width ?? 0.0)
    public static let screenHeight = Int(NSScreen.main?.frame.height ?? 0.0)
    #else
    public static let screenWidth = Int(UIScreen.main.bounds.width)
    public static let screenHeight = Int(UIScreen.main.bounds.height)
    #endif
        
    // MARK: - DialogMessages
    public static let strSessionExitWarn = "You have requested for remote support. If you exit the application, remote support will not be possible. Are you sure you want to exit?";
    public static let strReconnectPromptMsg = "You have been disconnected from the server. Would you like to reconnect?"
    public static let strReqSupportFailedMsg = "Error while trying to create support request."
    public static let strRegFailedMsg = "Error while registering with server."
    public static let strDisConnMsg = "Disconnected from server."
    public static let strConnectionTimedOut = "Lost connection to server. Keep alive packets not received in time"
    public static let strNoNetworkMsg = "Unable to connect to server. Please check your internet connection or try again later."
    public static let strSessionExpiredMsg = "Your previous session has expired. Please register a new request."
    public static let strDefaultConnErrorMsg = "Unable to connect to server."
    public static let strAPIConnErrorMsg = "Unable to connect to the API server."
    public static let strAuthErrorMsg = "Client authentication failure."
    public static let strNoConfigErrorMsg = "No config found."
    public static let strConfigRespErrorMsg = "Unable to get config from server.Server responded with status "
    public static let strAuthRespErrorMsg = "Unable to get token from server.Server responded with status "
    public static let strLocalConfErrorMsg = "Error in getting local configuration."
    public static let strLocalConfUpdateErrorMsg = "Error in updating local configuration."
    public static let streamErrorMessage = "Unknown Error. Kindly, contact ARCON GRA Administrator."
    // MARK: - API Handler Message
    public static let invalidTokenMessage = "Invalid token in request"
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
