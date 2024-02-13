//
//  JWTTool.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 3/8/23.
//

import Foundation

class JWTTool {
    /*
     let jwtItem: [String: Any] = [
         "ak": "mtGKdqO2rqw68T8YyJp1",
         "test": "testItem",
         "userId": "Vincent",
         "name": "Vincent Name",
         "gender": "m",
         "age": "25",
         "exp": 1680678546,
         "iat": 1678086546,
     ]

     let jwtHeaderItem: [String: Any] = [
         "typ": "JWT"
     ]
     
     guard let jwt = jwtItem.toJson()?.base64Encoded else { return }
     guard let jwtHeader = jwtHeaderItem.toJson()?.base64Encoded else { return }
     // print("\(jwtHeader).\(jwt)")
     */
    static func makeJWT(from: [String: Any]?) -> String? {
        guard var fromValue = from else { return nil }
        
        fromValue["iat"] = Date().timeIntervalSince1970
        
        let jwtHeaderItem: [String: Any] = [
            "typ": "JWT"
        ]
        
        guard let jwt = fromValue.toJson_SL()?.base64Encoded_SL else { return nil }
        guard let jwtHeader = jwtHeaderItem.toJson_SL()?.base64Encoded_SL else { return nil }
        
        return "\(jwtHeader).\(jwt).".removeJWTPadding_SL()
    }
    
}
