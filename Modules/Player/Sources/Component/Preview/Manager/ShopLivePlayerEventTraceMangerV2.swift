//
//  ShopLivePlayerEventTraceMangerV2.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/8/24.
//  Copyright © 2024 com.app. All rights reserved.
//


import Foundation
import ShopliveSDKCommon
import WebKit
//MARK: - 실제 이벤트트레이스 v2아니라 sdk v2.0.0에서 쓰는 클라스를 끌어온 것
enum ShopLivePlayerEventTraceAction {
    case detailShow
    case detailDismiss
    case previewShow
    case previewDismiss
    case previewClickDetail
    case playerToPipMode
    case pipToPlayerMode
}

enum ShopLivePlayerEventTraceStateAction {
    case setCampaignId(String?)
    case setShopLiveSessionId(String?)
    case setStreamActivityType(StreamActivityType)
    case setStreamEdgeType(String?)
}

protocol ShopLivePlayerEventTraceManager2  {
    func eventTraceAction(_ action : ShopLivePlayerEventTraceAction)
    func stateAction(_ action : ShopLivePlayerEventTraceStateAction)
}

class ShopLivePlayerEventTraceManagerImpl : NSObject, ShopLivePlayerEventTraceManager2 {
    
    enum PipType : String {
        case OS
        case APP
        case WEB // not used in sdk env
    }
    
    enum EventName : String {
        //sdk
        case previewShow = "PREVIEW_SHOW"
        case previewDismiss = "PREVIEW_DISMISS"
        case previewClickDetail = "PREVIEW_CLICK_DETAIL"
        

        case pipClickDetail = "PIP_CLICK_DETAIL"

        case playerToPipMode = "PLAYER_TO_PIP_MODE"
        case pipToPlayerMode = "PIP_TO_PLAYER_MODE"
        
        case detailOnSdkPlayerShow = "DETAIL_ON_SDK_PLAYER_SHOW"
        case detailOnSdkPlayerDismiss = "DETAIL_ON_SDK_PLAYER_DISMISS"
        
        
        //web에서 찍는 것
//        case previewActive = "PREVIEW_ACTIVE"
//        case previewViewingSeconds = "PREVIEW_VIEWING_SECONDS"
//        case pipActive = "PIP_ACTIVE"
//        case pipViewingSeconds = "PIP_VIEWING_SECONDS"
//        case pipPauseVideo = "PIP_PAUSE_VIDEO"
//        case pipResumeVideo = "PIP_RESUME_VIDEO"
        
//        case pipOnHide, pipOnExpose 이벤트 캐치 불가능해서 쓰지 않기로 협의됨
        
        //폐기된 이벤트들
//        case previewClickClose = "PREVIEW_CLICK_CLOSE"
//        case previewSwipeOutClose = "PREVIEW_SWIPEOUT_CLOSE"
//        case pipShow = "PIP_SHOW"
//        case pipDismiss = "PIP_DISMISS"
//        case pipClickClose = "PIP_CLICK_CLOSE"
    }
    
    enum EventCategory : String {
        case preview = "PREVIEW"
        case pip = "PIP"
        case detail = "DETAIL_PLAYER"
    }
    
    enum EventType : String {
        case system = "SYSTEM"
        case user = "USER"
    }
    
    
    private var campaignId : String?
    private var shopLiveSessionId : String?
    private var streamActivityType : StreamActivityType = .closed
    private var streamEdgeType : String?
    
    
    
    deinit {
        ShopLiveLogger.memoryLog("[ShopLivePlayerEventTraceManagerImpl] deinit")
    }
    
    func stateAction(_ action: ShopLivePlayerEventTraceStateAction) {
        switch action {
        case .setCampaignId(let campaignId):
            self.onSetCampaignId(campaignId: campaignId)
        case .setShopLiveSessionId(let id):
            self.onSetShopLiveSessionId(id: id)
        case .setStreamActivityType(let type):
            self.onSetStreamActivityType(type: type)
        case .setStreamEdgeType(let type):
            self.onSetStreamEdgeType(type: type)
        }
    }
    
    
    private func onSetCampaignId(campaignId : String?) {
        self.campaignId = campaignId
    }
    
