//
//  ShopliveBridgeWebMessageHandler.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 4/16/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon


class ShopliveBridgeWebMessageHandler : NSObject, SLReactor {
    typealias BridgeEventName = ShopLiveShortform.ShortsWebInterface.Bridge
    typealias ShortsCollectionModel = ShopLiveShortform.ShortsCollectionModel
    typealias ShortsModel = ShopLiveShortform.ShortsModel
    typealias BridgeModel = ShopLiveShortform.ShortsBridgeModel
    
    
    enum Action {
        case handleWebMessage([String : Any])
    }
    
    enum Result {
        case requestEvaluatJS((command : String, body : [String : Any]?))
        case showShortformPreview((reference : String? , shortsId : String?, shortsSrn : String?, requestModel : InternalShortformRelatedDTO?,shortsList : [ShortsModel], shortsCollectionModel : ShortsCollectionModel?,shopliveSessionId : String?))
        case showNormalFullScreen((reference : String?, shortsId : String?, shortsSrn : String?, requestModel : InternalShortformCollectionDto?,shopliveSessionId : String?))
        case showRelatedFullScreen((reference : String?, shortsId : String?, shortsSrn : String?, requestModel : InternalShortformRelatedDTO?,shopliveSessionId : String?))
        case onChangedUserAuthSdk
    }
    
    
    var resultHandler: ((Result) -> ())?
    
    func action(_ action: Action) {
        switch action {
        case .handleWebMessage(let body):
            self.onHandleWebMessage(body: body)
        }
    }
    
    private func onHandleWebMessage(body : [String : Any]?) {
        guard let body = body,
              let event = body["shopliveShortsEvent"] as? [String : Any],
              let eventName = event["name"] as? String else { return }
        
        if let webToSDKInterface = ShopLiveShortform.ShortsWebInterface.WebToSdk(rawValue: eventName), webToSDKInterface == .REQUEST_CLIENT_VERSION {
            self.onHandleWebToSDKInternalMessageHandler(eventName: webToSDKInterface, body: body)
        }
        else if let bridgeInterface = ShopLiveShortform.ShortsWebInterface.Bridge(rawValue: eventName) {
            self.onHandleBridgeInterfaceMessageHandler(eventName: bridgeInterface, body: body)
        }
    }
    
}
//MARK: -onHandleWebToSDKInternalMessageHandler
extension ShopliveBridgeWebMessageHandler  {
    private func onHandleWebToSDKInternalMessageHandler(eventName : ShopLiveShortform.ShortsWebInterface.WebToSdk,  body : [String : Any]) {
        switch eventName {
        case .REQUEST_CLIENT_VERSION:
            self.onHandleInternalMessageRequestClientVersion(body: body)
        default:
            break
        }
    }
    
    private func onHandleInternalMessageRequestClientVersion(body : [String : Any]) {
        let payload : [String : Any] = [
            "appVersion" : UIApplication.appVersion_SL(),
            "sdkVersion" : ShopLiveShortform.sdkVersion
        ]
        let sendName = ShopLiveShortform.ShortsWebInterface.SdkToWeb.SEND_CLIENT_VERSION.rawValue
        resultHandler?( .requestEvaluatJS((sendName, payload)) )
    }
}
//MARK: -onHandleBridgeInterfaceMessageHandler
extension ShopliveBridgeWebMessageHandler {
    private func onHandleBridgeInterfaceMessageHandler(eventName : BridgeEventName, body : [String : Any]) {
        let payload = body["payload"] as? [String : Any]
        
        switch eventName {
        case .SHOW_SHORTFORM_PREVIEW:
            self.onHandleBridgeMessageShowShortformPreview(payload: payload)
        case .HIDE_SHORTFORM_PREVIEW:
            self.onHandleBridgeMessageHideShortformPreview()
        case .PLAY_SHORTFORM_DETAIL:
            self.onHandleBridgeMessagePlayShortformDetail(payload: payload)
        case .ON_SHORTFORM_CLIENT_INITIALIZED:
            self.onHandleBridgeMessageShortformClientInitialized(payload: payload)
        case .ON_CHANGED_USER_AUTH:
            self.onHandleBridgeMessageOnChangeUserAuth(payload: payload)
        case .ON_CHANGED_USER_AUTH_WEB:
            self.onHandleBridgeMessageOnChangedUserAuthWeb(payload: payload)
        default:
            break
        }
    }
    
