//
//  ShopLiveCombine.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/04.
//

import UIKit
import AVKit
import WebKit

@objc internal final class ShopLiveBase: NSObject {

    private var shopLiveWindow: UIWindow? = nil
    private var videoWindowPanGestureRecognizer: UIPanGestureRecognizer?
    private var videoWindowTapGestureRecognizer: UITapGestureRecognizer?

    private var videoWindowSwipeDownGestureRecognizer: UISwipeGestureRecognizer?
    private var _webViewConfiguration: WKWebViewConfiguration?
    private var isRestoredPip: Bool = false
    private var accessKey: String? = nil
    internal var phase: ShopLive.Phase = .REAL {
        didSet {
            ShopLiveDefines.phase = phase
        }
    }
    private var campaignKey: String?

    private var isKeyboardShow: Bool = false
    private var lastPipPosition: ShopLive.PipPosition = .default
    private var lastPipScale: CGFloat = 2/5
    private var replaySize: CGSize = CGSize(width: 9, height: 16)
    weak private var mainWindow: UIWindow? = nil
    
    @objc dynamic var _style: ShopLive.PresentationStyle = .unknown
    @objc dynamic var _authToken: String?
    @objc dynamic var _user: ShopLiveUser?

    private var previewCallback: (() -> Void)?
    
    var liveStreamViewController: LiveStreamViewController?
    var pictureInPictureController: AVPictureInPictureController?
    
    var pipPossibleObservation: NSKeyValueObservation?
    var originAudioSessionCategory: AVAudioSession.Category?

    weak var _delegate: ShopLiveSDKDelegate?
    
    override init() {
        super.init()
    }

    deinit {
    }

    func showPreview(previewUrl: URL, completion: @escaping () -> Void) {
        liveStreamViewController?.viewModel.authToken = _authToken
        liveStreamViewController?.viewModel.user = _user
        showShopLiveView(with: previewUrl)
    }

