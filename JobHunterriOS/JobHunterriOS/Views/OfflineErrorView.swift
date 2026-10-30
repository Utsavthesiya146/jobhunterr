//
//  OfflineErrorView.swift
//  JobHunterriOS
//
//  Native offline state screen displayed when network connectivity is lost
//

import SwiftUI

public struct OfflineErrorView: View {
    public var onRetry: () -> Void
    
    public init(onRetry: @escaping () -> Void) {
        self.onRetry = onRetry
    }
    
    public var body: some View {
        ZStack {
            Theme.statusBar
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Network Disconnected Icon
                ZStack {
                    Circle()
                        .fill(Theme.primary.opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundColor(Theme.primary)
                }
                
                // Text details
                VStack(spacing: 10) {
                    Text("Connection Lost")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Unable to reach Jobhunterr servers. Please check your internet connection and try again.")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Retry Button
                Button(action: onRetry) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .bold))
                        Text("Retry Connection")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Theme.primary, Theme.primaryVariant],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(28)
                    .shadow(color: Theme.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.top, 10)
                
                Spacer()
                
                // Footer
                Text("Jobhunterr • Smart Career Platform")
                    .font(.footnote)
                    .foregroundColor(Color.white.opacity(0.5))
                    .padding(.bottom, 20)
            }
            .padding()
        }
    }
}
