//
//  ShopLiveShortformIdsMoreData.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/30/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon


public class ShopLiveShortformIdsMoreData {
    public var ids : [ShopLiveShortformIdData]?
    public var hasMore : Bool?
    
    public init(ids: [ShopLiveShortformIdData]? = nil, hasMore: Bool? = nil) {
        self.ids = ids
        self.hasMore = hasMore
    }
}
