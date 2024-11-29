//
//  ShortsIdsListAPI.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/30/23.
//

import Foundation
import ShopliveSDKCommon
import UIKit

struct ShortsIdsListAPI: APIDefinition {
    typealias ResultType = SLShortsCollectionModel
    
    var baseUrl: String {
        ShortFormConfigurationInfosManager.shared.shortsConfiguration.shortformApiEndpoint
    }
    
    var urlPath: String {
        if let ak = ShopLiveCommon.getAccessKey(), ak.isEmpty == false {
            return "/sdk/v1/\(ak)/shortform/ids"
        }
        else {
            return "/sdk/v1/shortform/ids"
        }
    }
    
    var method: SLHTTPMethod {
        .get
    }
    
    var headers: [String : String] {
        var header : [String : String] = [:]
        header[CommonKeys.x_sl_player_app_version] = UIApplication.appVersion_SL()
        header[CommonKeys.x_sl_player_sdk_version] = ShopLiveShortform.sdkVersion
        header[CommonKeys.x_sl_player_os_version] = UIDevice.current.systemVersion
        header[CommonKeys.x_sl_player_os_type] = "i"
        return header
    }
    
    
    var parameters: [String : Any]? {
        var params: [String: Any] = [:]
        if let accessKey = ShortFormAuthManager.shared.getAccessKey() {
            params["accessKey"] = accessKey
        }
        
        if let ids = ids {
            params["ids"] = ids.joined(separator: ",")
        }
        params["keepEmpty"] = true
        
        return params
    }
    
    var parameter: [String : Any]? {
        return nil
    }
    
    var ids : [String]?

    
}
