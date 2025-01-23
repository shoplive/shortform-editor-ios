//
//  MainUseCase.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/23/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

protocol MainUseCase {
    func executeCampaign(name: String, accessKey: String, campaignKey: String) async throws -> ShopLiveKeySet
}

final class DefaultMainUseCase: MainUseCase {
    private let mainRepository: MainRepository
    
    init(mainRepository: MainRepository) {
        self.mainRepository = mainRepository
    }
    
    func executeCampaign(name: String, accessKey: String, campaignKey: String) async throws -> ShopLiveKeySet {
        return try await mainRepository.insertBroadCast(name: name, accessKey: accessKey, campaignKey: campaignKey)
    }
}

