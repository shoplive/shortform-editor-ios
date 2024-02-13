//
//  UserObject.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 3/8/23.
//

import Foundation

extension ShopLiveShortform {
    struct UserObject: Codable {
        var userId: String?
        var userName: String?
    }
}

extension ShopLiveShortform.UserObject {
    var jwtToken: String? {
        guard var userDictionary = self.dictionary_SL else { return nil }
        
        userDictionary["ak"] = ShortFormAuthManager.shared.getAccessKey() ?? ""
        
        guard let jwt = JWTTool.makeJWT(from: userDictionary) else { return nil }
        
        return jwt
    }
}

extension [String: Any] {
    var jwtToken: String? {
        guard let jwt = JWTTool.makeJWT(from: self) else { return nil }
        return jwt
    }
}
