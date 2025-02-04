//
//  ShopLiveKeySetUserDefaultsModel.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/31/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

struct ShopLiveCampaignsKeyUserDefaultsModel: Codable {
    var currentSelectKey: String
    var shopLiveKeySets: [ShopLiveKeySetUserDefaultsModel]
}

struct ShopLiveKeySetUserDefaultsModel: Codable {
    var alias: String
    var campaignKey: String
    var accessKey: String
}

extension ShopLiveKeySetUserDefaultsModel {
    func toEntity() -> ShopLiveKeySet {
        .init(alias: alias,
              campaignKey: campaignKey,
              accessKey: accessKey)
    }
}
