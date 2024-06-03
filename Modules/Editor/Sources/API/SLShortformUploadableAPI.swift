//
//  ShortformUploadAPI.swift
//  shortform-upload
//
//  Created by 김우현 on 5/16/23.
//

import Foundation
import ShopliveSDKCommon

struct SLShortformUploadableAPI: APIDefinition {
    typealias ResultType = SLUploadableResponse
    
    var baseUrl: String {
        return ShortFormUploadConfigurationInfosManager.shared.getBaseUrl()
    }
    
    var showRequestLog: Bool = true
    var showResponseLog: Bool = true
    
    
    var urlPath: String {
        if let accessKey = ShopLiveCommon.getAccessKey(), accessKey.isEmpty == false {
            return "sdk/v1/\(accessKey)/shorts/uploadable"
        }
        else {
            return "sdk/v1/shorts/uploadable"
        }
    }

    var method: SLHTTPMethod {
        .get
    }
    
    var parameter: [String : Any]? {
        return nil
    }
    
}

