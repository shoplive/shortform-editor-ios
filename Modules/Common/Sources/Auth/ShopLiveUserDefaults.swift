//
//  ShopLiveUserDefaults.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2023/05/23.
//

import Foundation
final class ShopLiveUserDefaults {
    static var guestId : String? {
        get {
            return UserDefaults.standard.string(forKey: CommonKeys.x_sl_guest_uid)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: CommonKeys.x_sl_guest_uid)
        }
    }
    
    static var ceId : String? {
        get {
            return UserDefaults.standard.string(forKey: CommonKeys.x_sl_ce_id)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: CommonKeys.x_sl_ce_id)
        }
    }
}

