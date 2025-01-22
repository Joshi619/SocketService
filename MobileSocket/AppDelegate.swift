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
    var mainWindow: NSWindow?
    var statusItem: NSStatusItem?
    var connectionItem: NSMenuItem?
    static let shared = AppDelegate()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        ["File","Edit", "View", "Help", "Window"].forEach { name in
            NSApp.mainMenu?.item(withTitle: name).map { NSApp.mainMenu?.removeItem($0) }
        }
        
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
    @objc func statusBarButtonClicked() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Stop", action: #selector(option1Selected), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Restart", action: #selector(option1Selected), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Reconfiguration", action: #selector(showApp), keyEquivalent: ""))
        connectionItem = NSMenuItem(title: "Status: \(CommonDefine.shared.appState.title)", action: nil, keyEquivalent: "")
        if let item = connectionItem {
            menu.addItem(item)
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem?.menu = menu
    }
    
    @objc func option1Selected() {
        print("Option 1 selected")
    }
    
    @objc func showApp() {
        // Show the main window when the user selects "Show App"
        Utility.shared.requestAdminAccess { status in
            if status {
                self.showDockIcon()
                NSApp.activate(ignoringOtherApps: true)
            }
        }
        
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
    
    func hideDockIcon() {
        // Hide the app from Dock and app switcher
        NSApp.setActivationPolicy(.prohibited)
    }
    
    func updateStatus() {
        connectionItem?.title = CommonDefine.shared.appState.title
    }
    
    func showDockIcon() {
        // Show the app in Dock and app switcher
        NSApp.setActivationPolicy(.regular)
    }
}
