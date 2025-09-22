//
//  ShopLiveEventProduct.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 4/11/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation


public struct ShopLiveEventProduct: Codable {
    public var productId: String?
    public var customerProductId: String?
    public var sku: String?
    public var url: String?
    public var purchaseQuantity: Int?
    public var purchaseUnitPrice: Double?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        self.productId = try parser.parse(targetType: String.self, key: CodingKeys.productId)
        self.customerProductId = try parser.parse(targetType: String.self, key: CodingKeys.customerProductId)
        self.sku = try parser.parse(targetType: String.self, key: CodingKeys.sku)
        self.url = try parser.parse(targetType: String.self, key: CodingKeys.url)
        self.purchaseQuantity = try parser.parse(targetType: Int.self, key: CodingKeys.purchaseQuantity)
        self.purchaseUnitPrice = try parser.parse(targetType: Double.self, key: CodingKeys.purchaseUnitPrice)
    }
    
    
    
    public init(productId: String?, customerProductId: String?, sku: String?, url: String?, purchaseQuantity: Int?, purchaseUnitPrice: Double?) {
        self.productId = productId
        self.customerProductId = customerProductId
        self.sku = sku
        self.url = url
        self.purchaseQuantity = purchaseQuantity
        self.purchaseUnitPrice = purchaseUnitPrice
    }
    
}


