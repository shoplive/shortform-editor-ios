//
//  UserInfoRepository.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/22/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopliveSDKCommon

protocol UserInfoRepository {
    func fetchUser(userId: String?, userName: String?, age: String?, userScore: String?, gender: ShopliveCommonUserGender?) async throws -> ShopLiveCommonUser
}

final class DefaultUserInfoRepository: UserInfoRepository {
    func fetchUser(userId: String?, userName: String?, age: String?, userScore: String?, gender: ShopliveCommonUserGender?) async throws -> ShopLiveCommonUser {
        
        var value: ShopLiveCommonUser = .init(userId: userId ?? "")
        
        if let userName {
            value.userName = userName
        }
        
        if let age {
            value.age = Int(age)
        }
        
        if let userScore {
            value.userScore = Int(userScore)
        }
        
        if let gender {
            value.gender = gender
        }
        
        return value
    }
}
