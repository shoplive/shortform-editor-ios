//
//  MainRepository.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/23/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon

protocol MainRepository {
    func insertBroadCast(name: String, accessKey: String, campaignKey: String) async throws -> ShopLiveKeySet
}

final class DefaultMainRepository: MainRepository {
    func insertBroadCast(name: String, accessKey: String, campaignKey: String) async throws -> ShopLiveKeySet {
        ShopLiveKeySet(
            alias: name.trimmingCharacters(in: .whitespacesAndNewlines),
            campaignKey: campaignKey.trimmingCharacters(in: .whitespacesAndNewlines),
            accessKey: accessKey.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}

