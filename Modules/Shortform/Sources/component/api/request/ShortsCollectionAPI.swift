//
//  ShortsCollectionAPI.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/27/23.
//

import Foundation
import ShopliveSDKCommon
import UIKit

struct ShortsCollectionAPI: APIDefinition {
    typealias ResultType = ShortsCollectionModel
    
    var baseUrl: String {
        let shortformApiEndPoint = ShortFormConfigurationInfosManager.shared.shortsConfiguration.shortformApiEndpoint
        if shortformApiEndPoint != "" {
            return shortformApiEndPoint
        }
        else {
            return ""
        }
    }
    
    var urlPath: String {
        if let ak = ShopLiveCommon.getAccessKey(), ak.isEmpty == false {
            return "/sdk/v1/\(ak)/shortform/collection"
        }
        else {
            return "/sdk/v1/shortform/collection"
        }
    }
    
    
    var method: SLHTTPMethod {
        .post
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
        params["count"] = count
        
        if let accessKey = ShortFormAuthManager.shared.getAccessKey() {
            params["accessKey"] = accessKey
        }
       
        if let reference = reference, reference.isEmpty == false {
            params["reference"] = reference
        }
        if let shortsId = shortsId {
            params["shortsId"] = shortsId
        }
        if let shortsCollectionsId = shortsCollectionsId {
            params["shortsCollectionId"] = shortsCollectionsId
        }
        
        if let tags = tags {
            params["tags"] = tags
        }
        if let tagSearchOperator = tagSearchOperator {
            params["tagSearchOperator"] = tagSearchOperator
        }
        if let brands = brands {
            params["brands"] = brands
        }
        if let shuffle = shuffle {
            params["shuffle"] = shuffle
        }
        if let type = type {
            params["type"] = type
        }
        
        if let finite = finite {
            params["finite"] = finite
        }
        
        if let skus = skus {
            params["skus"] = skus
        }
        
        return params
    }
    
    var parameter: [String : Any]? {
        return nil
    }
    
    var reference : String?
    var count: Int = 3
    
    var shortsId: String?
    var regularOrder: Bool = true
    
    var shortsCollectionsId : String?
    var skus : [String]?
    var tags : [String]?
    var tagSearchOperator : String?
    var brands : [String]?
    var shuffle : Bool?
    var type : String?
    var finite : Bool?
    

    
}
