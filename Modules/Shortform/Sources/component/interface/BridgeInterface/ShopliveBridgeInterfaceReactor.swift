//
//  ShopliveBridgeInterfaceReactor.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 4/16/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import WebKit



class ShopliveBridgeInterfaceReactor : NSObject, SLReactor {
    typealias ShortsCollectionModel = ShopLiveShortform.ShortsCollectionModel
    typealias ShortsModel = ShopLiveShortform.ShortsModel
    typealias BridgeModel = ShopLiveShortform.ShortsBridgeModel
    typealias ShortsWebInterface = ShopLiveShortform.ShortsWebInterface
    
    enum Action {
        case setWebView(WKWebView)
        case removeWebViewObserver(WKWebView)
    }
    
    enum Result {
        case requestEvaluateJS((String,[String : Any]?))
        case showShortformPreview((reference : String? , shortsId : String?, shortsSrn : String?, requestModel : InternalShortformRelatedData?,shortsList : [ShortsModel], shortsCollectionModel : ShortsCollectionModel?,shopliveSessionId : String?))
        case showNormalFullScreen((reference : String?, shortsId : String?, shortsSrn : String?, requestModel : InternalShortformCollectionData?,shopliveSessionId : String?))
        case showRelatedFullScreen((reference : String?, shortsId : String?, shortsSrn : String?, requestModel : InternalShortformRelatedData?,shopliveSessionId : String?))
    }
    
    
    var resultHandler: ((Result) -> ())?
    
    private let webMessageHandler = ShopliveBridgeWebMessageHandler()
    
    override init() {
        super.init()
        self.bindBridgeWebMessageHandler()
    }
    
    
    
    func action(_ action: Action) {
        switch action {
        case .setWebView(let webView):
            self.onSetWebView(webView: webView)
        case .removeWebViewObserver(let webView):
            self.onRemoveWebViewObserver(webView: webView)
        }
    }
    
    
    private func onSetWebView(webView : WKWebView) {
        webView.addObserver(self, forKeyPath: "URL", options: [.old,.new], context: nil)
        webView.configuration.userContentController.add(LeakAvoider(delegate: self), name: "ShopLiveBridgeInterface")
    }
    
    private func onRemoveWebViewObserver(webView : WKWebView) {
        webView.safeRemoveObserver_SL(self, forKeyPath: "URL")
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "ShopLiveBridgeInterface")
    }
    
}
//MARK: - KVO
extension ShopliveBridgeInterfaceReactor {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "URL":
            guard let oldUrl = change?[NSKeyValueChangeKey.oldKey] as? URL,
                    let newUrl = change?[NSKeyValueChangeKey.newKey] as? URL,
                  oldUrl.absoluteString != newUrl.absoluteString else {
                return
            }
            ShopLiveShortform.closeShortformPreview()
        default:
            break
        }
    }
}
//MARK: - Delegate of LeakAvoider
extension ShopliveBridgeInterfaceReactor : WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "ShopLiveBridgeInterface" else { return }
        guard let body = message.body as? [String : Any] else { return }
        webMessageHandler.action( .handleWebMessage(body) )
        
    }
}
//MARK: -bind BridgeWebMessagHandler
extension ShopliveBridgeInterfaceReactor {
    private func bindBridgeWebMessageHandler() {
        webMessageHandler.resultHandler = { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .requestEvaluatJS((let command, let payload)):
                self.onBridgeMessageHandlerRequestEvaluateJS(command: command, payload: payload)
            case .showShortformPreview((let reference , let shortsId, let shortsSrn, let requestModel, let shortsList,let shortsCollectionModel, let shopliveSessionId)):
                self.onBridgeMessageHandlerShowShortformPreview(reference: reference, shortsId: shortsId, shortsSrn: shortsSrn, requestModel: requestModel, shortsList: shortsList, shortsCollectionModel: shortsCollectionModel, shopliveSessionId: shopliveSessionId)
            case .showNormalFullScreen((let reference , let shortsId, let shortsSrn, let requestModel, let shopliveSessionId)):
                self.onBridgeMessageHandlerShowNormalFullScreen(reference: reference, shortsId: shortsId, shortsSrn: shortsSrn, requestModel: requestModel, shopliveSessionId: shopliveSessionId)
            case .showRelatedFullScreen((let reference , let shortsId, let shortsSrn, let requestModel, let shopliveSessionId)):
                self.onBridgeMessageHandlerShowRelatedFullScreen(reference: reference, shortsId: shortsId, shortsSrn: shortsSrn, requestModel: requestModel, shopliveSessionId: shopliveSessionId)
            case .onChangedUserAuthSdk:
                self.onBridgeMessageHandlerOnChangeUserAuthSDK()
            }
        }
    }
    
    private func onBridgeMessageHandlerRequestEvaluateJS(command : String ,payload : [String : Any]?) {
        resultHandler?( .requestEvaluateJS( (command, payload)) )
    }
    
    private func onBridgeMessageHandlerShowShortformPreview(reference : String? , shortsId : String?, shortsSrn : String?, requestModel : InternalShortformRelatedData?,shortsList : [ShortsModel], shortsCollectionModel : ShortsCollectionModel?,shopliveSessionId : String?) {
        resultHandler?( .showShortformPreview((reference: nil,
                                               shortsId: shortsId,
                                               shortsSrn: shortsSrn,
                                               requestModel: requestModel,
                                               shortsList: shortsList,
                                               shortsCollectionModel: shortsCollectionModel,
                                               shopliveSessionId: shopliveSessionId)))
    }
    
    private func onBridgeMessageHandlerShowNormalFullScreen(reference : String?, shortsId : String?, shortsSrn : String?, requestModel : InternalShortformCollectionData?,shopliveSessionId : String?) {
        resultHandler?( .showNormalFullScreen((reference: nil,
                                               shortsId: shortsId,
                                               shortsSrn: shortsSrn,
                                               requestModel: requestModel,
                                               shopliveSessionId: shopliveSessionId)))
    }
    
    private func onBridgeMessageHandlerShowRelatedFullScreen(reference : String?, shortsId : String?, shortsSrn : String?, requestModel : InternalShortformRelatedData?,shopliveSessionId : String?) {
        resultHandler?( .showRelatedFullScreen((reference: nil,
                                                shortsId: shortsId,
                                                shortsSrn: shortsSrn,
                                                requestModel: requestModel,
                                                shopliveSessionId: shopliveSessionId)))
    }
    
    private func onBridgeMessageHandlerOnChangeUserAuthSDK() {
        let payload : [String : Any] = ShortFormAuthManager.shared.getAkAndUserJWTasDict()
        let eventName = ShortsWebInterface.SdkToWeb.ON_CHANGED_USER_AUTH_SDK.rawValue
        resultHandler?( .requestEvaluateJS((eventName, payload)) )
    }
}