    private func onSetShopLiveSessionId(id : String?) {
        self.shopLiveSessionId = id
    }
    
    private func onSetStreamActivityType(type : StreamActivityType) {
        self.streamActivityType = type
    }
    
    private func onSetStreamEdgeType(type : String?) {
        self.streamEdgeType = type
    }

    
}
extension ShopLivePlayerEventTraceManagerImpl {
    func eventTraceAction(_ action: ShopLivePlayerEventTraceAction) {
        switch action {
        case .detailShow:
            sendDetailShow()
        case .detailDismiss:
            sendDetailDismiss()
        case .previewShow:
            sendPreviewShow()
        case .previewDismiss:
            sendPreviewDismiss()
        case .previewClickDetail:
            sendPreviewClickDetailEventTrace()
        case .playerToPipMode:
            sendPlayerToPipMode()
        case .pipToPlayerMode:
            sendPipToPlayerMode()
        }
    }
    
    private func sendDetailShow() {
        ShoplivePlayerEventTraceManager.detailPlayerShow(campaignId: self.campaignId,
                                                         shopliveSessionId: self.shopLiveSessionId,
                                                         activityType: self.streamActivityType)
    }
    
    private func sendDetailDismiss() {
        ShoplivePlayerEventTraceManager.detailPlayerDismiss(campaignId: self.campaignId,
                                                            shopliveSessionId: self.shopLiveSessionId,
                                                            activityType: self.streamActivityType,
                                                            streamEdgeType: self.streamEdgeType)
    }
    
    private func sendPreviewShow() {
        ShoplivePlayerEventTraceManager.previewShow(campaignId: self.campaignId,
                                                    shopliveSessionId: self.shopLiveSessionId,
                                                    activityType: self.streamActivityType)
    }
    
    private func sendPreviewDismiss() {
        ShoplivePlayerEventTraceManager.previewDismiss(campaignId: self.campaignId,
                                                       shopliveSessionId: self.shopLiveSessionId,
                                                       activityType: self.streamActivityType,
                                                       streamEdgeType: self.streamEdgeType)
    }
    
    private func sendPreviewClickDetailEventTrace() {
        ShoplivePlayerEventTraceManager.previewClickDetail(campaignId: self.campaignId,
                                                           shopliveSessionId: self.shopLiveSessionId,
                                                           activityType: self.streamActivityType,
                                                           streamEdgeType: self.streamEdgeType)
    }
    
    private func sendPlayerToPipMode() {
        ShoplivePlayerEventTraceManager.playerToPip(campaignId: self.campaignId,
                                                    shopliveSessionId: self.shopLiveSessionId,
                                                    activityType: self.streamActivityType,
                                                    streamEdgeType: self.streamEdgeType)
    }
    
    private func sendPipToPlayerMode() {
        ShoplivePlayerEventTraceManager.pipToPlayer(campaignId: self.campaignId,
                                                    shopliveSessionId: self.shopLiveSessionId,
                                                    activityType: self.streamActivityType,
                                                    streamEdgeType: self.streamEdgeType)
    }
}
extension ShopLivePlayerEventTraceManagerImpl {
    private func detailPlayerShow(campaignId : String?, shopliveSessionId : String?,  activityType : StreamActivityType) {
        self.callAPI(eventName: .detailOnSdkPlayerShow,
                     eventCategory: .detail,
                     eventType: .system,
                     activityType: activityType,
                     streamEdgeType: nil,
                     campaignId: campaignId,
                     shopliveSessionId: shopliveSessionId,
                     val1: nil, val2: nil, val3: nil, val4: nil, val5: nil)
    }
    
    private func detailPlayerDismiss(campaignId : String?, shopliveSessionId : String?,  activityType : StreamActivityType,streamEdgeType : String?) {
        self.callAPI(eventName: .detailOnSdkPlayerDismiss,
                     eventCategory: .detail,
                     eventType: .system,
                     activityType: activityType,
                     streamEdgeType: streamEdgeType,
                     campaignId: campaignId,
                     shopliveSessionId: shopliveSessionId,
                     val1: nil, val2: nil, val3: nil, val4: nil, val5: nil)
    }
    
    
    private func previewShow(campaignId : String?, shopliveSessionId : String?,  activityType : StreamActivityType) {
        self.callAPI(eventName: .previewShow,
                     eventCategory: .preview,
                     eventType: .system,
                     activityType: activityType,
                     streamEdgeType: nil,
                     campaignId: campaignId,
                     shopliveSessionId: shopliveSessionId,
                     val1: nil, val2: nil, val3: nil, val4: nil, val5: nil)
    }
    
