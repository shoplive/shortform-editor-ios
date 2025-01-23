//
//  MainUseCaseTest.swift
//  PlayerDemo2Tests
//
//  Created by Tabber on 1/23/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import XCTest
@testable import ShopliveSDKCommon
@testable import PlayerDemo2

final class MainUseCaseTest: XCTestCase {

    var sut: MainUseCase!
    var mockRepository: MockMainRepository!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func test_방송_입력_테스트() async throws {
        
        mockRepository = MockMainRepository()
        sut = DefaultMainUseCase(mainRepository: mockRepository)
        
        //given
        let campaignName: String = "Test01"
        let campaignKey: String = "Lm9LJaufCztZXJ5gpNg2DDDDD"
        let campaignAccessKey: String = "Lm9LJaufCztZXJ5gpNg2dasdas"
        
        let testCampaign = ShopLiveKeySet(alias: "Test01",
                                       campaignKey: "Lm9LJaufCztZXJ5gpNg2DDDDD",
                                       accessKey: "Lm9LJaufCztZXJ5gpNg2dasdas")
        //when
        //let resultUser = try await sut.execute(userId: "dsa", userName: "dsa", age: "dfs", userScore: "dsa", gender: .female)
        let resultCampaign = try await sut.executeCampaign(name: campaignName,
                                                            accessKey: campaignAccessKey,
                                                            campaignKey: campaignKey)
        //then
        XCTAssertEqual(testCampaign.alias, resultCampaign.alias)

    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
