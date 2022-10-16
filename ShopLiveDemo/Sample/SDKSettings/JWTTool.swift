//
//  JWTTool.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/19.
//

import Foundation
import SwiftyJWT
#if SDK_MODULE
import ShopLiveSDK
#endif

class JWTTool {
    static let config = DemoConfiguration.shared

    static var secretKey: String? {
        return DemoSecretKeyTool.shared.currentKey()?.key
    }

    static func makeJWT(user: ShopLiveUser) -> String? {
        guard let secret = secretKey?.base64Decoded?.data(using: .utf8) else { return nil }
//        let secret = "ckFXaWtRWENtSTA2QnpGVmxWNlBySWF4cUk1Q1pxbHU=".base64Decoded!.data(using: .utf8)!
        var claims = ClaimSet()
        claims.expiration = Date(timeIntervalSinceNow:  60 * 60 * 12)
        claims.issuedAt = Date()
        if let userId = user.id {
            claims["userId"] = userId
        }

        if let name = user.name {
            claims["name"] = name
        }

        if let gender = user.gender?.description, gender == "f" || gender == "m" {
            claims["gender"] = gender
        }

        if let age = user.age {
            claims["age"] = age
        }

        if let userScore = user.getParams().first(where: {$0.key == "userScore"})?.value, let score = Int(userScore) {
            claims["userScore"] = score
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
            claims["name"] = name
        }

        if let gender = config.userGender?.description, gender == "f" || gender == "m" {
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
