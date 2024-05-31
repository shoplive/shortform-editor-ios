//
//  OverlayWebView.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/08.
//

import UIKit
import WebKit
import ShopliveSDKCommon

internal class OverlayWebView: SLView {
    private var _isPipMode : Bool = false
    var isPipMode: Bool  {
        set {
            self.setIsPipMode(isPipMode: newValue)
        }
        get {
            return _isPipMode
        }
    }
    var isSystemInitialized: Bool = false
    weak var webView: ShopLiveWebView?
    weak var delegate: OverlayWebViewDelegate?
    weak var webviewUIDelegate: WKUIDelegate? {
        didSet {
            webView?.uiDelegate = webviewUIDelegate
        }
    }
    
    /**
     must call setupOverlayWebView
     */
    init(with webViewConfiguration: WKWebViewConfiguration? =  nil) {
        super.init(frame: .zero)
        setUpWebView(with: webViewConfiguration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ShopLiveLogger.debugLog("overlayview deallocated")
    }
    
    func setupOverlayWebView() {
        ShopLiveController.shared.addPlayerDelegate(delegate: self)
    }
    
    func teardownOverlayWebView() {
        webView?.stopLoading()
        webView?.configuration.userContentController.removeAllUserScripts()
        if #available(iOS 14.0, *) {
            webView?.configuration.userContentController.removeAllScriptMessageHandlers()
        }
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: ShopLiveDefines.webInterface)
        webView?.removeFromSuperview()
        ShopLiveController.shared.removePlayerDelegate(delegate: self)
        webView = nil
        ShopLiveController.shared.webInstance = nil
        delegate = nil
    }
    
    func setHidden(toHidden: Bool) {
        self.webView?.isHidden = toHidden
    }
    
    func getCurrentUrl() -> URL? {
        return self.webView?.url
    }
    
    private func setUpWebView(with webViewConfiguration: WKWebViewConfiguration? = nil) {
        let webView = ShopLiveWebView(frame: CGRect.zero, configuration: self.setWebConfiguration())
        self.webView = webView
        webView.scrollView.delegate = self
        ShopLiveController.webInstance = webView
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.allowsLinkPreview = false
        webView.scrollView.layer.masksToBounds = false
        
        self.clipsToBounds = true
        sendUserAgentToWeb()
        webView.configuration.userContentController.add(SLLeakAvoider(delegate: self), name: ShopLiveDefines.webInterface)
    }
    
    private func setWebConfiguration(with webViewConfiguration : WKWebViewConfiguration? = nil) -> WKWebViewConfiguration {
        let configuration = webViewConfiguration ?? WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = false
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.preferences.javaScriptEnabled = true
        
        return configuration
    }
    
    private func sendUserAgentToWeb(){
        guard let webView = webView else { return }
        webView.evaluateJavaScript("navigator.userAgent") { (result, error) in
            guard let defaultUserAgent = result as? String else { return }
            webView.customUserAgent = defaultUserAgent + " shoplive/\(ShopLiveCommon.playerSdkVersion)"
            
            ShopLiveLogger.debugLog("userAgent: "+defaultUserAgent + " shoplive/\(ShopLiveCommon.playerSdkVersion)")
        }
    }
    
    
    private func loadOverlay(with url: URL) {
        self.webView?.removeQueuedRequest()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            ShopLiveLogger.debugLog("loadOverlay with \(url.absoluteString)")
            self.webView?.load(URLRequest(url: url))
        }
    }
    
    func reload(with url : URL){
        self.webView?.removeQueuedRequest()
        webView?.load(URLRequest(url: url))
    }
    
    func reload() {
        self.webView?.removeQueuedRequest()
        webView?.reload()
    }

    func updatePipStyle(with style: ShopLive.PresentationStyle) {
        isPipMode = style == .pip
    }
    
    private func setIsPipMode(isPipMode : Bool) {
        self._isPipMode = isPipMode
        guard self.isSystemInitialized else { return }
        self.webView?.sendEventToWeb(event: .onPipModeChanged, self.isPipMode)
    }
}

