//
//  SellerSubscriptionData.swift
//  ShopLivePlayerDemo
//
//  Created by sangmin han on 4/19/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation


class SellerSubscriptionData {
    var campaignKey : String?
    var campaignStatus : String?
    var campaignTitle : String?
    var isLogin : Bool?
    var saved : Bool?
    var seller : SellerData?
    
    init(campaignKey: String? = nil, campaignStatus: String? = nil, campaignTitle: String? = nil, isLogin: Bool? = nil, saved: Bool? = nil, seller: SellerData? = nil) {
        self.campaignKey = campaignKey
        self.campaignStatus = campaignStatus
        self.campaignTitle = campaignTitle
        self.isLogin = isLogin
        self.saved = saved
        self.seller = seller
    }
    
    
    init(dict  : [String : Any] ) {
        self.campaignKey = dict["campaignKey"] as? String
        self.campaignStatus = dict["campaignStatus"] as? String
        self.campaignTitle = dict["campaignTitle"] as? String
        self.isLogin = dict["isLogin"] as? Bool
        self.saved = dict["saved"] as? Bool
        self.seller = SellerData(dict: dict["seller"] as? [String : Any] ?? [:])
        
    }
    
}
