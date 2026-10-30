//
//  MainContentView.swift
//  JobHunterriOS
//
//  Main container view managing edge-to-edge layout, loading states, and offline screens
//

import SwiftUI

public struct MainContentView: View {
    @ObservedObject private var networkMonitor = NetworkMonitor.shared
    @State private var loadingProgress: Double = 0.0
    @State private var hasNetworkError: Bool = false
    @State private var webController: JobHunterrWebViewController?
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            // Background matching Android status bar theme #3A262E
            Theme.statusBar
                .ignoresSafeArea()
            
            // Content layer
            if !networkMonitor.isConnected || hasNetworkError {
                OfflineErrorView {
                    hasNetworkError = false
                    webController?.reloadCurrentPage()
                }
                .transition(.opacity)
            } else {
                JobHunterrWebView(
                    loadingProgress: $loadingProgress,
                    hasNetworkError: $hasNetworkError,
                    controllerRef: { controller in
                        self.webController = controller
                    }
                )
                .ignoresSafeArea(.container, edges: .bottom)
            }
            
            // Top loading progress bar
            if loadingProgress > 0.0 && loadingProgress < 1.0 && networkMonitor.isConnected {
                LoadingProgressBar(progress: loadingProgress)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: networkMonitor.isConnected)
        .animation(.easeInOut(duration: 0.25), value: hasNetworkError)
        .onAppear {
            NotificationService.shared.onNotificationReceivedURL = { targetURL in
                webController?.load(url: targetURL)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            if let webView = webController?.webView {
                SessionCookieManager.shared.saveCookies(from: webView)
            }
        }
    }
}
