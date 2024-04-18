//
//  ShortformUploadAPI.swift
//  shortform-upload
//
//  Created by 김우현 on 5/16/23.
//

import Foundation
import ShopliveSDKCommon

struct SLShortformUploadCheckAPI: APIDefinition {
    typealias ResultType = SLUploadableResponse
    
    var baseUrl: String {
        ShortFormUploadConfigurationInfosManager.shared.getBaseUrl()
    }
    
    
    var urlPath: String {
        "/shorts/uploadable"
    }

    var method: SLHTTPMethod {
        .get
    }
    
    var parameter: [String : Any]? {
        return nil
    }
    
}

