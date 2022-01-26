//
//  UIScreenExtensions.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/08/20.
//

import UIKit

extension UIScreen {
    static var isLandscape: Bool {
        let size = UIScreen.main.bounds.size
        return size.width > size.height
    }
}
