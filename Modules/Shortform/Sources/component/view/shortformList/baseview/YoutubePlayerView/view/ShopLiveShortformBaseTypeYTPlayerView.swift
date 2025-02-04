//
//  ShopLiveShortformBaseTypeYTPlayerView.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 3/4/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import WebKit


class ShopLiveShortformBaseTypeYTPlayerView : UIView, SLReactor {
    typealias WebInterface = ShopLiveShortform.ShortsWebInterface.WebToSdk
    typealias SdkToWeb = ShopLiveShortform.ShortsWebInterface.SdkToWeb
    typealias JSRequest = (SdkToWeb, [String : Any])
    
    enum Action {
        case setWebView(SLWebView)
        case setCurrentSrn(String?)
        case emptyWebView


        case play
        case pause
    }
    
    enum Result {
        case hidePosterImage(Bool)
    }
    
    private var webView : SLWebView?
    
    var resultHandler: ((Result) -> ())?
    
    private let reactor = ShopLiveShortformBaseTypeYTPlayerReactor()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bindReactor()
        
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    deinit {
        
    }
    
    
    func action(_ action: Action) {
        switch action {
        case .setWebView(let webView):
            self.onSetWebView(webView: webView)
        case .setCurrentSrn(let srn):
            self.onSetCurrentSrn(srn: srn)
        case .emptyWebView:
            self.onEmptyWebView()
        case .play:
            self.onPlay()
        case .pause:
            self.onPause()
        }
    }
    
    private func onSetWebView(webView : SLWebView) {
        self.webView?.slWebResponseDelegate = nil
        self.webView?.webViewNavigationDelegate = nil
        self.webView?.removeFromSuperview()
        self.webView = nil
        self.webView = webView
        self.webView?.slWebResponseDelegate = self
        self.webView?.webViewNavigationDelegate = self
        setLayout()
    }
    
    private func onSetCurrentSrn(srn : String?) {
        reactor.action( .setCurrentSrn(srn) )
    }
    
    private func onEmptyWebView() {
        self.webView?.slWebResponseDelegate = nil
        self.webView?.webViewNavigationDelegate = nil
        self.webView?.removeFromSuperview()
        self.webView = nil
    }
    
    private func onPlay() {
        reactor.action( .play )
    }
    
    private func onPause() {
        reactor.action( .pause )
    }
}
extension ShopLiveShortformBaseTypeYTPlayerView {
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .requestEvaluateJS(let requestList):
                self.onRequestEvaluateJSRequest(requestList: requestList)
            case .hidePosterImage(let hide):
                self.onHidePosterImage(hide: hide)
            }
        }
    }
    
    private func onRequestEvaluateJSRequest(requestList : [JSRequest]){
        requestList.forEach { request in
            if case .EXTERNAL_COMMAND(let command) = request.0  {
                webView?.sendShortsEvent(event: command, parameter: request.1) { }
            }
            else {
                webView?.sendShortsEvent(event: request.0.key, parameter: request.1) { }
            }
        }
    }
    
    private func onHidePosterImage(hide : Bool) {
        resultHandler?( .hidePosterImage(hide) )
    }
}
extension ShopLiveShortformBaseTypeYTPlayerView {
    private func setLayout() {
        guard let webView = self.webView else { return }
        self.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.topAnchor),
            webView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
extension ShopLiveShortformBaseTypeYTPlayerView : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        reactor.action( .setisWebViewLoaded(false) )
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        reactor.action( .setisWebViewLoaded(true) )
        reactor.action( .sendQueuedJSRequest )
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        reactor.action( .setisWebViewLoaded(false) )
    }
}
extension ShopLiveShortformBaseTypeYTPlayerView : SLWebviewResponseDelegate {
    func handleShopliveEvent(_ command: String, with payload: [String : Any]?, userImplements: Bool) {
        /* no - op */
    }
    
    func handleEventMessage(message: WKScriptMessage) {
        guard let body = message.body as? [String: Any],
              let event = body["shopliveShortsEvent"] as? [String : Any],
              let eventName = event["name"] as? String,
              let metadata = event["metadata"] as? [String: String],
              let type = metadata["type"] else {
            return
        }
        
        let payload = body["payload"] as? [String : Any]
        if eventName.contains("YOUTUBE") || eventName.contains("YTP") {
            guard let webInterface = ShopLiveShortform.ShortsWebInterface.WebToSdk(rawValue: eventName) else { return }
            reactor.action( .webToSDK(name: webInterface, payload: payload))
//            self.resultHandler?( .handleWebInterface((name: webInterface, payload: payload)))
        }
    }
}
