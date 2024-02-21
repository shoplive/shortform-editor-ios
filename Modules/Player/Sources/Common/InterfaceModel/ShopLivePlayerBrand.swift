//
//  ShopLivePlayerBrand.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 2/14/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation


@objc public class ShopLivePlayerBrand : NSObject {
    @objc public var name : String?
    @objc public var identifier : String?
    @objc public var imageUrl : String?

    @objc public init(name: String? = nil, identifier: String? = nil, imageUrl: String? = nil) {
        self.name = name
        self.identifier = identifier
        self.imageUrl = imageUrl
    }

    internal override init() {
        super.init()
    }


    internal func parse(payload : [String : Any]?) {
        guard let configJson =  payload?["configJson"] as? [String : Any] else { return }
        if let brandIdentifier = configJson["brandIdentifier"] as? String {
            self.identifier = brandIdentifier
        }
        if let brandName = configJson["brandName"] as? String {
            self.name = brandName
        }
        if let brandImage = configJson["brandImageUrl"] as? String {
            self.imageUrl = brandImage
        }
    }
}
