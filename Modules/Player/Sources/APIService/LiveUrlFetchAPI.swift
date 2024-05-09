//
//  LiveUrlFetchAPI.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/19/23.
//

import Foundation
import ShopliveSDKCommon
import UIKit


struct LiveUrlFetchAPI : APIDefinition {
    typealias ResultType = LiveFetchUrlModel
    
    private var campaignKey : String = ""
    
    init(campaignKey : String){
        self.campaignKey = campaignKey
    }
    
    
    var baseUrl: String {
       return "https://config.shoplive.cloud"
    }
    
    var urlPath: String {
        return "/\(ShopLiveCommon.getAccessKey() ?? "unknown")/live/\(self.campaignKey).json"
    }
    
    var method: SLHTTPMethod {
        return .get
    }
    
    var showResponseLog: Bool {
        return true
    }
    
}


