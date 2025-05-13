//
//  ShopLiveUgcUploaderData.swift
//  ShopLiveShortformEditorSDK
//
//  Created by Tabber on 3/27/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

public struct ShopLiveShortformUploaderData {
    var shortsId: String?
    var ui: ShopLiveUgcUploaderUiData
    var tags: [String]
    var products: [ShopLiveConversionProductData]
    
    public init(shortsId: String? = nil, ui: ShopLiveUgcUploaderUiData = .init(), tags: [String] = [], products: [ShopLiveConversionProductData] = []) {
        self.shortsId = shortsId
        self.ui = ui
        self.tags = tags
        self.products = products
    }
}

extension ShopLiveShortformUploaderData {
    func toDTO() -> ShopLiveShortformUploaderDTO {
        .init(tags: tags,
              products: products.map{ $0.toDTO() })
    }
}

public struct ShopLiveUgcUploaderUiData {
    var hashTag: Bool
    var videoChange: Bool
    var rating: Bool
    
    public init(hashTag: Bool = true, videoChange: Bool = false, rating: Bool = false) {
        self.hashTag = hashTag
        self.videoChange = videoChange
        self.rating = rating
    }
}

extension ShopLiveUgcUploaderUiData {
    func toDTO() -> ShopLiveShortformUploaderUiDTO {
        .init(hashTag: hashTag, videoChange: videoChange, rating: rating)
    }
}

public struct ShopLiveConversionProductData {
    var sku: String?
    var url: String?
    var productId: String?
    var customProductId: String?
    
    public init(sku: String? = nil, url: String? = nil, productId: String? = nil, customProductId: String? = nil) {
        self.sku = sku
        self.url = url
        self.productId = productId
        self.customProductId = customProductId
    }
}

extension ShopLiveConversionProductData {
    func toDTO() -> ShopLiveConversionProductDTO {
        .init(sku: sku, url: url, productId: productId, customProductId: customProductId)
    }
}
