//
//  SLShortformThumbnailAPI.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import UIKit



struct SLShortformThumbnailAPI : APIDefinition {
    typealias ResultType = SLShortsModel
    
    var image: String
    var imageData : UIImage
    var shortsId : String
    var fileName : String = "file"
    
    var showRequestLog: Bool = true
    
    var baseUrl: String {
        ShortFormUploadConfigurationInfosManager.shared.getBaseUrl()
    }
    
    var urlPath: String {
        if let accessKey = ShopLiveCommon.getAccessKey(), accessKey.isEmpty == false {
            return "sdk/v1/\(accessKey)/shortform/\(shortsId)/thumbnail"
        }
        else {
            return "sdk/v1/shortform/\(shortsId)/thumbnail"
        }
    }
    
    var method: SLHTTPMethod {
        .post
    }
    
    var uploadParameters: [String : Any] {
        var params: [String: Any] = [:]
        if let jpegData = imageData.jpegData(compressionQuality: 0.1) {
            params["imageData"] = jpegData
            params["imageFileName"] = fileName
        }
        return params
    }
    
    var parameters: [String : Any]? { nil }
    
}
