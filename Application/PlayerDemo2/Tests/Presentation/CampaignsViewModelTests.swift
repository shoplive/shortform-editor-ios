//
//  CampaignsViewModelTests.swift
//  PlayerDemo2Tests
//
//  Created by Tabber on 1/31/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import XCTest
import Testing
@testable import ShopliveSDKCommon
@testable import PlayerDemo2

@Suite("CampaignsViewModelTests")
class CampaignsViewModelTests: NSObject {
    
    @Test func 방송_데이터_추가() async throws {
        // given
        let campaignsUseCaseMock = CampaignsUseCaseMock()
        campaignsUseCaseMock.applyKetSet(keySet: .init(currentSelectKey: "", shopLiveKetSets: []))
        
        let viewModel = CampaignsViewModel(useCase: campaignsUseCaseMock,
                                           routing: self)
        
        viewModel.setItems(keySet: .init(currentSelectKey: "", shopLiveKetSets: []))
        
        guard let viewModelKeySet = viewModel.getItems().first else {
            Issue.record(CampaignError.firstDataIsNil)
            return
        }
        
        guard let mockKeySet = campaignsUseCaseMock.getKeySet()?.shopLiveKetSets.first else {
            Issue.record(CampaignError.firstDataIsNil)
            return
        }
        
        #expect(campaignsUseCaseMock.excuteCallCount == 4)
        #expect(viewModelKeySet.alias == mockKeySet.alias)
        #expect(viewModelKeySet.campaignKey == mockKeySet.campaignKey)
        #expect(viewModelKeySet.accessKey == mockKeySet.accessKey)
        
    }
}

extension CampaignsViewModelTests: CampaignsRouting {
    func dismissViewController() {
    }
}
