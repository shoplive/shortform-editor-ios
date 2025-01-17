//
//  ShopLiveUserDefaults.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2023/05/23.
//

import Foundation
public final class ShopLiveUserDefaults {
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
    
    // Tabber - (25.01.15) 초기 숏폼 가이드 노출 여부 업데이트 Boolean
    public static var shortFormGuideOpen: Bool {
        set {
            UserDefaults.init(suiteName: CommonKeys.ShopLiveUserDefaultID)?.set(newValue, forKey: CommonKeys.shortFormGuideOpen)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.init(suiteName: CommonKeys.ShopLiveUserDefaultID)?.bool(forKey: CommonKeys.shortFormGuideOpen) ?? false
        }
    }
}

