//
//  ShortFormAuthManager.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/05/23.
//

import Foundation
import ShopLiveSDKCommon


 
class ShortFormAuthManager {
    static let shared = ShortFormAuthManager()
    private var referrer : String?
    
    func setReferrer(referrer : String?){
        self.referrer = referrer
    }
    
    func getReferrer() -> String? {
        return self.referrer
    }
    
    
    func setAuthInfo(_ info : [String : Any]){
        if let ak = info["ak"] as? String {
            ShopLiveCommon.setAccessKey(accessKey: ak)
        }
        if let token = info["userJWT"] as? String {
            ShopLiveCommon.setAuthToken(authToken: token)
        }
        if let guestUid = info["guestUid"] as? String {
            ShopLiveCommon.setGuestUid(guestUid: guestUid)
        }
        
        
        if let utm_source = info["utm_source"] as? String {
            ShopLiveCommon.setUtmSource(utmSource: utm_source)
        }
        if let utm_content = info["utm_content"] as? String {
            ShopLiveCommon.setUtmContent(utmContent: utm_content)
        }
        
        if let utm_campaign = info["utm_campaign"] as? String {
            ShopLiveCommon.setUtmCampaign(utmCampaign: utm_campaign)
        }
        
        if let utm_medium = info["utm_medium"] as? String {
            ShopLiveCommon.setUtmMedium(utmMedium: utm_medium)
        }

    }
    

    
    func getAkAndUserJWTasDict() -> [String : Any] {
        var dict : [String : Any] = [:]
        if let ak = ShopLiveCommon.getAccessKey() {
            dict["ak"] = ak
        }
        if let userJWT = ShopLiveCommon.getAuthToken() {
            dict["userJWT"] = userJWT
        }
        else if let guestUid = ShopLiveCommon.getGuestUid() {
            dict["guestUid"] = guestUid
        }
        if let utm_source = ShopLiveCommon.getUtmSource() {
            dict["utm_source"] = utm_source
        }
        if let utm_content = ShopLiveCommon.getUtmContent() {
            dict["utm_content"] =  utm_content
        }
        if let utm_campaign = ShopLiveCommon.getUtmCampaign() {
            dict["utm_campaign"] =   utm_campaign
        }
        if let utm_medium = ShopLiveCommon.getUtmMedium() {
            dict["utm_medium"] =  utm_medium
        }
        return dict
    }
    
    func getAccessKey() -> String? {
        return ShopLiveCommon.getAccessKey()
    }
    
    func getuserJWT() -> String?{
        return ShopLiveCommon.getAuthToken()
    }
    
    func getGuestUId() -> String? {
        return ShopLiveCommon.getGuestUid()
    }
    
    func setAccessKey(accessKey : String?){
        ShopLiveCommon.setAccessKey(accessKey: accessKey)
    }
    
    func setGuestUid(guestUid : String?) {
        ShopLiveCommon.setGuestUid(guestUid: guestUid)
    }
    
    func setUserJWT(userJWT : String?){
        ShopLiveCommon.setAuthToken(authToken: userJWT)
    }
}