extension OverlayWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard !ShopLiveController.shared.isPreview else { return }
        guard !ShopLiveController.shared.isSameCampaign else { return }
        delegate?.requestHideOrShowLoadingFromWebView(isHidden: false)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard !ShopLiveController.shared.isPreview else { return }
        guard !ShopLiveController.shared.isSameCampaign else { return }
        self.webView?.setIsLoaded(isLoaded: false)
        delegate?.requestHideOrShowLoadingFromWebView(isHidden: false)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        if webView.url?.absoluteString == "about:blank" {
            delegate?.requestHideOrShowLoadingFromWebView(isHidden: false)
            delegate?.didFailToLoadWebViewWithNetworkUnreachable()
        }
        else {
            self.webView?.setIsLoaded(isLoaded: true)
            delegate?.requestHideOrShowLoadingFromWebView(isHidden: true)
            delegate?.webViewDidFinishedLoading()
//            self.webView?.invokeQueuedRequest()
//            //단순히 웹뷰가 load된게 아니라 진짜 렌더링 까지 끝나고 웹뷰 안쪽의 로직까지 끝나야 제대로 적용이 되는 것 같음
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.webView?.invokeQueuedRequest()
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if let blankUrl = URL(string: "about:blank") {
            self.webView?.load(URLRequest(url: blankUrl))
        }
        delegate?.requestHideOrShowLoadingFromWebView(isHidden: true)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
        if let blankUrl = URL(string: "about:blank") {
            self.webView?.load(URLRequest(url: blankUrl))
        }
        
        if let nsError = error as NSError? {
            switch nsError.domain {
            case NSURLErrorDomain:
                self.handleNSUrlDomainError(errorCode: nsError.code)
            case WKErrorDomain:
                self.handleWKErrorDomain(errorCode: nsError.code)
            case NSCocoaErrorDomain:
                self.handleNSCocoaErrorDomain(errorCode: nsError.code)
            default:
                break
            }
        }
        
        if NetworkReachability().connectionStatus() == .Offline {
            delegate?.didFailToLoadWebViewWithNetworkUnreachable()
        }
        else {
            delegate?.requestReloadWebView()
            delegate?.requestHideOrShowLoadingFromWebView(isHidden: true)
        }
    }
    
    private func handleNSUrlDomainError(errorCode : Int) {
        switch errorCode {
        case NSURLErrorNotConnectedToInternet:
            ShopLiveLogger.debugLog("[WEBVIEW_DIDFAIL_PROVISIONAL_NAVIGATION_URLDOMAIN] No internet connection")
        case NSURLErrorCannotFindHost:
            ShopLiveLogger.debugLog("[WEBVIEW_DIDFAIL_PROVISIONAL_NAVIGATION_URLDOMAIN] Cannot find host.")
        default:
            ShopLiveLogger.debugLog("[WEBVIEW_DIDFAIL_PROVISIONAL_NAVIGATION_URLDOMAIN] unknownError \(errorCode).")
        }
    }
    
    private func handleWKErrorDomain(errorCode : Int) {
        switch errorCode {
        case WKError.javaScriptExceptionOccurred.rawValue:
            ShopLiveLogger.debugLog("[WEBVIEW_DIDFAIL_PROVISIONAL_NAVIGATION_WKERRORDOMAIN] JavaScript exception occurred.")
        default:
            ShopLiveLogger.debugLog("[WEBVIEW_DIDFAIL_PROVISIONAL_NAVIGATION_WKERRORDOMAIN] unknownError \(errorCode)")
        }
    }
    
    private func handleNSCocoaErrorDomain(errorCode : Int) {
        switch errorCode {
        case NSUserCancelledError:
            ShopLiveLogger.debugLog("[WEBVIEW_DIDFAIL_PROVISIONAL_NAVIGATION_COCOERROR] User cancelled the operation.")
        default:
            ShopLiveLogger.debugLog("[WEBVIEW_DIDFAIL_PROVISIONAL_NAVIGATION_COCOERROR] unknownError \(errorCode)")
        }
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        delegate?.requestHideOrShowLoadingFromWebView(isHidden: true)
    }
}

