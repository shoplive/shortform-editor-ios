//
//  ShopLiveBackgroundPosterImageWebView.swift
//  ShopliveSDKCommon
//
//  Created by Tabber on 2/21/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import WebKit
import ShopliveSDKCommon

public class ShopLiveBackgroundPosterImageWebView: SLView, SLReactor {
    
    public enum Action {
        case setBackgroundUrl(url: URL?)
        case reload
    }
    
    public enum Result { }
    public var resultHandler: ((Result) -> ())?
    public weak var webView: SLWKWebView?
    
    private var cacheManager: ShopLiveWebViewCacheManager?
    
    init() {
        super.init(frame: .zero)
        let webView = SLWKWebView()
        self.webView = webView
        self.cacheManager = ShopLiveWebViewCacheManager()
        webView.navigationDelegate = self
        setLayout()
    }
    
    @preconcurrency required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func action(_ action: Action) {
        switch action {
        case .setBackgroundUrl(let url):
            self.onSetBackgroundUrl(url: url)
        case .reload:
            self.onReload()
        }
    }

    private func onSetBackgroundUrl(url: URL?) {
        guard let url else { return }
        
        cacheManager?.completionHandler = { [weak self] html in
            DispatchQueue.main.async { [weak self] in
                
                // html 값이 없거나 빈값일 경우 URL 로드
                guard let html, html != "" else {
                    self?.webView?.load(URLRequest(url: url))
                    return
                }
                
                self?.webView?.loadHTMLString(html, baseURL: url)
            }
        }
        
        cacheManager?.startDownload(url: url)
    }
    
    private func onReload() {
        webView?.reload()
    }
    
}

extension ShopLiveBackgroundPosterImageWebView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        let script: String = ShopLiveBackgroundPosterWebViewInterface.setBackgroundImageSrc(cacheManager?.getUrl() ?? "").stringValue
        
        self.webView?.evaluateJavaScript(script)
    }
}

//MARK: - setLayout
extension ShopLiveBackgroundPosterImageWebView {
    private func setLayout() {
        guard let webView = self.webView else { return }
        self.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.layer.masksToBounds = true
        webView.clipsToBounds = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.contentInset = .zero
        
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.topAnchor),
            webView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
