//
//  ShopLiveShortformUploaderDTO.swift
//  ShopLiveShortformEditorSDK
//
//  Created by Tabber on 3/27/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit

struct ShopLiveShortformUploaderDTO: Encodable {
    var tags: [String]
    var products: [ShopLiveConversionProductDTO]
    
    init(tags: [String] = [], products: [ShopLiveConversionProductDTO] = []) {
        self.tags = tags
        self.products = products
    }
    
    enum CodingKeys: String, CodingKey {
        case tags
        case products
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(tags, forKey: .tags)
        try container.encode(products, forKey: .products)
    }
}


public struct ShopLiveShortformUploaderUiDTO: Encodable {
    var hashTag: Bool
    var videoChange: Bool
    var rating: Bool
    
    init(hashTag: Bool = true, videoChange: Bool = false, rating: Bool = false) {
        self.hashTag = hashTag
        self.videoChange = videoChange
        self.rating = rating
    }
}

public struct ShopLiveConversionProductDTO: Encodable {
    var sku: String?
    var url: String?
    var productId: String?
    var customProductId: String?
    
    init(sku: String? = nil, url: String? = nil, productId: String? = nil, customProductId: String? = nil) {
        self.sku = sku
        self.url = url
        self.productId = productId
        self.customProductId = customProductId
    }
}
