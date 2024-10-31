//
//  TagsAndBrandsRequestParameterModel.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/07/19.
//

import Foundation

public class ShopLiveShortformCollectionData {
    public var reference : String?
    public var shortsId : String?
    public var tags : [String]?
    public var tagSearchOperator : ShopLiveTagSearchOperator?
    public var brands : [String]?
    public var shuffle : Bool?
    public var skus : [String]?
    public var shortsCollectionId : String?
    public var delegate : ShopLiveShortformReceiveHandlerDelegate?
    
    public init(reference: String? = nil, shortsId: String? = nil, tags: [String]? = nil, tagSearchOperator: ShopLiveTagSearchOperator? = nil, brands: [String]? = nil, shuffle: Bool? = nil,referrer : String? = nil, skus : [String]? = nil, shortsCollectionId : String?, delegate : ShopLiveShortformReceiveHandlerDelegate?) {
        self.reference = reference
        self.shortsId = shortsId
        self.tags = tags
        self.tagSearchOperator = tagSearchOperator
        self.brands = brands
        self.shuffle = shuffle
        self.skus = skus
        self.shortsCollectionId = shortsCollectionId
        self.delegate = delegate
        ShortFormAuthManager.shared.setReferrer(referrer: referrer)
    }
}
