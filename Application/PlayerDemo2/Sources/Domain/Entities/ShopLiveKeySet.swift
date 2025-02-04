//
//  ShopLiveKeySet.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

struct ShopLiveCampaignsKey {
    var currentSelectKey: String
    var shopLiveKetSets: [ShopLiveKeySet]
}

struct ShopLiveKeySet {
    var alias: String
    var campaignKey: String
    var accessKey: String
}

extension ShopLiveKeySet {
    func hasEmptyValue() -> Bool {
        return self.alias.isEmpty || self.accessKey.isEmpty || self.campaignKey.isEmpty
    }
    
    func isEqual(_ object: Any?) -> Bool {
        return self.alias == (object as? ShopLiveKeySet)?.alias && self.accessKey == (object as? ShopLiveKeySet)?.accessKey && self.campaignKey == (object as? ShopLiveKeySet)?.campaignKey
    }
    
}

extension ShopLiveKeySet {
    func toUserDefaultsModel() -> ShopLiveKeySetUserDefaultsModel {
        .init(alias: alias, campaignKey: campaignKey, accessKey: accessKey)
    }
}

extension ShopLiveCampaignsKey {
    func toUserDefaultsModel() -> ShopLiveCampaignsKeyUserDefaultsModel {
        .init(currentSelectKey: currentSelectKey,
              shopLiveKeySets: shopLiveKetSets.map({ $0.toUserDefaultsModel() }))
    }
}
