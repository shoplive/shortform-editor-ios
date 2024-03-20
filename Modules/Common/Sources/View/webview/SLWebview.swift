//
//  SLWebview.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/26/23.
//

import Foundation
import UIKit
import WebKit

@objc public protocol SLWebviewScrollDelegate: AnyObject {
    @objc optional func scrollViewDidScroll()
}

@objc public protocol SLWebviewResponseDelegate: AnyObject {
    @objc optional func handleShopliveEvent(_ command: String, with payload: [String: Any]?, userImplements: Bool)
    @objc optional func handleEventMessage(message: WKScriptMessage)
}

struct WebKeys {
    static let webInterface: String = "ShopLiveAppInterface"
    static let userImplementCallback: String = "USER_IMPLEMENTS_CALLBACK"
    static let name = "name"
    static let type = "type"
    static let metadata = "metadata"
    static let payload = "payload"
    static let shopliveEvent = "shopliveEvent"
}

public final class SLWebView: SLBaseView {
    
    weak var slWebNavigationDelegate: WKNavigationDelegate? {
        set {
            webview.navigationDelegate = newValue
        }
        get {
            webview.navigationDelegate
        }
    }
    
    weak var slWebUIDelegate: WKUIDelegate? {
        set {
            webview.uiDelegate = newValue
        }
        get {
            webview.uiDelegate
        }
    }
    
    public weak var slWebResponseDelegate: SLWebviewResponseDelegate?
    public weak var slWebScrollDelegate: SLWebviewScrollDelegate?
    public weak var webViewNavigationDelegate : WKNavigationDelegate? {
        didSet {
            webview.navigationDelegate = webViewNavigationDelegate
        }
    }
    
    lazy private var webview: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = false
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.preferences.javaScriptEnabled = true
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .clear
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    public override func layout() {
        self.addSubview(webview)
        webview.fit_SL()
        self.backgroundColor = .clear
    }
    
    public func load(_ request: URLRequest) {
        webview.load(request)
    }
    
    public func reload() {
        webview.reload()
    }
    
    public var url: String? {
        webview.url?.absoluteString
    }
    
    public override func attributes() {
        webview.backgroundColor = UIColor.clear
        webview.scrollView.backgroundColor = UIColor.clear
        webview.scrollView.isScrollEnabled = true
        webview.scrollView.contentInsetAdjustmentBehavior = .never
        webview.allowsLinkPreview = false
        webview.scrollView.layer.masksToBounds = false
        webview.scrollView.alwaysBounceVertical = false
        webview.scrollView.bounces = false
        
        self.clipsToBounds = true
    }
    
    public override func bindView() {
        webview.scrollView.delegate = self
        webview.configuration.userContentController.add(LeakAvoider(delegate: self), name: WebKeys.webInterface)
        webview.configuration.userContentController.add(LeakAvoider(delegate: self), name: "shopliveShortFormEvent")
    }
    
    deinit {
        webview.stopLoading()
        webview.configuration.userContentController.removeScriptMessageHandler(forName: WebKeys.webInterface)
        webview.configuration.userContentController.removeScriptMessageHandler(forName: "shopliveShortFormEvent")
    }
    
    public func close() {
        webview.stopLoading()
        webview.configuration.userContentController.removeScriptMessageHandler(forName: WebKeys.webInterface)
        webview.configuration.userContentController.removeScriptMessageHandler(forName: "shopliveShortFormEvent")
    }
    
    public func setScrollable(_ scrollable: Bool) {
        webview.scrollView.isScrollEnabled = scrollable
    }
    
    public func configure(url: String) {
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        webview.load(request)
    }
    
    public func configure(html: String) {
        if webview.superview == nil {
            return
        }
        webview.loadHTMLString(html, baseURL: nil)
    }
    
    public func sendEventToWeb(event: String, parameter: Any? = nil, wrapping: Bool = false) {
        let command: String = parameter == nil ?
        "window.__receiveAppEvent('\(event)');" :
        "window.__receiveAppEvent('\(event)', " +
        (wrapping ?
         "'\(String(describing: parameter!))');" :
            "\(String(describing: parameter!)));")
        
        webview.evaluateJavaScript(command, completionHandler: nil)
    }
    
    public func sendShortsEvent(event: String, parameter: [String: Any]? = nil, completion: @escaping ()->Void) {
        
        var command = "window.cloud.shoplive.ExternalMessageManager.send('\(event)'"
        if let payload = parameter, let payloadData = payload.toJson_SL() {
            command += ",\(payloadData)"
        }
        
        command += ");"
        
        webview.evaluateJavaScript(command) { _, _ in
            completion()
        }
    }
    
    
}

extension SLWebView: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        slWebResponseDelegate?.handleEventMessage?(message: message)
    }
}

extension SLWebView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        slWebScrollDelegate?.scrollViewDidScroll?()
    }
}

// MARK: LeakAvoider
public class LeakAvoider : NSObject, WKScriptMessageHandler {
    weak var delegate : WKScriptMessageHandler?
    public init(delegate:WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    
    public func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
    
    deinit { }
}
