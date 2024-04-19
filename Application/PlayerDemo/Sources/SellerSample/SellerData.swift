//
//  SellerData.swift
//  ShopLivePlayerDemo
//
//  Created by sangmin han on 4/19/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation

class SellerData {
    var descriptions : String?
    var name : String?
    var profileUrl : String?
    var scheme : String?
    var sellerId : Int?
    var sellerIdentifier : String?
    var storeUrl : String
    
    init(descriptions: String? = nil, name: String? = nil, profileUrl: String? = nil, scheme: String? = nil, sellerId: Int? = nil, sellerIdentifier: String? = nil, storeUrl: String) {
        self.descriptions = descriptions
        self.name = name
        self.profileUrl = profileUrl
        self.scheme = scheme
        self.sellerId = sellerId
        self.sellerIdentifier = sellerIdentifier
        self.storeUrl = storeUrl
    }
    
    
    init(dict : [String : Any]) {
        self.descriptions = dict["descriptions"] as? String
        self.name = dict["name"] as? String
        self.profileUrl = dict["profileUrl"] as? String
        self.scheme = dict["scheme"] as? String
        self.sellerId = dict["sellerId"] as? Int
        self.sellerIdentifier = dict["sellerIdentifier"] as? String
        self.storeUrl = dict["storeUrl"] as? String ?? ""
    }
}
