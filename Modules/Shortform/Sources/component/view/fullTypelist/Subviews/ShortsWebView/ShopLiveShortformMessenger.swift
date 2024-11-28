//
//  ShopLiveShortformMessageDelegate.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 11/27/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit


@objc public protocol ShopLiveShortformMessenger {
    var view : UIView { get }
    func evaluateJavaScript(command : String, payload : [String : Any])
}
