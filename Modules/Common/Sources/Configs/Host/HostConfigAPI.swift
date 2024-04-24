//
//  HostConfigAPI.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 4/23/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import os

struct HostConfigAPI : APIDefinition {
    typealias ResultType = HostConfigModel
    
    
    var baseUrl: String {
        return "https://config.shoplive.cloud"
    }
    var urlPath: String {
        if let accessKey = ShopLiveCommon.getAccessKey() {
            return "/\(accessKey)/hosts.json"
        }
        else {
            os_log("[Shoplive] accessKey not defined, please contact ask@shoplive.cloud for information", type: .error)
            return "/hosts.json"
        }
    }
    
    var method: SLHTTPMethod {
        return .get
    }
    
}

