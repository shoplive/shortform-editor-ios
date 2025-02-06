//
//  MockSDKConfigurationUserDefaults.swift
//  PlayerDemo2Tests
//
//  Created by sangmin han on 2/6/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
@testable import PlayerDemo2
import XCTest

final class MockSDKConfigurationUserDefault : AppUserDefaults {
    typealias DataType = SDKConfiguration
    var suiteName: String = "mock"
    var userDefaults: UserDefaults?
    
    private var sdkConfiguration: SDKConfiguration? = MockSDKConfiguration.getDummySDKConfiguration()
    
    func save(data: PlayerDemo2.SDKConfiguration) {
        self.sdkConfiguration = data
    }
    
    func get() -> PlayerDemo2.SDKConfiguration? {
        return sdkConfiguration
    }
    
    init(suiteName: String) {
        
    }
    
    
}
