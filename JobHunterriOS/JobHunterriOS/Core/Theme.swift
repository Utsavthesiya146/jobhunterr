//
//  Theme.swift
//  JobHunterriOS
//
//  Job Hunterr Brand Color System matching Android themes.xml & colors.xml
//

import SwiftUI
import UIKit

public struct Theme {
    // MARK: - Brand Hex Values (From Android res/values/themes.xml)
    public static let primaryHex = "#ed2d7b"        // colorPrimary
    public static let primaryVariantHex = "#c51f65" // colorPrimaryVariant
    public static let statusBarHex = "#3A262E"      // android:statusBarColor
    public static let onPrimaryHex = "#FFFFFF"      // colorOnPrimary
    public static let backgroundDarkHex = "#1D1317" // Deep surface
    
    // MARK: - UIKit UIColors
    public static let primaryColor = UIColor(hex: primaryHex)
    public static let primaryVariantColor = UIColor(hex: primaryVariantHex)
    public static let statusBarColor = UIColor(hex: statusBarHex)
    public static let onPrimaryColor = UIColor(hex: onPrimaryHex)
    
    // MARK: - SwiftUI Colors
    public static let primary = Color(uiColor: primaryColor)
    public static let primaryVariant = Color(uiColor: primaryVariantColor)
    public static let statusBar = Color(uiColor: statusBarColor)
    public static let onPrimary = Color(uiColor: onPrimaryColor)
}

// MARK: - Hex Color Helper
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleanHex.hasPrefix("#") {
            cleanHex.remove(at: cleanHex.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&rgbValue)
        
        if cleanHex.count == 6 {
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: alpha
            )
        } else if cleanHex.count == 8 {
            self.init(
                red: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x000000FF) / 255.0,
                alpha: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            )
        } else {
            self.init(red: 0, green: 0, blue: 0, alpha: alpha)
        }
    }
}
