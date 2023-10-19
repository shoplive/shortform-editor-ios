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
    private var inRotating: Bool = false
    private var shopLiveWindow: ShopliveWindow? = nil
    private var videoWindowPanGestureRecognizer: UIPanGestureRecognizer?
    private var videoWindowTapGestureRecognizer: UITapGestureRecognizer?
    private var videoPinchGestureRecognizer: UIPinchGestureRecognizer?
    
    private var videoWindowSwipeDownGestureRecognizer: UISwipeGestureRecognizer?
    private var _webViewConfiguration: WKWebViewConfiguration?
    private var isRestoredPip: Bool = false
    private var accessKey: String? = nil
    private var campaignKey: String?
    private var campaignChanged: Bool = false
    private var needExecuteFullScreen: Bool = false
    private var playerModeChanged: Bool = false
    private var needAnimateToChangePreivew: Bool = false
    private var activeFromBackground: Bool = false
    private var enabledPictureInPictureMode : Bool = true
    private var inAppPipConfiguration : ShopLiveInAppPipConfiguration?
    
    
    
#if EBAY
#else
    private var pipMin: CGFloat {
        let videoOrientaion: ShopLiveDefines.ShopLiveOrientaion = ShopLiveController.shared.videoOrientation
        
        switch videoOrientaion {
        case .portrait:
            return 200
        case .landscape:
            return 100
        }
    }
    
    private var pipMax: CGFloat {
        let videoOrientaion: ShopLiveDefines.ShopLiveOrientaion = ShopLiveController.shared.videoOrientation
        let maxHeight = (UIScreen.isLandscape ? UIScreen.main.bounds.height : UIScreen.main.bounds.width)
        switch videoOrientaion {
        case .portrait:
            return UIDevice.isIpad ? maxHeight * 0.7 : maxHeight * 0.84615385
        case .landscape:
            return UIDevice.isIpad ? maxHeight * 0.7 : maxHeight * 0.96//4615385
        }
        
    }
    
    private var minScale: CGFloat {
        let videoOrientaion: ShopLiveDefines.ShopLiveOrientaion = ShopLiveController.shared.videoOrientation
        
        switch videoOrientaion {
        case .portrait:
            let minWidth = pipMin * (ShopLiveController.shared.videoRatio.width/ShopLiveController.shared.videoRatio.height)
            return UIScreen.isLandscape ? minWidth / UIScreen.main.bounds.height : minWidth / UIScreen.main.bounds.width
        case .landscape:
            return UIScreen.isLandscape ? pipMin / UIScreen.main.bounds.height : pipMin / UIScreen.main.bounds.width
        }
    }
    
    private var maxScale: CGFloat {
        let videoOrientaion: ShopLiveDefines.ShopLiveOrientaion = ShopLiveController.shared.videoOrientation
        
        switch videoOrientaion {
        case .portrait:
            let maxWidth = pipMax * (ShopLiveController.shared.videoRatio.width/ShopLiveController.shared.videoRatio.height)
            return UIScreen.isLandscape ? maxWidth / UIScreen.main.bounds.height : maxWidth / UIScreen.main.bounds.width
        case .landscape:
            return UIScreen.isLandscape ? pipMax / UIScreen.main.bounds.height : pipMax / UIScreen.main.bounds.width
        }
    }
    
    private func convertPipScale(userScale: CGFloat) -> CGFloat {
        guard userScale > 1.0 && userScale <= 100 else {
            if userScale < 0 {
                return 0
            } else {
                return userScale
            }
        }
        let inputScale = userScale / 100
        let range: CGFloat = maxScale - minScale
        let tg: CGFloat = range * inputScale
        let value: CGFloat = tg + minScale
        return value
    }
