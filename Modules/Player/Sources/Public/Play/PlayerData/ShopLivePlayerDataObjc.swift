//
//  ShopLivePlayerDataObjc.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 1/10/24.
//

import Foundation
import UIKit

@objc public class ShopLivePlayerDataObjc: ShopLivePlayerData {
    @objc public var _campaignKey: String {
        set {
            super.campaignKey = newValue
        }
        get {
            return super.campaignKey
        }
    }
    
    @objc public var _keepWindowStateOnPlayExecuted: Bool {
        set {
            super.keepWindowStateOnPlayExecuted = newValue
        }
        get {
            return super.keepWindowStateOnPlayExecuted
        }
    }
    
    @objc public var _referrer: String {
        set {
            super.referrer = newValue
        }
        get {
            return super.referrer ?? ""
        }
    }
    
    @objc public init(
        campaignKey: String,
        keepWindowStateonPlayExecuted: Bool,
        referrer: String
    ) {
        super.init(
            campaignKey: campaignKey,
            keepWindowStateOnPlayExecuted: keepWindowStateonPlayExecuted,
            referrer: referrer
        )
    }
}
