//
//  ShopLiveDefines_ext.swift
//  ShopLiveSDK
//
//  Created by yong C on 8/6/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopliveSDKCommon

extension ShopLiveDefines {
    static var url: String {
        "https://www.shoplive.show/v1/sdk.html"
    }

    static let shopliveData = "shoplivedata"

    static let webInterface: String = "ShopLiveAppInterface"
    static let osVersion = UIDevice.current.systemVersion
    
    static let defVideoRatio: CGSize = .init(width: 9, height: 16)
    
    static var deviceIdentifier: String {
        return UIDevice.deviceIdentifier_sl
    }
    
    
    enum ShopLiveOrientaion {
        case portrait
        case landscape
    }
}
