//
//  SellerStoreData.swift
//  ShopLivePlayerDemo
//
//  Created by sangmin han on 4/19/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation

class SellerStoreData {
    var campaignKey : String?
    var campaignStatus : String?
    var campaignTitle : String?
    var seller : SellerData?
    
    init(campaignKey: String? = nil, campaignStatus: String? = nil, campaignTitle: String? = nil, seller: SellerData? = nil) {
        self.campaignKey = campaignKey
        self.campaignStatus = campaignStatus
        self.campaignTitle = campaignTitle
        self.seller = seller
    }
    
    init(dict : [String : Any]) {
        self.campaignKey = dict["campaignKey"] as? String
        self.campaignStatus = dict["campaignStatus"] as? String
        self.campaignTitle = dict["campaignTitle"] as? String
        self.seller = .init(dict: dict["seller"] as? [String : Any] ?? [:])
    }
}
