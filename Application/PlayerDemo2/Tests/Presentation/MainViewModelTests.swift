//
//  MainViewModelTests.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/23/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
@testable import ShopliveSDKCommon
@testable import PlayerDemo2

class MainViewModelTests: XCTestCase {
    
    private enum BroadCastUseCaseError: Error {
        case accessKeyNotFound
    }
    
    var keyset: ShopLiveKeySet = .init(alias: "Test",
                                       campaignKey: "Lm9LJaufCztZXJ5gpNg2DDDDD",
                                       accessKey: "Lm9LJaufCztZXJ5gpNg2dasdas")
    
    var items: [String] = ["CampaignInfoCell", "UserInfoCell"]
    
    class MainUseCaseMock: MainUseCase {
        func loadCurrentCampaign() -> PlayerDemo2.ShopLiveKeySet? { return nil }
        
        func loadAllCampaigns() -> PlayerDemo2.ShopLiveCampaignsKey? { return nil }
        
        func saveCurrentCampaign(keySet: PlayerDemo2.ShopLiveKeySet) { }
        
        func updateCampaign(keySet: PlayerDemo2.ShopLiveKeySet) { }
        
        var updateNoti: RxSwift.Observable<Void> {
            return .never()
        }
        
        
        var excuteCallCount: Int = 0
        
        func executeCampaign(name: String, accessKey: String, campaignKey: String) async throws -> ShopLiveKeySet {
            excuteCallCount += 1
            return .init(alias: name,
                         campaignKey: campaignKey,
                         accessKey: accessKey)
        }
        
    }
    
    func test_방송_데이터_추가_테스트() async throws {
        //given
        let mainUseCaseMock = MainUseCaseMock()
        
        let mockData = try await mainUseCaseMock.executeCampaign(name: keyset.alias,
                                                                 accessKey: keyset.accessKey,
                                                                 campaignKey: keyset.campaignKey)
        
        let viewModel = MainViewModel(useCase: mainUseCaseMock)
        
        // when
        viewModel.updateSetKey(value: mockData)
        
        guard let viewModelKeySet = viewModel.keyset else { return }
        XCTAssertEqual(viewModelKeySet.alias, mockData.alias)
        XCTAssertEqual(viewModelKeySet.accessKey, mockData.accessKey)
        XCTAssertEqual(viewModelKeySet.campaignKey, mockData.campaignKey)
        XCTAssertEqual(mainUseCaseMock.excuteCallCount, 1)
        
        await MainActor.run { addTeardownBlock { [weak viewModel] in XCTAssertNil(viewModel) } }
    }
    
    func test_홈_화면_테이블_뷰_셀_추가_테스트() async throws {
        
    }
}

