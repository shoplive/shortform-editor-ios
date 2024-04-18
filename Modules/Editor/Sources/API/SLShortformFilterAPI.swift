//
//  SLShortformFilterAPI.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 2/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon

struct SLShortformFilterAPI : APIDefinition {
    typealias ResultType = SLShortformFilterResponse
    
    var baseUrl: String {
        ShortFormUploadConfigurationInfosManager.shared.getBaseUrl()
    }
    
    var method: SLHTTPMethod {
        return .get
    }
    
    var urlPath: String {
        if let accessKey = ShopLiveCommon.getAccessKey(), accessKey.isEmpty == false {
            return "sdk/v1/\(accessKey)/video/edit/filters"
        }
        else {
            return "sdk/v1/video/edit/filters"
        }
    }
    
    var parameters: [String : Any]?
    
    var showDebugLog: Bool {
        return true
    }
}
