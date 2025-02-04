//
//  ShortsYoutubePlayer.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 3/5/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import WebKit


class ShortsYoutubePlayerView : UIView , SLReactor {
    typealias WebInterface = ShopLiveShortform.ShortsWebInterface.WebToSdk
    typealias SdkToWeb = ShopLiveShortform.ShortsWebInterface.SdkToWeb
    typealias JSRequest = (SdkToWeb, [String : Any])
    
    enum Action {
        case setWebView(SLWebView?)
        case evaluateJavaScript(JSRequest)
        case setCurrentIndexPath(IndexPath)
    }
    
    enum Result {
        case handleWebInterface( (name : WebInterface , payload : [String : Any]?) )
    }
    
    private var webView : SLWebView?
    
    private let reactor = ShortsYoutubePlayerReactor()
    
    var resultHandler: ((Result) -> ())?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.bindReactor()
        self.setLayout()
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
        case .evaluateJavaScript(let jsRequest):
            self.onEvaluateJavaScript(request: jsRequest)
        case .setCurrentIndexPath(let indexPath):
            self.onSetCurrentIndexPath(indexPath: indexPath)
        }
    }
    
    private func onSetWebView(webView : SLWebView?) {
        self.webView?.slWebResponseDelegate = nil
        self.webView?.webViewNavigationDelegate = nil
        self.webView?.removeFromSuperview()
        self.webView = nil
        guard let webView = webView else { return }
        self.webView = webView
        self.webView?.slWebResponseDelegate = self
        self.webView?.webViewNavigationDelegate = self
        setLayout()
    }
    
    private func onEvaluateJavaScript(request : JSRequest) {
        if let isLoaded = reactor.getIsWebViewLoaded(), isLoaded == true {
            if case .EXTERNAL_COMMAND(let command) = request.0 {
                webView?.sendShortsEvent(event: command, parameter: request.1) { }
            }
            else {
                webView?.sendShortsEvent(event: request.0.key, parameter: request.1) { }
            }
        }
        else {
            reactor.action( .queueJSRequest(request) )
        }
    }
    
    private func onSetCurrentIndexPath(indexPath : IndexPath) {
        reactor.action( .setCurrentIndexPath(indexPath) )
    }
}
extension ShortsYoutubePlayerView {
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .requestEvaluateJS(let requestList):
                self.onReactorRequestEvaluateJSRequest(request: requestList)
            }
        }
    }
    
    private func onReactorRequestEvaluateJSRequest(request : [JSRequest]) {
        guard let webView = self.webView else { return }
        for request in request {
            if case .EXTERNAL_COMMAND(let command) = request.0 {
                webView.sendShortsEvent(event: command, parameter: request.1) { }
            }
            else {
                webView.sendShortsEvent(event: request.0.key, parameter: request.1) { }
            }
        }
    }
    
}
extension ShortsYoutubePlayerView {
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
extension ShortsYoutubePlayerView : WKNavigationDelegate {
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
extension ShortsYoutubePlayerView : SLWebviewResponseDelegate {
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
        
//        self.parseBodyForLogging(body: body)
        
        //youtube 관련 이벤트만 내려보내도록
        guard eventName.contains("YOUTUBE") || eventName.contains("YTP") else { return }
        
        
        guard let webInterface = ShopLiveShortform.ShortsWebInterface.WebToSdk(rawValue: eventName) else { return }
        self.resultHandler?( .handleWebInterface((name: webInterface, payload: payload)))
    }
    
    
    //webcommand logging용 전용 함수
    private func parseBodyForLogging(body : [String : Any]) {
        var log : String = "[HASSAN LOG] <-------------- incoming command\n "
        let shopliveEvents = body["shopliveShortsEvent"] as? [String : Any]
        if let name = shopliveEvents?["name"] as? String {
            if name.contains("SDK_YTP_GET_CURRENT_TIME") {
                return
            }
            log += "name : \(name)\n"
        }
        
        let payload = body["payload"] as? [String : Any]
        
        if let eventName = payload?["name"] as? String {
            log += "eventName : \(eventName)\n"
        }
        
        if let youtubeId = payload?["youtubeId"] as? String {
            log += "youtubeId : \(youtubeId)\n"
        }
        
        if let values = payload?["values"] as? [String : Any] {
            log += "values : \(values)\n"
        }
        log += "indexPath : \(reactor.getCurrentIndexPath())\n"
        log += "================"
        
    }
}

