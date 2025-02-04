//
//  MainRepository.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/23/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import RxSwift

protocol ShopLiveKeySetRepository {
    func insertBroadCast(name: String, accessKey: String, campaignKey: String) async throws -> ShopLiveKeySet
    func loadCurrentCampaign() -> ShopLiveKeySet?
    func loadAllCampaigns() -> ShopLiveCampaignsKey?
    func saveCurrentCampaign(keySet: ShopLiveKeySet)
    func updateCampaign(keySet: ShopLiveKeySet)
    
    var fetchUpdateObservable: Observable<Void> { get }
}

final class DefaultShopLiveKeySetRepository: ShopLiveKeySetRepository {
    
    private var updateReplay = PublishSubject<Void>()
    
    private let shopLiveKeySetStorage: any AppUserDefaults<ShopLiveCampaignsKey>
    
    init(shopLiveKeySetStorage: any AppUserDefaults<ShopLiveCampaignsKey>) {
        self.shopLiveKeySetStorage = shopLiveKeySetStorage
    }
    
    func loadCurrentCampaign() -> ShopLiveKeySet? {
        let data = shopLiveKeySetStorage.get()
        guard let currentCampaign = data?.shopLiveKetSets.first(where: { $0.alias == data?.currentSelectKey ?? "" }) else { return nil }
        return currentCampaign
   }
    
    func loadAllCampaigns() -> ShopLiveCampaignsKey? {
        return shopLiveKeySetStorage.get()
    }
    
    func saveCurrentCampaign(keySet: ShopLiveKeySet) {
        
        var data = shopLiveKeySetStorage.get()
        
        data?.currentSelectKey = keySet.alias
        data?.shopLiveKetSets.append(keySet)
        
        guard let data = data else { return }
        shopLiveKeySetStorage.save(data: data)
        updateReplay.onNext(())
    }
    
    func updateCampaign(keySet: ShopLiveKeySet) {
        var data = shopLiveKeySetStorage.get()
        
        if let index = data?.shopLiveKetSets.firstIndex(where: { $0.alias == keySet.alias }) {
            data?.currentSelectKey = keySet.alias
            data?.shopLiveKetSets[index].accessKey = keySet.accessKey
            data?.shopLiveKetSets[index].campaignKey = keySet.campaignKey
        }
        
        guard let data else { return }
        shopLiveKeySetStorage.save(data: data)
        updateReplay.onNext(())
    }
    
    var fetchUpdateObservable: Observable<Void> {
        return updateReplay.asObservable()
    }
    
    func insertBroadCast(name: String, accessKey: String, campaignKey: String) async throws -> ShopLiveKeySet {
        ShopLiveKeySet(
            alias: name.trimmingCharacters(in: .whitespacesAndNewlines),
            campaignKey: campaignKey.trimmingCharacters(in: .whitespacesAndNewlines),
            accessKey: accessKey.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}
