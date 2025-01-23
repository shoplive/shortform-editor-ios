//
//  JWTTool.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/21/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import ShopLiveSDK
import ShopliveSDKCommon

/*

class JWTTool {
    static let config = DemoConfiguration.shared

    static var secretKey: String? {
        return DemoSecretKeyTool.shared.currentKey()?.key
    }

    static func makeJWT(user: ShopLiveCommonUser) -> String? {
        guard let secret = secretKey?.base64Decoded?.data(using: .utf8) else { return nil }
//        let secret = "ckFXaWtRWENtSTA2QnpGVmxWNlBySWF4cUk1Q1pxbHU=".base64Decoded!.data(using: .utf8)!
        var claims = ClaimSet()
        claims.expiration = Date(timeIntervalSinceNow:  60 * 60 * 12)
        claims.issuedAt = Date()
        claims["userId"] = user.userId

        if let name = user.userName {
            claims["userName"] = name
        }

        if let gender = user.gender?.rawValue, gender == "f" || gender == "m" {
            claims["gender"] = gender
        }

        if let age = user.age {
            claims["age"] = age
        }

        if let userScore = user.userScore {
            claims["userScore"] = userScore
        }

        let jwt = SwiftyJWT.encode(claims: claims, algorithm: .hs256(secret))
        
        return jwt
    }

    static var jwtToken: String? {
        guard let secret = secretKey?.base64Decoded?.data(using: .utf8) else { return nil }
//        let secret = "ckFXaWtRWENtSTA2QnpGVmxWNlBySWF4cUk1Q1pxbHU=".base64Decoded!.data(using: .utf8)!
        var claims = ClaimSet()
        claims.expiration = Date(timeIntervalSinceNow:  60 * 60 * 12)
        claims.issuedAt = Date()
        if let userId = config.userId {
            claims["userId"] = userId
        }

        if let name = config.userName {
            claims["userName"] = name
        }

        if let gender = config.userGender?.rawValue, gender == "f" || gender == "m" {
            claims["gender"] = gender
        }

        if let age = config.userAge {
            claims["age"] = age
        }

        if let userScore = config.userScore {
            claims["userScore"] = userScore
        }

        let jwt = SwiftyJWT.encode(claims: claims, algorithm: .hs256(secret))
        return jwt
    }

}

*/
