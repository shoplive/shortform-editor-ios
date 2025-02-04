//
//  ShortsYoutubePlayerReactor.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 3/5/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import WebKit


class ShortsYoutubePlayerReactor : NSObject, SLReactor {
    typealias ShortsMode = ShopLiveShortform.ShortsMode
    typealias SdkToWeb = ShopLiveShortform.ShortsWebInterface.SdkToWeb
    typealias WebToSdk = ShopLiveShortform.ShortsWebInterface.WebToSdk
    typealias JSRequest = (SdkToWeb, [String : Any])
    typealias ViewProvideType = ShortsCollectionBaseViewModel.ViewProvidedType
    
    enum Action {
        case setisWebViewLoaded(Bool?)
        case queueJSRequest(JSRequest)
        case sendQueuedJSRequest
        case setCurrentIndexPath(IndexPath)
    }
    
    enum Result {
        case requestEvaluateJS([JSRequest])
    }
    
    private var jsRequestsList : [JSRequest] = []
    private var isWebViewLoaded : Bool?
    //로깅용
    private var currentIndexPath : IndexPath = .init(row: 0, section: 0)
    
    var resultHandler: ((Result) -> ())?
    
    override init() {
        super.init()
    }
    
    deinit {
        
    }
    
    func action(_ action: Action) {
        switch action {
        case .setisWebViewLoaded(let isWebViewLoaded):
            self.onSetIsWebViewLoaded(isLoaded: isWebViewLoaded)
        case .queueJSRequest(let jSRequest):
            self.onQueueJSRequest(request: jSRequest)
        case .sendQueuedJSRequest:
            self.onSendQueuedJSRequest()
        case .setCurrentIndexPath(let indexPath):
            self.onSetCurrentIndexPath(indexPath: indexPath)
        }
    }
    
    private func onSetIsWebViewLoaded(isLoaded : Bool?) {
        self.isWebViewLoaded = isLoaded
    }
    
    private func onQueueJSRequest(request : JSRequest) {
        jsRequestsList.append(request)
    }
    
    private func onSendQueuedJSRequest() {
        resultHandler?( .requestEvaluateJS(jsRequestsList))
        jsRequestsList.removeAll()
    }
    
    private func onSetCurrentIndexPath(indexPath : IndexPath) {
        self.currentIndexPath = indexPath
    }
}
//MARK: -Getter
extension ShortsYoutubePlayerReactor {
    func getIsWebViewLoaded() -> Bool? {
        return isWebViewLoaded
    }
    func getCurrentIndexPath() -> IndexPath {
        return self.currentIndexPath
    }
    
}
