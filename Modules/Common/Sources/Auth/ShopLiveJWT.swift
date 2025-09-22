//
//  ShopLiveJWT.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2023/05/23.
//

import Foundation

class ShopLiveJWT {
    typealias Header = [String: Any]
    typealias Payload = [String: Any]
    
    static func make(accessKey: String, userData: ShopLiveCommonUser, iat: Double? = nil) -> String? {
        var dict = userData.toDictionary()
        var payLoad: Payload = [ "accessKey": accessKey ]
        if let iat = iat {
            payLoad["iat"] = iat
        }
        dict.removeValue(forKey: "custom")
        for (key,value) in dict {
            payLoad[key] = value
        }
        return make(payload: payLoad)
    }
    
    
    
    static func make(header: Header, payload: Payload ) -> String? {
        guard var header64BaseEncoded = header.toJson_SL()?.base64Encoded_SL else { return nil }
        header64BaseEncoded = header64BaseEncoded.replacingOccurrences(of: "=", with: "")
        var payLoad = payload
        if payLoad.keys.contains(where: { $0 == "iat" }) == false {
            payLoad["iat"] = Int(Date().timeIntervalSince1970)
        }
        guard var payload64BaseEncoded = payLoad.toJson_SL()?.base64Encoded_SL else { return nil }
        payload64BaseEncoded = payload64BaseEncoded.replacingOccurrences(of: "=", with: "")
        
        return "\(header64BaseEncoded).\(payload64BaseEncoded)."
    }
    
    
    static func make(payload: Payload) -> String? {
        return make(header: ["typ": "JWT"], payload: payload)
    }
    
}

