//
//  SessionCookieManager.swift
//  JobHunterriOS
//
//  Manages persistent cookie storage and session synchronization across app restarts
//

import Foundation
import WebKit

public final class SessionCookieManager {
    public static let shared = SessionCookieManager()
    
    private let cookieStorageKey = "com.jobhunterr.saved_cookies"
    
    private init() {}
    
    /// Persists cookies from WKHTTPCookieStore to UserDefaults
    public func saveCookies(from webView: WKWebView, completion: (() -> Void)? = nil) {
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        cookieStore.getAllCookies { [weak self] cookies in
            guard let self = self else { return }
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false)
                UserDefaults.standard.set(data, forKey: self.cookieStorageKey)
            } catch {
                #if DEBUG
                print("[SessionCookieManager] Error archiving cookies: \(error)")
                #endif
            }
            completion?()
        }
    }
    
    /// Restores previously saved cookies into the WKHTTPCookieStore
    public func restoreCookies(to webView: WKWebView, completion: (() -> Void)? = nil) {
        guard let data = UserDefaults.standard.data(forKey: cookieStorageKey) else {
            completion?()
            return
        }
        
        do {
            let cookies: [HTTPCookie]?
            if #available(iOS 14.0, *) {
                cookies = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, HTTPCookie.self], from: data) as? [HTTPCookie]
            } else {
                cookies = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [HTTPCookie]
            }
            
            guard let unarchivedCookies = cookies else {
                completion?()
                return
            }
            
            let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
            let group = DispatchGroup()
            
            for cookie in unarchivedCookies {
                group.enter()
                cookieStore.setCookie(cookie) {
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion?()
            }
        } catch {
            #if DEBUG
            print("[SessionCookieManager] Error unarchiving cookies: \(error)")
            #endif
            completion?()
        }
    }
    
    /// Clears saved cookies and website data upon user logout
    public func clearAllCookies(for webView: WKWebView, completion: (() -> Void)? = nil) {
        UserDefaults.standard.removeObject(forKey: cookieStorageKey)
        let dataStore = webView.configuration.websiteDataStore
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let dateFrom = Date(timeIntervalSince1970: 0)
        
        dataStore.removeData(ofTypes: dataTypes, modifiedSince: dateFrom) {
            completion?()
        }
    }
}
