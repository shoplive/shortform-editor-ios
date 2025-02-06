//
//  MainRepositoryMock.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/23/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
@testable import PlayerDemo2
@testable import RxSwift



class MockMainRepository: ShopLiveKeySetRepository {
    func loadCurrentCampaign() -> PlayerDemo2.ShopLiveKeySet? {
        return nil
    }
    
    func loadAllCampaigns() -> PlayerDemo2.ShopLiveCampaignsKey? {
        return nil
    }
    
    func saveCurrentCampaign(keySet: PlayerDemo2.ShopLiveKeySet) {
        
    }
    
    func updateCampaign(keySet: PlayerDemo2.ShopLiveKeySet) {
        
    }
    
    var fetchUpdateObservable: RxSwift.Observable<Void> {
        return Observable<Void>.create { seal in
            seal.onNext(())
            return Disposables.create {

            }
        }
    }
    
    var shouldFail = false
    var mockKeySet: ShopLiveKeySet?
    
    func insertBroadCast(name: String, accessKey: String, campaignKey: String) async throws -> ShopLiveKeySet {
        if shouldFail {
            throw NSError(domain: "Test", code: -1)
        }
        
        return mockKeySet ??  ShopLiveKeySet.init(alias: name,
                                                  campaignKey: campaignKey,
                                                  accessKey: accessKey)
    }
}