    private func onHandleBridgeMessageShowShortformPreview(payload : [String : Any]?) {
        guard let payload = payload, let param = payload.toJson_SL(), let model = param.convert_SL(to: BridgeModel.self) else { return }
        let requestModel = InternalShortformRelatedDTO()
        requestModel.tags = model.relatedQuery?.tags
        requestModel.tagSearchOperator = model.relatedQuery?.tagSearchOperator
        requestModel.brands = model.relatedQuery?.brands
        requestModel.productId = model.relatedQuery?.productId
        requestModel.name = model.relatedQuery?.name
        requestModel.skus = model.relatedQuery?.skus
        requestModel.url = model.relatedQuery?.url
        requestModel.shuffle = model.relatedQuery?.shuffle
        requestModel.shortsId = model.relatedQuery?.shortsId
        
        let shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        resultHandler?( .showShortformPreview((reference: nil,
                                               shortsId: model.shorts?.shortsId,
                                               shortsSrn: model.shorts?.srn,
                                               requestModel: requestModel,
                                               shortsList: model.shortsList ?? [],
                                               shortsCollectionModel: model.shortsCollection,
                                               shopliveSessionId: shopliveSessionId)))
    }
    
    private func onHandleBridgeMessageHideShortformPreview() {
        ShopLiveShortform.close()
    }
    
    private func onHandleBridgeMessagePlayShortformDetail(payload : [String : Any]?) {
        guard let payload = payload,
              let param = payload.toJson_SL(),
              let bridgeModel = param.convert_SL(to: BridgeModel.self) else { return }
        
        ShortFormAuthManager.shared.setAuthInfo(payload)
        let shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        
        self.onPlayShortformDetailShowNormalFullScreen(model: bridgeModel,shopliveSessionId: shopliveSessionId)
        
        let evaluateJSPaylad : [String : Any] = [
            "isShown" : true,
            "srn" : bridgeModel.shorts?.srn ?? ""
        ]
        resultHandler?( .requestEvaluatJS(("ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN", evaluateJSPaylad)))
        
    }
    
    private func onPlayShortformDetailShowNormalFullScreen(model : BridgeModel, shopliveSessionId : String) {
        let requestModel = InternalShortformCollectionDto()
        requestModel.tags = model.collectionQuery?.tags
        requestModel.tagSearchOperator = model.collectionQuery?.tagSearchOperator
        requestModel.brands = model.collectionQuery?.brands
        requestModel.shuffle = model.collectionQuery?.shuffle
        requestModel.shortsCollectionId = model.collectionQuery?.shortsCollectionId
        requestModel.skus = model.collectionQuery?.skus
        
        resultHandler?( .showNormalFullScreen((reference: nil,
                                               shortsId: model.shorts?.shortsId,
                                               shortsSrn: model.shorts?.srn,
                                               requestModel: requestModel,
                                               shopliveSessionId: shopliveSessionId)))
    }
    
    private func onPlayShortformDetailShowRelatedFullScreen(model : BridgeModel, shopliveSessionId : String) {
        let requestModel = InternalShortformRelatedDTO()
        requestModel.tags = model.relatedQuery?.tags
        requestModel.tagSearchOperator = model.relatedQuery?.tagSearchOperator
        requestModel.brands = model.relatedQuery?.brands
        requestModel.productId = model.relatedQuery?.productId
        requestModel.name = model.relatedQuery?.name
        requestModel.skus = model.relatedQuery?.skus
        requestModel.url = model.relatedQuery?.url
        requestModel.shuffle = model.relatedQuery?.shuffle
        requestModel.shortsId = model.relatedQuery?.shortsId
        
        resultHandler?( .showRelatedFullScreen((reference: nil,
                                                shortsId: model.shorts?.shortsId,
                                                shortsSrn: model.shorts?.srn,
                                                requestModel: requestModel,
                                                shopliveSessionId: shopliveSessionId)))
        
    }
    
    private func onHandleBridgeMessageShortformClientInitialized(payload : [String : Any]?) {
        let ak = ((payload?["ak"] ?? nil) as? String) ?? nil
        ShortFormConfigurationInfosManager.shared.callShortsConfigurationAPI(accessKey : ak,params: payload) { [weak self] _ in
            self?.resultHandler?( .onChangedUserAuthSdk )
        }
    }
    
    private func onHandleBridgeMessageOnChangeUserAuth(payload : [String : Any]?) {
        guard let payload = payload else { return }
        ShortFormAuthManager.shared.setAuthInfo(payload)
    }
    
    private func onHandleBridgeMessageOnChangedUserAuthWeb(payload : [String : Any]?) {
        guard let payload = payload else { return }
        let deviceJwt = ShopLiveCommon.getAuthToken()
        let webJwt : String? = payload["userJWT"] as? String
        if deviceJwt != nil || webJwt == nil {
            ShortFormAuthManager.shared.setAuthInfo(payload)
        }
    }
}
