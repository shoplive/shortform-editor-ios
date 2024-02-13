//
//  CGSize + extension.swift
//  ShopLiveSDKCommon
//
//  Created by sangmin han on 2023/07/05.
//

import Foundation
import UIKit

public extension CGSize {
    var transpolate_SL : CGSize {
        return CGSize(width: self.height, height: self.width)
    }
}

