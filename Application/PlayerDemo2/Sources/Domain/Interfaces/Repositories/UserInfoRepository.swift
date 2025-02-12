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
    func loadSDKConfiguration() -> SDKConfiguration?
    func loadUserMode() -> UserMode?
    
    func fetchUser(userId: String?, userName: String?, age: String?, userScore: String?, gender: ShopliveCommonUserGender?) async throws -> ShopLiveCommonUser
    func fetchUserData(user: ShopLiveCommonUser?, userToken: String?)
    func fetchUserMode(userMode: UserMode)
    func fetchLandingUrl(url: String)
    func fetchVersionInfoDatas(type: VersionInfoButtonType, value: String)
    
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
    
    func loadSDKConfiguration() -> SDKConfiguration? {
        userDefaultsStorage.get()
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

    func fetchLandingUrl(url: String) {
        var currentData = userDefaultsStorage.get()
        
        currentData?.customLandingUrl = url
        
        guard let currentData else { return }
        userDefaultsStorage.save(data: currentData)
    }
    
    func fetchVersionInfoDatas(type: VersionInfoButtonType, value: String) {
        var currentData = userDefaultsStorage.get()
        
        switch type {
        case .AppVersion:
            currentData?.customerAppVersion = value
        case .Referrer:
            currentData?.referrer = value
        case .AdId:
            currentData?.adId = value
        case .AnonId:
            currentData?.anonId = value
        case .UtmSource:
            currentData?.utmSource = value
        case .UtmContent:
            currentData?.utmContent = value
        case .UtmCampaign:
            currentData?.utmCampaign = value
        case .UtmMedium:
            currentData?.utmMedium = value
        default:
            break
        }
        
        guard let currentData else { return }
        userDefaultsStorage.save(data: currentData)
    }
}
