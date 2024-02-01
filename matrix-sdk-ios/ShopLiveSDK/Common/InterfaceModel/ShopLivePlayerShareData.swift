//
//  ShopLivePlayerShareData.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 1/30/24.
//

import Foundation


@objc public class ShopLivePlayerShareData : NSObject {
    @objc public let campaign : ShopLivePlayerShareCampaign?
    @objc public let url : String?
    
    internal init(campaign : ShopLivePlayerShareCampaign?, url : String?) {
        self.campaign = campaign
        self.url = url
    }
    
}
