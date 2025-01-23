//
//  UserInfoUseCase.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/22/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import ShopLiveSDK

protocol UserInfoUseCase {
    func execute(userId: String?, userName: String?, age: String?, userScore: String?, gender: ShopliveCommonUserGender?) async throws -> ShopLiveCommonUser
}

final class DefaultUserInfoUseCase: UserInfoUseCase {
    private let repository: UserInfoRepository
    
    init(repository: UserInfoRepository) {
        self.repository = repository
    }
    
    func execute(userId: String?, userName: String?, age: String?, userScore: String?, gender: ShopliveCommonUserGender?) async throws -> ShopLiveCommonUser {
        return try await repository.fetchUser(userId: userId, userName: userName, age: age, userScore: userScore, gender: gender)
    }
    
}
