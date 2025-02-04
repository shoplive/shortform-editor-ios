//
//  DeepLinkUseCase.swift
//  PlayerDemo2
//
//  Created by Tabber on 2/4/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import RxSwift

protocol DeepLinkUseCase {
    func executeCampaign(name: String, accessKey: String, campaignKey: String) async throws -> ShopLiveKeySet
    func loadCurrentCampaign() -> ShopLiveKeySet?
    func loadAllCampaigns() -> ShopLiveCampaignsKey?
    func saveCurrentCampaign(keySet: ShopLiveKeySet)
    func updateCampaign(keySet: ShopLiveKeySet)

    var updateNoti: Observable<Void> { get }
}

final class DefaultDeepLinkUseCase: DeepLinkUseCase {
    
    private let shopLiveKeySetRepository: ShopLiveKeySetRepository
    
    init(shopLiveKeySetRepository: ShopLiveKeySetRepository) {
        self.shopLiveKeySetRepository = shopLiveKeySetRepository
    }
    
    func loadCurrentCampaign() -> ShopLiveKeySet? {
        shopLiveKeySetRepository.loadCurrentCampaign()
    }
    
    func loadAllCampaigns() -> ShopLiveCampaignsKey? {
        shopLiveKeySetRepository.loadAllCampaigns()
    }
    
    func saveCurrentCampaign(keySet: ShopLiveKeySet) {
        shopLiveKeySetRepository.saveCurrentCampaign(keySet: keySet)
    }
    
    func updateCampaign(keySet: ShopLiveKeySet) {
        shopLiveKeySetRepository.updateCampaign(keySet: keySet)
    }
    
    var updateNoti: Observable<Void> {
        return shopLiveKeySetRepository.fetchUpdateObservable
    }
    
    func executeCampaign(name: String, accessKey: String, campaignKey: String) async throws -> ShopLiveKeySet {
        return try await shopLiveKeySetRepository.insertBroadCast(name: name, accessKey: accessKey, campaignKey: campaignKey)
    }
    
}
