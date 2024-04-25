//
//  ShopLiveConversionEventAPI.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 4/12/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation


struct ShopLiveConversionEventAPI : APIDefinition {
    typealias ResultType = ShopLiveEventRequest
    
    static var baseurl : String = "https://dev-capi.shoplive.cloud/v2"
    
    var baseUrl: String {
        return Self.baseurl
    }
    
    var urlPath: String {
        if let accessKey = ShopLiveCommon.getAccessKey() {
            return "/v2/\(accessKey)" + "/conversion/event"
        }
        else {
            return "/v2/conversion/event"
        }
    }
    
    var method: SLHTTPMethod {
        .post
    }
    
    var parameters: [String : Any]? {
        var params : [String : Any] = [:]
        if let anonId = anonId {
            params["anonId"] = anonId
        }
        if let custom = custom {
            params["custom"] = custom
        }
        if let env = env {
            params["env"] = env
        }
        if let ceId = ceId {
            params["ceId"] = ceId
        }
        if let idfv = idfv {
            params["idfv"] = idfv
        }
        if let idfa = idfa {
            params["idfa"] = idfa
        }
        if let osType = osType {
            params["osType"] = osType
        }
        
        if let products = products, products.isEmpty == false {
            do {
                var temp : [[String:Any]] = []
                for item in products {
                    let jsonData = try JSONEncoder().encode(item)
                    if let dict = try JSONSerialization.jsonObject(with: jsonData,options: .allowFragments) as? [String : Any] {
                        temp.append(dict)
                    }
                }
                params["products"] = temp
            }
            catch(let error) {
                ShopLiveLogger.debugLog("error \(error)")
            }
        }
        
        if let referrer = referrer {
            params["referrer"] = referrer
        }
        if let type = type {
            params["type"] = type
        }
        if let userId = userId {
            params["userId"] = userId
        }
        if let orderId = orderId {
            params["orderId"] = orderId
        }
        if let createdAt = createdAt {
            params["createdAt"] = createdAt
        }
        return params
    }
    
    
    var anonId : String?
    var custom : String?
    var env : String?
    var ceId : String?
    var idfv : String?
    var idfa : String?
    var osType : String?
    var products : [ShopLiveEventProduct]?
    var referrer : String?
    var type : String?
    var userId : String?
    var orderId : String?
    var createdAt : Int?
    
}
