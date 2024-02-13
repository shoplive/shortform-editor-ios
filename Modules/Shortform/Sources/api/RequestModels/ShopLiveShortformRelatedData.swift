//
//  RelatedShortsRequestParameterModel.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/07/20.
//

import Foundation


public class ShopLiveShortformRelatedData {
    public var reference : String?
    public var productId : String?
    public var name : String?
    public var sku : String?
    public var url : String?
    public var tags : [String]?
    public var tagSearchOperator : ShopLiveTagSearchOperator?
    public var brands : [String]?
    public var shuffle : Bool?
    
    
    public init(reference: String? = nil, productId: String? = nil, name: String? = nil, sku: String? = nil, url: String? = nil, tags: [String]? = nil, tagSearchOperator: ShopLiveTagSearchOperator? = nil, brands: [String]? = nil, shuffle: Bool? = nil, referrer : String? = nil) {
        self.reference = reference
        self.productId = productId
        self.name = name
        self.sku = sku
        self.url = url
        self.tags = tags
        self.tagSearchOperator = tagSearchOperator
        self.brands = brands
        self.shuffle = shuffle
        ShortFormAuthManager.shared.setReferrer(referrer: referrer)
    }
}

internal class InternalShortformRelatedData {
    var productId : String?
    var name : String?
    var sku : String?
    var url : String?
    var tags : [String]?
    var tagSearchOperator : String?
    var brands : [String]?
    var shuffle : Bool?
    
    public init(productId: String? = nil, name: String? = nil, sku: String? = nil, url: String? = nil, tags: [String]? = nil, tagSearchOperator: String? = nil, brands: [String]? = nil, shuffle: Bool? = nil) {
        self.productId = productId
        self.name = name
        self.sku = sku
        self.url = url
        self.tags = tags
        self.tagSearchOperator = tagSearchOperator
        self.brands = brands
        self.shuffle = shuffle
    }
}



