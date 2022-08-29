//
//  OverlayWebView.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/08.
//

import UIKit
import WebKit

internal class OverlayWebView: UIView {
    @objc dynamic var isPipMode: Bool = false
    
    private var isSystemInitialized: Bool = false
    private weak var webView: ShopLiveWebView?
    
    weak var delegate: OverlayWebViewDelegate?
    weak var webviewUIDelegate: WKUIDelegate? {
        didSet {
            webView?.uiDelegate = webviewUIDelegate
        }
    }

    private var inBuffering: Bool = false
    
    private var needSeek: Bool = false
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
    }
    
    init(with webViewConfiguration: WKWebViewConfiguration? =  nil) {
        super.init(frame: .zero)
        initWebView(with: webViewConfiguration)
        setupOverlayWebView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initWebView()
        setupOverlayWebView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWebView()
        setupOverlayWebView()
    }
    
    deinit {
        teardownOverlayWebView()
    }
    
    private func setupOverlayWebView() {
        addObserver()
    }
    
    private func teardownOverlayWebView() {
        webView?.stopLoading()
        webView?.configuration.userContentController.removeScriptMessageHandler(forName: ShopLiveDefines.webInterface)
        webView?.removeFromSuperview()
        ShopLiveController.shared.removePlayerDelegate(delegate: self)
        removeObserver()
        delegate = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func setHidden(toHidden: Bool) {
        self.webView?.isHidden = toHidden
    }
    
    private lazy var blockTouchView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private func initWebView(with webViewConfiguration: WKWebViewConfiguration? = nil) {
        ShopLiveController.shared.addPlayerDelegate(delegate: self)
        let configuration = webViewConfiguration ?? WKWebViewConfiguration()
        if #available(iOS 14.5, *) {
            configuration.preferences.isTextInteractionEnabled = false
        } else {
            // Fallback on earlier versions
        }
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = false
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.preferences.javaScriptEnabled = true

        let webView = ShopLiveWebView(frame: CGRect.zero, configuration: configuration)
        webView.scrollView.delegate = self
        ShopLiveController.webInstance = webView
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([webView.topAnchor.constraint(equalTo: self.topAnchor),
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

        webView.evaluateJavaScript("navigator.userAgent") { [weak webView] (result, error) in
            if let webView = webView, let defaultUserAgent = result as? String {
                webView.customUserAgent = defaultUserAgent + " shoplive/\(ShopLiveDefines.sdkVersion)"
                ShopLiveLogger.debugLog("userAgent: "+defaultUserAgent + " shoplive/\(ShopLiveDefines.sdkVersion)")
                ShopLiveViewLogger.shared.addLog(log: .init(logType: .interface, log: "userAgent: "+defaultUserAgent + " shoplive/\(ShopLiveDefines.sdkVersion)"))
            }
        }
        webView.configuration.userContentController.add(LeakAvoider(delegate: self), name: ShopLiveDefines.webInterface)
        self.webView = webView
        // setupBlockTouchView()
    }

    private func setupBlockTouchView() {
        self.addSubview(blockTouchView)
        self.bringSubviewToFront(blockTouchView)
        NSLayoutConstraint.activate([blockTouchView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
                                     blockTouchView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                                     blockTouchView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                                     blockTouchView.widthAnchor.constraint(equalTo: self.widthAnchor)
        ])

        self.blockTouchView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapBLockTouchView)))
    }

    func setBlockView(show: Bool) {
        self.blockTouchView.isHidden = !show
    }

    @objc private func tapBLockTouchView() {
        delegate?.didTouchBlockView()
    }
    
    private func loadOverlay(with url: URL) {
        DispatchQueue.main.async {
            self.webView?.load(URLRequest(url: url))
        }
    }
    
    func reload() {
        webView?.reload()
    }
    
    func sendCommandMessage(command: String, payload: [String : Any]?) {
            guard let payload = payload else {
                return
            }

            var message: [String : Any] = [:]

            message["command"] = command
            message["payload"] = payload

        self.webView?.sendEventToWeb(event: .sendCommandMessage, message.toJson() ?? "", false)
        }

    func didCompleteDownloadCoupon(with couponId: String) {
            self.webView?.sendEventToWeb(event: .completeDownloadCoupon, couponId, true)
        }

    
    func didCompleteDownloadCoupon(with couponResult: ShopLiveCouponResult) {
        guard let couponResultJson = couponResult.toJson() else {
            return
        }

        self.webView?.sendEventToWeb(event: .downloadCouponResult, couponResultJson)
    }
    
    @available(*, deprecated, message: "use didCompleteDownloadCoupon(with couponResult: ShopLiveCouponResult) instead")
    func didCompleteDownloadCoupon(with couponResult: CouponResult) {
        guard let couponResultJson = couponResult.toJson() else {
            return
        }

        self.webView?.sendEventToWeb(event: .downloadCouponResult, couponResultJson)
    }

    func didCompleteCustomAction(with customActionResult: ShopLiveCustomActionResult) {
        guard let customActionResultJson = customActionResult.toJson() else {
            return
        }

        self.webView?.sendEventToWeb(event: .customActionResult, customActionResultJson)
    }
    
    @available(*, deprecated, message: "use didCompleteCustomAction(with customActionResult: ShopLiveCustomActionResult) instead")
    func didCompleteCustomAction(with customActionResult: CustomActionResult) {
        guard let customActionResultJson = customActionResult.toJson() else {
            return
        }

        self.webView?.sendEventToWeb(event: .customActionResult, customActionResultJson)
    }

    func didCompleteCustomAction(with id: String) {
        self.webView?.sendEventToWeb(event: .completeCustomAction, id)
    }

    func closeWebSocket() {
        self.sendEventToWeb(event: .onTerminated)
    }

    func updatePipStyle(with style: ShopLive.PresentationStyle) {
        isPipMode = style == .pip
    }

    func sendEventToWeb(event: WebInterface, _ param: Any? = nil, _ wrapping: Bool = false) {
        self.webView?.sendEventToWeb(event: event, param, wrapping)
    }

     func addObserver() {
        self.addObserver(self, forKeyPath: "isPipMode", options: [.initial, .old, .new], context: nil)
     }

     func removeObserver() {
        self.removeObserver(self, forKeyPath: "isPipMode")
     }

     override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
         switch keyPath {
         case "isPipMode":
             guard let newValue: Bool = change?[.newKey] as? Bool else { return }
             guard self.isSystemInitialized else { return }
             self.webView?.sendEventToWeb(event: .onPipModeChanged, newValue)
             break
         default:
             break
         }
     }
}

