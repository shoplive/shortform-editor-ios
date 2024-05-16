//
//  UIKit + Extension.swift
//  CustomImagePicker
//
//  Created by sangmin han on 5/3/24.
//

import Foundation
import UIKit

extension UIFont {
    
    enum FigmaWeight {
        case _400
        case _500
        case _600
        case _700
    }
    
    static func set(size : CGFloat,weight : FigmaWeight ) -> UIFont {
        var w : UIFont.Weight = .regular
        switch weight {
        case ._400:
            w = .regular
        case ._500:
            w = .semibold
        case ._600:
            w = .bold
        case ._700:
            w = .bold
        }
        
        return UIFont.systemFont(ofSize: size, weight: w)
    }
}

extension UIColor {
    
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat, aa: CGFloat = 1) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: aa
        )
    }
    
    convenience init(_ hex: String, alpha: CGFloat = 1.0) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") { cString.removeFirst() }
        
        if cString.count != 6 {
            self.init("ff0000") // return red color for wrong hex input
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
