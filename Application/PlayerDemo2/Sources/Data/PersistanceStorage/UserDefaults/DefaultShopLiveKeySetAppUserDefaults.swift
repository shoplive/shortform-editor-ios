//
//  DefaultShopLiveKeySetAppUserDefaults.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/31/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

final class DefaultShopLiveKeySetAppUserDefaults: AppUserDefaults {
    typealias DataType = ShopLiveCampaignsKey
    private let userDefaultsShopLiveKeySetStoreKey = "userDefaultsShopLiveKeySetStoreKey"
    var suiteName: String
    
    lazy var userDefaults : UserDefaults? = {
        return UserDefaults(suiteName: suiteName)
    }()
    
    init(suiteName: String) {
        self.suiteName = suiteName
    }
    
    func get() -> ShopLiveCampaignsKey? {
        guard let userDefaults else {
            return nil
        }
        
        if let data = userDefaults.object(forKey: userDefaultsShopLiveKeySetStoreKey) as? Data {
            if let result = try? JSONDecoder().decode(ShopLiveCampaignsKeyUserDefaultsModel.self, from: data) {
                return result.toEntity()
            }
        }
        
        return nil
    }
    
    func save(data: ShopLiveCampaignsKey) {
        guard let userDefaults else {
            return
        }
        
        let encoder = JSONEncoder()
        let userDefaultsModel = data.toUserDefaultsModel()
        if let encoded = try? encoder.encode(userDefaultsModel) {
            userDefaults.set(encoded, forKey: userDefaultsShopLiveKeySetStoreKey)
        }
    }
}
