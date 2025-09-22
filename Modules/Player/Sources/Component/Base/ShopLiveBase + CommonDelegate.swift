//
//  ShopLiveBase + CommonDelegate.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/7/23.
//

import Foundation
import ShopliveSDKCommon

extension ShopLiveBase: ShopLiveCommonDelegate {
    var identifier: String {
        get {
            return "ShopLiveBase"
        }
    }
    
    func onChangedShopLiveUserJWT(to: String?) {
        /** no op */
    }
    
    func onChangeShopLiveUser(to: ShopliveSDKCommon.ShopLiveCommonUser?) {
        /** no op */
    }
}
