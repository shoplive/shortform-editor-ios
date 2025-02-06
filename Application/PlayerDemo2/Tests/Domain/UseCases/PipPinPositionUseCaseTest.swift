//
//  PipPinPositionUseCaseTest.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/6/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
@testable import ShopLiveSDK
@testable import ShopliveSDKCommon
@testable import PlayerDemo2
import XCTest


final class DefaultPipPinPositionUseCaseTest : XCTestCase {
    
    var useCase : PIPPinPositionUseCase!
    
    override func setUp() {
        let mockDefaults = MockSDKConfigurationUserDefault(suiteName: "dkdkdk")
        let mockRepository = MockOptionSettingRepository(sdkConfigUserDefaults: mockDefaults)
        useCase = DefaultPIPPinPositionUseCase(sdkConfigurationRepository: mockRepository,
                                               sdkConfigurationMapperUseCase: DefaultSDKConfigurationMapperUseCase())
    }
    
    
    
    func test_디폴트_값() {
        //given null
        
        //when
        let result = useCase.getPIPPinPosition()
        
        //then
        XCTAssertEqual(result, [.bottomRight])
    }
    
    
    func test_단일_입력() {
        //given 1
        useCase.setPIPPinPositions(pipPositions: [.bottomRight])
        let given : ShopLive.PipPosition = .bottomLeft
        
        //when 1
        useCase.setPIPPinPosition(pipPosition: given)
        
        //then 1
        let result1 = useCase.getPIPPinPosition()
        XCTAssertEqual(Set(result1), Set([.bottomRight,.bottomLeft]))
        
        //given 2
        useCase.setPIPPinPositions(pipPositions: [.topRight])
        let given2 : ShopLive.PipPosition = .bottomLeft
        
        //when 2
        useCase.setPIPPinPosition(pipPosition: given2)
        
        //then 2
        let result2 = useCase.getPIPPinPosition()
        XCTAssertEqual(Set(result2), Set([.bottomLeft,.topRight]))
        
    }
    
    func test_다수_입력() {
        //given 1
        let given : [ShopLive.PipPosition] = [.bottomRight,.bottomCenter,.topLeft,.topCenter]
        
        //when 1
        useCase.setPIPPinPositions(pipPositions: given)
        
        //then 1
        let result1 = useCase.getPIPPinPosition()
        XCTAssertEqual(Set(result1), Set([.bottomRight,.bottomCenter,.topLeft,.topCenter]))
    }
    
    
    
}
