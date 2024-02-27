//
//  UserDefaults.swift
//  ShortformDemo
//
//  Created by sangmin han on 2/27/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation

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
}

struct Defaults {
    @UserDefault(key: DefaultsKey.customAccessKey.rawValue, defaultValue: "")
    static var customAccessKey: String
}
