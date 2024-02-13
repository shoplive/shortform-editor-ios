//
//  CALayer+extension.swift
//  ShopLiveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation
import UIKit

public extension CALayer {
    func fitToSuperView_SL(superview: UIView) {
        self.frame = superview.frame
    }
}
