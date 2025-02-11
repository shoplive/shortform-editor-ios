//
//  CustomParameterSettingUseCaseTest.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/7/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
@testable import ShopLiveSDK
@testable import ShopliveSDKCommon
@testable import PlayerDemo2
import XCTest



final class DefaultCustomparameterSettingUseCaseTest : XCTestCase {
    
    var useCase : CustomParameterSettingUseCase!
    
    
    override func setUp() {
        let mockDefaults = MockSDKConfigurationUserDefault(suiteName: "dkdkdk")
        let mockRepository = MockOptionSettingRepository(sdkConfigUserDefaults: mockDefaults)
        useCase = DefaultCustomParamterSettingUseCase(sdkConfigurationRepository: mockRepository,
                                                      sdkConfigurationMapperUseCase: DefaultSDKConfigurationMapperUseCase())
        
    }
    
    
    func test_get_default_custom_parameeter() {
        //given null
        
        //when
        let result = useCase.getCustomParameters()
        
        
        //then
        XCTAssertEqual(result.count, 0)
    }
    
    func test_save_custom_parameter() {
        //given
        let given : [String : Any] = ["test1" : "test1", "test2" : "test2"]
        let temp = given.map { CustomParameter(customParameterId: 0, paramKey: $0.key,paramValue: $0.value as! String,isUseParam: true) }
        
        
        
        //when
        useCase.saveCustomParameters(customParamter: temp)
        
        
        //then
        let result = useCase.getCustomParameters()
        XCTAssertEqual(Set(result.map{ $0.paramKey }), Set(["test1","test2"]))
        XCTAssertEqual(Set(result.map{ $0.paramValue }), Set(["test1","test2"]))
        
    }
    
}
