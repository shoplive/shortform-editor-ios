//
//  SLShortformRegisterAPI.swift
//  shortform-upload
//
//  Created by 김우현 on 5/17/23.
//

import Foundation
import ShopliveSDKCommon


struct SLShortformRegisterAPI: APIDefinition {
    typealias ResultType = ShortsModel
    
    var showRequestLog: Bool = false
    var showResponseLog: Bool = false
    
    var baseUrl: String {
        ShortFormUploadConfigurationInfosManager.shared.getBaseUrl()
    }
    
    var urlPath: String {
        if let accessKey = ShopLiveCommon.getAccessKey(), accessKey.isEmpty == false {
            return "sdk/v1/\(accessKey)/shortform"
        }
        else {
            return "sdk/v1/shortform"
        }
    }
    
    var method: SLHTTPMethod {
        .post
    }
    
    var parameters: [String : Any]?
    
}
