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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
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
            mainWindow = NSWindow(
                        contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                        styleMask: [.titled, .closable, .resizable, .miniaturizable],
                        backing: .buffered,
                        defer: false
                    )
            mainWindow?.title = "MobileSocket"
            mainWindow?.contentView = NSHostingView(rootView: HomeView()) // Assign SwiftUI view
            mainWindow?.makeKeyAndOrderFront(nil)
            
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
}

extension AppDelegate {
    @objc func statusBarButtonClicked() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Check for update", action: #selector(option1Selected), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Show App", action: #selector(showApp), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: "Status: \(CommonDefine.appState.title)", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem?.menu = menu
    }
    
    @objc func option1Selected() {
        print("Option 1 selected")
    }
    
    @objc func showApp() {
        // Show the main window when the user selects "Show App"
        mainWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}
