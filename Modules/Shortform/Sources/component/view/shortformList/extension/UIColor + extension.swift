//
//  UIColor + extension.swift
//  matrix-shortform-ios
//
//  Created by sangmin han on 2023/05/02.
//

import Foundation
import UIKit
import ShopliveSDKCommon

extension UIColor {
    
    static var black_700_main : UIColor {
        get {
            return UIColor.init(sl_hex:"#333333")
        }
    }
    
    static var dim_black_60 : UIColor {
        get {
            return UIColor.init(sl_hex:"#000000",alpha: 0.6)
        }
    }
    
    
    static var black_500 : UIColor {
        get {
            return UIColor.init(sl_hex:"#8F8F8F")
        }
    }
    
    static var brand_red : UIColor {
        get {
            return UIColor.init(sl_hex: "#EF3434")
        }
    }
    
    static var black_600 : UIColor {
        get {
            return UIColor.init(sl_hex:"#545454")
        }
    }
}
