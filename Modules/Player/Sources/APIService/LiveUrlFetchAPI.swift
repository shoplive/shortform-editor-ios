//
//  LiveUrlFetchAPI.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/19/23.
//

import Foundation
import ShopLiveSDKCommon
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
    
    var headers: [String : String] {
        var header : [String : String] = [:]
        header[CommonKeys.x_sl_player_app_version] = UIApplication.appVersion()
        header[CommonKeys.x_sl_player_sdk_version] = ShopLive.sdkVersion
        header[CommonKeys.x_sl_player_os_version] = ShopLiveDefines.osVersion
        header[CommonKeys.x_sl_player_os_type] = "i"
        return header
    }
}


