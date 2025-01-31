//
//  AppUserDefaults.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/28/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation



final class DefaultAppUserDefaults : AppUserDefaults {
    typealias DataType = SDKConfiguration
    private let userDefaultsConfigurationStoreKey = "userDefaultsConfigurationStoreKey"
    var suiteName: String
    
    lazy var userDefaults : UserDefaults? = {
        return UserDefaults(suiteName: suiteName)
    }()
    
    init(suiteName: String) {
        self.suiteName = suiteName
    }
    
    func get() -> SDKConfiguration? {
        guard let userDefaults = userDefaults else {
            return nil
        }
        if let data = userDefaults.object(forKey: userDefaultsConfigurationStoreKey) as? Data {
            if let result = try? JSONDecoder().decode(SDKConfigurationUserDefaultsModel.self, from: data) {
                return result.toEntity()
            }
        }
        return nil
    }
    
    func save(data: SDKConfiguration) {
        guard let userDefaults = userDefaults else {
            return
        }
        let encoder = JSONEncoder()
        let userDefaultsModel = data.toUserDefaultsModel()
        if let encoded = try? encoder.encode(userDefaultsModel) {
            userDefaults.set(encoded, forKey: userDefaultsConfigurationStoreKey)
        }
    }
}
