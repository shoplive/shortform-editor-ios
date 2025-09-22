//
//  ShopLiveConversionProductData.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 4/11/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation

public struct ShopLiveConversionProductData {
    public var productId: String?
    public var customerProductId: String?
    public var sku: String?
    public var url: String?
    public var purchaseQuantity: Int?
    public var purchaseUnitPrice: Double?
    
    
    public init(productId: String? = nil, customerProductId: String? = nil, sku: String? = nil, url: String? = nil, purchaseQuantity: Int? = nil, purchaseUnitPrice: Double? = nil) {
        self.productId = productId
        self.customerProductId = customerProductId
        self.sku = sku
        self.url = url
        self.purchaseQuantity = purchaseQuantity
        self.purchaseUnitPrice = purchaseUnitPrice
    }
    
    func toShopLiveEventProduct() -> ShopLiveEventProduct {
        return .init(productId: productId,
                     customerProductId: customerProductId,
                     sku: sku,
                     url: url,
                     purchaseQuantity: purchaseQuantity,
                     purchaseUnitPrice: purchaseUnitPrice)
    }
}