#endif
    
    private var isKeyboardShow: Bool = false
    private var replaySize: CGSize = CGSize(width: 9, height: 16)
    weak private var mainWindow: UIWindow? = nil
    
    @objc dynamic var _style: ShopLive.PresentationStyle = .unknown {
        willSet {
            self.lastStyle = self._style
        }
    }
    private var lastStyle: ShopLive.PresentationStyle = .unknown
    @objc dynamic var _authToken: String?
    @objc dynamic var _user: ShopLiveUser?
    
    private var previewCallback: (() -> Void)?
    
    let debouncer = Debouncer(timeInterval: 0.6)
    static let parentStatusBarStyle = UIApplication.shared.statusBarStyle
    var liveStreamViewController: LiveStreamViewController?
    var osPictureInPictureController: SLPictureInPictureController?
    
    var pipPossibleObservation: NSKeyValueObservation?
    var originAudioSessionCategory: AVAudioSession.Category?
    
    var isWindowChanging = false
    var windowChangeCommand: ShopLiveWindowChangeCommand = .none 
    var queryParameters: [String: String] = [:]
    
    weak var _delegate: ShopLiveSDKDelegate?
    
    static var sessionState: PlayerSessionState = .terminated
    
    override init() {
        super.init()
    }
    
    deinit {
    }
    
    func showPreview(previewUrl: URL) {
        liveStreamViewController?.viewModel.authToken = _authToken
        liveStreamViewController?.viewModel.user = _user
        showShopLiveView(with: previewUrl) { [weak self] in
            guard let self = self else { return }
            ShopLiveController.shared.setSoundMute(isMuted: true)
            if let ak = self.accessKey,
               let vc = self.liveStreamViewController,
               ShopLiveController.shared.isPreview {
                vc.viewModel.updatePlayerItemWithLiveUrlFetchAPI(accessKey: ak,
                                                                 campaignKey: ShopLiveController.shared.campaignKey,
                                                                 isPreview: true) {
                    
                    self.updatePictureInPicture()
                }
            }
        }
    }
    
    func showShopLiveView(with overlayUrl: URL, _ completion: (() -> Void)? = nil) {
        
        UIApplication.shared.isIdleTimerDisabled = true
        if !ShopLiveController.shared.isSameCampaign {
            ShopLiveController.shared.resetVideoDatas()
        }
        
        ShopLiveController.shared.newStartPlay = true
        
        
        if _style != .unknown {
            self.liveStreamViewController?.viewModel.overayUrl = overlayUrl
            self.liveStreamViewController?.reload()
            self.liveStreamViewController?.updateChattingWriteView()
            if self.needExecuteFullScreen {
                if ShopLiveController.shared.isSameCampaign {
                    ShopLiveController.shared.keepSnapshot = true
                    self.liveStreamViewController?.takeSnapShot(on: true)
                }
                self._style = .fullScreen
            }
            else {
                if ShopLiveConfiguration.UI.keepWindowStateOnPlayExecuted == false || self.campaignChanged {
                    if ShopLiveController.shared.isPreview == false {
                        if self._style == .pip {
                            self._style = .fullScreen
                            ShopLiveController.windowStyle = .normal
                        }
                    }
                    else {
                        self.needAnimateToChangePreivew = true
                        self._style = .pip
                        ShopLiveController.windowStyle = .inAppPip
                    }
                }
                else {
                    if ShopLiveController.shared.isPreview {
                        self._style = .pip
                        ShopLiveController.windowStyle = .inAppPip
                        self.liveStreamViewController?.hideSnapShotView()
                        
                    } else {
                        ShopLiveController.shared.keepOrientationWhenPlayStart = true
                    }
                }
            }
            if let completion = completion {
                completion()
            }
            return
        }
        
        if !ShopLiveController.shared.isPreview {
            let audioSession = AVAudioSession.sharedInstance()
            let audioSessionManager = AudioSessionManager.shared
            originAudioSessionCategory = audioSession.category
            audioSessionManager.setCategory(category: .playback, options: audioSessionManager.currentCategoryOptions)
        }
        
        ShopLiveController.shared.releaseData()
        isKeyboardShow = false
        
        liveStreamViewController = LiveStreamViewController()
        // inAppPipConfiguration에서 pipPosition이 설정되어 있지 않다면, legacy를 통해서 세팅된거여서 초기값을 밀어넣어줘야 함
        if inAppPipConfiguration?.pipPosition == nil {
            liveStreamViewController?.viewModel.setPipPosition(position: ShopLiveController.shared.initialPipPosition)
        }
        liveStreamViewController?.viewModel.setInAppPipConfiguration(config: inAppPipConfiguration)
        liveStreamViewController?.delegate = self
        liveStreamViewController?.webViewConfiguration = _webViewConfiguration
        liveStreamViewController?.viewModel.overayUrl = overlayUrl
        liveStreamViewController?.viewModel.authToken = _authToken
        liveStreamViewController?.viewModel.user = _user
        
        mainWindow = (UIApplication.shared.windows.first(where: { $0.isKeyWindow }))
        
        shopLiveWindow = ShopliveWindow()
        if #available(iOS 13.0, *) {
            shopLiveWindow?.windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        }
        shopLiveWindow?.backgroundColor = .clear
        shopLiveWindow?.windowLevel = .statusBar - 1
        shopLiveWindow?.isHidden = false
        
        if ShopLiveController.shared.isPreview {
            shopLiveWindow?.frame = .zero
            shopLiveWindow?.center = self.pipPosition(with: self.pipScale, position: self.getPipPosition()).center
        } else {
            shopLiveWindow?.frame = mainWindow?.frame ?? UIScreen.main.bounds
        }
        
        self.shopLiveWindow?.rootViewController = self.liveStreamViewController
        self.liveStreamViewController?.view.backgroundColor = .white
        
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
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureHandler))
        shopLiveWindow?.addGestureRecognizer(pinchGesture)
        videoPinchGestureRecognizer = pinchGesture
        videoPinchGestureRecognizer?.isEnabled = ShopLiveController.shared.isPreview ? false : true
        
        ShopLiveController.windowStyle = .normal
        
        setupOsPictureInPicture()
        shopLiveWindow?.makeKeyAndVisible()
        
        self.delegate?.handleChangedPlayerStatus?(status: "CREATED")
        
        if ShopLiveController.shared.isPreview {
            _style = .pip
            self.liveStreamViewController?.updateStatusBarToDefault()
            ShopLiveController.windowStyle = .inAppPip
        } else {
            mainWindow?.rootViewController?.shopliveHideKeyboard()
            ShopLiveController.windowStyle = .normal
            _style = .fullScreen
        }
        
        ShopLiveBase.sessionState = .foreground
        if let completion = completion {
            completion()
        }
    }
    
    func hideShopLiveView(_ animated: Bool = true) {
        self.liveStreamViewController?.updateStatusBarToDefault()
        ShopLiveController.shared.execusedClose = true
        UIApplication.shared.isIdleTimerDisabled = false
        
        ShopLiveController.webInstance?.sendEventToWeb(event: .onTerminated)
        delegate?.handleCommand("willShopLiveOff", with: ["style" : self.style.rawValue])
        if let originAudioSessionCategory = self.originAudioSessionCategory {
            let audioSessionManager = AudioSessionManager.shared
            audioSessionManager.setCategory(category: originAudioSessionCategory, options: audioSessionManager.customerAudioCategoryOptions)
        }
        
        self.originAudioSessionCategory = nil
        
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
        
        self.shopLiveWindow?.isHidden = true
        self.shopLiveWindow?.transform = .identity
        self.shopLiveWindow?.alpha = 1
        
        self.shopLiveWindow?.resignKey()
        self.mainWindow?.makeKeyAndVisible()
        
        self.videoWindowPanGestureRecognizer = nil
        self.videoWindowTapGestureRecognizer = nil
        self.videoWindowSwipeDownGestureRecognizer = nil
        self.videoPinchGestureRecognizer = nil
        self.osPictureInPictureController = nil
        
        self.liveStreamViewController?.removeFromParent()
        self.liveStreamViewController?.viewModel.stop()
        self.liveStreamViewController?.delegate = nil
        self.liveStreamViewController = nil
        
        self.mainWindow = nil
        self.shopLiveWindow?.removeFromSuperview()
        self.shopLiveWindow?.rootViewController = nil
        
        self.shopLiveWindow = nil
        self.delegate?.handleChangedPlayerStatus?(status: "DESTROYED")
        delegate?.log?(name: "player_close", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, parameter: ["type" : (_style == .pip ? (ShopLiveController.shared.isPreview ? "preview" : "pip") : "normal")])
        delegate?.log?(name: "player_close", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: ["type" : (_style == .pip ? (ShopLiveController.shared.isPreview ? "preview" : "pip") : "normal")])
        self.delegate?.handleCommand("didShopLiveOff", with: ["style" : self.style.rawValue])
        self._style = .unknown
        self.lastStyle = .unknown
        self._authToken = nil
        self._user = nil
        
        ShopLiveBase.sessionState = .terminated
        ShopLiveController.shared.resetOnlyFinished()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            ShopLiveController.shared.execusedClose = false
        }
    }
    
    func setupOsPictureInPicture() {
        guard !ShopLiveController.shared.isPreview else {
            self.osPictureInPictureController?.delegate = nil
            self.osPictureInPictureController = nil
            return
        }
        
        guard osPictureInPictureController == nil else { return }
        
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
        if AVPictureInPictureController.isPictureInPictureSupported() {
            osPictureInPictureController = SLPictureInPictureController(playerLayer: playerLayer)
            osPictureInPictureController?.delegate = self
            
            if #available(iOS 14.2, *) {
                osPictureInPictureController?.canStartPictureInPictureAutomaticallyFromInline = true
            }
            
            if #available(iOS 14.0, *) {
                osPictureInPictureController?.requiresLinearPlayback = false
            }
        }
    }
    
    func startOsPictureInPicture(){
        if AVPictureInPictureController.isPictureInPictureSupported() == false {
            delegate?.handleError(code: "9500", message: "Unsupported OS version to use OS PIP mode.")
            return
        }
        if (osPictureInPictureController?.isPictureInPictureActive ?? false) == true {
            return
        }
        setupOsPictureInPicture()
        guard let osPictureInPictureController = osPictureInPictureController else {
            return
        }
        
        if osPictureInPictureController.isPictureInPicturePossible && osPictureInPictureController.isPictureInPictureActive == false {
            osPictureInPictureController.startPictureInPicture()
        }
    }
    
    func startShopLivePictureInPicture() {
        startCustomPictureInPicture(with: self.getPipPosition(), scale: pipScale)
    }
    
    func stopShopLivePictureInPicture() {
        stopCustomPictureInPicture()
    }
    
    private func pipSize(with scale: CGFloat) -> CGSize {
        guard self.mainWindow != nil else { return .zero }
        let defSize = ShopLiveController.shared.videoRatio
        if let config = inAppPipConfiguration, let pipMaxSize = config.pipMaxSize {
            if defSize.width > defSize.height { //가로모드 방송에서는 세로를 기준으로 가로를 맞추고
                return CGSize(width: pipMaxSize, height: pipMaxSize * ( defSize.height / defSize.width))
            }
            else { //세로 모드 방송에서는 가로를 기준으로 세로를 맞춤
                return CGSize(width: pipMaxSize * (defSize.width / defSize.height ), height: pipMaxSize)
            }
        }
        else {
            let width =  (UIScreen.isLandscape ? UIScreen.main.bounds.height : UIScreen.main.bounds.width) * scale
            let height = (defSize.height / defSize.width) * width
            return CGSize(width: width, height: height)
        }
        
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
        
        let standardSize: CGSize = UIScreen.main.bounds.size
        
        switch position {
        case .bottomRight, .default:
            origin.x = standardSize.width - safeAreaInsets.right - pipEdgeInsets.right - pipSize.width - pipFloatingOffset.right
            origin.y = standardSize.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight - pipFloatingOffsetBottom
        case .bottomLeft:
            origin.x = safeAreaInsets.left + pipEdgeInsets.left + pipFloatingOffset.left
            origin.y = standardSize.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight - pipFloatingOffsetBottom
        case .topRight:
            origin.x = standardSize.width - safeAreaInsets.right - pipEdgeInsets.right - pipSize.width - pipFloatingOffset.right
            
            let isOutOfScreen = (standardSize.height - keyboardHeight - (safeAreaInsets.top + pipEdgeInsets.top + pipFloatingOffset.top)) < pipSize.height
            origin.y = isOutOfScreen ? standardSize.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight - pipFloatingOffsetBottom : safeAreaInsets.top + pipEdgeInsets.top + pipFloatingOffset.top
        case .topLeft:
            origin.x = safeAreaInsets.left + pipEdgeInsets.left + pipFloatingOffset.left
            
            let isOutOfScreen = (standardSize.height - keyboardHeight - (safeAreaInsets.top + pipEdgeInsets.top + pipFloatingOffset.top)) < pipSize.height
            origin.y = isOutOfScreen ? standardSize.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight - pipFloatingOffsetBottom : safeAreaInsets.top + pipEdgeInsets.top + pipFloatingOffset.top
        }
        
        pipPosition = CGRect(origin: origin, size: pipSize)
        
        return pipPosition
    }
    
    private func startCustomPictureInPicture(with position: ShopLive.PipPosition = .default, scale: CGFloat = 2/5) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            
            if self.enabledPictureInPictureMode == false {
                self.close()
                return
            }
            
            guard !ShopLiveController.shared.pipAnimating else { return }
            guard let shopLiveWindow = self.shopLiveWindow else { return }
            guard shopLiveWindow.frame.size != .zero else { return }
            self.liveStreamViewController?.updateStatusBarToDefault()
            self.delegate?.handleCommand("willShopLiveOff", with: ["style" : self.lastStyle.rawValue])
            self.mainWindow?.makeKey()
            
            shopLiveWindow.backgroundColor = .clear
            shopLiveWindow.layer.cornerRadius = 10
            shopLiveWindow.rootViewController?.view.backgroundColor = .clear
            
            self.liveStreamViewController?.shopliveHideKeyboard()
            self.liveStreamViewController?.showBackgroundPoster()
            
            let pipPosition: CGRect = self.pipPosition(with: scale, position: position)
            
            ShopLiveController.windowStyle = .inAppPip
            self._style = .pip
            
            ShopLiveController.shared.pipAnimating = true
            
            shopLiveWindow.rootViewController?.view.layer.cornerRadius = 10
            shopLiveWindow.rootViewController?.view.layer.masksToBounds = true
            shopLiveWindow.layer.masksToBounds = true
            
            self.videoWindowPanGestureRecognizer?.isEnabled = true
            self.videoWindowTapGestureRecognizer?.isEnabled = true
            self.videoWindowSwipeDownGestureRecognizer?.isEnabled = false
            
            ShopLiveController.webInstance?.isHidden = true
            
            self.liveStreamViewController?.showSnapshotBackground()
            self.liveStreamViewController?.updateVideoFit(centerCrop: true, immediately: false)
            self.liveStreamViewController?.updateVideoConstraint()
            self.shopLiveWindow?.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                shopLiveWindow.frame = pipPosition
                shopLiveWindow.layer.shadowColor = UIColor.black.cgColor
                shopLiveWindow.layer.shadowOpacity = 0.5
                shopLiveWindow.layer.shadowOffset = .zero
                shopLiveWindow.layer.shadowRadius = 10
                shopLiveWindow.setNeedsLayout()
                shopLiveWindow.layoutIfNeeded()
            } completion: { (isCompleted) in
                self.liveStreamViewController?.hideSnapshotBackground()
                ShopLiveController.shared.pipAnimating = false
                self.shopLiveWindow?.backgroundColor = .black
                self.liveStreamViewController?.view.backgroundColor = .black
                shopLiveWindow.layer.masksToBounds = false
                self.liveStreamViewController?.setCloseButtonVisible(true)
                
                ShopLiveController.shared.videoExpanded = true
                
                if self.windowChangeCommand != .none && self.isWindowChanging {
                    self.handleWindowChangeCommand()
                }
                
                self.delegate?.log?(name: "player_to_pip_mode", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, parameter: [:])
                self.delegate?.log?(name: "player_to_pip_mode", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: [:])
                self.sendCommandChangeToPip()
                self.delegate?.handleCommand("didShopLiveOff", with: ["style" : self.lastStyle.rawValue])
            }
        }
    }
    
    func startFromCampaignFullscreen(animationDuration : Double = 0.3) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard !ShopLiveController.shared.pipAnimating else { return }
            guard let mainWindow = self.mainWindow else { return }
            guard let shopLiveWindow = self.shopLiveWindow else { return }
            guard shopLiveWindow.frame != mainWindow.frame else {
                if ShopLiveController.windowStyle == .normal {
                    self.liveStreamViewController?.updateVideoFrame(immeadiately: true, fitTopArea: false)
                }
                self.liveStreamViewController?.updateVideoConstraint()
                self.delegate?.handleCommand("willShopLiveOn", with: nil)
                self.delegate?.handleCommand("didShopLiveOn", with: self.lastStyle)
                return
            }
            
            shopLiveWindow.backgroundColor = .clear
            shopLiveWindow.layer.cornerRadius = 10
            shopLiveWindow.rootViewController?.view.backgroundColor = .clear
            
            if self.osPictureInPictureController == nil {
                self.setupOsPictureInPicture()
            }
            
            mainWindow.rootViewController?.shopliveHideKeyboard()
            self.liveStreamViewController?.showBackgroundPoster()
            
            self.delegate?.handleCommand("willShopLiveOn", with: nil)
            ShopLiveController.shared.pipAnimating = true
            
            self.videoWindowPanGestureRecognizer?.isEnabled = false
            self.videoWindowTapGestureRecognizer?.isEnabled = false
            self.videoWindowSwipeDownGestureRecognizer?.isEnabled = true
            self.videoPinchGestureRecognizer?.isEnabled = true
            ShopLiveController.windowStyle = .normal
            
            shopLiveWindow.layer.shadowColor = nil
            shopLiveWindow.layer.shadowOpacity = 0.0
            shopLiveWindow.layer.shadowOffset = .zero
            shopLiveWindow.layer.shadowRadius = 0
            
            self.liveStreamViewController?.updateVideoFrame(immeadiately: false, fitTopArea: self.needExecuteFullScreen)
            self.shopLiveWindow?.layer.masksToBounds = true
            self.liveStreamViewController?.view.layer.masksToBounds = true
            self.liveStreamViewController?.setCloseButtonVisible(false)
            self.shopLiveWindow?.layer.removeAllAnimations()
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.allowUserInteraction, .curveEaseInOut]) {
                self.liveStreamViewController?.updateVideoConstraint()
                shopLiveWindow.frame = mainWindow.bounds
                shopLiveWindow.layer.cornerRadius = 0
                shopLiveWindow.rootViewController?.view.layer.cornerRadius = 0
                ShopLiveController.webInstance?.isHidden = false
            } completion: { done in
                shopLiveWindow.rootViewController?.view.backgroundColor = .black
                ShopLiveController.shared.pipAnimating = false
                self.needExecuteFullScreen = false
                if self.needExecuteFullScreen == true {
                    ShopLiveController.shared.keepSnapshot = false
                    ShopLiveController.shared.playControl = .play
                    self.delegate?.handleCommand("didShopLiveOn", with: self.lastStyle)
                }
                else {
                    self.delegate?.handleCommand("didShopLiveOn", with: self.style)
                }
                self.handleWindowChangeCommand()
            }
            self._style = .fullScreen
        }
    }
    
    private func stopCustomPictureInPicture() {
        
        if osPictureInPictureController == nil {
            setupOsPictureInPicture()
        }

        guard !ShopLiveController.shared.pipAnimating else { return }
        guard let mainWindow = self.mainWindow else { return }
        guard let shopLiveWindow = self.shopLiveWindow else { return }
        
        self.liveStreamViewController?.updateStatuBarStyleToLightContent()
        
        shopLiveWindow.backgroundColor = .clear
        shopLiveWindow.layer.cornerRadius = 10
        shopLiveWindow.rootViewController?.view.backgroundColor = .clear

        mainWindow.rootViewController?.shopliveHideKeyboard()

        delegate?.handleCommand("willShopLiveOn", with: nil)
        ShopLiveController.shared.pipAnimating = true

        videoWindowPanGestureRecognizer?.isEnabled = false
        videoWindowTapGestureRecognizer?.isEnabled = false
        videoWindowSwipeDownGestureRecognizer?.isEnabled = true
        ShopLiveController.windowStyle = .normal
        _style = .fullScreen
        shopLiveWindow.layer.shadowColor = nil
        shopLiveWindow.layer.shadowOpacity = 0.0
        shopLiveWindow.layer.shadowOffset = .zero
        shopLiveWindow.layer.shadowRadius = 0
        
        self.liveStreamViewController?.showSnapshotBackground()
        
        shopLiveWindow.invalidateBlockAddSubViewTimer()
        
        if self.needExecuteFullScreen {
            self.liveStreamViewController?.updateVideoFrame(immeadiately: false, fitTopArea: true)
            ShopLiveController.webInstance?.isHidden = false
            shopLiveWindow.startBlockAddSubViewTimer()
            shopLiveWindow.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.3, delay: 0, options: []) {
                self.liveStreamViewController?.updateVideoConstraint()
                shopLiveWindow.frame = mainWindow.bounds
                shopLiveWindow.layer.cornerRadius = 0
                shopLiveWindow.rootViewController?.view.layer.cornerRadius = 0
                self.liveStreamViewController?.setCloseButtonVisible(false)
                } completion: { (isCompleted) in
                    self.liveStreamViewController?.hideSnapshotBackground()
                    shopLiveWindow.rootViewController?.view.backgroundColor = .black
                    ShopLiveController.webInstance?.isHidden = false
                    shopLiveWindow.backgroundColor = .black
                    ShopLiveController.shared.pipAnimating = false
                    self.liveStreamViewController?.showBackgroundPoster()
                    if self.windowChangeCommand != .none {
                        self.isWindowChanging = false
                    }
                }
        } else {
            shopLiveWindow.startBlockAddSubViewTimer()
            self.liveStreamViewController?.updateVideoFrame(immeadiately: false, fitTopArea: true)
            shopLiveWindow.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.3, delay: 0, options: []) {
                self.liveStreamViewController?.updateVideoConstraint()
                shopLiveWindow.frame = mainWindow.bounds
                shopLiveWindow.layer.cornerRadius = 0
                shopLiveWindow.rootViewController?.view.layer.cornerRadius = 0
                self.liveStreamViewController?.setCloseButtonVisible(false)
                } completion: { (isCompleted) in
                    self.liveStreamViewController?.hideSnapshotBackground()
                    shopLiveWindow.rootViewController?.view.backgroundColor = .black
                    ShopLiveController.webInstance?.isHidden = false
                    shopLiveWindow.backgroundColor = .black
                    ShopLiveController.shared.pipAnimating = false
                    self.liveStreamViewController?.showBackgroundPoster()
                    if self.windowChangeCommand != .none {
                        self.isWindowChanging = false
                    }
                    
                }
        }
        shopLiveWindow.makeKey()
        _style = .fullScreen
        delegate?.handleCommand("didShopLiveOn", with: nil)
        delegate?.log?(name: "pip_to_player_mode", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, parameter: [:])
        delegate?.log?(name: "pip_to_player_mode", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: [:])
    }

    func updatePip(isRotation: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard !ShopLiveController.shared.pipAnimating else { return }
            
            self.isWindowChanging = true
            if isRotation {
                let param: Dictionary = Dictionary<String, Any>.init(dictionaryLiteral: ("top", UIScreen.safeArea.top),
                                                                     ("left", UIScreen.safeArea.left),
                                                                     ("right", UIScreen.safeArea.right),
                                                                     ("bottom", UIScreen.safeArea.bottom),
                                                                     ("orientation", UIScreen.currentOrientation.angle))
                
                self.liveStreamViewController?.sendCommandMessage(command: "SET_SAFE_AREA_MARGIN", payload: param)
            } else {
                self.delegate?.handleCommand("willShopLiveOff", with: nil)
            }
            
            ShopLiveController.webInstance?.isHidden = true
            
            ShopLiveController.shared.pipAnimating = true
            let pipSize: CGRect = self.pipPosition(with: self.pipScale, position: self.getPipPosition())
            
            self.liveStreamViewController?.updateVideoFrame(immeadiately: false)
            self.shopLiveWindow?.layer.masksToBounds = true
            self.liveStreamViewController?.view.layer.masksToBounds = true
            self.liveStreamViewController?.setCloseDimLayerVisible(false)
            self.shopLiveWindow?.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
                self.liveStreamViewController?.updateVideoConstraint()
            } completion: { _ in
                self.shopLiveWindow?.layer.removeAllAnimations()
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    self.shopLiveWindow?.frame = pipSize
                    self.shopLiveWindow?.layoutIfNeeded()
                } completion: { _ in
                    ShopLiveController.shared.pipAnimating = false
                    
                    if !isRotation {
                        self.sendCommandChangeToPip()
                        self.delegate?.handleCommand("didShopLiveOff", with: ["style" : self.lastStyle.rawValue])
                        self.shopLiveWindow?.layer.masksToBounds = false
                    }
                    self.handleWindowChangeCommand()
                }
            }
        }
    }
    
    func startFromCampaignPIP() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.liveStreamViewController?.updateVideoFit(centerCrop: true)
            self.delegate?.handleCommand("willShopLiveOff", with: ["style" : self.lastStyle.rawValue])
            guard !ShopLiveController.shared.pipAnimating else { return }
            guard let shopLiveWindow = self.shopLiveWindow else { return }
            
            ShopLiveController.shared.pipAnimating = true
            shopLiveWindow.backgroundColor = .clear
            shopLiveWindow.layer.cornerRadius = 10
            shopLiveWindow.rootViewController?.view.backgroundColor = .clear

            self.liveStreamViewController?.shopliveHideKeyboard()

            ShopLiveController.windowStyle = .inAppPip
            
            shopLiveWindow.rootViewController?.view.layer.cornerRadius = 10
            shopLiveWindow.rootViewController?.view.layer.masksToBounds = true
        
            ShopLiveController.webInstance?.isHidden = true
            self.videoWindowPanGestureRecognizer?.isEnabled = true
            self.videoWindowTapGestureRecognizer?.isEnabled = true
            self.videoWindowSwipeDownGestureRecognizer?.isEnabled = false
            
            let pipPosition: CGRect = self.pipPosition(with: self.pipScale, position: self.getPipPosition())
            shopLiveWindow.frame = pipPosition
            
            shopLiveWindow.layer.masksToBounds = false
            shopLiveWindow.layer.shadowColor = UIColor.black.cgColor
            shopLiveWindow.layer.shadowOpacity = 0.5
            shopLiveWindow.layer.shadowOffset = .zero
            shopLiveWindow.layer.shadowRadius = 10
            ShopLiveController.shared.pipAnimating = false
            shopLiveWindow.setNeedsLayout()
            shopLiveWindow.layoutIfNeeded()
            
            shopLiveWindow.backgroundColor = .black
            self.liveStreamViewController?.setCloseButtonVisible(true)
            
            self.sendCommandChangeToPip()
            self.delegate?.handleCommand("didShopLiveOff", with: ["style" : self.lastStyle.rawValue])
            self.handleWindowChangeCommand()
        }
    }
    
    func willChangePreview() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.isWindowChanging = true
            
            if self.osPictureInPictureController != nil {
                self.osPictureInPictureController?.delegate = nil
                self.osPictureInPictureController = nil
            }
            
            ShopLiveController.windowStyle = .inAppPip
            self.delegate?.handleCommand("willShopLiveOff", with: ["style" : self.lastStyle.rawValue])
            
            self.liveStreamViewController?.view.backgroundColor = .clear
            
            let pipSize: CGRect = self.pipPosition(with: self.pipScale, position: self.getPipPosition())
            
            if self.needAnimateToChangePreivew {
                self.liveStreamViewController?.hideBackgroundPoster()
                ShopLiveController.webInstance?.isHidden = false
            } else {
                self.shopLiveWindow?.isHidden = true
            }
            
            self.shopLiveWindow?.layer.cornerRadius = 10
            
            self.videoWindowPanGestureRecognizer?.isEnabled = true
            self.videoWindowTapGestureRecognizer?.isEnabled = true
            self.videoWindowSwipeDownGestureRecognizer?.isEnabled = false
            
            if !self.needAnimateToChangePreivew {
                self.liveStreamViewController?.updateVideoFit(centerCrop: true, immediately: false)
                self.shopLiveWindow?.layer.removeAllAnimations()
                UIView.animate(withDuration: 0, delay: 0, options: .transitionCrossDissolve) {
                    self.liveStreamViewController?.updateVideoConstraint()
                    self.shopLiveWindow?.layer.shadowColor = UIColor.black.cgColor
                    self.shopLiveWindow?.layer.shadowOpacity = 0.5
                    self.shopLiveWindow?.layer.shadowOffset = .zero
                    self.shopLiveWindow?.rootViewController?.view.layer.cornerRadius = 10
                    self.shopLiveWindow?.frame = pipSize
                    self.shopLiveWindow?.setNeedsLayout()
                    self.shopLiveWindow?.layoutIfNeeded()
                } completion: { _ in
                    self.liveStreamViewController?.setCloseButtonVisible(true)
                    self.shopLiveWindow?.isHidden = false
                    ShopLiveController.shared.webInstance?.isHidden = true
                    self.shopLiveWindow?.layer.masksToBounds = false
                    self.liveStreamViewController?.view.layer.masksToBounds = true
                    self.shopLiveWindow?.backgroundColor = .clear
                    self.liveStreamViewController?.showBackgroundPoster()
                    self.delegate?.handleCommand("didShopLiveOff", with: ["style" : self.lastStyle.rawValue])
                    ShopLiveController.shared.videoExpanded = true
                    self.needAnimateToChangePreivew = false
                    self.handleWindowChangeCommand()
                }
            } else {
                self.liveStreamViewController?.updateVideoFit(centerCrop: true, imageUpdate: false)
                self.shopLiveWindow?.layer.removeAllAnimations()
                UIView.animate(withDuration: 0.4, delay: 0, options: []) {
                    self.liveStreamViewController?.updateVideoConstraint()
                    self.shopLiveWindow?.frame = pipSize
                    self.shopLiveWindow?.layer.masksToBounds = true
                    self.shopLiveWindow?.layer.shadowColor = UIColor.black.cgColor
                    self.shopLiveWindow?.layer.shadowOpacity = 0.5
                    self.shopLiveWindow?.layer.shadowOffset = .zero
                    self.shopLiveWindow?.rootViewController?.view.layer.cornerRadius = 10
                    self.shopLiveWindow?.setNeedsLayout()
                    self.shopLiveWindow?.layoutIfNeeded()
                } completion: { _ in
                    self.liveStreamViewController?.setCloseButtonVisible(true)
                    ShopLiveController.shared.keepSnapshot = false
                    ShopLiveController.shared.playControl = .play
                    self.shopLiveWindow?.isHidden = false
                    ShopLiveController.shared.webInstance?.isHidden = true
                    self.shopLiveWindow?.layer.masksToBounds = false
                    self.liveStreamViewController?.view.layer.masksToBounds = true
                    self.liveStreamViewController?.showBackgroundPoster()
                    self.delegate?.handleCommand("didShopLiveOff", with: ["style" : self.lastStyle.rawValue])
                    ShopLiveController.shared.videoExpanded = true
                    self.needAnimateToChangePreivew = false
                    self.handleWindowChangeCommand()
                }
            }
            
            
        }
    }
    
    func didChangeOSPIP() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard !ShopLiveController.shared.isPreview else { return }
            guard let mainWindow = self.mainWindow else { return }
            guard let shopLiveWindow = self.shopLiveWindow else { return }
            self.isWindowChanging = true
            if ShopLiveConfiguration.UI.keepWindowStyleOnReturnFromOsPip {
                if self._style == .fullScreen {
                    shopLiveWindow.frame = mainWindow.bounds
                } else {
                    shopLiveWindow.frame = self.pipPosition(with: self.pipScale, position: self.getPipPosition())
                }
            } else {
                guard self._style != .fullScreen else { return }
                shopLiveWindow.frame = mainWindow.bounds
            }

            self.liveStreamViewController?.shopliveHideKeyboard()

            self.videoWindowPanGestureRecognizer?.isEnabled = false
            self.videoWindowTapGestureRecognizer?.isEnabled = false
            self.videoWindowSwipeDownGestureRecognizer?.isEnabled = true
            ShopLiveController.webInstance?.isHidden = false

            shopLiveWindow.layer.shadowColor = nil
            shopLiveWindow.layer.shadowOpacity = 0.0
            shopLiveWindow.layer.shadowOffset = .zero
            shopLiveWindow.layer.shadowRadius = 0

            shopLiveWindow.rootViewController?.view.backgroundColor = .black

            shopLiveWindow.layer.cornerRadius = 0
            shopLiveWindow.rootViewController?.view.layer.cornerRadius = 0
            shopLiveWindow.setNeedsLayout()
            shopLiveWindow.layoutIfNeeded()

            self.liveStreamViewController?.setCloseButtonVisible(false)
            self.liveStreamViewController?.showBackgroundPoster()
            ShopLiveController.shared.pipAnimating = false
        }
    }

    private func alignPipView() {
        guard let currentCenter = shopLiveWindow?.center else { return }
        guard let mainWindow = self.mainWindow else { return }
        let center = mainWindow.center
        let keyboardHeight: CGFloat = isKeyboardShow ? ShopLiveController.shared.keyboardHeight : 0
        let rate = (mainWindow.frame.height - keyboardHeight) / mainWindow.frame.height
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

        self.setPipPosition(pos: position)
//        self.pipPosition = position
        self.handleKeyboard()

    }
    
    private func handleWindowChangeCommand() {
        if ShopLiveConfiguration.UI.keepWindowStyleOnReturnFromOsPip && windowChangeCommand == .none{
            return
        }
        
        self.activeFromBackground = false
        self.isWindowChanging = false
        switch self.windowChangeCommand {
        case .switchToFullScreen:
            guard ShopLiveController.windowStyle == .inAppPip || ShopLiveController.windowStyle == .osPip else {
                return
            }
            guard !ShopLiveController.shared.isPreview else {
                return
            }
            self.stopPictureInPicture()
            self.windowChangeCommand = .none
            break
        case .switchToInAppPip:
            guard ShopLiveController.windowStyle == .normal else {
                return
            }
            guard !ShopLiveController.shared.isPreview else {
                return
            }
            self.startCustomPictureInPicture(with: self.getPipPosition(), scale: self.pipScale)
            self.windowChangeCommand = .none
            break
        default:
            break
        }
        
    }
    
    private func alignPipPosion(pipCenter: CGPoint) -> ShopLive.PipPosition {
        guard let mainWindow = self.mainWindow else { return .bottomRight }
        let center = mainWindow.center
        let keyboardHeight: CGFloat = isKeyboardShow ? ShopLiveController.shared.keyboardHeight : 0
        let rate = (mainWindow.frame.height - keyboardHeight) / mainWindow.frame.height
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
        
        liveWindow.layer.masksToBounds = false
        let translation = recognizer.translation(in: liveWindow)
        
        delegate?.playerPanGesture?(state: recognizer.state, position: liveWindow.center)
        
        switch recognizer.state {
        case .began:
            panGestureInitialCenter = liveWindow.center
        case .changed:
            let centerX = panGestureInitialCenter.x + translation.x
            let centerY = panGestureInitialCenter.y + translation.y
            liveWindow.center = CGPoint(x: centerX, y: centerY)
        case .ended:
            guard let mainWindow = self.mainWindow else { return }
            liveWindow.layer.masksToBounds = true
            let velocity = recognizer.velocity(in: liveWindow)

            let safeAreaInset = mainWindow.safeAreaInsets
            let pipEdgeInsets: UIEdgeInsets = ShopLiveConfiguration.UI.pipPadding
            let pipFloatingOffset: UIEdgeInsets = ShopLiveConfiguration.UI.pipFloatingOffset
            let pipFloatingOffsetBottom: CGFloat = isKeyboardShow ? 0 : pipFloatingOffset.bottom
            
            let mainWindowHeight: CGFloat = mainWindow.bounds.height - (isKeyboardShow ? ShopLiveController.shared.keyboardHeight : 0)
            let minX = (liveWindow.bounds.width / 2.0) + pipEdgeInsets.left + safeAreaInset.left + liveWindow.bounds.origin.x + pipFloatingOffset.left
            let maxX = mainWindow.bounds.width - ((liveWindow.bounds.width / 2.0) + pipEdgeInsets.right + safeAreaInset.right + pipFloatingOffset.right)
            let minY = liveWindow.bounds.height / 2.0 + pipEdgeInsets.top + safeAreaInset.top + pipFloatingOffset.top + liveWindow.bounds.origin.y - (isKeyboardShow ? ShopLiveController.shared.keyboardHeight : 0)
            let maxY = mainWindowHeight - ((liveWindow.bounds.height / 2.0) + pipEdgeInsets.bottom + pipFloatingOffsetBottom + safeAreaInset.bottom)
            
            var centerX = panGestureInitialCenter.x + translation.x
            var centerY = panGestureInitialCenter.y + translation.y
            
            let xRange = (pipFloatingOffset.left + pipEdgeInsets.left)...(mainWindow.bounds.width - pipFloatingOffset.right - pipEdgeInsets.right)
            let yRange = (pipFloatingOffset.top + pipEdgeInsets.top + safeAreaInset.top)...(mainWindowHeight - (safeAreaInset.bottom + pipFloatingOffset.bottom + pipEdgeInsets.bottom)) + (isKeyboardShow ? liveWindow.frame.height * 0.2 : 0)
            
            //범위밖으로 나가면 stop shoplive
            
            var checkCenterX = centerX
            var checkCenterY = centerY
            
            ShopLiveLogger.debugLog("xRange \(xRange)")
            ShopLiveLogger.debugLog("yRange \(yRange)")
            
            guard let liveStreamViewController = self.liveStreamViewController else { return }
            
            let pipPosition = liveStreamViewController.viewModel.getPipPosition()
            if pipPosition == .topLeft || pipPosition == .bottomLeft {
                if velocity.x < 0 {
                    if velocity.x.magnitude > 600 {
                        if checkCenterX + velocity.x < minX {
                            checkCenterX = minX - liveWindow.frame.width
                        }
                    }
                }
            } else if pipPosition == .topRight || pipPosition == .bottomRight {
                if velocity.x > 0 {
                    if velocity.x.magnitude > 600 {
                        if checkCenterX + velocity.x > maxX {
                            checkCenterX = maxX + liveWindow.frame.width
                        }
                    }
                }
            }
            
            if pipPosition == .topLeft || pipPosition == .topRight {
                if velocity.y > 0 {
                    if velocity.y.magnitude > 600 {
                        if checkCenterY + velocity.y < minY {
                            checkCenterY = minY - liveWindow.frame.height
                        }
                    }
                }
            } else if pipPosition == .bottomLeft || pipPosition == .bottomRight {
                if velocity.y < 0 {
                    if velocity.y.magnitude > 600 {
                        if checkCenterY + velocity.y > maxY {
                            checkCenterY = maxY + liveWindow.frame.height
                        }
                    }
                }
            }
            
            ShopLiveLogger.debugLog("checkCenterX \(checkCenterX)")
            ShopLiveLogger.debugLog("checkCenterY \(checkCenterY)")
            
            if liveStreamViewController.viewModel.getEnablePipSwipeOut() == true || ShopLiveController.shared.isPreview {
                guard xRange.contains(checkCenterX), yRange.contains(checkCenterY) else {
                    delegate?.handleCommand(ShopLiveController.shared.isPreview ? "CLOSE_FROM_PREVIEW" : "CLOSE_FROM_PLAY", with: nil)
                    hideShopLiveView()
                    return
                }
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
        if self.enabledPictureInPictureMode == false {
            return
        }
        
        guard ShopLiveController.shared.swipeEnabled else { return }
        guard !ShopLiveController.shared.isPreview else { return }
        guard _style == .fullScreen else { return }
        guard let topViewController = UIApplication.topViewController(base: self.liveStreamViewController), topViewController.isKind(of: LiveStreamViewController.self) else {
            self.shopLiveWindow?.rootViewController?.dismiss(animated: false, completion: nil)
            return
        }
        delegate?.log?(name: "swipe_pip_mode", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, parameter: [:])
        delegate?.log?(name: "swipe_pip_mode", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: [:])
        if ShopLiveController.shared.videoOrientation == .landscape {
            if UIScreen.isLandscape {
                self.liveStreamViewController?.updateOrientation(toLandscape: false)
            } else {
                self.startCustomPictureInPicture(with: self.getPipPosition(), scale: self.pipScale)
            }
        } else {
            self.startCustomPictureInPicture(with: self.getPipPosition(), scale: self.pipScale)
        }
    }
    
    @objc private func pipTapGestureHandler(_ recognizer: UITapGestureRecognizer) {
        if ShopLiveController.shared.isPreview {
            previewCallback?()
            return
        }
        guard _style == .pip else { return }
        stopShopLivePictureInPicture()
    }
    
    @objc private func pinchGestureHandler(_ recognizer: UIPinchGestureRecognizer) {
        guard ShopLiveController.shared.videoOrientation == .landscape, ShopLiveController.windowStyle == .normal else { return }
        guard UIScreen.isLandscape else { return }
        guard ShopLiveController.shared.videoExpanded else { return }
        
        if let isSnapshotHidden = self.liveStreamViewController?.getIsSnapShotHidden() {
            guard (isSnapshotHidden && ShopLiveController.timeControlStatus == .playing) ||
                    (!isSnapshotHidden && ShopLiveController.timeControlStatus != .playing) else {
                return
            }
        }
                
        switch recognizer.state {
        case .ended:
            ShopLiveController.shared.videoCenterCrop = recognizer.scale > 1.0
            self.liveStreamViewController?.changeVideoGravity(centerCrop: ShopLiveController.shared.videoCenterCrop)
            delegate?.log?(name: recognizer.scale > 1.0 ? "pinch_zoom_out" : "pinch_zoom_in", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, parameter: [:])
            delegate?.log?(name: recognizer.scale > 1.0 ? "pinch_zoom_out" : "pinch_zoom_in", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: [:])
            break
        default:
            break
        }
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

        self.queryParameters.forEach { param in
            queryItems.append(URLQueryItem(name: param.key, value: param.value))
        }
        
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
        #if EBAY
        queryItems.append(URLQueryItem(name: "keepAspectOnTabletPortrait", value: "false"))
        #else
        queryItems.append(URLQueryItem(name: "keepAspectOnTabletPortrait", value: "\(ShopLiveConfiguration.UI.keepAspectOnTabletPortrait ? "true" : "false")"))
        #endif
        #if DEMO
            queryItems.append(URLQueryItem(name: "applicationName", value: "shoplive-sdk-sample"))
        #endif
        
        self.queryParameters.forEach { param in
            queryItems.append(URLQueryItem(name: param.key, value: param.value))
        }
        
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

        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.protectedDataWillBecomeUnavailableNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        
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

        NotificationCenter.default.removeObserver(self, name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.protectedDataWillBecomeUnavailableNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
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

        let pipPosition: CGRect = self.pipPosition(with: self.pipScale, position: self.getPipPosition())
        
        UIView.animate(withDuration: 0.3, delay: 0, options: []) {
            shopLiveWindow.frame = pipPosition
            shopLiveWindow.setNeedsLayout()
            shopLiveWindow.layoutIfNeeded()
        }
    }

    
    private var backgroundPlayerBlockTimer : Timer?
    private func setBackgroundPlayerBlockTimer(){
        invalidateAndResetbackgroundPlayerBlockTimer()
        if ShopLiveController.windowStyle == .osPip {
            return
        }
        backgroundPlayerBlockTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
            guard let player = ShopLiveController.player else {
                timer.invalidate()
                return
            }
            if ShopLiveController.windowStyle != .osPip {
                player.pause()
                player.currentItem?.cancelPendingSeeks()
                player.cancelPendingPrerolls()
                player.currentItem?.asset.cancelLoading()
            }
            
        })
        backgroundPlayerBlockTimer?.fire()
    }
    
    private func invalidateAndResetbackgroundPlayerBlockTimer(){
        if backgroundPlayerBlockTimer != nil {
            backgroundPlayerBlockTimer?.invalidate()
            backgroundPlayerBlockTimer = nil
        }
    }
    
    @objc func handleNotification(_ notification: Notification) {
        switch notification.name {
        case UIApplication.didBecomeActiveNotification:
            invalidateAndResetbackgroundPlayerBlockTimer()
            if ShopLiveController.shared.isPreview {
                ShopLiveController.playControl = .resume
            } else {
                if ShopLiveController.timeControlStatus == .paused {
                    ShopLiveController.playControl = .resume
                }
                self.osPictureInPictureController?.stopPictureInPicture()
            }
            break
        case UIApplication.willResignActiveNotification:
            self.startOsPictureInPicture()
            break
        case UIApplication.didEnterBackgroundNotification:
            self.startOsPictureInPicture()
            self.liveStreamViewController?.onBackground()
            setBackgroundPlayerBlockTimer()
            break
        case UIApplication.protectedDataDidBecomeAvailableNotification:
            ShopLiveController.shared.screenLock = false
            self.liveStreamViewController?.onUnlockScreen()
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
            self.liveStreamViewController?.onLockScreen()
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
        case UIApplication.willChangeStatusBarOrientationNotification:
            break
        case UIDevice.orientationDidChangeNotification:
            break
        default:
            break
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "_style":
            guard let oldValue: Int = change?[.oldKey] as? Int,
                  let newValue: Int = change?[.newKey] as? Int, oldValue != newValue,
                  let newStyle: ShopLive.PresentationStyle = .init(rawValue: newValue) else {
                if let newValue: Int = change?[.newKey] as? Int,
                   let newStyle: ShopLive.PresentationStyle = .init(rawValue: newValue),
                   ShopLiveController.windowStyle != .osPip {
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
    private func sendCommandChangeToPip() {
        guard !ShopLiveController.shared.isPreview else { return }
        self.delegate?.handleCommand("CHANGE_TO_PIP", with: nil)
    }
}

extension ShopLiveBase: ShopLiveComponent {
    func getPipPosition() -> ShopLive.PipPosition {
        if let liveStreamViewController = self.liveStreamViewController {
            return liveStreamViewController.viewModel.getPipPosition()
        }
        if let config = self.inAppPipConfiguration, let pos = config.pipPosition {
            return pos
        }
        return ShopLiveController.shared.initialPipPosition
    }
    
    func setPipPosition(pos : ShopLive.PipPosition) {
        liveStreamViewController?.viewModel.setPipPosition(position: pos)
    }
    
    func setInAppPipConfiguration(config: ShopLiveInAppPipConfiguration) {
        self.inAppPipConfiguration = config
    }
    
    func setMixWithOthers(isMixAudio: Bool) {
        ShopLiveConfiguration.SoundPolicy.useMixWithOthers = isMixAudio
    }
    func setEnabledPictureInPictureMode(isEnabled : Bool){
        self.enabledPictureInPictureMode = isEnabled
    }
    
    func awakePlayer() {
        self.liveStreamViewController?.awakePlayer()
    }
    
    func isSuccessCampaignJoin() -> Bool {
        return ShopLiveController.shared.isSuccessCampaignJoin
    }

    func setLoadingAnimation(images: [UIImage]) {
        ShopLiveConfiguration.UI.setLoadingAnimation(images: images)
    }

    func setKeepAspectOnTabletPortrait(_ keep: Bool) {
        #if EBAY
        ShopLiveConfiguration.UI.keepAspectOnTabletPortrait = true
        #else
        ShopLiveConfiguration.UI.keepAspectOnTabletPortrait = keep
        #endif
    }

    var playerWindow: ShopliveWindow? {
        return self.shopLiveWindow
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
        ShopLiveController.shared.customShareAction = .init(custom: custom)
    }

    func onTerminated() {
        #if DEMO
        ShopLiveDevConfiguration.shared.useAppLog = false
        #endif

        liveStreamViewController?.onTerminated()
    }
    
    func setKeepPlayVideoOnHeadphoneUnplugged(_ keepPlay: Bool, isMute: Bool = false) {
        ShopLiveConfiguration.SoundPolicy.keepPlayVideoOnHeadphoneUnplugged = keepPlay
        ShopLiveConfiguration.SoundPolicy.onHeadphoneUnpluggedIsMute = isMute
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
        startPictureInPicture(with: self.getPipPosition(), scale: self.pipScale)
//        startCustomPictureInPicture(with: self.pipPosition, scale: self.pipScale)
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

    @objc func configure(with accessKey: String) {
        self.accessKey = accessKey
    }

    func preview(with campaignKey: String?, referrer: String? = nil, completion: @escaping () -> Void) {
        guard !ShopLiveController.shared.pipAnimating else { return }

        ShopLiveController.shared._playerMode = .preview
        debouncer.renewInterval()
        debouncer.handler = {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(ShopLiveController.shared.execusedClose ? 800 : 0)) { [weak self] in
                guard let self = self else { return }
                self.resetQueryParameters()
                
                ShopLiveController.shared.execusedClose = false
                guard self.accessKey != nil else { return }
                
                let audioSessionManager = AudioSessionManager.shared
                if self._style == .unknown {
                    audioSessionManager.customerAudioCategoryOptions = audioSessionManager.currentCategoryOptions
                }
                
                audioSessionManager.setCategory(category: .playback, options: .mixWithOthers)
                
                if let referrer = referrer {
                    self.queryParameters["referrer"] = referrer
                }
                
                self.queryParameters["_from"] = "sdk_direct"
                
                ShopLiveController.shared.campaignKey = campaignKey ?? ""
                self.delegate?.log?(name: "player_start", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, parameter: ["type" : "preview"])
                self.delegate?.log?(name: "player_start", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: ["type" : "preview"])
                
                self.addObserver()
                
                if !ShopLiveController.shared.isPreview && ShopLiveController.windowStyle == .normal {
                    if ShopLiveController.shared.isSameCampaign {
                        ShopLiveController.shared.keepSnapshot = true
                        self.liveStreamViewController?.takeSnapShot(on: true) {
                            self.liveStreamViewController?.updateImageFit()
                            self.startCustomPictureInPicture(with: self.getPipPosition(), scale: self.pipScale)
                        }
                    } else {
                        self.liveStreamViewController?.updateImageFit()
                        self.startCustomPictureInPicture(with: self.getPipPosition(), scale: self.pipScale)
                    }
                }
                
                ShopLiveController.shared.isPreview = true
                
                self.previewCallback = completion
                self.campaignKey = campaignKey
                self.fetchPreviewUrl(with: campaignKey) { [weak self] url in
                    guard let url = url else {
                        self?.removeObserver()
                        return
                    }
                    self?.windowChangeCommand = .none
                    self?.isWindowChanging = false
                    self?.showPreview(previewUrl: url)
                }
            }
        }
        
    }
    
    @objc func play(with campaignKey: String?, referrer: String? = nil) {
        guard !ShopLiveController.shared.pipAnimating else { return }
        ShopLiveController.shared._playerMode = .play
        debouncer.renewInterval()
        debouncer.handler = {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(ShopLiveController.shared.execusedClose ? 800 : 0)) {
                self.resetQueryParameters()
                ShopLiveController.shared.execusedClose = false
                guard self.accessKey != nil else { return }
                
                if let referrer = referrer {
                    self.queryParameters["referrer"] = referrer
                }
                
                ShopLiveController.shared.campaignKey = campaignKey ?? ""
                self.needExecuteFullScreen = ShopLiveController.shared.isPreview

                let audioSessionManager = AudioSessionManager.shared
                if self._style == .unknown {
                    audioSessionManager.customerAudioCategoryOptions = audioSessionManager.currentCategoryOptions
                }
                
                let categoryOption: AVAudioSession.CategoryOptions = ShopLiveConfiguration.SoundPolicy.useMixWithOthers ? .mixWithOthers : audioSessionManager.customerAudioCategoryOptions
                
                audioSessionManager.setCategory(category: .playback, options: categoryOption)
                
                if self.needExecuteFullScreen {
                    self.queryParameters["_from"] = "sdk_preview"
                    self.delegate?.log?(name: "preview_to_player_mode", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, parameter: [:])
                    self.delegate?.log?(name: "preview_to_player_mode", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: [:])
                } else {
                    self.queryParameters["_from"] = "sdk_direct"
                }
                self.delegate?.log?(name: "player_start", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, parameter: ["type" : "normal"])
                self.delegate?.log?(name: "player_start", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: ["type" : "normal"])
                ShopLiveController.shared.isPreview = false
                self.addObserver()
                self.campaignChanged = (campaignKey != self.campaignKey)
                self.campaignKey = campaignKey
                
                self.fetchOverlayUrl(with: campaignKey) { [weak self] url in
                    guard let url = url else {
                        self?.removeObserver()
                        return
                    }
                    self?.liveStreamViewController?.viewModel.authToken = self?._authToken
                    self?.liveStreamViewController?.viewModel.user = self?._user
                    
                    self?.windowChangeCommand = .none
                    self?.isWindowChanging = false
                    
                    self?.showShopLiveView(with: url) { [weak self] in
                        guard let self = self else { return }
                        if let ak = self.accessKey,
                           let vc = self.liveStreamViewController,
                           ShopLiveController.shared.isPreview == false {
                            vc.viewModel.updatePlayerItemWithLiveUrlFetchAPI(accessKey: ak,
                                                                             campaignKey: ShopLiveController.shared.campaignKey,
                                                                             isPreview: false) {
                                
                                guard let playerFrame = vc.viewModel.getEstimatedPlayerFrameForFullScreenOnInitalize() else { return }
                                DispatchQueue.main.async {
                                    vc.updatePlayerFrame(centerCrop : true, playerFrame: playerFrame,immediately: false)
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    @objc func reloadLive() {
        guard self.accessKey != nil else { return }
        liveStreamViewController?.reload()
    }
    
    @objc func startPictureInPicture(with position: ShopLive.PipPosition, scale: CGFloat) {
        self.pipScale = scale
        self.setPipPosition(pos: position)
        
        if !self.isWindowChanging {
            self.startShopLivePictureInPicture()
        } else {
            self.windowChangeCommand = .switchToInAppPip
            if !activeFromBackground {
                self.startShopLivePictureInPicture()
            }
        }
        
    }
    @objc func stopPictureInPicture() {
        if self.isWindowChanging == false {
            self.stopShopLivePictureInPicture()
        } else {
            self.windowChangeCommand = .switchToFullScreen
        }
        
    }
    
    @objc var style: ShopLive.PresentationStyle {
        get {
            return _style
        }
    }
    
    @objc var pipScale: CGFloat {
        get {
            guard let fixPipWidth = fixedPipWidth as? CGFloat else {
                return convertPipScale(userScale: ShopLiveController.shared.lastPipScale)
            }

            let fixedScale = fixPipWidth / (UIScreen.isLandscape ? UIScreen.main.bounds.height : UIScreen.main.bounds.width)
            return (fixedScale >= 0.0 && fixedScale <= 1.0) ? fixedScale : (fixedScale < 0 ? 0.0 : 1.0)
        }
        set {
            ShopLiveController.shared.lastPipScale = newValue
        }
    }

    @objc var fixedPipWidth: NSNumber? {
        get {
            return ShopLiveController.shared.fixedPipWidth as NSNumber?
        }
        set {
            ShopLiveController.shared.fixedPipWidth = newValue as? CGFloat
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
        self.isWindowChanging = true
        ShopLiveController.shared.willStartPip = true
        ShopLiveController.shared.needReload = false
        ShopLiveController.windowStyle = .osPip
        ShopLiveController.shared.lastPipPlaying = ShopLiveController.timeControlStatus == .playing
        self.liveStreamViewController?.shopliveHideKeyboard()
    }
    
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        ShopLiveController.playControl = .resume
        ShopLiveController.webInstance?.sendEventToWeb(event: .onPipModeChanged, true)
        
        if !ShopLiveConfiguration.UI.keepWindowStyleOnReturnFromOsPip {
            didChangeOSPIP()
        }
    }
    
    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        setupOsPictureInPicture()
        if !ShopLiveController.isReplayMode && ShopLiveController.timeControlStatus == .playing {
            ShopLiveController.webInstance?.sendEventToWeb(event: .reloadBtn, false, false)
        }
        
        if ShopLiveConfiguration.UI.keepWindowStyleOnReturnFromOsPip {
            let prevWindowStyle = ShopLiveController.shared.prevWindowStyle
            _style = prevWindowStyle == .normal ? .fullScreen : prevWindowStyle == .inAppPip ? .pip : .unknown
            ShopLiveController.windowStyle = prevWindowStyle
        } else {
            _style = .fullScreen
            ShopLiveController.windowStyle = .normal
        }
        ShopLiveController.shared.willStartPip = false
        preSetUpSwipeEnabledRestoredFromOsPip()
    }

    private func preSetUpSwipeEnabledRestoredFromOsPip(){
        if ShopLiveController.windowStyle != .inAppPip {
            ShopLiveController.shared.swipeEnabled = true
        }
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        self.activeFromBackground = true
        
        if !isRestoredPip { //touch stop pip button in OS PIP view
            self.hideShopLiveView()
        }
        else {
            if ShopLiveController.shared.needReload {
                ShopLiveController.shared.needReload = false
                guard !ShopLiveController.isReplayMode else {
                    return
                }

                ShopLiveController.shared.playControl = .resume
            }
            else {
                if ShopLiveController.timeControlStatus == .paused, !ShopLiveController.isReplayMode {
                    ShopLiveController.shared.playControl = .resume
                }
            }
            
            if ShopLiveConfiguration.UI.keepWindowStyleOnReturnFromOsPip && ShopLiveController.windowStyle == .inAppPip && ShopLiveController.shared.isPreview == false {
                self.startFromCampaignPIP()
            }
            else {
                self.startFromCampaignFullscreen(animationDuration: 0.1)
            }
            self.isWindowChanging = false
        }
        
        ShopLiveController.webInstance?.sendEventToWeb(event: .onPipModeChanged, false)
        
        isRestoredPip = false
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        ShopLiveLogger.debugLog("AVPictureInPicture failed to start with error -> \(error)")
    }
    
    private func resetQueryParameters() {
        queryParameters.removeAll()
    }
}

extension ShopLiveBase: LiveStreamViewControllerDelegate {
    func resetPictureInPicture() {
        if osPictureInPictureController == nil {
            setupOsPictureInPicture()
        }
    }
    
    func log(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any]) {
        delegate?.log?(name: name, feature: feature, campaign: campaign, payload: payload)
        var param : [String : Any] = ["campaignKey" : campaign]
        for (key, value) in payload {
            param.updateValue(value, forKey: key)
        }
        delegate?.handleReceivedCommand(name, with: param.toJSONString())
    }
    
    func handleReceivedCommand(_ command: String, with payload: Any?) {
        delegate?.handleReceivedCommand(command, with: payload)
    }
    
    
    func changeOrientation(to: ShopLiveDefines.ShopLiveOrientaion) {
        self.inRotating = true
        if _style == .pip, ShopLiveController.windowStyle == .inAppPip {
            updatePip(isRotation: true)
        } else {
            
            let param: Dictionary = Dictionary<String, Any>.init(dictionaryLiteral: ("top", UIScreen.safeArea.top), ("left", UIScreen.safeArea.left),
                                                                 ("right", UIScreen.safeArea.right), ("bottom", UIScreen.safeArea.bottom), ("orientation", UIScreen.currentOrientation.angle))
            
            self.liveStreamViewController?.sendCommandMessage(command: "SET_SAFE_AREA_MARGIN", payload: param)
            
            self.liveStreamViewController?.updateVideoFrame(immeadiately: false)
            self.shopLiveWindow?.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
                
            } completion: { [weak self] _ in
                self?.shopLiveWindow?.layer.removeAllAnimations()
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) { [weak self] in
                    self?.liveStreamViewController?.updateVideoConstraint()
                    self?.shopLiveWindow?.layoutIfNeeded()
                } completion: { _ in
                }
            }
        }
    }
    
    func finishRotation() {
        self.inRotating = false
        self.shopLiveWindow?.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve) { [weak self] in
            self?.liveStreamViewController?.showBackgroundPoster()
        } completion: { [weak self] _ in
            self?.shopLiveWindow?.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.3, delay: 0.25, options: .transitionCrossDissolve) {
                ShopLiveController.shared.webInstance?.alpha = 1
            } completion: { [weak self] _ in
                guard let self = self else { return }
                if !self.inRotating {
                    self.shopLiveWindow?.layer.masksToBounds = false
                    self.liveStreamViewController?.setCloseDimLayerVisible(true)
                }
            }
        }
    }
    
    func updatePictureInPicture() {
        if ShopLiveController.shared.isPreview  {
            willChangePreview()
        }
        else {
            if _style == .pip {
                if ShopLiveController.shared.videoOrientation == .landscape {
                    updatePip()
                } else {
                    startFromCampaignPIP()
                }
            } else {
                self.startFromCampaignFullscreen()
            }
        }
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

        let completionResult: (ShopLiveCustomActionResult?) -> Void = { [weak self] customActionResult in
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
                startCustomPictureInPicture(with: self.getPipPosition(), scale: self.pipScale)
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

        let completionResult: (ShopLiveCouponResult?) -> Void = { [weak self] couponResult in
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
