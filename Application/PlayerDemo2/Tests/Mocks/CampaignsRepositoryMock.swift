//
//  CampaignsRepositoryMock.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/24/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
@testable import PlayerDemo2

class MockCampaignsRepository: CampaignsRepository {
    
    var shouldFail = false
    var mockData: ShopLiveCampaignsKey = .init(currentSelectKey: "", shopLiveKetSets: [])
    
    func excute(keySet: ShopLiveCampaignsKey) {
        mockData = keySet
    }
    
    func getKeySet() -> ShopLiveCampaignsKey? {
        return mockData
    }
}

