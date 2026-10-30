//
//  AppConfiguration.swift
//  JobHunterriOS
//
//  Created as the iOS equivalent for Job Hunterr Android MainActivity.
//

import Foundation
import UIKit

public struct AppConfiguration {
    /// Domain restricted for in-app navigation matching Android MainActivity.ALLOWED_DOMAIN
    public static let allowedDomain = "jobhunterr.com"
    
    /// Entry point for Jobhunterr mobile platform
    public static let initialURL = URL(string: "https://\(allowedDomain)")!
    
    /// Application display metadata
    public static let appName = "Jobhunterr"
    public static let appVersion = "1.1"
    public static let buildNumber = "8"
    public static let bundleId = "com.jobhunterr.jobhunterr20"
    
    /// Custom User-Agent suffix to identify the native iOS client if needed by the backend
    public static let customUserAgentSuffix = "JobHunterr-iOS/1.1 (AppleWebKit/WKWebView; iOS)"
    
    /// Supported native external schemes
    public static let externalSchemes: Set<String> = [
        "tel",
        "mailto",
        "sms",
        "whatsapp",
        "facetime",
        "maps"
    ]
    
    /// Checks whether the URL belongs to the allowed Job Hunterr domain or safe web engine schemes
    public static func isInternal(url: URL) -> Bool {
        // Safe internal browser schemes used by web engines
        if let scheme = url.scheme?.lowercased() {
            if scheme == "about" || scheme == "data" || scheme == "blob" {
                return true
            }
        }
        
        guard let host = url.host?.lowercased() else { return false }
        return host == allowedDomain || host.hasSuffix("." + allowedDomain)
    }
    
    /// Checks whether the URL is a native device action
    public static func isExternalScheme(url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased() else { return false }
        return externalSchemes.contains(scheme)
    }
}
