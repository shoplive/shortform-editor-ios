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
    func loadSDKConfiguration() -> SDKConfiguration?
    func loadUserMode() -> UserMode?
    
    func updateCampaign(keySet: ShopLiveKeySet)
    func saveCurrentCampaign(keySet: ShopLiveKeySet)
    func fetchUserMode(userMode: UserMode)
    func fetchLandingUrl(url: String)

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
    
    func loadSDKConfiguration() -> SDKConfiguration? {
        userInfoRepository.loadSDKConfiguration()
    }
    
    func loadUserMode() -> UserMode? {
        userInfoRepository.loadUserMode()
    }
    
    func fetchUserMode(userMode: UserMode) {
        userInfoRepository.fetchUserMode(userMode: userMode)
    }
    
    func fetchLandingUrl(url: String) {
        userInfoRepository.fetchLandingUrl(url: url)
    }
    
    func executeCampaign(name: String, accessKey: String, campaignKey: String) async throws -> ShopLiveKeySet {
        return try await shopLiveKeySetRepository.insertBroadCast(name: name, accessKey: accessKey, campaignKey: campaignKey)
    }
}

