//
//  ShortsRelatedCollectionAPI.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/07/20.
//

import Foundation
import ShopliveSDKCommon
import UIKit

struct ShortsRelatedCollectionAPI : APIDefinition {
    typealias ResultType = SLShortsCollectionModel
    
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
            return "/sdk/v1/\(ak)/shortform/related"
        }
        else {
            return "/sdk/v1/shortform/related"
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
        var params : [String : Any] = [:]
        params["count"] = count
        
        if let accessKey = ShortFormAuthManager.shared.getAccessKey() {
            params["accessKey"] = accessKey
        }
        if let shortsCollectionId = shortsCollectionId {
            params["shortsCollectionId"] = shortsCollectionId
        }
        if let reference = reference {
            params["reference"] = reference
        }
        if let productId = productId {
            params["productId"] = productId
        }
        if let name = name {
            params["name"] = name
        }
        if let skus = skus {
            params["skus"] = skus
        }
        if let url = url {
            params["url"] = url
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
        if let shortsId = shortsId {
            params["shortsId"] = shortsId
        }
        if let detailInfo = detailInfo {
            params["detailInfo"] = detailInfo
        }
        return params
    }
    
    var shortsCollectionId : Int?
    var productId : String?
    var name : String? // product name
    var skus : [String]?
    var url : String?
    var tags : [String]?
    var tagSearchOperator : String?
    var brands : [String]?
    var shortsId : String?
    var detailInfo : Bool?
    var count : Int = 3
    var shuffle : Bool?
    var reference : String?
}

