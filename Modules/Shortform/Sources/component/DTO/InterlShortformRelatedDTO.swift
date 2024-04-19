//
//  InterlShortformRelatedDTO.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 4/17/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation


internal class InternalShortformRelatedDTO {
    var shortsId : String?
    var productId : String?
    var name : String?
    var skus : [String]?
    var url : String?
    var tags : [String]?
    var tagSearchOperator : String?
    var brands : [String]?
    var shuffle : Bool?
    
    
    public init(shortsId : String? = nil, productId: String? = nil, name: String? = nil, skus: [String]? = nil, url: String? = nil, tags: [String]? = nil, tagSearchOperator: String? = nil, brands: [String]? = nil, shuffle: Bool? = nil) {
        self.shortsId = shortsId
        self.productId = productId
        self.name = name
        self.skus = skus
        self.url = url
        self.tags = tags
        self.tagSearchOperator = tagSearchOperator
        self.brands = brands
        self.shuffle = shuffle
    }
}



