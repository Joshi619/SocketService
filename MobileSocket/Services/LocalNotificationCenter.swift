//
//  LocalNotificationCenter.swift
//  pocService
//
//  Created by Aditya on 09/01/25.
//


import Foundation
import AppKit
import UserNotifications

final class LocalNotificationCenter: NSObject {
    static let shared = LocalNotificationCenter()
    
    /// Request permission to show notifications
    func requestNotificationPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error)")
            } else if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    func sendLocalNotification(title: String = CommonDefine.shared.appName, subtitle: String, body: String, completion: @escaping (Bool) -> Void) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        // 1. Define the content of the notification
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = UNNotificationSound.default

        // 2. Create a trigger (immediate in this case)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) // Notification after 5 seconds

        // 3. Create a notification request
        let request = UNNotificationRequest(identifier: "macOS.local.notification", content: content, trigger: trigger)

        // 4. Add the request to the notification center
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error adding notification: \(error)")
            } else {
                completion(true)
            }
        }
    }
}
