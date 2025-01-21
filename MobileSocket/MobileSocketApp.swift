//
//  MobileSocketApp.swift
//  MobileSocket
//
//  Created by Aditya on 20/01/25.
//

import SwiftUI

@main
struct MobileSocketApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            HomeView()
                .frame(width: 400, height: 300)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
        .defaultSize(width: 800, height: 600)
    }
}


