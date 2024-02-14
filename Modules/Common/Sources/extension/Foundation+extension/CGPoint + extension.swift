//
//  CGPoint + extension.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2023/07/05.
//

import Foundation
import UIKit


public extension CGPoint {
    var transpolate_SL: CGPoint {
        return CGPoint(x: self.y, y: self.x)
    }
}
