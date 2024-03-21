//
//  ShopLiveShortformListYoutubeUrlGenerator.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 3/4/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import ShopliveSDKCommon

struct ShopLiveShortformListYoutubeUrlGenerator {
    
    static func getYoutubeUrl( shortsModel : ShopLiveShortform.ShortsModel?) -> URL? {
        var payload: String = ""
        let shortsDict = shortsModel?.getRawDataDict()
        var payloadDict: [String: Any] = ["shorts": shortsDict]
        
        if let userJWT = ShortFormAuthManager.shared.getuserJWT() {
            payloadDict["userJWT"] = userJWT
        }
        else if let guestUid = ShortFormAuthManager.shared.getGuestUId() {
            payloadDict["guestUid"] = guestUid
        }
        
        if let referrer = ShortFormAuthManager.shared.getReferrer() {
            payloadDict["referrer"] = referrer
        }
        
        if let adIdentifier = ShopLiveCommon.getAdIdentifier(), !adIdentifier.isEmpty {
            payloadDict["adIdentifier"] = adIdentifier
        }
        
        if let utm_source = ShopLiveCommon.getUtmSource() {
            payloadDict["utm_source"] = utm_source
        }
        
        if let utm_content = ShopLiveCommon.getUtmContent() {
            payloadDict["utm_content"] = utm_content
        }
        
        if let utm_campaign = ShopLiveCommon.getUtmCampaign() {
            payloadDict["utm_campaign"] = utm_campaign
        }
        
        if let utm_medium = ShopLiveCommon.getUtmMedium() {
            payloadDict["utm_medium"] = utm_medium
        }
        
        
        payloadDict["appVersion"] = UIApplication.appVersion_SL()
        payloadDict["sdkVersion"] = ShopLiveShortform.sdkVersion
        
        payloadDict["safeArea"] = [
            "top": 0,
            "right": 0,
            "bottom": 0,
            "left": 0
        ]
        
        if let youtubeId = shortsModel?.cards?.first?.externalVideoId {
            payloadDict["youtubeId"] = youtubeId
        }
        
        ShortFormAuthManager.shared.getAkAndUserJWTasDict().forEach { payloadDict[$0.key] = $0.value }
        
        if let shortJson = payloadDict.toJson_SL()  {
            payload = shortJson
        } else {
            return nil
        }

        let urlString : String = ShortFormConfigurationInfosManager.shared.shortsConfiguration.youtubeUrl
        let urlComponents = URLComponents(string: urlString)
        var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "payload", value: payload))
       
        guard let params = URLUtil_SL.query(queryItems) else {
            return URL(string: urlString)
        }

        guard let url = URL(string: urlString + "?" + params) else {
            return URL(string: urlString)
        }
        
        return url
    }
    
}
