//
//  UIColor+extension.swift
//  ShopLiveShortformUploadSDK
//
//  Created by 김우현 on 5/24/23.
//

import UIKit

extension UIColor {
    static var baseColor: UIColor {
        get {
//            if #available(iOS 13.0, *) {
//                return .systemBackground
//            } else {
                return .white
//            }
        }
    }
    
    static var baseLabelColor: UIColor {
        get {
//            if #available(iOS 13.0, *) {
//                return .label
//            } else {
                return .black
//            }
        }
    }
}
