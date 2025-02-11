//
//  UserInfoRepositoryMock.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/23/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
@testable import PlayerDemo2

class MockUserInfoRepository: UserInfoRepository {
    
    let userDefaults: any AppUserDefaults<SDKConfiguration>
    
    var shouldFail = false
    var mockUser: ShopLiveCommonUser?
    
    init(userDefaults: any AppUserDefaults<SDKConfiguration>) {
        self.userDefaults = userDefaults
    }
    
    func loadUserData() -> (ShopliveSDKCommon.ShopLiveCommonUser?, String?) { (nil, nil) }
    
    func fetchUserData(user: ShopliveSDKCommon.ShopLiveCommonUser?, userToken: String?) {}
    
    func fetchUserMode(userMode: PlayerDemo2.UserMode) {}
    
    func loadUserMode() -> PlayerDemo2.UserMode? { nil }
    
    func fetchUser(userId: String?, userName: String?, age: String?, userScore: String?, gender: ShopliveCommonUserGender?) async throws -> ShopLiveCommonUser {
        if shouldFail {
            throw NSError(domain: "Test", code: -1)
        }
        
        return mockUser ?? ShopLiveCommonUser(userId: "dsa")
    }
}
