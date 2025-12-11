//
//  UIColor+extension.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/25/23.
//

import UIKit

public extension UIColor {
    
    convenience init(sl_red: Int, green: Int, blue: Int, a: Int = 0xFF) {
        self.init(
            red: CGFloat(sl_red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
    
    convenience init(sl_rgb: Int) {
        self.init(
            sl_red: (sl_rgb >> 16) & 0xFF,
            green: (sl_rgb >> 8) & 0xFF,
            blue: sl_rgb & 0xFF
        )
    }
    
    convenience init(sl_argb: Int) {
        self.init(
            sl_red: (sl_argb >> 16) & 0xFF,
            green: (sl_argb >> 8) & 0xFF,
            blue: sl_argb & 0xFF,
            a: (sl_argb >> 24) & 0xFF
        )
    }
    
    convenience init(sl_hex: String, alpha: CGFloat = 1.0) {
        var cString = sl_hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") { cString.removeFirst() }
        
        if cString.count != 6 {
            self.init(sl_hex: "ff0000") // return red color for wrong hex input
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    /// UIColor를 헥스 문자열로 변환 - Returns: #RRGGBB 또는 #RRGGBBAA 형식의 문자열
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        if a < 1.0 {
            return String(format: "#%06x%02x", rgb, Int(a*255))
        } else {
            return String(format: "#%06x", rgb)
        }
    }
    
    /// 헥스 문자열로부터 UIColor를 생성  - Parameter hexString: #RRGGBB 또는 #RRGGBBAA 형식의 헥스 문자열
    convenience init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        guard Scanner(string: hex).scanHexInt64(&int) else {
            return nil
        }
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // RGBA (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
