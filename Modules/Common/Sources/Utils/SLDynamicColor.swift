//
//  SLDynamicColor.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2/14/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit



@propertyWrapper
public struct SLDynamicColor {
    let light: UIColor
    let dark: UIColor

    public var wrappedValue: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.init { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return dark
                case .light:
                    return light
                default:
                    return light
                }
            }
        } else {
            return light
        }
    }
}
