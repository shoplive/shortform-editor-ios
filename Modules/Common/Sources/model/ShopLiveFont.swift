//
//  ShopLiveFont.swift
//  ShopliveSDKCommon
//
//  Created by Tabber on 2/13/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

public struct ShopLiveFont {
    var customFont: UIFont? = nil
    var size: CGFloat
    var weight: UIFont.Weight = .regular
    
    public init(customFont: UIFont? = nil,
                size: CGFloat,
                weight: UIFont.Weight = .regular) {
        self.customFont = customFont
        self.size = size
        self.weight = weight
    }
}
