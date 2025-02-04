//
//  CampaignsRepository.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/24/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation


protocol CampaignsRepository<DataType> {
    associatedtype DataType
    func excute(keySet: DataType)
    func getKeySet() -> DataType?
}

final class DefaultCampaignsRepository: CampaignsRepository {
    
    private let userDefaultsStorage: any AppUserDefaults<ShopLiveCampaignsKey>
    
    init(userDefaultsStorage: any AppUserDefaults<ShopLiveCampaignsKey>) {
        self.userDefaultsStorage = userDefaultsStorage
    }

    func excute(keySet: ShopLiveCampaignsKey) {
        self.userDefaultsStorage.save(data: keySet)
    }
    
    func getKeySet() -> ShopLiveCampaignsKey? {
        self.userDefaultsStorage.get()
    }
}
