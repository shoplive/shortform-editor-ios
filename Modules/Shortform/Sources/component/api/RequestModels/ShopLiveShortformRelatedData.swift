//
//  RelatedShortsRequestParameterModel.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/07/20.
//

import Foundation


public class ShopLiveShortformRelatedData {
    
    public var shortsId : String?
    public var reference : String?
    public var productId : String?
    public var name : String?
    public var skus : [String]?
    public var url : String?
    public var tags : [String]?
    public var tagSearchOperator : ShopLiveTagSearchOperator?
    public var brands : [String]?
    public var shuffle : Bool?
    public var isMuted : Bool? = false
    public var delegate : ShopLiveShortformReceiveHandlerDelegate?
    
    
    public init(shortsId : String? = nil,
                reference: String? = nil,
                productId: String? = nil,
                name: String? = nil,
                skus: [String]? = nil,
                url: String? = nil,
                tags: [String]? = nil,
                tagSearchOperator: ShopLiveTagSearchOperator? = nil,
                brands: [String]? = nil,
                shuffle: Bool? = nil,
                referrer : String? = nil,
                isMuted : Bool? = false,
                delegate : ShopLiveShortformReceiveHandlerDelegate?) {
        self.shortsId = shortsId
        self.reference = reference
        self.productId = productId
        self.name = name
        self.skus = skus
        self.url = url
        self.tags = tags
        self.tagSearchOperator = tagSearchOperator
        self.brands = brands
        self.shuffle = shuffle
        self.delegate = delegate
        self.isMuted = isMuted
        ShortFormAuthManager.shared.setReferrer(referrer: referrer)
    }
}
