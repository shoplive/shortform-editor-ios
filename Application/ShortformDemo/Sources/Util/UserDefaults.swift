//
//  UserDefaults.swift
//  ShortformDemo
//
//  Created by sangmin han on 2/27/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon

@propertyWrapper
struct UserDefault<T> {
    private let key: String
    private let defaultValue: T

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue 
    }

    var wrappedValue: T {
        get {
            // Read value from UserDefaults
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            // Set value to UserDefaults
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

enum DefaultsKey: String {
    case customAccessKey = "customAccessKey"
    case userId = "userId"
    case userName = "userName"
    case userAge = "userAge"
    case userGender = "userGender"
    case userScore = "userScore"
}

struct Defaults {
    @UserDefault(key: DefaultsKey.customAccessKey.rawValue, defaultValue: "")
    static var customAccessKey: String
    
    @UserDefault(key: DefaultsKey.userId.rawValue, defaultValue: "testiOSUser")
    static var userId : String
    
    @UserDefault(key: DefaultsKey.userName.rawValue, defaultValue: "testiOSUser")
    static var userName : String
    
    @UserDefault(key: DefaultsKey.userAge.rawValue, defaultValue: 10)
    static var userAge : Int
    
    @UserDefault(key: DefaultsKey.userGender.rawValue, defaultValue: "m")
    static var userGender : String
    
    @UserDefault(key: DefaultsKey.userScore.rawValue, defaultValue: 0)
    static var userScore : Int
    
}
