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
    func loadUserData() -> (ShopLiveCommonUser?, String?)
    func fetchUser(userId: String?, userName: String?, age: String?, userScore: String?, gender: ShopliveCommonUserGender?) async throws -> ShopLiveCommonUser
    func fetchUserData(user: ShopLiveCommonUser?, userToken: String?)
    func fetchUserMode(userMode: UserMode)
    func loadUserMode() -> UserMode?
    
}

final class DefaultUserInfoRepository: UserInfoRepository {
    
    private let userDefaultsStorage: any AppUserDefaults<SDKConfiguration>
    
    init(userDefaultsStorage: any AppUserDefaults<SDKConfiguration>) {
        self.userDefaultsStorage = userDefaultsStorage
    }
    
    func loadUserData() -> (ShopLiveCommonUser?, String?) {
        let data = userDefaultsStorage.get()
        return (data?.user, data?.jwtToken)
    }
    
    func loadUserMode() -> UserMode? {
        let data = userDefaultsStorage.get()
        return data?.userMode
    }
    
    func fetchUserData(user: ShopLiveCommonUser?, userToken: String?) {
        
        var currentData = userDefaultsStorage.get()
        
        currentData?.user = user
        currentData?.jwtToken = userToken
        
        guard let currentData else { return }
        
        userDefaultsStorage.save(data: currentData)
    }
    
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
    
    func fetchUserMode(userMode: UserMode) {
        var currentData = userDefaultsStorage.get()
        
        currentData?.userMode = userMode
        currentData?.isGuestMode = userMode.isGuestMode
        currentData?.useJWTToken = userMode.useJWT
        
        guard let currentData else { return }
        userDefaultsStorage.save(data: currentData)
    }
}
