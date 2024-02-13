//
//  ShopLivePlayerShareCampaign.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 1/30/24.
//

import Foundation


@objc public class ShopLivePlayerShareCampaign : NSObject {
    @objc public let campaignKey : String?
    @objc public let title : String?
    @objc public let descriptions : String?
    @objc public let thumbnail : String?
    
    internal init(payload : [String : Any]) {
        self.campaignKey = payload["campaignKey"] as? String
        let campaignDict = payload["campaign"] as? [String : Any]
        self.title = campaignDict?["title"] as? String
        self.descriptions = campaignDict?["description"] as? String
        self.thumbnail = campaignDict?["posterUrl"] as? String
    }
    
}
