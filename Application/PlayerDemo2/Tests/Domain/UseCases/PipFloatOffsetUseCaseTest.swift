//
//  PipFloatOffsetUseCaseTest.swift
//  PlayerDemo2Tests
//
//  Created by sangmin han on 2/5/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
@testable import PlayerDemo2
import XCTest



final class DefaultPipFloatOffsetUseCaseTest : XCTestCase {
    
    var useCase : PIPFloatingUseCase!
    
    override func setUp() {
        print("reset ")
        let mockDefaults = MockSDKConfigurationUserDefault(suiteName: "dkdkdk")
        let mockRepository = MockOptionSettingRepository(sdkConfigUserDefaults: mockDefaults)
        useCase = DefaultPIPFloatingUseCase(sdkConfigurationRepository: mockRepository,
                                            sdkConfigurationMapperUseCase: DefaultSDKConfigurationMapperUseCase())
    }
    
    func test_패딩_입력_테스트() {
        //
        let given : UIEdgeInsets = .init(top: 201, left: 201, bottom: 201, right: 201 )
        useCase.setPipPaddingInset(inset: given )
        
        //when
        let when = useCase.getPipPaddingInset()
        
        
        //then
        XCTAssertEqual(given, when)
       
    }
    
    func test_플로팅_입력_테스트() {
        let given : UIEdgeInsets = .init(top: 201, left: 201, bottom: 201, right: 201 )
        useCase.setPipFloatingOffset(inset: given )
        
        //when
        let when = useCase.getPipFloatingOffset()
        
        
        //then
        XCTAssertEqual(given, when)
    }
    
    func test_디폴트_값_테스트() {
        
        //given null
        
        //when
        let padding = useCase.getPipPaddingInset()
        let floating = useCase.getPipFloatingOffset()
        
        
        //then
        XCTAssertEqual(padding, .init(top: 20, left: 20, bottom: 20, right: 20))
        XCTAssertEqual(floating, .init(top: 20, left: 20, bottom: 20, right: 20))
    }
}

