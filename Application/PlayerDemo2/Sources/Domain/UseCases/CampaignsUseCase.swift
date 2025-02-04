//
//  CampaignsUseCase.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/24/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

protocol CampaignsUseCase {
    func applyKetSet(keySet: ShopLiveCampaignsKey)
    func getKeySet() -> ShopLiveCampaignsKey?
}

final class DefaultCampaignsUseCase: CampaignsUseCase {
    private let campaignsRepository: any CampaignsRepository<ShopLiveCampaignsKey>
    
    init(campaignsRepository: any CampaignsRepository<ShopLiveCampaignsKey>) {
        self.campaignsRepository = campaignsRepository
    }
    
    func applyKetSet(keySet: ShopLiveCampaignsKey) {
        campaignsRepository.excute(keySet: keySet)
    }
    
    func getKeySet() -> ShopLiveCampaignsKey? {
        return campaignsRepository.getKeySet()
    }
}

class CampaignsUseCaseMock: CampaignsUseCase {
    
    private var keySet: ShopLiveCampaignsKey = .init(currentSelectKey: "", shopLiveKetSets: [])
    
    var excuteCallCount: Int = 0
    
    func applyKetSet(keySet: ShopLiveCampaignsKey) {
        excuteCallCount += 1
        self.keySet = keySet
    }
    
    func getKeySet() -> ShopLiveCampaignsKey? {
        excuteCallCount += 1
        return self.keySet
    }
}
