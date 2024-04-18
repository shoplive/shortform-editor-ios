//
//  ShopLiveConversionData.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 4/11/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation

public struct ShopLiveConversionData {
    public var type : String?
    public var products : [ShopLiveConversionProductData]?
    public var orderId : String?
    public var referrer : String?
    public var custom : [String : Any?]?
    
    
    public init(type: String? = nil, products: [ShopLiveConversionProductData]? = nil, orderId: String? = nil, referrer: String? = nil, custom: [String : Any?]? = nil) {
        self.type = type
        self.products = products
        self.orderId = orderId
        self.referrer = referrer
        self.custom = custom
    }
}
