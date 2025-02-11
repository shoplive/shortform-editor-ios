//
//  MainUseCase.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/23/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import RxSwift
import ShopliveSDKCommon

protocol MainUseCase {
    func executeCampaign(name: String, accessKey: String, campaignKey: String) async throws -> ShopLiveKeySet
    func loadCurrentCampaign() -> ShopLiveKeySet?
    func loadAllCampaigns() -> ShopLiveCampaignsKey?
    func saveCurrentCampaign(keySet: ShopLiveKeySet)
    func updateCampaign(keySet: ShopLiveKeySet)
    func loadUserInfo() -> (ShopLiveCommonUser?, String?)
    func loadUserMode() -> UserMode?
    func fetchUserMode(userMode: UserMode)

    var updateNoti: Observable<Void> { get }
}

final class DefaultMainUseCase: MainUseCase {
    private let shopLiveKeySetRepository: ShopLiveKeySetRepository
    private let userInfoRepository: UserInfoRepository
    
    init(shopLiveKeySetRepository: ShopLiveKeySetRepository, userInfoRepository: UserInfoRepository) {
        self.shopLiveKeySetRepository = shopLiveKeySetRepository
        self.userInfoRepository = userInfoRepository
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
    
    func loadUserInfo() -> (ShopLiveCommonUser?, String?) {
        userInfoRepository.loadUserData()
    }
    
    func loadUserMode() -> UserMode? {
        userInfoRepository.loadUserMode()
    }
    
    func fetchUserMode(userMode: UserMode) {
        userInfoRepository.fetchUserMode(userMode: userMode)
    }
    
    func executeCampaign(name: String, accessKey: String, campaignKey: String) async throws -> ShopLiveKeySet {
        return try await shopLiveKeySetRepository.insertBroadCast(name: name, accessKey: accessKey, campaignKey: campaignKey)
    }
}

