//
//  ShopliveCeId.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 4/2/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation

struct ShopliveCeId {
    
    
    static func makeShopliveCeId() -> String {
        
        let currentMilliSeconds = Date().timeIntervalSince1970 * 1000 // 현재 시간 current milliseconds로
        
        let prefix = String(Int(currentMilliSeconds) ,radix: 36)
        let suffix = Self.generateRandomString(length: 16)
        
        return prefix + suffix
    }
    
    
    static func generateRandomString(length: Int) -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        var randomString = ""

        for _ in 0..<length {
            let randomIndex = Int(arc4random_uniform(UInt32(characters.count)))
            let randomCharacter = characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
            randomString.append(randomCharacter)
        }

        return randomString
    }
    
}
