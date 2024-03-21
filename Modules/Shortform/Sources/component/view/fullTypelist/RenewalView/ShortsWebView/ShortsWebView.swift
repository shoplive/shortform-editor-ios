//
//  ShortsWebView.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2/1/24.
//

import Foundation
import UIKit
import WebKit
import ShopliveSDKCommon


class ShortsWebView : UIView, SLReactor {
    typealias WebInterface = ShopLiveShortform.ShortsWebInterface.WebToSdk
    typealias SdkToWeb = ShopLiveShortform.ShortsWebInterface.SdkToWeb
    typealias JSRequest = (SdkToWeb, [String : Any])
    
    enum Action {
        case setWebView(SLWebView)
        case evaluateJavaScript(JSRequest)
        case setWebViewIsScrollable(Bool)
        case reloadWebView(URL?)
        
        case reconnectWebView
    }
    
    enum Result {
        case shortsCommand((name : String, payload : [String : Any]?))
        case handleWebInterface( (name : WebInterface , payload : [String : Any]?) )
        case didFinishLoadingWebView
        case onExternEmitEvent((command : String, payload : [String : Any]?))
        
    }

    private var overlayWebView : SLWebView?
    
    private let reactor = ShortsWebViewReactor()
    
    var resultHandler: ((Result) -> ())?
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        self.bindReactor()
        self.setLayout()
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    deinit {
        ShopLiveLogger.debugLog("shortswebview deinited")
    }
    
    
    func action(_ action: Action) {
        switch action {
        case .setWebView(let webView):
            self.onSetWebView(webView: webView)
        case .evaluateJavaScript(let request):
            self.onEvaluateJavaScript(request: request)
        case .setWebViewIsScrollable(let isScrollable):
            self.onSetWebViewIsScrollable(isScrollable: isScrollable)
        case .reloadWebView(let overlayURl):
            self.onReloadWebView(url: overlayURl)
        case .reconnectWebView:
            self.onReconnectWebView()
        }
    }
    
    private func onSetWebView(webView : SLWebView) {
        overlayWebView?.slWebResponseDelegate = nil
        overlayWebView?.webViewNavigationDelegate = nil
        overlayWebView?.removeFromSuperview()
        overlayWebView = nil
        overlayWebView = webView
        overlayWebView?.slWebResponseDelegate = self
        overlayWebView?.webViewNavigationDelegate = self
        setLayout()
    }
    
    private func onEvaluateJavaScript(request : JSRequest) {
        if let isLoaded = reactor.getIsWebViewLoaded(), isLoaded == true {
            overlayWebView?.sendShortsEvent(event: request.0.rawValue, parameter: request.1) { }
        }
        else {
            reactor.action( .queueJSRequest(request) )
        }
    }
    
    private func onSetWebViewIsScrollable(isScrollable : Bool) {
        overlayWebView?.setScrollable(isScrollable)
    }
    
    private func onReloadWebView(url : URL?) {
        if let url = url {
            let request = URLRequest(url: url)
            overlayWebView?.load(request)
        }
        else {
            overlayWebView?.reload()
        }
    }
    
    private func onReconnectWebView() {
        overlayWebView?.slWebResponseDelegate = self
        overlayWebView?.webViewNavigationDelegate = self
    }
    
}
extension ShortsWebView {
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
        guard let webView = self.overlayWebView else { return }
        for request in request {
            webView.sendShortsEvent(event: request.0.rawValue, parameter: request.1) { }
        }
    }
    
}
extension ShortsWebView {
    private func setLayout() {
        guard let webView = self.overlayWebView else { return }
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
extension ShortsWebView : WKNavigationDelegate {
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
extension ShortsWebView : SLWebviewResponseDelegate {
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
        //유투브 이벤트는 ShortsYoutubePlayer에서 내려받도록
        guard eventName.contains("YOUTUBE") == false && eventName.contains("YTP") == false else { return }
        if type != "INTERNAL_MESSAGE" {
            //고객사에게 주는 이벤트
            self.resultHandler?( .onExternEmitEvent((eventName, payload)))
        }
        self.resultHandler?( .shortsCommand((name: eventName, payload: payload)))
    
        guard let webInterface = ShopLiveShortform.ShortsWebInterface.WebToSdk(rawValue: eventName) else { return }
        
        
        self.resultHandler?( .handleWebInterface((name: webInterface, payload: payload)))
    }
    
    private func parseBodyForLogging(body : [String : Any]) {
        var log : String = "[HASSAN LOG] <-------------- incoming command\n "
        
        let shopliveEvents = body["shopliveShortsEvent"] as? [String : Any]
        if let name = shopliveEvents?["name"] as? String {
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
        log += "================"
        ShopLiveLogger.debugLog(log)
    }
    
}
//MARK: - getter
extension ShortsWebView {
    func getIsWebViewExist() -> Bool {
        return self.overlayWebView == nil ? false : true
    }
}
