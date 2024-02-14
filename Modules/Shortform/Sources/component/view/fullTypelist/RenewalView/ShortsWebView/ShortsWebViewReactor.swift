//
//  ShortsWebViewReactor.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2/1/24.
//

import Foundation
import UIKit
import ShopliveSDKCommon


class ShortsWebViewReactor : SLReactor {

    typealias ShortsMode = ShopLiveShortform.ShortsMode
    typealias SdkToWeb = ShopLiveShortform.ShortsWebInterface.SdkToWeb
    typealias WebToSdk = ShopLiveShortform.ShortsWebInterface.WebToSdk
    typealias ShortsModel = ShopLiveShortform.ShortsModel
    typealias JSRequest = (SdkToWeb, [String : Any])
    typealias ViewProvideType = ShortsCollectionBaseViewModel.ViewProvidedType
    
    enum Action {
        case setisWebViewLoaded(Bool?)
        case queueJSRequest(JSRequest)
        case sendQueuedJSRequest
    }
    
    enum Result {
        case requestEvaluateJS([JSRequest])
    }
    
    private var jsRequestsList : [JSRequest] = []
    private var isWebViewLoaded : Bool?
    
    var resultHandler: ((Result) -> ())?
    
    
    func action(_ action: Action) {
        switch action {
        case .setisWebViewLoaded(let isWebViewLoaded):
            self.onSetIsWebViewLoaded(isLoaded: isWebViewLoaded)
        case .queueJSRequest(let jSRequest):
            self.onQueueJSRequest(request: jSRequest)
        case .sendQueuedJSRequest:
            self.onSendQueuedJSRequest()
        }
        
    }
    
    private func onSetIsWebViewLoaded(isLoaded : Bool?) {
        self.isWebViewLoaded = isLoaded
    }
    
    private func onQueueJSRequest(request : JSRequest) {
        if jsRequestsList.contains(where: { $0.0 == .ON_VIDEO_TIME_UPDATED }) && request.0 == .ON_VIDEO_TIME_UPDATED {
            jsRequestsList.removeAll(where: { $0.0 == .ON_VIDEO_TIME_UPDATED })
        }
        jsRequestsList.append(request)
    }
    
    private func onSendQueuedJSRequest() {
        resultHandler?( .requestEvaluateJS(jsRequestsList))
        jsRequestsList.removeAll()
    }
    
}
//MARK: -Getter
extension ShortsWebViewReactor {
    func getIsWebViewLoaded() -> Bool? {
        return isWebViewLoaded
    }
    
}

