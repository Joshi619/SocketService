//
//  AppMonitor.swift
//  pocService
//
//  Created by Aditya on 08/01/25.
//


import Cocoa

class AppMonitor: NSObject {
    
    static let shared = AppMonitor()
    
    func loadObserver() {
        // Set up the observer for application launch notifications
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(applicationDidLaunch(_:)),
            name: NSWorkspace.didLaunchApplicationNotification,
            object: nil
        )
    }
    
    @objc private func applicationDidLaunch(_ notification: Notification) {
        // Extract application info from the notification
        if let userInfo = notification.userInfo,
           let appInfo = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
           let appName = appInfo.localizedName,
           let bundleIdentifier = appInfo.bundleIdentifier {
            // Prepare the log entry
            let logEntry = "Application Launched: \(appName) (\(bundleIdentifier))\n"
            Logger.shared.writeLog(.info, logEntry)
        }
    }
}
