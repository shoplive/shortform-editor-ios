//
//  CGRect+extension.swift
//  ShopLiveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation
import UIKit

public extension CGRect {
    var center_SL: CGPoint {
        CGPoint(x: self.midX, y: self.midY)
    }
}

