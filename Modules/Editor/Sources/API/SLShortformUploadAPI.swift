//
//  SLShortformUploadAPI.swift
//  shortform-upload
//
//  Created by 김우현 on 5/17/23.
//

import Foundation
import ShopLiveSDKCommon

struct SLShortformUploadAPI: APIDefinition {
    typealias ResultType = SLUploadResponse
    
    var apiEndpoint: String
    
    var image: String
    var video: String
    var videoFileName: String = ""
    var sessionSecret: String
    
    var baseUrl: String {
        apiEndpoint
    }
    
    var urlPath: String {
        return "/shorts/video"
    }
    
    var method: SLHTTPMethod {
        .post
    }
    
    var uploadParameters: [String : Any] {
        var params: [String: Any] = [:]
        if let imageUrl = URL(string: image) {
            params["image"] = imageUrl
        }
        
        if let videoUrl = URL(string: video) {
            params["video"] = (path: videoUrl, name: videoFileName)
        }
        
        params["sessionSecret"] = sessionSecret
        return params
    }
    
    var parameter: [String : Any]? {
        return nil
    }
    
}
