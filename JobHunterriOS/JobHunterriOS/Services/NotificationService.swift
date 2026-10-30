//
//  NotificationService.swift
//  JobHunterriOS
//
//  Push and local notification integration for job alerts and application status
//

import UIKit
import UserNotifications

public final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationService()
    
    public var onNotificationReceivedURL: ((URL) -> Void)?
    
    private override init() {
        super.init()
    }
    
    /// Requests push notification authorization from the user
    public func requestAuthorization(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    /// Called when device token is received from APNs
    public func handleDeviceToken(_ deviceToken: Data) {
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        #if DEBUG
        print("[JobHunterr] APNs Device Token: \(token)")
        #endif
        // Token can be sent to backend /api/register_device if supported
    }
    
    /// Called when registration for remote notifications fails
    public func handleRegistrationError(_ error: Error) {
        #if DEBUG
        print("[JobHunterr] Failed to register for remote notifications: \(error.localizedDescription)")
        #endif
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Display notification banner even when the app is in the foreground
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .badge, .sound])
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }
    
    /// Handle user tapping on a notification
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        handlePayload(userInfo: userInfo)
        completionHandler()
    }
    
    /// Parses payload and routes to URL if present
    public func handlePayload(userInfo: [AnyHashable: Any]) {
        if let targetURLString = userInfo["url"] as? String,
           let targetURL = URL(string: targetURLString) {
            DispatchQueue.main.async {
                self.onNotificationReceivedURL?(targetURL)
            }
        }
    }
}
