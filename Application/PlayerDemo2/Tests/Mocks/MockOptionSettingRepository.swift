//
//  MockOptionSettingRepository.swift
//  PlayerDemo2Tests
//
//  Created by sangmin han on 2/6/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
@testable import PlayerDemo2
import XCTest

final class MockOptionSettingRepository : OptionSettingRepository {
    typealias DataType = SDKConfiguration
    
    let sdkConfigUserDefaults : any AppUserDefaults<SDKConfiguration>
    
    init(sdkConfigUserDefaults: any AppUserDefaults<SDKConfiguration>) {
        self.sdkConfigUserDefaults = sdkConfigUserDefaults
    }
    
    func saveOptions(data: PlayerDemo2.SDKConfiguration) {
        sdkConfigUserDefaults.save(data: data)
    }
    
    func getOptions() -> PlayerDemo2.SDKConfiguration? {
        return sdkConfigUserDefaults.get()
    }
}