    func showShopLiveView(with overlayUrl: URL, _ completion: (() -> Void)? = nil) {
        UIApplication.shared.isIdleTimerDisabled = true

        if _style == .fullScreen {
            liveStreamViewController?.viewModel.overayUrl = overlayUrl
            liveStreamViewController?.reload()
            liveStreamViewController?.updateChattingWriteView()
        } else if _style == .pip {
            liveStreamViewController?.viewModel.overayUrl = overlayUrl
            liveStreamViewController?.reload()
            liveStreamViewController?.updateChattingWriteView()

            if !ShopLiveController.shared.isPreview {
                stopShopLivePictureInPicture()
                return
            }
        }

        guard liveStreamViewController == nil else {
            setupPictureInPicture()
            return
        }

        if !ShopLiveController.shared.isPreview {
            delegate?.handleCommand("willShopLiveOn", with: nil)
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        originAudioSessionCategory = audioSession.category
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
        } catch  {
            print("Audio session failed")
        }

        ShopLiveController.shared.releaseData()

        liveStreamViewController = LiveStreamViewController()
        liveStreamViewController?.delegate = self
        liveStreamViewController?.webViewConfiguration = _webViewConfiguration
        liveStreamViewController?.viewModel.overayUrl = overlayUrl
        liveStreamViewController?.viewModel.authToken = _authToken
        liveStreamViewController?.viewModel.user = _user
        
        mainWindow = (UIApplication.shared.windows.first(where: { $0.isKeyWindow }))
        
        shopLiveWindow = UIWindow()
        if #available(iOS 13.0, *) {
            shopLiveWindow?.windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        }
        shopLiveWindow?.backgroundColor = .clear
        shopLiveWindow?.windowLevel = .statusBar - 1
        shopLiveWindow?.frame = ShopLiveController.shared.isPreview ? pipPosition(with: lastPipScale, position: lastPipPosition) : mainWindow?.frame ?? UIScreen.main.bounds
        shopLiveWindow?.rootViewController = liveStreamViewController

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(liveWindowPanGestureHandler))
        shopLiveWindow?.addGestureRecognizer(panGesture)
        videoWindowPanGestureRecognizer = panGesture
        videoWindowPanGestureRecognizer?.isEnabled = ShopLiveController.shared.isPreview ? true : false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pipTapGestureHandler))
        shopLiveWindow?.addGestureRecognizer(tapGesture)
        videoWindowTapGestureRecognizer = tapGesture
        videoWindowTapGestureRecognizer?.isEnabled = ShopLiveController.shared.isPreview ? true : false
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGestureHandler))
        swipeDownGesture.direction = .down
        shopLiveWindow?.addGestureRecognizer(swipeDownGesture)
        videoWindowSwipeDownGestureRecognizer = swipeDownGesture
        videoWindowSwipeDownGestureRecognizer?.isEnabled = ShopLiveController.shared.isPreview ? false : true
        
        setupPictureInPicture()
        shopLiveWindow?.makeKeyAndVisible()

        liveStreamViewController?.view.alpha = 0

        ShopLiveLogger.debugLog("ShowShopLiveView")
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
            self.liveStreamViewController?.view.alpha = 1.0
        }

        if ShopLiveController.shared.isPreview {
            willChangePreview()
            _style = .pip
        } else {
            mainWindow?.rootViewController?.shopliveHideKeyboard()
            _style = .fullScreen
        }
    }
    
    func hideShopLiveView(_ animated: Bool = true) {
        UIApplication.shared.isIdleTimerDisabled = false

        ShopLiveController.webInstance?.sendEventToWeb(event: .onTerminated)
        delegate?.handleCommand("willShopLiveOff", with: ["style" : style.rawValue])
        if let originAudioSessionCategory = self.originAudioSessionCategory {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(originAudioSessionCategory)
            } catch  {
                ShopLiveLogger.debugLog("Audio session failed")
            }
        }
        
        if let videoWindowPanGestureRecognizer = self.videoWindowPanGestureRecognizer {
            shopLiveWindow?.removeGestureRecognizer(videoWindowPanGestureRecognizer)
        }
        if let videoWindowTapGestureRecognizer = self.videoWindowTapGestureRecognizer {
            shopLiveWindow?.removeGestureRecognizer(videoWindowTapGestureRecognizer)
        }
        if let videoWindowSwipeDownGestureRecognizer = self.videoWindowSwipeDownGestureRecognizer {
            shopLiveWindow?.removeGestureRecognizer(videoWindowSwipeDownGestureRecognizer)
        }

        removeObserver()
        ShopLiveController.shared.releaseData()
        SoundManager.shared.removeAllSounds()
        
        self.shopLiveWindow?.transform = .identity
        self.shopLiveWindow?.alpha = 1

        self.shopLiveWindow?.resignKey()
        self.mainWindow?.makeKeyAndVisible()

        self.videoWindowPanGestureRecognizer = nil
        self.videoWindowTapGestureRecognizer = nil
        self.pictureInPictureController = nil

        self.liveStreamViewController?.removeFromParent()
        self.liveStreamViewController?.stop()
        self.liveStreamViewController?.delegate = nil
        self.liveStreamViewController = nil

        self.mainWindow = nil
        self.shopLiveWindow?.removeFromSuperview()
        self.shopLiveWindow?.rootViewController = nil

        self.shopLiveWindow = nil

        self.delegate?.handleCommand("didShopLiveOff", with: ["style" : self.style.rawValue])
        self._style = .unknown
        self._authToken = nil
        self._user = nil
        ShopLiveController.shared.resetOnlyFinished()
    }
    
    func setupPictureInPicture() {
        guard !ShopLiveController.shared.isPreview else {
            do {
                pictureInPictureController?.delegate = nil
                try AVAudioSession.sharedInstance().setActive(false)
                self.pictureInPictureController = nil
            } catch {}
            return
        }
        guard pictureInPictureController == nil else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            ShopLiveLogger.debugLog("interruption setActive")
        }
        catch let error {
            ShopLiveLogger.debugLog("interruption setActive Failed error: \(error.localizedDescription)")
            debugPrint(error)
        }

        guard let playerLayer = liveStreamViewController?.playerLayer else { return }
        playerLayer.frame = CGRect(x: 100, y: 100, width: 320, height: 180)
        // Ensure PiP is supported by current device.
        if AVPictureInPictureController.isPictureInPictureSupported() {
            // Create a new controller, passing the reference to the AVPlayerLayer.
            pictureInPictureController = AVPictureInPictureController(playerLayer: playerLayer)
            pictureInPictureController?.delegate = self


            if #available(iOS 14.0, *) {
                pictureInPictureController?.requiresLinearPlayback = false
            } else {
                // Fallback on earlier versions
            }
        } else {
            // PiP isn't supported by the current device. Disable the PiP button.
        }
    }
    
    func startShopLivePictureInPicture() {
        startCustomPictureInPicture(with: lastPipPosition, scale: lastPipScale)
    }
    
    func stopShopLivePictureInPicture() {
        stopCustomPictureInPicture()
    }
    
    private func pipSize(with scale: CGFloat) -> CGSize {
        guard let mainWindow = self.mainWindow else { return .zero }

        let defSize = CGSize(width: 9, height: 16)
        let width = mainWindow.bounds.width * scale
        let height = (defSize.height / defSize.width) * width

        return CGSize(width: width, height: height)
    }

    private func pipPosition(with scale: CGFloat = 2/5, position: ShopLive.PipPosition = .default) -> CGRect {
        guard let mainWindow = self.mainWindow else { return .zero }

        var pipPosition: CGRect = .zero
        var origin = CGPoint.zero
        let safeAreaInsets = mainWindow.safeAreaInsets
        let pipSize = self.pipSize(with: scale)
        let pipEdgeInsets: UIEdgeInsets = ShopLiveConfiguration.UI.pipPadding
        let pipFloatingOffset: UIEdgeInsets = ShopLiveConfiguration.UI.pipFloatingOffset
        let pipFloatingOffsetBottom: CGFloat = isKeyboardShow ? 0 : pipFloatingOffset.bottom
        let keyboardHeight: CGFloat = isKeyboardShow ? ShopLiveController.shared.keyboardHeight : 0
        
        switch position {
        case .bottomRight, .default:
            origin.x = mainWindow.frame.width - safeAreaInsets.right - pipEdgeInsets.right - pipSize.width - pipFloatingOffset.right
            origin.y = mainWindow.frame.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight - pipFloatingOffsetBottom
        case .bottomLeft:
            origin.x = safeAreaInsets.left + pipEdgeInsets.left + pipFloatingOffset.left
            origin.y = mainWindow.frame.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight - pipFloatingOffsetBottom
        case .topRight:
            origin.x = mainWindow.frame.width - safeAreaInsets.right - pipEdgeInsets.right - pipSize.width - pipFloatingOffset.right
            origin.y = safeAreaInsets.top + pipEdgeInsets.top + pipFloatingOffset.top
        case .topLeft:
            origin.x = safeAreaInsets.left + pipEdgeInsets.left + pipFloatingOffset.left
            origin.y = safeAreaInsets.top + pipEdgeInsets.top + pipFloatingOffset.top
        }

        pipPosition = CGRect(origin: origin, size: pipSize)

        return pipPosition
    }
    
    private func startCustomPictureInPicture(with position: ShopLive.PipPosition = .default, scale: CGFloat = 2/5) {

        guard let topVC = UIApplication.topViewController(), topVC.isKind(of: LiveStreamViewController.self) else {
            return
        }
        
        delegate?.handleCommand("willShopLiveOff", with: ["style" : style.rawValue])
        guard !ShopLiveController.shared.pipAnimating else { return }
        guard let shopLiveWindow = self.shopLiveWindow else { return }

        shopLiveWindow.rootViewController?.view.backgroundColor = .clear

        liveStreamViewController?.shopliveHideKeyboard()
        let pipPosition: CGRect = self.pipPosition(with: scale, position: position)

        ShopLiveController.windowStyle = .inAppPip
        shopLiveWindow.clipsToBounds = false
        shopLiveWindow.rootViewController?.view.layer.cornerRadius = 10

//        liveStreamViewController?.hideBackgroundPoster()
        ShopLiveController.webInstance?.isHidden = true
        videoWindowPanGestureRecognizer?.isEnabled = true
        videoWindowTapGestureRecognizer?.isEnabled = true
        videoWindowSwipeDownGestureRecognizer?.isEnabled = false

        UIView.animate(withDuration: 0.4, delay: 0, options: []) {
            ShopLiveController.isHiddenOverlay = true
            shopLiveWindow.frame = pipPosition
            shopLiveWindow.rootViewController?.view.clipsToBounds = true
            shopLiveWindow.layer.shadowColor = UIColor.black.cgColor
            shopLiveWindow.layer.shadowOpacity = 0.5
            shopLiveWindow.layer.shadowOffset = .zero
            shopLiveWindow.layer.shadowRadius = 10
            ShopLiveController.shared.pipAnimating = false
            shopLiveWindow.setNeedsLayout()
            shopLiveWindow.layoutIfNeeded()
        } completion: { (isCompleted) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100), execute: {
                shopLiveWindow.rootViewController?.view.backgroundColor = .black
            })
        }

        delegate?.handleCommand("didShopLiveOff", with: ["style" : style.rawValue])
        _style = .pip
    }

    private func stopCustomPictureInPicture() {

        setupPictureInPicture()

        guard !ShopLiveController.shared.pipAnimating else { return }
        guard let mainWindow = self.mainWindow else { return }
        guard let shopLiveWindow = self.shopLiveWindow else { return }

        shopLiveWindow.rootViewController?.view.backgroundColor = .clear

        mainWindow.rootViewController?.shopliveHideKeyboard()

        delegate?.handleCommand("willShopLiveOn", with: nil)
        ShopLiveController.shared.pipAnimating = true
        ShopLiveController.webInstance?.isHidden = false

        videoWindowPanGestureRecognizer?.isEnabled = false
        videoWindowTapGestureRecognizer?.isEnabled = false
        videoWindowSwipeDownGestureRecognizer?.isEnabled = true
        ShopLiveController.windowStyle = .normal

        shopLiveWindow.layer.shadowColor = nil
        shopLiveWindow.layer.shadowOpacity = 0.0
        shopLiveWindow.layer.shadowOffset = .zero
        shopLiveWindow.layer.shadowRadius = 0

        UIView.animate(withDuration: 0.3, delay: 0, options: []) {
            shopLiveWindow.frame = mainWindow.bounds
            shopLiveWindow.layer.cornerRadius = 0
            shopLiveWindow.setNeedsLayout()
            shopLiveWindow.layoutIfNeeded()
            shopLiveWindow.rootViewController?.view.layer.cornerRadius = 0
        } completion: { (isCompleted) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300), execute: {
                ShopLiveController.isHiddenOverlay = false
                ShopLiveController.shared.pipAnimating = false
                shopLiveWindow.rootViewController?.view.backgroundColor = .black
            })
        }

        _style = .fullScreen
    }

    func willChangePreview() {
        ShopLiveController.windowStyle = .inAppPip

        let pipSize: CGRect = self.pipPosition(with: lastPipScale, position: lastPipPosition)
        self.shopLiveWindow?.frame = pipSize
        self.shopLiveWindow?.clipsToBounds = false
        self.shopLiveWindow?.rootViewController?.view.layer.cornerRadius = 10
        self.shopLiveWindow?.rootViewController?.view.backgroundColor = .black

        videoWindowPanGestureRecognizer?.isEnabled = true
        videoWindowTapGestureRecognizer?.isEnabled = true
        videoWindowSwipeDownGestureRecognizer?.isEnabled = false

        ShopLiveController.isHiddenOverlay = true

        self.shopLiveWindow?.rootViewController?.view.clipsToBounds = true
        self.shopLiveWindow?.layer.shadowColor = UIColor.black.cgColor
        self.shopLiveWindow?.layer.shadowOpacity = 0.5
        self.shopLiveWindow?.layer.shadowOffset = .zero
        self.shopLiveWindow?.layer.shadowRadius = 10

        self.shopLiveWindow?.layoutIfNeeded()
        self.liveStreamViewController?.view.layoutIfNeeded()

    }

    func didChangeOSPIP() {
        guard !ShopLiveController.shared.isPreview else { return }
        guard let mainWindow = self.mainWindow else { return }
        guard let shopLiveWindow = self.shopLiveWindow else { return }
        guard _style != .fullScreen else { return }
        shopLiveWindow.frame = mainWindow.bounds

        mainWindow.rootViewController?.shopliveHideKeyboard()

        videoWindowPanGestureRecognizer?.isEnabled = false
        videoWindowTapGestureRecognizer?.isEnabled = false
        videoWindowSwipeDownGestureRecognizer?.isEnabled = true
        ShopLiveController.webInstance?.isHidden = false

        shopLiveWindow.layer.shadowColor = nil
        shopLiveWindow.layer.shadowOpacity = 0.0
        shopLiveWindow.layer.shadowOffset = .zero
        shopLiveWindow.layer.shadowRadius = 0

        shopLiveWindow.rootViewController?.view.backgroundColor = .clear

        shopLiveWindow.layer.cornerRadius = 0
        shopLiveWindow.rootViewController?.view.layer.cornerRadius = 0
        shopLiveWindow.layoutIfNeeded()

        self.liveStreamViewController?.showBackgroundPoster()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300), execute: {
            ShopLiveController.isHiddenOverlay = false
            ShopLiveController.shared.pipAnimating = false
            shopLiveWindow.rootViewController?.view.backgroundColor = .black
        })
    }

    private func alignPipView() {
        guard let currentCenter = shopLiveWindow?.center else { return }
        guard let mainWindow = self.mainWindow else { return }
        let center = mainWindow.center
        let rate = (mainWindow.frame.height - ShopLiveController.shared.keyboardHeight) / mainWindow.frame.height
        let isPositiveDiffX = center.x - currentCenter.x > 0
        let isPositiveDiffY = (center.y * rate) - currentCenter.y > 0
        let position: ShopLive.PipPosition = {
            switch (isPositiveDiffX, isPositiveDiffY) {
            case (true, true):
                return .topLeft
            case (true, false):
                return .bottomLeft
            case (false, true):
                return .topRight
            case (false, false):
                return .bottomRight
            }
        }()

        lastPipPosition = position
        self.handleKeyboard()

    }
    
    private func alignPipPosion(pipCenter: CGPoint) -> ShopLive.PipPosition {
        guard let mainWindow = self.mainWindow else { return .bottomRight }
        let center = mainWindow.center
        let rate = (mainWindow.frame.height - ShopLiveController.shared.keyboardHeight) / mainWindow.frame.height
        let isPositiveDiffX = center.x - pipCenter.x > 0
        let isPositiveDiffY = (center.y * rate) - pipCenter.y > 0
        let position: ShopLive.PipPosition = {
            switch (isPositiveDiffX, isPositiveDiffY) {
            case (true, true):
                return .topLeft
            case (true, false):
                return .bottomLeft
            case (false, true):
                return .topRight
            case (false, false):
                return .bottomRight
            }
        }()
        
        return position
    }
    
    var panGestureInitialCenter: CGPoint = .zero

    @objc private func liveWindowPanGestureHandler(_ recognizer: UIPanGestureRecognizer) {
        guard _style == .pip else { return }
        guard let liveWindow = recognizer.view else { return }
        
        let translation = recognizer.translation(in: liveWindow)
        
        switch recognizer.state {
        case .began:
            panGestureInitialCenter = liveWindow.center
        case .changed:
            let centerX = panGestureInitialCenter.x + translation.x
            let centerY = panGestureInitialCenter.y + translation.y
            liveWindow.center = CGPoint(x: centerX, y: centerY)
        case .ended:
            guard let mainWindow = self.mainWindow else { return }
            let velocity = recognizer.velocity(in: liveWindow)

            let safeAreaInset = mainWindow.safeAreaInsets
            let pipEdgeInsets: UIEdgeInsets = ShopLiveConfiguration.UI.pipPadding
            let pipFloatingOffset: UIEdgeInsets = ShopLiveConfiguration.UI.pipFloatingOffset
            let pipFloatingOffsetBottom: CGFloat = isKeyboardShow ? 0 : pipFloatingOffset.bottom
            
            let mainWindowHeight: CGFloat = mainWindow.bounds.height - (isKeyboardShow ? ShopLiveController.shared.keyboardHeight : 0)
            let minX = (liveWindow.bounds.width / 2.0) + pipEdgeInsets.left + safeAreaInset.left + liveWindow.bounds.origin.x + pipFloatingOffset.left
            let maxX = mainWindow.bounds.width - ((liveWindow.bounds.width / 2.0) + pipEdgeInsets.right + safeAreaInset.right + pipFloatingOffset.right)
            let minY = liveWindow.bounds.height / 2.0 + pipEdgeInsets.top + safeAreaInset.top + pipFloatingOffset.top + liveWindow.bounds.origin.y + pipFloatingOffset.top
            let maxY = mainWindowHeight - ((liveWindow.bounds.height / 2.0) + pipEdgeInsets.bottom + pipFloatingOffsetBottom + safeAreaInset.bottom)
            
            var centerX = panGestureInitialCenter.x + translation.x
            var centerY = panGestureInitialCenter.y + translation.y
            
            let xRange = 0...(mainWindow.bounds.width)
            let yRange = (0 + safeAreaInset.top)...(mainWindowHeight - (safeAreaInset.bottom)) + (isKeyboardShow ? liveWindow.frame.height * 0.2 : 0)
            
            //범위밖으로 나가면 stop shoplive
            guard xRange.contains(centerX), yRange.contains(centerY) else {
                hideShopLiveView()
                return
            }
            
            let animationDuration: CGFloat = 0.7
            
            if velocity.x.magnitude > 600 {
                if centerX + velocity.x < minX {
                    centerX = minX
                } else if centerX + velocity.x > maxX {
                    centerX = maxX
                }
            }
            
            if velocity.y.magnitude > 600 {
                if centerY + velocity.y < minY {
                    centerY = minY
                } else if centerY + velocity.y > maxY {
                    centerY = maxY
                }
            }
            
            switch alignPipPosion(pipCenter: .init(x: centerX, y: centerY)) {
            case .bottomLeft:
                centerX = minX
                centerY = maxY
                break
            case .topLeft:
                centerX = minX
                centerY = minY
            case .topRight:
                centerX = maxX
                centerY = minY
                break
            case .bottomRight:
                centerX = maxX
                centerY = maxY
                break
            case .default:
                centerX = maxX
                centerY = maxY
                break
            }
            
            let destination = CGPoint(x: centerX, y: centerY)
            let parameters = UISpringTimingParameters(dampingRatio: 1, initialVelocity: .init(dx: 0, dy: 0))
            let animator = UIViewPropertyAnimator(duration: TimeInterval(animationDuration), timingParameters: parameters)

            animator.addAnimations {
                liveWindow.center = destination
                self.alignPipView()
            }

            animator.startAnimation()
        default:
            break
        }
    }
    
    @objc private func swipeDownGestureHandler(_ recognizer: UISwipeGestureRecognizer) {
        guard ShopLiveController.shared.swipeEnabled else { return }
        guard !ShopLiveController.shared.isPreview else { return }
        guard _style == .fullScreen else { return }
        startShopLivePictureInPicture()
    }
    
    @objc private func pipTapGestureHandler(_ recognizer: UITapGestureRecognizer) {
        guard !ShopLiveController.shared.isPreview else {
            previewCallback?()
            return
        }
        guard _style == .pip else { return }
        stopShopLivePictureInPicture()
    }

    func fetchPreviewUrl(with campaignKey: String?, completionHandler: @escaping ((URL?) -> Void)) {
        let urlComponents = URLComponents(string: ShopLiveConfiguration.AppPreference.landingUrl)
        var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "ak", value: accessKey))
        if let ck = campaignKey {
            queryItems.append(URLQueryItem(name: "ck", value: ck))
        }

        queryItems.append(URLQueryItem(name: "version", value: ShopLiveDefines.sdkVersion))
        queryItems.append(URLQueryItem(name: "preview", value: "1"))

        let baseUrl = URL(string: ShopLiveConfiguration.AppPreference.landingUrl)
        guard let params = URLUtil.query(queryItems) else {
            completionHandler(baseUrl)
            return
        }

        guard let url = URL(string: ShopLiveConfiguration.AppPreference.landingUrl + "?" + params) else {
            completionHandler(baseUrl)
            return
        }

        completionHandler(url)
    }

    func fetchOverlayUrl(with campaignKey: String?, completionHandler: ((URL?) -> Void)) {
        guard let accessKey = self.accessKey else {
            completionHandler(nil)
            return
        }

        let urlComponents = URLComponents(string: ShopLiveConfiguration.AppPreference.landingUrl)
        var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()
        #if DEMO
        if UserDefaults.standard.bool(forKey: "useWebLog") {
            queryItems.append(URLQueryItem(name: "__debug", value: "true"))
        }
        #endif
        queryItems.append(URLQueryItem(name: "ak", value: accessKey))
        if let ck = campaignKey {
            queryItems.append(URLQueryItem(name: "ck", value: ck))
        }
        queryItems.append(URLQueryItem(name: "version", value: ShopLiveDefines.sdkVersion))
        queryItems.append(URLQueryItem(name: "keepAspectOnTabletPortrait", value: "\(ShopLiveConfiguration.UI.keepAspectOnTabletPortrait ? "true" : "false")"))
        #if DEMO
            queryItems.append(URLQueryItem(name: "applicationName", value: "shoplive-sdk-sample"))
        #endif
        
        if let localStorage = UserDefaults.standard.string(forKey: ShopLiveDefines.shopliveData), ShopLiveConfiguration.Data.useLocalStorage {
            queryItems.append(URLQueryItem(name: ShopLiveDefines.shopliveData, value: localStorage))
        }
        
        UserDefaults.standard.synchronize()

        let baseUrl = URL(string: ShopLiveConfiguration.AppPreference.landingUrl)
        guard let params = URLUtil.query(queryItems) else {
            completionHandler(baseUrl)
            return
        }

        guard let url = URL(string: ShopLiveConfiguration.AppPreference.landingUrl + "?" + params) else {
            completionHandler(baseUrl)
            return
        }

        completionHandler(url)
    }

    func addObserver() {
        removeObserver()
        
        self.addObserver(self, forKeyPath: "_style", options: [.initial, .old, .new], context: nil)
        self.addObserver(self, forKeyPath: "_authToken", options: [.initial, .old, .new], context: nil)
        self.addObserver(self, forKeyPath: "_user", options: [.initial, .old, .new], context: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.protectedDataWillBecomeUnavailableNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func removeObserver() {
        if self.observationInfo != nil {
            self.removeObserver(self, forKeyPath: "_style")
            self.removeObserver(self, forKeyPath: "_authToken")
            self.removeObserver(self, forKeyPath: "_user")
        }

        NotificationCenter.default.removeObserver(self, name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.protectedDataWillBecomeUnavailableNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func handleKeyboard(_ notification: Notification? = nil) {
        guard _style == .pip else { return }
        guard let shopLiveWindow = self.shopLiveWindow else { return }

        if let notification = notification, let keyboardFrameEndUserInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardScreenEndFrame = keyboardFrameEndUserInfo.cgRectValue
            var bottomPadding: CGFloat = 0
                
            let window = UIApplication.shared.keyWindow
            bottomPadding = window?.safeAreaInsets.bottom ?? 0
        
            ShopLiveController.shared.keyboardHeight = keyboardScreenEndFrame.height - bottomPadding
        }

        let pipPosition: CGRect = self.pipPosition(with: lastPipScale, position: lastPipPosition)

        UIView.animate(withDuration: 0.3, delay: 0, options: []) {
            shopLiveWindow.frame = pipPosition
            shopLiveWindow.setNeedsLayout()
            shopLiveWindow.layoutIfNeeded()
        }
    }

    @objc func handleNotification(_ notification: Notification) {
        switch notification.name {
        case UIApplication.didBecomeActiveNotification:
            if ShopLiveController.shared.isPreview {
                ShopLiveController.playControl = .resume
            } else {
                if ShopLiveController.timeControlStatus == .paused {
                    ShopLiveController.playControl = .resume
                }
                self.pictureInPictureController?.stopPictureInPicture()
            }
            break
        case UIApplication.didEnterBackgroundNotification:
            self.liveStreamViewController?.onBackground()
            break
        case UIApplication.protectedDataDidBecomeAvailableNotification:
            ShopLiveController.shared.screenLock = false
            guard ShopLiveController.windowStyle == .osPip, !ShopLiveController.isReplayMode else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if !ShopLiveController.shared.screenLock {
                    ShopLiveController.playControl = .resume
                }
            }
            break
        case UIApplication.protectedDataWillBecomeUnavailableNotification:
            ShopLiveController.shared.screenLock = true
            ShopLiveController.playControl = .pause
            break
        case UIApplication.willEnterForegroundNotification:
            self.liveStreamViewController?.onForeground()
            break
        case UIResponder.keyboardWillShowNotification:
            isKeyboardShow = true
            self.handleKeyboard(notification)
            break
        case UIResponder.keyboardWillHideNotification:
            isKeyboardShow = false
            self.handleKeyboard()
            break
        default:
            break
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "_style":
            guard let oldValue: Int = change?[.oldKey] as? Int, let newValue: Int = change?[.newKey] as? Int, oldValue != newValue,
                  let newStyle: ShopLive.PresentationStyle = .init(rawValue: newValue) else {
                if let newValue: Int = change?[.newKey] as? Int, let newStyle: ShopLive.PresentationStyle = .init(rawValue: newValue) {
                    self.liveStreamViewController?.updatePipStyle(with: newStyle)
                }
                return
            }

            self.liveStreamViewController?.updatePipStyle(with: newStyle)
            break
        case "_authToken":
            guard let oldValue: String = change?[.oldKey] as? String,
                  let newValue: String = change?[.newKey] as? String, oldValue != newValue else { return }
            self.liveStreamViewController?.viewModel.authToken = newValue
            break
        case "_user":
            guard let oldValue: ShopLiveUser = change?[.oldKey] as? ShopLiveUser,
                  let newValue: ShopLiveUser = change?[.newKey] as? ShopLiveUser, oldValue != newValue else { return }
            self.liveStreamViewController?.viewModel.user = newValue
            break
        default:
            break
        }
    }
}

extension ShopLiveBase: ShopLiveComponent {
    func isSuccessCampaignJoin() -> Bool {
        return ShopLiveController.shared.isSuccessCampaignJoin
    }

    func setLoadingAnimation(images: [UIImage]) {
        ShopLiveConfiguration.UI.setLoadingAnimation(images: images)
    }

    func setKeepAspectOnTabletPortrait(_ keep: Bool) {
        ShopLiveConfiguration.UI.keepAspectOnTabletPortrait = keep
    }

    var viewController: ShopLiveViewController? {
        return self.liveStreamViewController
    }

    func close() {
        self.hideShopLiveView()
    }

    func setChatViewFont(inputBoxFont: UIFont?, sendButtonFont: UIFont?) {
        ShopLiveConfiguration.UI.inputBoxFont = inputBoxFont
        ShopLiveConfiguration.UI.sendButtonFont = sendButtonFont
    }

    func hookNavigation(navigation: @escaping ((URL) -> Void)) {
        ShopLiveController.shared.hookNavigation = nil
        ShopLiveController.shared.hookNavigation = navigation
    }

    func setShareScheme(_ scheme: String? = nil, custom: (() -> Void)?) {

        ShopLiveController.shared.customShareAction = nil
        if scheme == nil {
            guard custom != nil else {
                print("When `scheme` not used, `custom` must be used, `custom` can not be null")
                return
            }
        }

        ShopLiveController.shared.shareScheme = scheme
        ShopLiveController.shared.customShareAction = custom
    }

    func onTerminated() {
        #if DEMO
        ShopLiveDevConfiguration.shared.useAppLog = false
        #endif

        liveStreamViewController?.onTerminated()
    }
    
    func setKeepPlayVideoOnHeadphoneUnplugged(_ keepPlay: Bool) {
        ShopLiveConfiguration.SoundPolicy.keepPlayVideoOnHeadphoneUnplugged = keepPlay
    }

    func isKeepPlayVideoOnHeadPhoneUnplugged() -> Bool {
        return ShopLiveConfiguration.SoundPolicy.keepPlayVideoOnHeadphoneUnplugged
    }

    func setAutoResumeVideoOnCallEnded(_ autoResume: Bool) {
        ShopLiveConfiguration.SoundPolicy.autoResumeVideoOnCallEnded = autoResume
    }

    func isAutoResumeVideoOnCallEnded() -> Bool {
        return ShopLiveConfiguration.SoundPolicy.autoResumeVideoOnCallEnded
    }

    @objc func startPictureInPicture() {
        startPictureInPicture(with: .default, scale: 2/5)
    }
    
    @objc var authToken: String? {
        get {
            return _authToken
        }
        set {
            _authToken = newValue
        }
    }
    
    @objc var user: ShopLiveUser? {
        get {
            return self._user
        }
        set {
            self._user = newValue
        }
    }
    #if DEMO
    @objc var demo_phase: ShopLive.Phase {
        get {
            return self.phase
        }
        set {
            self.phase = newValue
        }
    }
    #endif

    @objc func configure(with accessKey: String) {
        self.accessKey = accessKey
        #if DEMO
        #else
            self.phase = .REAL
        #endif
    }

    func preview(with campaignKey: String?, completion: @escaping () -> Void) {
        guard self.accessKey != nil else { return }
        addObserver()
        ShopLiveController.loading = true
        previewCallback = completion
        self.campaignKey = campaignKey
        fetchPreviewUrl(with: campaignKey) { [weak self] url in
            guard let url = url else {
                self?.removeObserver()
                return
            }
            self?.showPreview(previewUrl: url, completion: completion)
        }
    }
    
    @objc func play(with campaignKey: String?, _ parent: UIViewController?) {
        guard self.accessKey != nil else { return }
        addObserver()
        self.campaignKey = campaignKey
        ShopLiveController.loading = true
        fetchOverlayUrl(with: campaignKey) { [weak self] url in
            guard let url = url else {
                self?.removeObserver()
                return
            }
            self?.liveStreamViewController?.viewModel.authToken = _authToken
            self?.liveStreamViewController?.viewModel.user = _user
            self?.showShopLiveView(with: url, nil)
        }
    }
    
    @objc func reloadLive() {
        guard self.accessKey != nil else { return }
        liveStreamViewController?.reload()
    }
    
    @objc func startPictureInPicture(with position: ShopLive.PipPosition, scale: CGFloat) {
        lastPipScale = scale
        lastPipPosition = position
        startShopLivePictureInPicture()
    }
    @objc func stopPictureInPicture() {
        stopShopLivePictureInPicture()
    }
    
    @objc var style: ShopLive.PresentationStyle {
        get {
            return _style
        }
    }
    
    @objc var pipPosition: ShopLive.PipPosition {
        get {
            return lastPipPosition
        }
        set {
            lastPipPosition = newValue
        }
    }
    
    @objc var pipScale: CGFloat {
        get {
            return lastPipScale
        }
        set {
            lastPipScale = newValue
        }
    }

    @objc var indicatorColor: UIColor {
        get {
            return ShopLiveConfiguration.UI.color
        }
        set {
            ShopLiveConfiguration.UI.color = newValue
        }
    }

    
    @objc public var delegate: ShopLiveSDKDelegate? {
        set {
            self._delegate = newValue
        }
        get {
            return self._delegate
        }
    }
    
    @objc var webViewConfiguration: WKWebViewConfiguration? {
        set {
            self._webViewConfiguration = newValue
        }
        get {
            return self._webViewConfiguration
        }
    }
}

extension ShopLiveBase: AVPictureInPictureControllerDelegate {
    
    public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        // stop pip button selected
        isRestoredPip = true
        completionHandler(true)
    }
    
    public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        ShopLiveController.shared.needReload = false
        ShopLiveController.windowStyle = .osPip
        ShopLiveController.shared.lastPipPlaying = ShopLiveController.timeControlStatus == .playing
    }
    
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        ShopLiveController.webInstance?.sendEventToWeb(event: .onPipModeChanged, true)
        didChangeOSPIP()
    }
    
    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        _style = .fullScreen
        ShopLiveController.windowStyle = .normal
    }

    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        if !isRestoredPip { //touch stop pip button in OS PIP view
            self.hideShopLiveView()
        } else {
            if ShopLiveController.shared.needReload {
                ShopLiveController.shared.needReload = false
                guard !ShopLiveController.isReplayMode else { return }
                
                ShopLiveController.shared.playControl = .resume
            } else {
                if ShopLiveController.timeControlStatus == .paused, !ShopLiveController.isReplayMode {
                    ShopLiveController.shared.playControl = .resume
                }
            }
        }

        ShopLiveController.webInstance?.sendEventToWeb(event: .onPipModeChanged, false)
        
        isRestoredPip = false
    }
}