extension OverlayWebView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == ShopLiveDefines.webInterface else { return }
        if let body = message.body as? [String: Any],
           let shopliveEvent = body["shopliveEvent"] as? [String : Any],
           let metadata = shopliveEvent["metadata"] as? [String : String],
           let type = metadata["type"],
           let name = shopliveEvent["name"] as? String {
            
            let parameters = body["payload"] as? [String: Any]
            if type == "USER_IMPLEMENTS_CALLBACK" {
                self.handleUserImplementsCallback(type: type, name: name, param: parameters)
            } else {
                switch name {
                case "ON_CLICK_SHARE_BUTTON":
                    self.handleON_CLICK_SHARE_BUTTON(payload: parameters)
                case "SHOW_NATIVE_DEBUG":
                    break
                case "VIBRATE":
                    if let typeValue = parameters?["type"] as? String, let style = HapticStyle(rawValue: typeValue)?.style {
                        HapticManager.impact(style: style)
                    }
                    break
                case "SET_SOUNDS":
                    if let sounds = parameters?["sounds"] as? [[String: String]] {
                        var newItems: [SoundItem] = []
                        sounds.forEach { sound in
                            if let alias = sound["alias"], let url = sound["url"] {
                                newItems.append(.init(alias: alias, url: url))
                            }
                        }
                        SoundManager.shared.addItems(newItems: newItems)
                    }
                    break
                case "PLAY_SOUND":
                    if let alias = parameters?["alias"] as? String {
                        SoundManager.shared.play(alias: alias)
                    }
                    break
                case "STOP_SOUND":
                    if let alias = parameters?["alias"] as? String {
                        SoundManager.shared.stop(alias: alias)
                    }
                    break
                case "OPEN_DEEPLINK":
                    if let scheme = parameters?["scheme"] as? String {
                        guard let schemeUrl = URL(string: scheme),
                              UIApplication.shared.canOpenURL(schemeUrl) else { return }
                        
                        UIApplication.shared.open(schemeUrl, options: [:], completionHandler: nil)
                    }
                    break
                case "ON_CHANGED_VIDEO_EXPANDED":
                    guard let videoExpanded = parameters?["videoExpanded"] as? Int, let isVideoExpended = String(describing: videoExpanded).boolValue else { return }
                    if ShopLiveController.shared.videoExpanded != isVideoExpended {
                        ShopLiveController.shared.videoExpanded = isVideoExpended
                    }
                    break
                case "SET_VIDEO_POSITION":
                    guard let x = parameters?["x"] as? CGFloat, let y = parameters?["y"] as? CGFloat,
                          let height = parameters?["height"] as? CGFloat, let width = parameters?["width"] as? CGFloat,
                          let centerCrop = parameters?["centerCrop"] as? Int, let isCenterCrop = String(describing: centerCrop).boolValue else { return }
                    
                    
                    if ShopLiveController.shared.supportOrientation == .landscape {
                        let right = (self.window?.frame.width ?? UIWindow.mainWindowFrame.frame.width) - x - width
                        let bottom = (self.window?.frame.height ?? UIWindow.mainWindowFrame.frame.height) - y - height
                        
                        let playerFrame = CGRect(x: x, y: y, width: right, height: bottom)
                        if UIScreen.isLandscape {
                            if ShopLiveController.shared.videoExpanded {
                                ShopLiveController.shared.videoFrame.landscape.expanded = playerFrame
                                if ShopLiveController.windowStyle == .normal || ShopLiveController.shared.needForceSetVideoPositionUpdate == true  {
                                    delegate?.updatePlayerViewFrameFromWeb(targetFrame: playerFrame)
                                }
                            } else {
                                ShopLiveController.shared.videoFrame.landscape.standard = playerFrame
                                if ShopLiveController.windowStyle == .normal || ShopLiveController.shared.needForceSetVideoPositionUpdate == true  {
                                    delegate?.updatePlayerViewFrameFromWeb(targetFrame: playerFrame)
                                }
                            }
                        } else {
                            ShopLiveController.shared.videoFrame.portrait = playerFrame
                            if ShopLiveController.windowStyle == .normal || ShopLiveController.shared.needForceSetVideoPositionUpdate == true {
                                delegate?.updatePlayerViewFrameFromWeb(targetFrame: playerFrame)
                            }
                        }
                    }
                    break
                case "SET_SCREEN_ORIENTATION":
                    guard !ShopLiveController.shared.keepOrientationWhenPlayStart else {
                        ShopLiveController.shared.keepOrientationWhenPlayStart = false
                        return
                    }
                    
                    guard let orientation = parameters?["orientation"] as? String else {
                        self.delegate?.updateOrientation(toLandscape: false)
                        return
                    }
                    
                    self.delegate?.updateOrientation(toLandscape: ("LANDSCAPE" == orientation))
                    break
                case "SET_PLAYBACK_SPEED":
                    if let playBackSpeed = parameters?["rate"] as? Float {
                        self.delegate?.didUpdatePlaybackSpeed(speed: playBackSpeed)
                    }
                case "ON_CHANGED_ACTIVITY_TYPE":
                    self.delegate?.didChangeActivityType(activityType: parameters?["activityType"] as? String ?? "", campaignKey: parameters?["campaignKey"] as? String ?? "")
                default:
                    break
                }
            }
            return
        }
        
        guard let interface = WebInterface(message: message) else { return }
        switch interface {
        case .systemInit:
            ShopLiveLogger.debugLog("systemInit")
            self.isSystemInitialized = true
            ShopLiveController.shared.initialize()
            self.webView?.sendEventToWeb(event: .videoInitialized)
            if !ShopLiveController.shared.isPreview {
                let param: Dictionary = Dictionary<String, Any>.init(dictionaryLiteral: ("top", UIScreen.safeArea.top), ("left", UIScreen.safeArea.left),
                                                                     ("right", UIScreen.safeArea.right), ("bottom", UIScreen.safeArea.bottom), ("orientation", UIScreen.currentOrientation.angle))
                
                self.sendCommandMessage(command: "SET_SAFE_AREA_MARGIN", payload: param)
                
            }
            self.delegate?.requestNetworkCapabilityOnSystemInit()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.webView?.sendEventToWeb(event: .onPipModeChanged, self.isPipMode)
            }
        case .setVideoMute(let isMuted):
            ShopLiveLogger.debugLog("setVideoMute(\(isMuted))")
            delegate?.didTouchWebViewMuteButton(with: isMuted)
        case .setPosterUrl(let posterUrl):
            ShopLiveLogger.debugLog("setPosterUrl(\(posterUrl))")
            self.delegate?.didUpdatePoster(with: posterUrl)
        case .setLiveStreamUrl(let streamUrl):
            ShopLiveLogger.debugLog("setLiveStreamUrl(\(streamUrl.absoluteString))")
            self.delegate?.didUpdateVideo(with: streamUrl)
        case .setIsPlayingVideo(let isPlaying):
            if isPlaying {
                self.delegate?.didTouchWebViewPlayButton()
            }
            else {
                self.delegate?.didTouchWebViewPauseButton()
            }
            ShopLiveLogger.debugLog("setIsPlayingVideo(\(isPlaying))")
            ShopLiveController.isPlaying = isPlaying
        case .reloadVideo:
            ShopLiveLogger.debugLog("reloadVideo")
            self.delegate?.reloadVideo()
        case .startPictureInPicture:
            ShopLiveLogger.debugLog("startPictureInPicture")
            self.delegate?.didTouchWebViewPipButton()
        case .close:
            ShopLiveLogger.debugLog("webView back btn close")
            self.delegate?.didTouchWebViewCloseButton()
        case .navigation(let navigationUrl):
            ShopLiveLogger.debugLog("navigationUrl")
            self.delegate?.didTouchWebViewNavigation(with: navigationUrl)
        case .coupon(let id):
            ShopLiveLogger.debugLog("coupon")
            self.delegate?.didTouchWebViewCoupon(with: id)
        case .playVideo:
            ShopLiveLogger.debugLog("navigation")
            self.delegate?.didTouchWebViewPlayButton()
            ShopLiveController.isPlaying = true
        case .pauseVideo:
            ShopLiveLogger.debugLog("pauseVideo")
            self.delegate?.didTouchWebViewPauseButton()
            ShopLiveController.isPlaying = false
        case .replay(let width, let height):
            ShopLiveLogger.debugLog("replay")
            self.delegate?.replay(with: CGSize(width: width, height: height))
        case .setVideoCurrentTime(let time):
            self.delegate?.setVideoCurrentTime(to: .init(seconds: time, preferredTimescale: 1))
        case .enableSwipeDown:
            ShopLiveController.shared.swipeEnabled = true
        case .disableSwipeDown:
            ShopLiveController.shared.swipeEnabled = false
        case .customAction(let id, let type, let payload):
            self.delegate?.didTouchWebViewCustomAction(id: id, type: type, payload: payload)
            break
        case .onCampaignStatusChanged(let status):
            ShopLiveController.shared.campaignStatus = .init(rawValue: status) ?? .close
            delegate?.didChangeCampaignStatus(status: status)
            break
        case .setParam(let key, let value):
            ShopLiveLogger.debugLog("setparam key: \(key) value: \(value)")
            guard ShopLiveConfiguration.Data.useLocalStorage, key == ShopLiveDefines.shopliveData else { return }
            UserDefaults.standard.set(value, forKey: ShopLiveDefines.shopliveData)
            UserDefaults.standard.synchronize()
            break
        case .delParam(_):
            UserDefaults.standard.removeObject(forKey: ShopLiveDefines.shopliveData)
            break
        case .showNativeDebug:
            break
        case .debuglog(let log):
            break
        case .setUserName(let payload):
            delegate?.onSetUserName(payload as [String : Any])
            break
        case .error(let code, let message):
            delegate?.onError(code: code, message: message)
            break
        case .command(let command, let payload):
            self.delegate?.handleCommand(command, with: payload)
        default:
            break
        }
    }
    
    private func handleON_CLICK_SHARE_BUTTON(payload : [String : Any]?) {
        guard let payload = payload else { return }
        let shareUrl = ShopLiveController.shared.shareScheme
        delegate?.requestHandleShare(data: .init(campaign: .init(payload: payload), url: shareUrl))
    }
}

extension OverlayWebView: ShopLivePlayerDelegate {
    func handleIsHiddenOverlay() {
        guard !ShopLiveController.isHiddenOverlay else {
            self.alpha = 0.0
            self.isHidden = true
            return
        }
        
        self.alpha = 1.0
        self.isHidden = false
    }
    
    var identifier: String {
        return "OverlayWebView"
    }
    
    func updatedValue(key: ShopLivePlayerObserveValue) {
        switch key {
        case .isHiddenOverlay:
            handleIsHiddenOverlay()
            break
        case .overlayUrl:
            if let overlayUrl = ShopLiveController.overlayUrl {
                self.loadOverlay(with: overlayUrl)
                ShopLiveLogger.debugLog("overlayUrl exist \(overlayUrl.absoluteString)")
            } else {
                ShopLiveLogger.debugLog(".overlayUrl")
            }
            break
        default:
            break
        }
    }
}

extension OverlayWebView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ShopLiveLogger.debugLog("rect: \(scrollView.frame) webview inset: \(String(describing: webView?.scrollView.contentInset))")
        scrollView.setContentOffset(.init(x: 0, y: 0), animated: false)
    }
}

