//
//  CampaignsUseCaseTest.swift
//  PlayerDemo2Tests
//
//  Created by Tabber on 1/24/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import XCTest
import Testing
@testable import ShopliveSDKCommon
@testable import PlayerDemo2

enum CampaignError: Error {
    case firstDataIsNil
}

final class CampaignsUseCaseTest: XCTestCase {

    var sut: CampaignsUseCase!
    var mockRepository: MockCampaignsRepository!
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_KeySet_주입_후_확인_테스트() async throws {
        mockRepository = MockCampaignsRepository()
        sut = DefaultCampaignsUseCase(campaignsRepository: mockRepository)
        
        // given
        
        let campaignTitle: String = "Test"
        let campaignKey: String = "Lm9LJaufCztZXJ5gpNg2DDDDD"
        let campaignAccessKey: String = "Lm9LJaufCztZXJ5gpNg2dasdas"
        
        // when
        sut.applyKetSet(keySet: .init(currentSelectKey: "", shopLiveKetSets: [ShopLiveKeySet(alias: campaignTitle, campaignKey: campaignKey, accessKey: campaignAccessKey)]))
        let getCampaignData = sut.getKeySet()
        
        // then
        
        let count: Int = getCampaignData?.shopLiveKetSets.count ?? 0
        guard let firstData: ShopLiveKeySet = getCampaignData?.shopLiveKetSets.first else {
            Issue.record(CampaignError.firstDataIsNil)
            return
        }
        
        #expect(count == 1)
        #expect(firstData.alias == campaignTitle)
        #expect(firstData.campaignKey == campaignKey)
        #expect(firstData.accessKey == campaignAccessKey)
        
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
