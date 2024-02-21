//
//  ShortsEventTraceAPI.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/07/21.
//

import Foundation
import ShopliveSDKCommon
import QuartzCore
import UIKit

struct ShortsEventTraceAPI : APIDefinition {
    
    enum EventName : String {
        case COLLECTION_SHOW
        case COLLECTION_CLICK_ITEM
        
        // Related api call 할때만 찍어야함 안그러면 web 과 동시에 찍힐 수 있음
        case PREVIEW_SHOWN
        case PREVIEW_HIDDEN
        case PREVIEW_CLICK_CLOSE
        case PREVIEW_CLICK_SHOW
    }
    
    enum EventCategory : String {
        case COLLECTION
        case PREVIEW
    }
    
    enum EventType : String {
        case VIEW
        case UI
    }
    
    typealias ResultType = EmptyResponse
    
    var baseUrl: String {
        ShortFormConfigurationInfosManager.shared.shortsConfiguration.eventTraceEndpoint
    }
    
    var urlPath: String {
        if let ak = ShopLiveCommon.getAccessKey(), ak.isEmpty == false {
            return "/v1/\(ak)/shortform/eventTrace"
        }
        else {
            return "/v1/shortform/eventTrace"
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
    
    var parameter: [String : Any]? {
        return nil
    }
    
    
    var parameters: [String : Any]? {
        var param : [String : Any] = [:]
        param["env"] = "SDK"
        param["osType"] = "i"
        
        if let srn = srn {
            param["srn"] = srn
        }
        if let eventName = eventName {
            param["eventName"] = eventName.rawValue
        }
        if let eventCategory = eventCategory {
            param["eventCategory"] = eventCategory.rawValue
        }
        if let eventType = eventType {
            param["eventType"] = eventType.rawValue
        }
        if let referrer = referrer {
            param["referrer"] = referrer
        }
        if let shopliveSessionId = shopliveSessionId {
            param["shopliveSessionId"] = shopliveSessionId
        }
        param["createdAt"] = Int(1000 * Date().timeIntervalSince1970)
        
        var values : [Any] = []
        
        if let val1 = val1 {
            values.append(val1)
        }
        if let val2 = val2 {
            values.append(val2)
        }
        if let val3 = val3 {
            values.append(val3)
        }
        if let val4 = val4 {
            values.append(val4)
        }
        if let val5 = val5 {
            values.append(val5)
        }
        if values.isEmpty == false {
            param["values"] = values
        }
        
        return param
    }
    
    var eventName : EventName?
    var eventCategory : EventCategory?
    var eventType : EventType?
    var srn : String?
    var referrer : String?
    var shopliveSessionId : String?
    
    var val1 : Any?
    var val2 : Any?
    var val3 : Any?
    var val4 : Any?
    var val5 : Any?
}
