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
}
