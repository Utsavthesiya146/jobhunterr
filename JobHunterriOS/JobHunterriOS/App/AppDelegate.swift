//
//  AppDelegate.swift
//  JobHunterriOS
//
//  Application lifecycle and push notification registration
//

import UIKit

public class AppDelegate: NSObject, UIApplicationDelegate {
    
    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // Register for push notifications
        NotificationService.shared.requestAuthorization(application: application)
        
        // Handle notification payload on cold launch
        if let notificationPayload = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            NotificationService.shared.handlePayload(userInfo: notificationPayload)
        }
        
        // Appearance configuration
        setupAppearance()
        
        return true
    }
    
    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        NotificationService.shared.handleDeviceToken(deviceToken)
    }
    
    public func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        NotificationService.shared.handleRegistrationError(error)
    }
    
    private func setupAppearance() {
        // Configure global window and navigation bar appearance matching brand theme
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.statusBarColor
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = Theme.primaryColor
    }
}
