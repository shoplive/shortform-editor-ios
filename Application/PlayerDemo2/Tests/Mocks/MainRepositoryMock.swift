//
//  MainRepositoryMock.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/23/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
@testable import PlayerDemo2

class MockMainRepository: MainRepository {
    var shouldFail = false
    var mockKeySet: ShopLiveKeySet?
    
    func insertBroadCast(name: String, accessKey: String, campaignKey: String) async throws -> ShopLiveKeySet {
        if shouldFail {
            throw NSError(domain: "Test", code: -1)
        }
        
        return mockKeySet ??  ShopLiveKeySet.init(alias: name,
                                                  campaignKey: campaignKey,
                                                  accessKey: accessKey)
    }
}
