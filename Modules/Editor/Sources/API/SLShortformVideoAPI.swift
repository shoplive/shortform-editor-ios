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
    
    var videoWidth : CGFloat?
    var videoHeight : CGFloat?
    var videoDuration : Double?
    
    var showRequestLog: Bool = false
    var showResponseLog: Bool = false
    
    var baseUrl: String {
        return apiEndpoint
    }
    
    var urlPath: String {
        return ""
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
        
        if let videoWidth = videoWidth {
            params["videoWidth"] = videoWidth
        }
        if let videoHeight = videoHeight {
            params["videoHeight"] = videoHeight
        }
        if let videoDuration = videoDuration {
            params["videoDuration"] = videoDuration
        }
        return params
    }
    
    var parameter: [String : Any]? {
        return nil
    }
    
}
