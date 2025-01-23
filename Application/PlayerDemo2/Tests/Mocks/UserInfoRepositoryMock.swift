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

class MockUserRepository: UserInfoRepository {
    var shouldFail = false
    var mockUser: ShopLiveCommonUser?
    
    func fetchUser(userId: String?, userName: String?, age: String?, userScore: String?, gender: ShopliveCommonUserGender?) async throws -> ShopLiveCommonUser {
        if shouldFail {
            throw NSError(domain: "Test", code: -1)
        }
        
        return mockUser ?? ShopLiveCommonUser(userId: "dsa")
    }
}
