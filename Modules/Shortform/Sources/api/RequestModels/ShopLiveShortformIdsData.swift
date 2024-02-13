//
//  ShopLiveShortformIdsData.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/30/23.
//

import Foundation


public class ShopLiveShortformIdsData {
    public var ids : [String]?
    public var currentId : String?
    
    public init(ids : [String]?,currentId: String? = nil, referrer: String? = nil) {
        self.ids = ids
        self.currentId = currentId
        ShortFormAuthManager.shared.setReferrer(referrer: referrer)
    }
}
