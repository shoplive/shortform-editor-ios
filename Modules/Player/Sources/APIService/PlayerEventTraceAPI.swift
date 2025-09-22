//
//  PlayerEventTraceAPI.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 4/22/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import UIKit


struct PlayerEventTraceAPI: APIDefinition {
    typealias ResultType = BaseResponse
    
    var baseUrl: String {
        //TODO: [HASSAN] need to change
        return ShopLiveCommonConfigurationManager.shared.getShortformEventTraceHostUrl()
    }
    
    var urlPath: String {
        return "/v2/\(ShopLiveCommon.getAccessKey() ?? "")/campaign/eventTrace"
    }
    
    var method: SLHTTPMethod {
        return .post
    }
    
    var parameters: [String: Any]? {
        var param: [String: Any] = [:]
        
        
        var campaignEventTraceInfos: [String: Any ] = [: ]
        
        
        if let eventName = eventName {
            campaignEventTraceInfos["eventName"] = eventName
        }
        
        if let eventCategory = eventCategory {
            campaignEventTraceInfos["eventCategory"] = eventCategory
        }
        
        if let eventType = eventType {
            campaignEventTraceInfos["eventType"] = eventType
        }
        
        campaignEventTraceInfos["createdAt"] = Int(Date().timeIntervalSince1970 * 1000)
        
        
        param["campaignEventTraceInfos"] = [campaignEventTraceInfos]
        
        
        if let activityType = activityType {
            param["activityType"] = activityType
        }
        
        if let campaignId = campaignId {
            param["campaignId"] = campaignId
        }
        
        if let shopliveSessionId = shopliveSessionId {
            param["shopliveSesssionId"] = shopliveSessionId
        }
        
        if let streamEdgeType = streamEdgeType {
            param["liveStreamEdgeType"] = streamEdgeType
        }
        param["osType"] = "i"
        param["env"] = "SDK"
        
        return param
    }
    
    var eventName: String?
    var eventCategory: String?
    var eventType: String?
    var activityType: String?
    var campaignId: String?
    var shopliveSessionId: String?
    var streamEdgeType: String?
    
    var val1: Any?
    var val2: Any?
    var val3: Any?
    var val4: Any?
    var val5: Any?
    
}
