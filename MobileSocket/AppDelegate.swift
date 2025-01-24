//
//  AppDelegate.swift
//  MobileSocket
//
//  Created by Aditya on 21/01/25.
//


import Cocoa
import SwiftUI

//@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var viewModel = HomeViewModel()
    var statusItem: NSStatusItem?
    var connectionItem: NSMenuItem?
    static let shared = AppDelegate()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        ["File","Edit", "View", "Help", "Window"].forEach { name in
            NSApp.mainMenu?.item(withTitle: name).map { NSApp.mainMenu?.removeItem($0) }
        }
        CommonDefine.shared.isCurrentUserAdmin = Utility.shared.isCurrentUserAdmin()
        // notification permission
        LocalNotificationCenter.shared.requestNotificationPermission()
        
        let arguments = CommandLine.arguments

        // Check if the app is launched in CLI mode
        if arguments.contains("--cli") {
            runCLI(arguments: arguments)
            NSApplication.shared.terminate(self) // Exit after handling CLI command
        } else {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
            if let button = statusItem?.button {
                button.image = NSImage(systemSymbolName: "star.fill", accessibilityDescription: "Status Bar Icon")
                button.action = #selector(statusBarButtonClicked)
            }
            print("Launching GUI...")
            
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
            // Return false to keep the application alive
            return false
        }

    func runCLI(arguments: [String]) {
        // Handle CLI arguments
        if arguments.contains("--help") {
            print("""
            Usage: MobileSocket [options]
            Options:
              --cli         Run in CLI mode
              --help        Show this help message
              --version     Display the application version
            """)
        } else if arguments.contains("--version") {
            print("MyApp version 1.0.0")
        } else if arguments.contains("--stop server") {
            
        } else if arguments.contains("--start server") {
            
        } else if arguments.contains("--restart server") {
            
        } else {
            print("Unknown command. Use --help for available options.")
        }
    }
    
    // MARK: - Intial setup and configuration
    private func setupInitialSetup() {
        if UserDefaults.standard.bool(forKey: UserDefaultKeys.isConfigured) == false {
            showDockIcon()
        } else {
            hideDockIcon()
        }
    }
}

extension AppDelegate {
    // MARK: - StatusBar Button Action
    @objc func statusBarButtonClicked() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Stop", action: #selector(stopServiceAction), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Restart", action: #selector(restartServiceAction), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Reconfiguration", action: #selector(showApp), keyEquivalent: ""))
        connectionItem = NSMenuItem(title: "Status: \(CommonDefine.shared.appState.title)", action: nil, keyEquivalent: "")
        if let item = connectionItem {
            menu.addItem(item)
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem?.menu = menu
    }
    
    // MARK: - Stop Service Action
    @objc func stopServiceAction() {
        if CommonDefine.shared.isCurrentUserAdmin {
            
        } else {
            Utility.shared.requestAdminAccess { status in
                if status {
                    
                }
            }
        }
    }
    
    // MARK: - Restart Service Action
    @objc func restartServiceAction() {
        if CommonDefine.shared.isCurrentUserAdmin {
            
        } else {
            Utility.shared.requestAdminAccess { status in
                if status {
                    
                }
            }
        }
    }
    
    @objc func showApp() {
        // Show the main window when the user selects "Show App"
        if CommonDefine.shared.isCurrentUserAdmin {
            self.showDockIcon()
            NSApp.activate(ignoringOtherApps: true)
        } else {
            Utility.shared.requestAdminAccess { status in
                if status {
                    self.showDockIcon()
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
    }
    
    // MARK: - Quite application
    @objc func quit() {
        if CommonDefine.shared.isCurrentUserAdmin {
            NSApplication.shared.terminate(self)
        } else {
            Utility.shared.requestAdminAccess { status in
                if status {
                    NSApplication.shared.terminate(self)
                }
            }
        }
    }
    
    // MARK: - Hide Dock Icon
    func hideDockIcon() {
        // Hide the app from Dock and app switcher
        NSApp.setActivationPolicy(.prohibited)
    }
    
    // MARK: - Status updated of connectivity
    func updateStatus() {
        connectionItem?.title = CommonDefine.shared.appState.title
    }
    
    // MARK: - Show Dock Icon
    func showDockIcon() {
        // Show the app in Dock and app switcher
        NSApp.setActivationPolicy(.regular)
    }
}
