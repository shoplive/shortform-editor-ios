//
//  SLShortformUploadAPI.swift
//  shortform-upload
//
//  Created by 김우현 on 5/17/23.
//

import Foundation
import ShopliveSDKCommon
import UIKit


struct SLShortformVideoAPI: APIDefinition {
    typealias ResultType = SLUploadResponse
    
    var apiEndpoint: String
    
    var image: String?
    var video: String
    var imageData : UIImage?
    var videoFileName: String = ""
    var sessionSecret: String
    
    var showRequestLog: Bool = false
    var showResponseLog: Bool = false
    
    var baseUrl: String {
        ShortFormUploadConfigurationInfosManager.shared.getBaseUrl()
    }
    
    var urlPath: String {
        if let accessKey = ShopLiveCommon.getAccessKey(), accessKey.isEmpty == false {
            return "sdk/v1/\(accessKey)/shortform/video"
        }
        else {
            return "sdk/v1/shortform/video"
        }
    }
    
    var method: SLHTTPMethod {
        .post
    }
    
    var uploadParameters: [String : Any] {
        var params: [String: Any] = [:]
        if let imgString = image, let imageUrl = URL(string: imgString) {
            params["image"] = imageUrl
        }
        else if let imageData = imageData {
            params["imageData"] = imageData.jpegData(compressionQuality: 0.1)
        }
        
        let videoUrl = URL(fileURLWithPath: video)
        params["video"] = (path: videoUrl, name: videoFileName)
        
        params["sessionSecret"] = sessionSecret
        return params
    }
    
    var parameter: [String : Any]? {
        return nil
    }
    
}
