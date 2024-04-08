//
//  ShopLiveCommonAuth.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2023/05/23.
//

import Foundation
import AppTrackingTransparency
import AdSupport

public struct ShopLiveCommonAuth {
    var userJWT : String? = nil
    var guestUid : String? = nil
    var accessKey : String? = nil
    
    //플레이어 전용
    var adId : String? = nil
    
    var adIdentifier : String? {
        get {
            if #available(iOS 14, *) {
                let status = ATTrackingManager.trackingAuthorizationStatus
                switch status {
                case .notDetermined, .restricted, .denied:
                    return nil
                case .authorized:
                    return ASIdentifierManager.shared().advertisingIdentifier.uuidString
                @unknown default:
                    return nil
                }
            } else {
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            }
        }
    }
    
    var utmSource : String? = nil
    var utmMedium : String? = nil
    var utmCampaign : String? = nil
    var utmContent : String? = nil
    
    var anonId : String? = nil
    
}



