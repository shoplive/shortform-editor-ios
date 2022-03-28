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
        webView = nil
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
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = false
        configuration.mediaTypesRequiringUserActionForPlayback = []

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

    func didCompleteDownloadCoupon(with couponId: String) {
            self.webView?.sendEventToWeb(event: .completeDownloadCoupon, couponId, true)
        }

    
    func didCompleteDownloadCoupon(with couponResult: ShopLive.CouponResult) {
        guard let couponResultJson = couponResult.toJson() else {
            return
        }

        self.webView?.sendEventToWeb(event: .downloadCouponResult, couponResultJson)
    }
    
    @available(*, deprecated, message: "use didCompleteDownloadCoupon(with couponResult: ShopLive.CouponResult) instead")
    func didCompleteDownloadCoupon(with couponResult: CouponResult) {
        guard let couponResultJson = couponResult.toJson() else {
            return
        }

        self.webView?.sendEventToWeb(event: .downloadCouponResult, couponResultJson)
    }

    func didCompleteCustomAction(with customActionResult: ShopLive.CustomActionResult) {
        guard let customActionResultJson = customActionResult.toJson() else {
            return
        }

        self.webView?.sendEventToWeb(event: .customActionResult, customActionResultJson)
    }
    
    @available(*, deprecated, message: "use didCompleteCustomAction(with customActionResult: ShopLive.CustomActionResult) instead")
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

        guard message.name == ShopLiveDefines.webInterface else { return }
        if let body = message.body as? [String: Any],
           let shopliveEvent = body["shopliveEvent"] as? [String : Any],
           let metadata = shopliveEvent["metadata"] as? [String : String],
           let type = metadata["type"],
           let name = shopliveEvent["name"] as? String {

            let parameters = body["payload"] as? [String: Any]
            if type == "USER_IMPLEMENTS_CALLBACK" {
                ShopLiveViewLogger.shared.addLog(log: .init(logType: .interface, log: "[shopliveEvent] type: \(type) name: \(name) payload: \(parameters)"))
                ShopLiveLogger.debugLog("[shopliveEvent] type: \(type) name: \(name) payload: \(parameters)")
                if name == "ON_SUCCESS_CAMPAIGN_JOIN" {
                    ShopLiveController.shared.isSuccessCampaignJoin = true
                }

                delegate?.handleReceivedCommand(name, with: parameters)
            } else {
                ShopLiveViewLogger.shared.addLog(log: .init(logType: .interface, log: "[shopliveEvent] type: \(type) name: \(name) payload: \(parameters)"))
                ShopLiveLogger.debugLog("[shopliveEvent] type: \(type) name: \(name) payload: \(parameters)")
                
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
                    self.webView?.sendEventToWeb(event: .setVideoMute(isMuted: ShopLiveController.isMuted), ShopLiveController.isMuted)
                }
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
            self.isHidden = ShopLiveController.isHiddenOverlay
            return
        }
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        } completion: { (completion) in
            self.isHidden = ShopLiveController.isHiddenOverlay
        }
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
            if let overlayUrl = ShopLiveController.overlayUrl { //}, !ShopLiveController.shared.isPreview {
                self.loadOverlay(with: overlayUrl)
                ShopLiveLogger.debugLog("overlayUrl exist \(overlayUrl.absoluteString)")
            } else {
                ShopLiveLogger.debugLog(".overlayUrl")
            }
            break
        case .isPlaying:
            guard self.isSystemInitialized else { return }
            ShopLiveLogger.debugLog("isPlaying: \(ShopLiveController.isPlaying)")
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