extension ShopLiveBase: LiveStreamViewControllerDelegate {
    func handleReceivedCommand(_ command: String, with payload: Any?) {
        delegate?.handleReceivedCommand(command, with: payload)
    }

    func onSetUserName(_ payload: [String : Any]) {
        delegate?.onSetUserName(payload)
    }

    func campaignInfo(campaignInfo: [String : Any]) {
        delegate?.handleCampaignInfo(campaignInfo: campaignInfo)
    }

    func didChangeCampaignStatus(status: String) {
        delegate?.handleChangeCampaignStatus(status: status)
    }

    func onError(code: String, message: String) {
        delegate?.handleError(code: code, message: message)
    }

    func didTouchCustomAction(id: String, type: String, payload: Any?) {
        let completion: () -> Void = {
            self.liveStreamViewController?.didCompleteCustomAction(with: id) }
        _delegate?.handleCustomAction?(with: id, type: type, payload: payload, completion: completion)

        let completionResult: (ShopLive.CustomActionResult?) -> Void = { [weak self] customActionResult in
            if let result = customActionResult {
                self?.liveStreamViewController?.didCompleteCustomAction(with: result)
            }
        }
        _delegate?.handleCustomAction?(with: id, type: type, payload: payload, result: completionResult)
        
        let deprecatedCompletionResult: (CustomActionResult?) -> Void = { [weak self] customActionResult in
            if let result = customActionResult {
                self?.liveStreamViewController?.didCompleteCustomAction(with: result)
            }
        }
        _delegate?.handleCustomActionResult?(with: id, type: type, payload: payload, completion: deprecatedCompletionResult)
    }

