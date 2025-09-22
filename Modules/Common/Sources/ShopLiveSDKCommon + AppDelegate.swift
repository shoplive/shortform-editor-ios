//
//  ShopliveSDKCommon + AppDelegate.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2023/06/01.
//

import Foundation
import UIKit


extension ShopLiveCommon {
    public static func setShopLiveOrientation(orientation: UIInterfaceOrientationMask) {
        ShopLiveAppDelegate.shared.setOrientation(orientation)
    }
  
    public static func setEnabledShopLiveOrientationLock(enable: Bool) {
        ShopLiveAppDelegate.shared.setEnableOrientationSwizzle(enable: enable)
    }
    
    public static func getEnabledShopLiveOrientationLock() -> Bool {
        return ShopLiveAppDelegate.shared.getEnableOrientationSwizzle()
    }
    
    public static func setShopLiveAppDelegateHandler(handler: ShopLiveAppDelegateHandler?) {
        ShopLiveAppDelegate.shared.delegate = handler
    }
}
