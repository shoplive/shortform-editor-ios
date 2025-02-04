//
//  ShopLiveKeySetEntity + Mapping.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/31/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

extension ShopLiveCampaignsKeyUserDefaultsModel {
    func toEntity() -> ShopLiveCampaignsKey {
        .init(currentSelectKey: currentSelectKey,
              shopLiveKetSets: shopLiveKeySets.map({ $0.toEntity() })
        )
    }
}