    func replay(with size: CGSize) {
        replaySize = size
    }
    
    func didTouchPipButton() {
        startShopLivePictureInPicture()
    }
    
    func didTouchCloseButton() {
        hideShopLiveView()
    }
    
    func didTouchNavigation(with url: URL) {
        guard let hookNavigation = ShopLiveController.shared.hookNavigation else {
            switch ShopLiveConfiguration.UI.nextActionTypeOnHandleNavigation {
            case .PIP:
                startPictureInPicture()
            case .CLOSE:
                close()
                _delegate?.handleNavigation(with: url)
                return
            case .KEEP:
                break
            }
            _delegate?.handleNavigation(with: url)
            return
        }

        hookNavigation(url)
    }
    
    func didTouchCoupon(with couponId: String) {
        let completion: () -> Void = { [weak self] in
            self?.liveStreamViewController?.didCompleteDownLoadCoupon(with: couponId)
        }

        _delegate?.handleDownloadCoupon?(with: couponId, completion: completion)

        let completionResult: (ShopLive.CouponResult?) -> Void = { [weak self] couponResult in
            if let result = couponResult {
                self?.liveStreamViewController?.didCompleteDownLoadCoupon(with: result)
            }
        }
        _delegate?.handleDownloadCoupon?(with: couponId, result: completionResult)
        
        let deprecatedCompletionResult: (CouponResult?) -> Void = { [weak self] couponResult in
            if let result = couponResult {
                self?.liveStreamViewController?.didCompleteDownLoadCoupon(with: result)
            }
        }
        _delegate?.handleDownloadCouponResult?(with: couponId, completion: deprecatedCompletionResult)
    }
    
    func handleCommand(_ command: String, with payload: Any?) {
        _delegate?.handleCommand(command, with: payload)
    }
}