extension OverlayWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ShopLiveController.shared.loading = false
    }
}

extension OverlayWebView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        ShopLiveLogger.debugLog("interface: \(WebInterface(message: message)?.functionString)")

        /**
            Receive data from web client
                - Receiving the data from Web Client
         */

        ShopLiveLogger.debugLog("web receive message.name: \(message.name) message.body: \(message.body)")
        
        guard message.name == ShopLiveDefines.webInterface else { return }
        if let body = message.body as? [String: Any],
           let shopliveEvent = body["shopliveEvent"] as? [String : Any],
           let metadata = shopliveEvent["metadata"] as? [String : String],
           let type = metadata["type"],
           let name = shopliveEvent["name"] as? String {

            let parameters = body["payload"] as? [String: Any]
            if type == "USER_IMPLEMENTS_CALLBACK" {
                ShopLiveViewLogger.shared.addLog(log: .init(logType: .interface, log: "[shopliveEvent] type: \(type) name: \(name) payload: \(parameters)"))
                ShopLiveLogger.debugLog("from Web [shopliveEvent] type: \(type) name: \(name) payload: \(parameters)")
                var passToReceivedCommand: Bool = true
                switch name {
                case "ON_SUCCESS_CAMPAIGN_JOIN":
                    ShopLiveController.shared.isSuccessCampaignJoin = true
                    break
                case "EVENT_LOG":
                    guard let feature = parameters?["feature"] as? String,
                            let featureType = ShopLiveLog.Feature.featureFrom(type: feature),
                            let name = parameters?["name"] as? String else { return }
                    
                    let logParameter: [String : String] = parameters?["parameter"] as? [String : String] ?? [:]
                    let campaignKey: String = (parameters?["campaignKey"] as? String) ?? ShopLiveController.shared.campaignKey
                    passToReceivedCommand = false
                    delegate?.log(name: name, feature: featureType, campaign: campaignKey, parameter: logParameter)
                    break
                case "CLICK_BACK_BUTTON":
                    delegate?.handleCommand("didTapCloseButton", with: nil)
                    break
                default:
                    break
                }
                
                if passToReceivedCommand {
                    delegate?.handleReceivedCommand(name, with: parameters)
                }

                
            } else {
                ShopLiveViewLogger.shared.addLog(log: .init(logType: .interface, log: "[shopliveEvent] type: \(type) name: \(name) payload: \(parameters)"))
                ShopLiveLogger.debugLog("from Web [shopliveEvent] type: \(type) name: \(name) payload: \(parameters)")
                
                switch name {
                case "SHOW_NATIVE_DEBUG":
                    ShopLiveViewLogger.shared.setVisible(show: true)
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
                        DispatchQueue.global(qos: .background).async {
                            SoundManager.shared.play(alias: alias)
                        }
                    }
                    break
                case "STOP_SOUND":
                    if let alias = parameters?["alias"] as? String {
                        DispatchQueue.global(qos: .background).async {
                            SoundManager.shared.stop(alias: alias)
                        }
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
                        delegate?.updateVideoExpanded()
                    }
                    break
                case "SET_VIDEO_POSITION":
                    guard let x = parameters?["x"] as? CGFloat, let y = parameters?["y"] as? CGFloat,
                          let height = parameters?["height"] as? CGFloat, let width = parameters?["width"] as? CGFloat,
                          let centerCrop = parameters?["centerCrop"] as? Int, let isCenterCrop = String(describing: centerCrop).boolValue else { return }
                    
                    
                    if ShopLiveController.shared.supportOrientation == .landscape {
                        let SET_VIDEO_POSITION_LOG = CGRect(x: x, y: y, width: width, height: height)

                        let right = (self.window?.frame.width ?? UIWindow.mainWindowFrame.frame.width) - x - width
                        let bottom = (self.window?.frame.height ?? UIWindow.mainWindowFrame.frame.height) - y - height
            
                        let playerFrame = CGRect(x: x, y: y, width: right, height: bottom)
                        
                            if UIScreen.isLandscape {
                                if ShopLiveController.shared.videoExpanded {
                                    ShopLiveController.shared.videoFrame.landscape.expanded = playerFrame
                                    if ShopLiveController.windowStyle == .normal {
                                        ShopLiveLogger.debugLog("update frame expanded")
                                        delegate?.updatePlayerFrame(centerCrop: ShopLiveController.shared.videoCenterCrop, playerFrame: playerFrame, immediately: true)
                                    }
                                } else {
                                    ShopLiveController.shared.videoFrame.landscape.standard = playerFrame
                                    if ShopLiveController.windowStyle == .normal {
                                        ShopLiveLogger.debugLog("update frame standard")
                                        delegate?.updatePlayerFrame(centerCrop: isCenterCrop, playerFrame: playerFrame, immediately: true)
                                    }
                                }
                            } else {
                                ShopLiveController.shared.videoFrame.portrait = playerFrame
                                if ShopLiveController.windowStyle == .normal {
                                    ShopLiveLogger.debugLog("update frame portrait")
                                    delegate?.updatePlayerFrame(centerCrop: isCenterCrop, playerFrame: playerFrame, immediately: true)
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
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.webView?.sendEventToWeb(event: .setVideoMute(isMuted: ShopLiveConfiguration.SoundPolicy.isMuted), ShopLiveConfiguration.SoundPolicy.isMuted)
                }
                
                let param: Dictionary = Dictionary<String, Any>.init(dictionaryLiteral: ("top", UIScreen.safeArea.top), ("left", UIScreen.safeArea.left),
                                                                     ("right", UIScreen.safeArea.right), ("bottom", UIScreen.safeArea.bottom), ("orientation", UIScreen.currentOrientation.angle))
                
                self.sendCommandMessage(command: "SET_SAFE_AREA_MARGIN", payload: param)
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.webView?.sendEventToWeb(event: .onPipModeChanged, self.isPipMode)
            }
        case .setVideoMute(let isMuted):
            ShopLiveLogger.debugLog("setVideoMute(\(isMuted))")
            delegate?.didTouchMuteButton(with: isMuted)
        case .setPosterUrl(let posterUrl):
            ShopLiveLogger.debugLog("setPosterUrl(\(posterUrl))")
            self.delegate?.didUpdatePoster(with: posterUrl)
        case .setLiveStreamUrl(let streamUrl):
            ShopLiveLogger.debugLog("setLiveStreamUrl(\(streamUrl.absoluteString))")
            self.delegate?.didUpdateVideo(with: streamUrl)
        case .setIsPlayingVideo(let isPlaying):
            if isPlaying {
                self.delegate?.didTouchPlayButton()
            }
            else {
                self.delegate?.didTouchPauseButton()
            }
            ShopLiveLogger.debugLog("setIsPlayingVideo(\(isPlaying))")
            ShopLiveController.isPlaying = isPlaying
        case .reloadVideo:
            ShopLiveLogger.debugLog("reloadVideo")
            self.delegate?.reloadVideo()
        case .startPictureInPicture:
            ShopLiveLogger.debugLog("startPictureInPicture")
            self.delegate?.didTouchPipButton()
        case .close:
            ShopLiveLogger.debugLog("close")
            self.delegate?.didTouchCloseButton()
        case .navigation(let navigationUrl):
            ShopLiveLogger.debugLog("navigation")
            self.delegate?.didTouchNavigation(with: navigationUrl)
        case .coupon(let id):
            ShopLiveLogger.debugLog("coupon")
            self.delegate?.didTouchCoupon(with: id)
        case .playVideo:
            ShopLiveLogger.debugLog("navigation")
            self.delegate?.didTouchPlayButton()
            ShopLiveController.isPlaying = true
        case .pauseVideo:
            ShopLiveLogger.debugLog("navigation")
            self.delegate?.didTouchPauseButton()
            ShopLiveController.isPlaying = false
        case .clickShareButton(let url):
            ShopLiveLogger.debugLog("clickShareButton(\(String(describing: url)))")
            self.delegate?.didTouchShareButton(with: url)
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
            self.delegate?.didTouchCustomAction(id: id, type: type, payload: payload)
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
            ShopLiveViewLogger.shared.setVisible(show: true)
            break
        case .debuglog(let log):
            ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: log))
            break
        case .setUserName(let payload):
            delegate?.onSetUserName(payload as [String : Any])
            break
        case .error(let code, let message):
            delegate?.onError(code: code, message: message)
            break
        case .command(let command, let payload):
            ShopLiveLogger.debugLog("rawCommand: \(command)\(payload == nil ? "" : "(\(payload as? String ?? "")")")
            self.delegate?.handleCommand(command, with: payload)
        default:
            break
        }
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
        case .isPlaying:
            guard self.isSystemInitialized else { return }
            ShopLiveController.webInstance?.sendEventToWeb(event: .setIsPlayingVideo(isPlaying: ShopLiveController.isPlaying), ShopLiveController.isPlaying)
            break
        default:
            break
        }
    }


}

class LeakAvoider : NSObject, WKScriptMessageHandler {
    weak var delegate : WKScriptMessageHandler?
    init(delegate:WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(
            userContentController, didReceive: message)
    }
}

extension NSObject {
    func propertyNames() -> [String] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap{ $0.label }
    }
}

extension OverlayWebView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ShopLiveLogger.debugLog("rect: \(scrollView.frame) webview inset: \(String(describing: webView?.scrollView.contentInset))")
        scrollView.setContentOffset(.init(x: 0, y: 0), animated: false)
    }
}
