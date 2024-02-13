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
    
    var baseUrl: String {
        ShortFormUploadConfigurationInfosManager.shared.getBaseUrl()
    }
    
    var urlPath: String {
        "/shorts"
    }
    
    var method: SLHTTPMethod {
        .post
    }
    
    var parameters: [String : Any]?
}
