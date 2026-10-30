//
//  JobHunterrApp.swift
//  JobHunterriOS
//
//  SwiftUI Main Entry Point
//

import SwiftUI

@main
struct JobHunterrApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .preferredColorScheme(.dark)
        }
    }
}
