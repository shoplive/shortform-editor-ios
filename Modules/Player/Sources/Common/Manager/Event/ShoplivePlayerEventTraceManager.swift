//
//  ShoplivePlayerEventTraceManager.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 4/22/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon

final class ShoplivePlayerEventTraceManager {
    
    enum PipType: String {
        case OS
        case APP
        case WEB // not used in sdk env
    }
    
    enum EventName: String {
        //sdk
        case previewShow = "PREVIEW_SHOW"
        case previewDismiss = "PREVIEW_DISMISS"
        case previewClickDetail = "PREVIEW_CLICK_DETAIL"
        
        
        case pipClickDetail = "PIP_CLICK_DETAIL"
        
        case playerToPipMode = "PLAYER_TO_PIP_MODE"
        case pipToPlayerMode = "PIP_TO_PLAYER_MODE"
        
        case detailOnSdkPlayerShow = "DETAIL_ON_SDK_PLAYER_SHOW"
        case detailOnSdkPlayerDismiss = "DETAIL_ON_SDK_PLAYER_DISMISS"
        
    }
    
    enum EventCategory: String {
        case preview = "PREVIEW"
        case pip = "PIP"
        case detail = "DETAIL_PLAYER"
    }
    
    enum EventType: String {
        case system = "SYSTEM"
        case user = "USER"
    }
    
    class func detailPlayerShow(
        campaignId: String?,
        shopliveSessionId: String?,
        activityType: StreamActivityType
    ) {
        self.callAPI(
            eventName: .detailOnSdkPlayerShow,
            eventCategory: .detail,
            eventType: .system,
            activityType: activityType,
            streamEdgeType: nil,
            campaignId: campaignId,
            shopliveSessionId: shopliveSessionId,
            val1: nil, val2: nil, val3: nil, val4: nil, val5: nil
        )
    }
    
    class func detailPlayerDismiss(
        campaignId: String?,
        shopliveSessionId: String?,
        activityType: StreamActivityType,
        streamEdgeType: String?
    ) {
        self.callAPI(
            eventName: .detailOnSdkPlayerDismiss,
            eventCategory: .detail,
            eventType: .system,
            activityType: activityType,
            streamEdgeType: streamEdgeType,
            campaignId: campaignId,
            shopliveSessionId: shopliveSessionId,
            val1: nil, val2: nil, val3: nil, val4: nil, val5: nil
        )
    }
    
    
    class func previewShow(
        campaignId: String?,
        shopliveSessionId: String?,
        activityType: StreamActivityType
    ) {
        self.callAPI(
            eventName: .previewShow,
            eventCategory: .preview,
            eventType: .system,
            activityType: activityType,
            streamEdgeType: nil,
            campaignId: campaignId,
            shopliveSessionId: shopliveSessionId,
            val1: nil, val2: nil, val3: nil, val4: nil, val5: nil
        )
    }
    
    class func previewDismiss(
        campaignId: String?,
        shopliveSessionId: String?,
        activityType: StreamActivityType,
        streamEdgeType: String?
    ) {
        self.callAPI(
            eventName: .previewDismiss,
            eventCategory: .preview,
            eventType: .system,
            activityType: activityType,
            streamEdgeType: streamEdgeType,
            campaignId: campaignId,
            shopliveSessionId: shopliveSessionId,
            val1: nil, val2: nil, val3: nil, val4: nil, val5: nil
        )
    }
    
    
    
    class func previewClickDetail(
        campaignId: String?,
        shopliveSessionId: String?,
        activityType: StreamActivityType,
        streamEdgeType: String?
    ) {
        self.callAPI(
            eventName: .previewClickDetail,
            eventCategory: .preview,
            eventType: .user,
            activityType: activityType,
            streamEdgeType: streamEdgeType,
            campaignId: campaignId, shopliveSessionId: shopliveSessionId,
            val1: nil, val2: nil, val3: nil, val4: nil, val5: nil
        )
    }
    
    class func pipClickDetail(
        campaignId: String?,
        shopliveSessionId: String?,
        activityType: StreamActivityType,
        pipType: PipType,
        streamEdgeType: String?
    ) {
        self.callAPI(
            eventName: .pipClickDetail,
            eventCategory: .pip,
            eventType: .user,
            activityType: activityType,
            streamEdgeType: streamEdgeType,
            campaignId: campaignId, shopliveSessionId: shopliveSessionId,
            val1: pipType.rawValue, val2: nil, val3: nil, val4: nil, val5: nil
        )
    }
    
    class func playerToPip(
        campaignId: String?,
        shopliveSessionId: String?,
        activityType: StreamActivityType,
        streamEdgeType: String?
    ) {
        self.callAPI(
            eventName: .playerToPipMode,
            eventCategory: .pip,
            eventType: .user,
            activityType: activityType,
            streamEdgeType: streamEdgeType,
            campaignId: campaignId,
            shopliveSessionId: shopliveSessionId,
            val1: nil, val2: nil, val3: nil, val4: nil, val5: nil
        )
    }
    
    class func pipToPlayer(campaignId: String?, shopliveSessionId: String?, activityType: StreamActivityType,streamEdgeType: String?) {
        self.callAPI(
            eventName: .pipToPlayerMode,
            eventCategory: .pip,
            eventType: .user,
            activityType: activityType,
            streamEdgeType: streamEdgeType,
            campaignId: campaignId,
            shopliveSessionId: shopliveSessionId,
            val1: nil, val2: nil, val3: nil, val4: nil, val5: nil
        )
    }
    
    
    
    
    private class func callAPI(
        eventName: EventName,
        eventCategory: EventCategory,
        eventType: ShoplivePlayerEventTraceManager.EventType,
        activityType: StreamActivityType,
        streamEdgeType: String?,
        campaignId: String?,
        shopliveSessionId: String?,
        val1: Any?,
        val2: Any?,
        val3: Any?,
        val4: Any?,
        val5: Any?
    ){
        ShopLiveCommonConfigurationManager.shared.callHostConfigAPI { result in
            switch result {
            case .success(_):
                PlayerEventTraceAPI(
                    eventName: eventName.rawValue,
                    eventCategory: eventCategory.rawValue,
                    eventType: eventType.rawValue,
                    activityType: activityType.rawValue,
                    campaignId: campaignId,
                    shopliveSessionId: shopliveSessionId,
                    streamEdgeType: streamEdgeType,
                    val1: val1, val2: val2, val3: val3, val4: val4, val5: val5
                )
                .request { _  in }
                break
            case .failure(_):
                break
            }
        }
    }
}
