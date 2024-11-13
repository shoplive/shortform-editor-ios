//
//  ShopLiveShortformIdsData.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/30/23.
//

import Foundation


public class ShopLiveShortformIdsData {
    public var ids : [ShopLiveShortformIdData]?
    public var currentId : String?
    
    public init(ids : [ShopLiveShortformIdData]?,currentId: String? = nil, referrer: String? = nil) {
        self.ids = ids
        self.currentId = currentId
        ShortFormAuthManager.shared.setReferrer(referrer: referrer)
    }
}

public struct ShopLiveShortformIdData {
    public let shortsId : String
    public let payload : [String : Any]?
    
    public init(shortsId: String, payload: [String : Any]?) {
        self.shortsId = shortsId
        var payloadWithShortsId : [String : Any]? = payload
        payloadWithShortsId?["shortsId"] = shortsId
        self.payload = payloadWithShortsId
    }
}