    private func previewDismiss(campaignId : String?, shopliveSessionId : String?,  activityType : StreamActivityType,streamEdgeType : String?) {
        self.callAPI(eventName: .previewDismiss,
                     eventCategory: .preview,
                     eventType: .system,
                     activityType: activityType,
                     streamEdgeType: streamEdgeType,
                     campaignId: campaignId,
                     shopliveSessionId: shopliveSessionId,
                     val1: nil, val2: nil, val3: nil, val4: nil, val5: nil)
    }
    
    
    
    private func previewClickDetail(campaignId : String?, shopliveSessionId : String?, activityType : StreamActivityType,streamEdgeType : String?) {
        self.callAPI(eventName : .previewClickDetail,
                     eventCategory: .preview,
                     eventType: .user,
                     activityType: activityType,
                     streamEdgeType: streamEdgeType,
                     campaignId: campaignId, shopliveSessionId: shopliveSessionId,
                     val1: nil, val2: nil, val3: nil, val4: nil, val5: nil)
    }
    
    private func pipClickDetail(campaignId : String?, shopliveSessionId : String?, activityType : StreamActivityType,
                              pipType : PipType,streamEdgeType : String?) {
        self.callAPI(eventName : .pipClickDetail,
                     eventCategory: .pip,
                     eventType: .user,
                     activityType: activityType,
                     streamEdgeType: streamEdgeType,
                     campaignId: campaignId, shopliveSessionId: shopliveSessionId,
                     val1: pipType.rawValue, val2: nil, val3: nil, val4: nil, val5: nil)
        
    }
    
    private func playerToPip(campaignId : String?, shopliveSessionId : String?, activityType : StreamActivityType,streamEdgeType : String?) {
        self.callAPI(eventName : .playerToPipMode,
                     eventCategory: .pip,
                     eventType: .user,
                     activityType: activityType,
                     streamEdgeType: streamEdgeType,
                     campaignId: campaignId,
                     shopliveSessionId: shopliveSessionId,
                     val1: nil, val2: nil, val3: nil, val4: nil, val5: nil)
    }
    
    private func pipToPlayer(campaignId : String?, shopliveSessionId : String?, activityType : StreamActivityType,streamEdgeType : String?) {
        self.callAPI(eventName : .pipToPlayerMode,
                     eventCategory: .pip,
                     eventType: .user,
                     activityType: activityType,
                     streamEdgeType: streamEdgeType,
                     campaignId: campaignId,
                     shopliveSessionId: shopliveSessionId,
                     val1: nil, val2: nil, val3: nil, val4: nil, val5: nil)
    }
    
    
    private func callAPI(eventName : EventName, eventCategory : EventCategory, eventType : ShoplivePlayerEventTraceManager.EventType,
                               activityType : StreamActivityType, streamEdgeType : String?,
                               campaignId : String?, shopliveSessionId : String?, val1 : Any?, val2 : Any?, val3 : Any?, val4 : Any?, val5 : Any?){
    
        
        ShopLiveCommonConfigurationManager.shared.callHostConfigAPI { result in
            switch result {
            case .success(_):
                PlayerEventTraceAPI(eventName : eventName.rawValue,
                                    eventCategory: eventCategory.rawValue,
                                    eventType: eventType.rawValue,
                                    activityType: activityType.rawValue,
                                    campaignId: campaignId,
                                    shopliveSessionId: shopliveSessionId,
                                    streamEdgeType: streamEdgeType,
                                    val1: val1, val2: val2, val3: val3, val4: val4, val5: val5)
                    .request { _  in
                        
                    }
                break
            case .failure(_):
                break
            }
        }
    }
    
}
