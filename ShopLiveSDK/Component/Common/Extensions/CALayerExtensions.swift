//
//  CALayerExtensions.swift
//  ShopLivePlayer
//
//  Created by ShopLive on 2021/07/31.
//

import UIKit

extension CALayer {
    func fitToSuperView(superview: UIView) {
        self.frame = superview.frame
    }
}
