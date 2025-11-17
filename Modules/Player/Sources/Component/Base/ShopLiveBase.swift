import UIKit
import AVKit
import WebKit
import ShopliveSDKCommon

@objc internal final class ShopLiveBase: NSObject {
    private var inRotating: Bool = false
    private var shopLiveWindow: ShopliveWindow? = nil
    private var videoWindowPanGestureRecognizer: UIPanGestureRecognizer?
    private var videoWindowTapGestureRecognizer: UITapGestureRecognizer?
    
    private var videoWindowSwipeDownGestureRecognizer: UISwipeGestureRecognizer?
    private var _webViewConfiguration: WKWebViewConfiguration?
    private var isRestoredPip: Bool = false
    private var campaignKey: String?
    private var campaignChanged: Bool = false
    private var needExecuteFullScreen: Bool = false
    private var playerModeChanged: Bool = false
    private var needAnimateToChangePreivew: Bool = false
    private var activeFromBackground: Bool = false
    private var enabledPictureInPictureMode: Bool = true
    private var enabledOSPictureInPictureMode: Bool = true
    private var blockWindowTapGesture: Bool = false
    private var inAppPipConfiguration: ShopLiveInAppPipConfiguration?
    private var blockLiveWindowPangestureHapticSound: Bool = false
    
    private var windowAnimator: UIViewPropertyAnimator?
    private var reservedPlayInfo: (playStyle: ShopLiveWindowStyle, campaignKey: String, referrer: String?, campaignHandler: ((ShopLivePlayerCampaign) -> ())?, brandHandler: ((ShopLivePlayerBrand) -> ())?)?
    private var statusBarVisibility: Bool = true
    lazy private var shareDelegate: ShopLivePlayerShareDelegate = self
    //무신사 요청 사항
    private var customerPreviewCoverView: UIView?
    
    private var shopLivePlayerCampaignHandler: ((ShopLivePlayerCampaign) -> ())?
    private var shopLivePlayerBrandHandler: ((ShopLivePlayerBrand) -> ())?
    
    private var customerVideoResizeMode: ShopLiveResizeMode?
    private var isForceStartWithPortraitMode: Bool = true
    
    private let throttle = SLThrottle(queue: .main, delay: 0.9)
    
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
        let maxHeight = (UIScreen.isLandscape_SL ? UIScreen.main.bounds.height : UIScreen.main.bounds.width)
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
            return UIScreen.isLandscape_SL ? minWidth / UIScreen.main.bounds.height : minWidth / UIScreen.main.bounds.width
        case .landscape:
            return UIScreen.isLandscape_SL ? pipMin / UIScreen.main.bounds.height : pipMin / UIScreen.main.bounds.width
        }
    }
    
    private var maxScale: CGFloat {
        let videoOrientaion: ShopLiveDefines.ShopLiveOrientaion = ShopLiveController.shared.videoOrientation
        
        switch videoOrientaion {
        case .portrait:
            let maxWidth = pipMax * (ShopLiveController.shared.videoRatio.width/ShopLiveController.shared.videoRatio.height)
            return UIScreen.isLandscape_SL ? maxWidth / UIScreen.main.bounds.height : maxWidth / UIScreen.main.bounds.width
        case .landscape:
            return UIScreen.isLandscape_SL ? pipMax / UIScreen.main.bounds.height : pipMax / UIScreen.main.bounds.width
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
    weak private var mainWindow: UIWindow? = nil
    
    @objc dynamic var _style: ShopLive.PresentationStyle = .unknown {
        didSet{
            self._lastStyle = oldValue
        }
    }
    
    private var _lastStyle: ShopLive.PresentationStyle = .unknown
    
    
    private var previewCallback: (() -> Void)?
    static let parentStatusBarStyle = UIApplication.shared.statusBarStyle
    var liveStreamViewController: LiveStreamViewController?
    var osPictureInPictureController: SLPictureInPictureController?
    
    var pipPossibleObservation: NSKeyValueObservation?
    
    var isWindowChanging = false
    var windowChangeCommand: ShopLiveWindowChangeCommand = .none
    var queryParameters: [String: String] = [:]
    
    weak var _delegate: ShopLiveSDKDelegate?
    
    static var sessionState: PlayerSessionState = .terminated
    
    override init() {
        super.init()
        ShopLiveCommon.setDelegate(delegate: self)
        ShopLiveController.shared.delegate = self
    }
    
    deinit {
        ShopLiveController.shared.delegate = nil
    }
    
    func showShopLiveView(
        with overlayUrl: URL,
        isPreview: Bool,
        _ completion: (() -> Void)? = nil
    ) {
        UIApplication.shared.isIdleTimerDisabled = true
        
        if shopLiveWindow != nil {
            teardownShopLiveWindow()
        }
        
        if !ShopLiveController.shared.isSameCampaign {
            ShopLiveController.shared.resetVideoDatas()
        }
        
        if (shopLiveWindow == nil || liveStreamViewController == nil) && _style != .unknown {
            self._style = .unknown
        }
        
        if _style != .unknown {
            self.liveStreamViewController?.viewModel.overayUrl = overlayUrl
            self.liveStreamViewController?.reload()
            self.liveStreamViewController?.updateChattingViewPlaceholderVisibility()
            if self.needExecuteFullScreen {
                if ShopLiveController.shared.isSameCampaign {
                    self.liveStreamViewController?.takeSnapShot()
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
            let audioSessionManager = SLAudioSessionManager.shared
            audioSessionManager.setCategory(category: ShopLiveConfiguration.SoundPolicy.audioSessionCategory, options: audioSessionManager.currentCategoryOptions)
        }
        
        ShopLiveController.shared.releaseData()
        isKeyboardShow = false
        
        liveStreamViewController = LiveStreamViewController()
        liveStreamViewController?.setInitialAVPlayerLayerVideoGravity(isPreview: isPreview)
        // inAppPipConfiguration에서 pipPosition이 설정되어 있지 않다면, legacy를 통해서 세팅된거여서 초기값을 밀어넣어줘야 함
        if inAppPipConfiguration?.pipPosition == nil {
            liveStreamViewController?.viewModel.setPipPosition(position: ShopLiveController.shared.initialPipPosition)
        }
        liveStreamViewController?.viewModel.setResizeMode(mode: customerVideoResizeMode)
        liveStreamViewController?.viewModel.setInAppPipConfiguration(config: inAppPipConfiguration)
        liveStreamViewController?.delegate = self
        liveStreamViewController?.webViewConfiguration = _webViewConfiguration
        liveStreamViewController?.viewModel.overayUrl = overlayUrl
        
        if isPreview {
            self.liveStreamViewController?.setStatusBarVisiblityOnFullScreen(isVisible: true)
        }
        else {
            self.liveStreamViewController?.setStatusBarVisiblityOnFullScreen(isVisible: statusBarVisibility)
        }
        
        
        shopLiveWindow = ShopliveWindow()
        
        if #available(iOS 13.0, *) {
            var activeScene: UIWindowScene? = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }
            mainWindow = activeScene?.windows.first(where: { $0.isKeyWindow })
            shopLiveWindow?.windowScene = activeScene
        } else {
            mainWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        }
        
        shopLiveWindow?.backgroundColor = .clear
        shopLiveWindow?.windowLevel = .statusBar - 1
        shopLiveWindow?.isHidden = false
        
        if isPreview {
            ShopLiveController.shared.isPreview = true
            let pipPosition = self.pipPosition(with: self.pipScale, position: self.getPipPosition())
            shopLiveWindow?.frame = .zero
            shopLiveWindow?.center = pipPosition.center
            
            _style = .pip
            self.liveStreamViewController?.updateStatusBarToDefault()
            ShopLiveController.windowStyle = .inAppPip
            
            
        } else {
            ShopLiveController.shared.isPreview = false
            shopLiveWindow?.frame = mainWindow?.frame ?? UIScreen.main.bounds
            
            mainWindow?.rootViewController?.shopliveHideKeyboard_SL()
            ShopLiveController.windowStyle = .normal
            _style = .fullScreen
        }
        
        self.shopLiveWindow?.rootViewController = self.liveStreamViewController
        self.liveStreamViewController?.view.backgroundColor = .black
        
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
        
        ShopLiveController.windowStyle = .normal
        
        setupOsPictureInPicture()
        shopLiveWindow?.makeKeyAndVisible()
        
        self.delegate?.handleChangedPlayerStatus?(status: "CREATED")
        
        ShopLiveBase.sessionState = .foreground
        if let completion = completion {
            completion()
        }
    }
    
    func hideShopLiveView(_ animated: Bool = true, viewHideActionType: ShopLiveViewHiddenActionType) {
        self.liveStreamViewController?.updateStatusBarToDefault()
        ShopLiveController.shared.execusedClose = true
        UIApplication.shared.isIdleTimerDisabled = false
        
        if ShopLiveBase.sessionState != .terminated {
            ShopLiveController.webInstance?.sendEventToWeb(event: .onTerminated)
        }
        delegate?.handleCommand?("willShopLiveOff", with: ["style": self.style.rawValue])
        
        //inAppPip일때 lastStyle이 fullScreen으로 나오는점 때문에
        //나중에 완전히 갈아 엎으면서 style, lastStyle 다시 재정의 필요
        if ShopLiveController.windowStyle == .inAppPip && ShopLiveController.shared.isPreview == false {
            delegate?.handleCommand?( ShopLiveViewTrackEvent.viewWillDisAppear.name, with: ["lastStyle": ShopLive.PresentationStyle.pip.name ,
                                                                                            "currentStyle": self.style.name,
                                                                                            "isPreview": ShopLiveController.shared.isPreview])
        }
        else {
            delegate?.handleCommand?( ShopLiveViewTrackEvent.viewWillDisAppear.name, with: ["lastStyle": self._lastStyle.name , "currentStyle": self.style.name, "isPreview": ShopLiveController.shared.isPreview])
        }
        
        
        let audioSessionManager = SLAudioSessionManager.shared
        audioSessionManager.setCategory(category: AVAudioSession.sharedInstance().category, options: audioSessionManager.customerAudioCategoryOptions)
        
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
        
        self.videoWindowPanGestureRecognizer = nil
        self.videoWindowTapGestureRecognizer = nil
        self.videoWindowSwipeDownGestureRecognizer = nil
        self.osPictureInPictureController = nil
        
        self.liveStreamViewController?.removeFromParent()
        self.liveStreamViewController?.viewModel.stop()
        self.liveStreamViewController?.delegate = nil
        self.liveStreamViewController = nil
        
        let finalStyle = self.style
        let finalLastStyle = self._lastStyle
        let finalIsPreview = ShopLiveController.shared.isPreview
        let finalCampaignKey = ShopLiveController.shared.campaignKey
        
        if Thread.isMainThread {
            self.teardownShopLiveWindow { [weak self] in
                guard let self = self else { return }
                self.mainWindow = nil
                
                self.delegate?.handleChangedPlayerStatus?(status: "DESTROYED")
                self.delegate?.onEvent?(name: "player_close", feature: .ACTION, campaign: finalCampaignKey, payload: ["type": (finalStyle == .pip ? (finalIsPreview ? "preview" : "pip") : "normal")])
                self.delegate?.onEvent?(name: "player_close", feature: .ACTION, campaign: finalCampaignKey, payload: ["type": (finalStyle == .pip ? (finalIsPreview ? "preview" : "pip") : "normal")])
                self.delegate?.handleCommand?("didShopLiveOff", with: ["style": finalStyle.rawValue])
                self.delegate?.handleCommand?(
                    ShopLiveViewTrackEvent.viewDidDisAppear.name,
                    with: ["lastStyle": finalLastStyle.name,
                           "currentStyle": finalStyle.name,
                           "isPreview": finalIsPreview,
                           "viewHiddenActionType": viewHideActionType.name]
                )
                self._style = .unknown
                self._lastStyle = .unknown
                ShopLiveBase.sessionState = .terminated
                ShopLiveController.shared.resetOnlyFinished()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                    ShopLiveController.shared.execusedClose = false
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.teardownShopLiveWindow { [weak self] in
                    guard let self = self else { return }
                    self.mainWindow = nil
                    
                    // teardown 완료 후 delegate 호출
                    self.delegate?.handleChangedPlayerStatus?(status: "DESTROYED")
                    self.delegate?.onEvent?(name: "player_close", feature: .ACTION, campaign: finalCampaignKey, payload: ["type": (finalStyle == .pip ? (finalIsPreview ? "preview" : "pip") : "normal")])
                    self.delegate?.onEvent?(name: "player_close", feature: .ACTION, campaign: finalCampaignKey, payload: ["type": (finalStyle == .pip ? (finalIsPreview ? "preview" : "pip") : "normal")])
                    self.delegate?.handleCommand?("didShopLiveOff", with: ["style": finalStyle.rawValue])
                    self.delegate?.handleCommand?(
                        ShopLiveViewTrackEvent.viewDidDisAppear.name,
                        with: ["lastStyle": finalLastStyle.name,
                               "currentStyle": finalStyle.name,
                               "isPreview": finalIsPreview,
                               "viewHiddenActionType": viewHideActionType.name]
                    )
                    self._style = .unknown
                    self._lastStyle = .unknown
                    ShopLiveBase.sessionState = .terminated
                    ShopLiveController.shared.resetOnlyFinished()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
                        ShopLiveController.shared.execusedClose = false
                    }
                }
            }
        }
    }
    
    private func teardownShopLiveWindow(completion: (() -> Void)? = nil) {
        
        guard let shopLiveWindow else {
            completion?()
            return
        }
        
        shopLiveWindow.isHidden = true
        shopLiveWindow.windowLevel = .normal
        if #available(iOS 13.0, *) {
            shopLiveWindow.windowScene = nil
        }
        
        self.mainWindow?.makeKeyAndVisible()
        
        shopLiveWindow.transform = .identity
        shopLiveWindow.alpha = 1
        shopLiveWindow.removeFromSuperview()
        shopLiveWindow.rootViewController = nil
        self.shopLiveWindow = nil
        
        completion?()
    }
    
    func setupOsPictureInPicture() {
        guard !ShopLiveController.shared.isPreview, enabledPictureInPictureMode, enabledOSPictureInPictureMode else {
            self.osPictureInPictureController?.delegate = nil
            self.osPictureInPictureController = nil
            return
        }
        
        guard osPictureInPictureController == nil else { return }
        SLAudioSessionManager.shared.setActive(true, options: [.notifyOthersOnDeactivation])
        
        guard let playerLayer = liveStreamViewController?.playerView.playerLayer else { return }
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
            delegate?.handleError?(code: "9500", message: "Unsupported OS version to use OS PIP mode.")
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
        let result = self.calculatePipSize(inAppPipConfiguration: inAppPipConfiguration, scale: scale, defSize: defSize)
        return result
    }
    
    private func calculatePipSize(inAppPipConfiguration: ShopLiveInAppPipConfiguration?, scale: CGFloat, defSize: CGSize) -> CGSize {
        if let config = inAppPipConfiguration, let pipSize = config.pipSize {
            if let pipMaxSize = pipSize.pipMaxSize {
                if defSize.width > defSize.height { //가로모드 방송에서는 세로를 기준으로 가로를 맞추고
                    return CGSize(width: pipMaxSize, height: pipMaxSize * ( defSize.height / defSize.width))
                }
                else { //세로 모드 방송에서는 가로를 기준으로 세로를 맞춤
                    return CGSize(width: pipMaxSize * (defSize.width / defSize.height ), height: pipMaxSize)
                }
            }
            else if let pipFixedheightSize = pipSize.pipFixedheight {
                return CGSize(width: pipFixedheightSize * (defSize.width / defSize.height), height: pipFixedheightSize)
            }
            else if let pipFixedWidthSize = pipSize.pipFixedWidth {
                return CGSize(width: pipFixedWidthSize, height: pipFixedWidthSize * (defSize.height / defSize.width))
            }
        }
        let width =  (UIScreen.isLandscape_SL ? UIScreen.main.bounds.height : UIScreen.main.bounds.width) * scale
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
        
        let screenSize: CGSize = UIScreen.main.bounds.size
        
        let isOutOfScreen = (screenSize.height - keyboardHeight - (safeAreaInsets.top + pipEdgeInsets.top + pipFloatingOffset.top)) < pipSize.height
        switch position {
        case .bottomRight, .default:
            origin.x = screenSize.width - safeAreaInsets.right - pipEdgeInsets.right - pipSize.width - pipFloatingOffset.right
            origin.y = screenSize.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight - pipFloatingOffsetBottom
        case .bottomCenter:
            origin.x = (screenSize.width / 2 ) - (pipSize.width / 2)
            origin.y = screenSize.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight - pipFloatingOffsetBottom
        case .bottomLeft:
            origin.x = safeAreaInsets.left + pipEdgeInsets.left + pipFloatingOffset.left
            origin.y = screenSize.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight - pipFloatingOffsetBottom
            
            
        case .topRight:
            origin.x = screenSize.width - safeAreaInsets.right - pipEdgeInsets.right - pipSize.width - pipFloatingOffset.right
            if isOutOfScreen {
                origin.y = screenSize.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight - pipFloatingOffsetBottom
            }
            else {
                origin.y = safeAreaInsets.top + pipEdgeInsets.top + pipFloatingOffset.top
            }
        case .topCenter:
            origin.x = (screenSize.width / 2 ) - (pipSize.width / 2)
            if isOutOfScreen {
                origin.y = screenSize.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight - pipFloatingOffsetBottom
            }
            else {
                origin.y = safeAreaInsets.top + pipEdgeInsets.top + pipFloatingOffset.top
            }
        case .topLeft:
            origin.x = safeAreaInsets.left + pipEdgeInsets.left + pipFloatingOffset.left
            if isOutOfScreen {
                origin.y = screenSize.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight - pipFloatingOffsetBottom
            }
            else {
                origin.y = safeAreaInsets.top + pipEdgeInsets.top + pipFloatingOffset.top
            }
            
            
        case .middleLeft:
            origin.x = safeAreaInsets.left + pipEdgeInsets.left + pipFloatingOffset.left
            if isOutOfScreen {
                origin.y = screenSize.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight - pipFloatingOffsetBottom
            }
            else {
                origin.y = ((screenSize.height - keyboardHeight) / 2) - ( pipSize.height / 2 )
            }
        case .middleCenter:
            origin.x = (screenSize.width / 2 ) - (pipSize.width / 2)
            if isOutOfScreen {
                origin.y = screenSize.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight - pipFloatingOffsetBottom
            }
            else {
                origin.y = ((screenSize.height - keyboardHeight) / 2) - ( pipSize.height / 2 )
            }
        case .middleRight:
            origin.x = screenSize.width - safeAreaInsets.right - pipEdgeInsets.right - pipSize.width - pipFloatingOffset.right
            if isOutOfScreen {
                origin.y = screenSize.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipSize.height - keyboardHeight - pipFloatingOffsetBottom
            }
            else {
                origin.y = ((screenSize.height - keyboardHeight) / 2) - ( pipSize.height / 2 )
            }
        }
        
        pipPosition = CGRect(origin: origin, size: pipSize)
        
        return pipPosition
    }
    
    private func startCustomPictureInPicture(with position: ShopLive.PipPosition = .default, scale: CGFloat = 2/5) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.enabledPictureInPictureMode == false {
                self.close(actionType: .onClose)
                return
            }
            
            guard let shopLiveWindow = self.shopLiveWindow else { return }
            guard let liveVc = self.liveStreamViewController else { return }
            guard shopLiveWindow.frame.size != .zero else { return }
            liveVc.updateStatusBarToDefault()
            self.delegate?.handleCommand?("willShopLiveOff", with: ["style": self._lastStyle.rawValue])
            self.delegate?.handleCommand?( ShopLiveViewTrackEvent.pipWillAppear.name, with: ["lastStyle": self._lastStyle.name,
                                                                                             "currentStyle": ShopLive.PresentationStyle.pip.name,
                                                                                             "isPreview": ShopLiveController.shared.isPreview])
            
            self.mainWindow?.makeKey()
            
            self.showShadow()
            
            self.videoWindowPanGestureRecognizer?.isEnabled = true
            self.videoWindowTapGestureRecognizer?.isEnabled = true
            self.videoWindowSwipeDownGestureRecognizer?.isEnabled = false
            
            liveVc.shopliveHideKeyboard_SL()
            ShopLiveController.webInstance?.isHidden = true
            
            let pipPosition: CGRect = self.pipPosition(with: scale, position: position)
            
            ShopLiveController.windowStyle = .inAppPip
            self._style = .pip
            liveVc.takeSnapShot()
            
            if windowAnimator != nil {
                windowAnimator?.stopAnimation(false)
                windowAnimator?.finishAnimation(at: .current)
                windowAnimator = nil
            }
            
            windowAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
            windowAnimator?.addAnimations { [weak self] in
                guard let self = self else { return }
                liveVc.setStatusBarVisiblityOnFullScreen(isVisible: true)
                shopLiveWindow.frame = pipPosition
                liveVc.updatePlayerViewToPipMode()
                
                shopLiveWindow.layer.cornerRadius = self.inAppPipConfiguration?.pipRadius ?? 10
                shopLiveWindow.rootViewController?.view.backgroundColor = .clear
                shopLiveWindow.rootViewController?.view.layer.cornerRadius = self.inAppPipConfiguration?.pipRadius ?? 10
                shopLiveWindow.rootViewController?.view.layer.masksToBounds = true
            }
            
            windowAnimator?.addCompletion({ [weak self] position in
                guard let self = self, position == .end else { return }
                shopLiveWindow.backgroundColor = .clear
                liveVc.view.backgroundColor = .black
                liveVc.view.frame = shopLiveWindow.bounds
                shopLiveWindow.layer.masksToBounds = true
                liveVc.view.layer.masksToBounds = true
                liveVc.view.clipsToBounds = true
                liveVc.setInAppViewVisible(true)
                liveVc.setCloseButtonVisible(liveVc.viewModel.getUseCloseBtnIsEnabled())
                
                ShopLiveController.shared.videoExpanded = true
                
                if self.windowChangeCommand != .none && self.isWindowChanging {
                    self.handleWindowChangeCommand()
                }
                
                if ShopLiveController.webInstance == nil {
                    liveVc.setupOverayWebview()
                    ShopLiveController.webInstance?.isHidden = true
                }
                
                self.delegate?.onEvent?(name: "player_to_pip_mode", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: [:])
                self.liveStreamViewController?.viewModel.sendPlayerToPipMode()
                self.sendCommandChangeToPip()
                self.delegate?.handleCommand?("didShopLiveOff", with: ["style": self._lastStyle.rawValue])
                self.delegate?.handleCommand?( ShopLiveViewTrackEvent.pipDidAppear.name, with: ["lastStyle": self.style.name,
                                                                                                "currentStyle": self.style.name,
                                                                                                "isPreview": ShopLiveController.shared.isPreview,
                                                                                                "from": #function ])
                self.showPreviewCoverView()
                self.windowAnimator = nil
            })
            
            windowAnimator?.startAnimation()
        }
    }
    
    func startFromCampaignFullscreen(animationDuration: Double = 0.3, onOsPipRestoration: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let shopLiveWindow = self.shopLiveWindow,
                  let liveVc = self.liveStreamViewController else {
                return
            }
            
            guard let mainWindow = self.mainWindow else { return }
            
            guard shopLiveWindow.frame != mainWindow.frame else {
                if ShopLiveController.windowStyle == .normal {
                    if onOsPipRestoration == false {
                        liveVc.updatePlayerViewFrameFromStartFromCampaignFullScreen(needExecuteFullScreen: false)
                    }
                }
                self.delegate?.handleCommand?("willShopLiveOn", with: nil)
                self.delegate?.handleCommand?("didShopLiveOn", with: self._lastStyle)
                self.delegate?.handleCommand?( ShopLiveViewTrackEvent.fullScreenWillAppear.name, with: ["lastStyle": self._lastStyle.name, "currentStyle": self.style.name])
                self._lastStyle = .fullScreen
                self.delegate?.handleCommand?( ShopLiveViewTrackEvent.fullScreenDidAppear.name, with: ["lastStyle": self.style.name, "currentStyle": self.style.name])
                return
            }
            
            shopLiveWindow.backgroundColor = .clear
            shopLiveWindow.rootViewController?.view.backgroundColor = .clear
            
            if self.osPictureInPictureController == nil {
                self.setupOsPictureInPicture()
            }
            
            mainWindow.rootViewController?.shopliveHideKeyboard_SL()
            
            self.delegate?.handleCommand?("willShopLiveOn", with: nil)
            self.delegate?.handleCommand?(ShopLiveViewTrackEvent.fullScreenWillAppear.name, with: ["lastStyle": self._lastStyle.name, "currentStyle": self.style.name])
            
            self.videoWindowPanGestureRecognizer?.isEnabled = false
            self.videoWindowTapGestureRecognizer?.isEnabled = false
            self.videoWindowSwipeDownGestureRecognizer?.isEnabled = true
            ShopLiveController.windowStyle = .normal
            
            self.hideShadow()
            
            
            if onOsPipRestoration == false {
                liveVc.updatePlayerViewFrameFromStartFromCampaignFullScreen(needExecuteFullScreen: self.needExecuteFullScreen)
            }
            
            liveVc.setInAppViewVisible(false)
            liveVc.setCloseButtonVisible(false)
            
            if windowAnimator != nil {
                windowAnimator?.stopAnimation(false)
                windowAnimator?.finishAnimation(at: .current)
                windowAnimator = nil
            }
            self.hidePreviewCoverView()
            windowAnimator = UIViewPropertyAnimator(duration: animationDuration, curve: .easeInOut)
            windowAnimator?.addAnimations { [weak self] in
                guard let self = self else { return }
                liveVc.setStatusBarVisiblityOnFullScreen(isVisible: statusBarVisibility)
                shopLiveWindow.frame = mainWindow.bounds
                shopLiveWindow.layer.cornerRadius = 0
                shopLiveWindow.rootViewController?.view.layer.cornerRadius = 0
            }
            windowAnimator?.addCompletion({ [weak self] position in
                guard let self = self, position == .end else { return }
                self._style = .fullScreen
                liveVc.view.frame = shopLiveWindow.bounds
                ShopLiveController.webInstance?.isHidden = false
                shopLiveWindow.rootViewController?.view.backgroundColor = .black
                if self.needExecuteFullScreen == true {
                    ShopLiveController.shared.playControl = .play
                    self.delegate?.handleCommand?("didShopLiveOn", with: self._lastStyle)
                }
                else {
                    self.delegate?.handleCommand?("didShopLiveOn", with: self.style)
                }
                self.delegate?.handleCommand?( ShopLiveViewTrackEvent.fullScreenDidAppear.name, with: ["lastStyle": self.style.name, "currentStyle": self.style.name])
                self.handleWindowChangeCommand()
                self.needExecuteFullScreen = false
                self.windowAnimator = nil
            })
            windowAnimator?.startAnimation()
        }
    }
    
    private func stopCustomPictureInPicture() {
        
        if osPictureInPictureController == nil {
            setupOsPictureInPicture()
        }
        
        guard let mainWindow = self.mainWindow else { return }
        guard let shopLiveWindow = self.shopLiveWindow else { return }
        
        self.liveStreamViewController?.updateStatuBarStyleToLightContent()
        
        shopLiveWindow.backgroundColor = .clear
        shopLiveWindow.layer.cornerRadius = inAppPipConfiguration?.pipRadius ?? 10
        shopLiveWindow.rootViewController?.view.backgroundColor = .clear
        
        mainWindow.rootViewController?.shopliveHideKeyboard_SL()
        
        delegate?.handleCommand?("willShopLiveOn", with: nil)
        
        
        self.delegate?.handleCommand?(ShopLiveViewTrackEvent.fullScreenWillAppear.name, with: ["lastStyle": ShopLive.PresentationStyle.pip.name,
                                                                                               "currentStyle": ShopLive.PresentationStyle.fullScreen.name])
        
        videoWindowPanGestureRecognizer?.isEnabled = false
        videoWindowTapGestureRecognizer?.isEnabled = false
        videoWindowSwipeDownGestureRecognizer?.isEnabled = true
        
        self.hideShadow()
        
        
        ShopLiveController.shared.needForceSetVideoPositionUpdate = true
        self.liveStreamViewController?.updatePipStyle(with: .fullScreen)
        
        shopLiveWindow.invalidateBlockAddSubViewTimer()
        if windowAnimator != nil {
            windowAnimator?.stopAnimation(false)
            windowAnimator?.finishAnimation(at: .current)
            windowAnimator = nil
        }
        shopLiveWindow.startBlockAddSubViewTimer()
        self.hidePreviewCoverView()
        self.liveStreamViewController?.requestHideOrShowSnapShotImageView(isHidden: true)
        windowAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut)
        windowAnimator?.addAnimations { [weak self] in
            guard let self = self else { return }
            shopLiveWindow.frame = mainWindow.bounds
            shopLiveWindow.layer.cornerRadius = 0
            shopLiveWindow.rootViewController?.view.layer.cornerRadius = 0
            self.liveStreamViewController?.updatePlayerViewFrameFromStopCustomPictureInPicture()
            self.liveStreamViewController?.setInAppViewVisible(false)
            self.liveStreamViewController?.setCloseButtonVisible(false)
            self.liveStreamViewController?.setStatusBarVisiblityOnFullScreen(isVisible: self.statusBarVisibility)
        }
        windowAnimator?.addCompletion({ [weak self] position in
            guard let self = self, position == .end else { return }
            self.onStopCustomPictureInPictureAnimationComplete()
            shopLiveWindow.rootViewController?.view.backgroundColor = .black
            ShopLiveController.webInstance?.isHidden = false
            shopLiveWindow.backgroundColor = .clear
            self.liveStreamViewController?.view.frame = shopLiveWindow.bounds
            if self.windowChangeCommand != .none {
                self.isWindowChanging = false
            }
            self.windowAnimator = nil
        })
        windowAnimator?.startAnimation()
    }
    
    private func onStopCustomPictureInPictureAnimationComplete() {
        if let shopLiveWindow = shopLiveWindow {
            shopLiveWindow.makeKey()
        }
        _style = .fullScreen
        _lastStyle = .fullScreen
        ShopLiveController.windowStyle = .normal
        ShopLiveController.shared.needForceSetVideoPositionUpdate = false
        delegate?.handleCommand?("didShopLiveOn", with: nil)
        self.delegate?.handleCommand?( ShopLiveViewTrackEvent.fullScreenDidAppear.name, with: ["lastStyle": self.style.name, "currentStyle": self.style.name])
        
        delegate?.onEvent?(name: "pip_to_player_mode", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: [:])
        self.liveStreamViewController?.viewModel.sendPipToPlayerMode()
    }
    
    func updatePip(isRotation: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.isWindowChanging = true
            
            let orientation = UIDevice.current.orientation
            
            var rotate: CGFloat = 0
            
            switch orientation {
            case .landscapeLeft:
                rotate = 270
            case .landscapeRight:
                rotate = 90
            case .unknown:
                rotate = 270
            case .portrait, .portraitUpsideDown:
                rotate = 0
            default: rotate = 270
            }
            if isRotation {
                let param: Dictionary = Dictionary<String, Any>.init(
                    dictionaryLiteral: ("top", UIScreen.safeArea_SL.top),
                    ("left", UIScreen.safeArea_SL.left),
                    ("right", UIScreen.safeArea_SL.right),
                    ("bottom", UIScreen.safeArea_SL.bottom),
                    ("orientation", rotate)
                )
                self.liveStreamViewController?.sendCommandMessage(command: "SET_SAFE_AREA_MARGIN", payload: param)
            } else {
                self.delegate?.handleCommand?("willShopLiveOff", with: nil)
                self.delegate?.handleCommand?( ShopLiveViewTrackEvent.pipWillAppear.name, with: ["lastStyle": self._lastStyle.name , "currentStyle": self.style.name, "isPreview": ShopLiveController.shared.isPreview])
            }
            
            ShopLiveController.webInstance?.isHidden = true
            
            let pipSize: CGRect = self.pipPosition(with: self.pipScale, position: self.getPipPosition())
            
            self.liveStreamViewController?.updatePlayerViewFrameFromUpdatePip(targetWindowStyle: ShopLiveController.windowStyle)
            self.shopLiveWindow?.layer.masksToBounds = true
            self.liveStreamViewController?.view.layer.masksToBounds = true
            self.liveStreamViewController?.setCloseDimLayerVisible(false)
            
            if windowAnimator != nil {
                windowAnimator?.stopAnimation(false)
                windowAnimator?.finishAnimation(at: .current)
                windowAnimator = nil
            }
            windowAnimator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut)
            windowAnimator?.addAnimations({ [weak self] in
                guard let self = self else { return }
                UIView.animateKeyframes(withDuration: 0.4, delay: 0) {
                    UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 1) {
                        self.shopLiveWindow?.frame = pipSize
                        self.shopLiveWindow?.layoutIfNeeded()
                    }
                }
            })
            windowAnimator?.addCompletion({ [weak self] position in
                guard let self = self, position == .end else { return }
                if let shopLiveWindow = shopLiveWindow {
                    self.liveStreamViewController?.view.frame = shopLiveWindow.bounds
                }
                if !isRotation {
                    self.sendCommandChangeToPip()
                    self.delegate?.handleCommand?("didShopLiveOff", with: ["style": self._lastStyle.rawValue])
                    self.delegate?.handleCommand?( ShopLiveViewTrackEvent.pipDidAppear.name, with: ["lastStyle": self.style.name , "currentStyle": self.style.name, "isPreview": ShopLiveController.shared.isPreview, "from": #function])
                    self.shopLiveWindow?.layer.masksToBounds = false
                    if ShopLiveController.shared.isPreview == false {
                        //                        self.liveStreamViewController?.viewModel.sendPipActive(pipType: .APP)
                    }
                }
                self.handleWindowChangeCommand()
                self.windowAnimator = nil
            })
            windowAnimator?.startAnimation()
        }
    }
    
    func startFromCampaignPIP() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.liveStreamViewController?.updatePlayerViewToPipMode()
            self.delegate?.handleCommand?("willShopLiveOff", with: ["style": self._lastStyle.rawValue])
            self.delegate?.handleCommand?( ShopLiveViewTrackEvent.pipWillAppear.name, with: ["lastStyle": self._lastStyle.name , "currentStyle": self.style.name, "isPreview": ShopLiveController.shared.isPreview])
            guard let shopLiveWindow = self.shopLiveWindow else { return }
            
            shopLiveWindow.backgroundColor = .black
            shopLiveWindow.layer.cornerRadius = self.inAppPipConfiguration?.pipRadius ?? 10
            
            shopLiveWindow.rootViewController?.view.layer.cornerRadius = self.inAppPipConfiguration?.pipRadius ?? 10
            shopLiveWindow.rootViewController?.view.layer.masksToBounds = true
            shopLiveWindow.rootViewController?.view.backgroundColor = .clear
            
            self.liveStreamViewController?.shopliveHideKeyboard_SL()
            
            ShopLiveController.windowStyle = .inAppPip
            
            ShopLiveController.webInstance?.isHidden = true
            self.videoWindowPanGestureRecognizer?.isEnabled = true
            self.videoWindowTapGestureRecognizer?.isEnabled = true
            self.videoWindowSwipeDownGestureRecognizer?.isEnabled = false
            
            let pipPosition: CGRect = self.pipPosition(with: self.pipScale, position: self.getPipPosition())
            shopLiveWindow.frame = pipPosition
            
            
            shopLiveWindow.setNeedsLayout()
            shopLiveWindow.layoutIfNeeded()
            
            self.liveStreamViewController?.setInAppViewVisible(false)
            self.liveStreamViewController?.setCloseButtonVisible(self.liveStreamViewController?.viewModel.getUseCloseBtnIsEnabled() ?? true)
            self.liveStreamViewController?.setStatusBarVisiblityOnFullScreen(isVisible: true)
            self.sendCommandChangeToPip()
            self.delegate?.handleCommand?("didShopLiveOff", with: ["style": self._lastStyle.rawValue])
            self.delegate?.handleCommand?( ShopLiveViewTrackEvent.pipDidAppear.name, with: ["lastStyle": self.style.name, "currentStyle": self.style.name, "isPreview": ShopLiveController.shared.isPreview,"from": #function])
            self.showPreviewCoverView()
            self.handleWindowChangeCommand()
            
            if ShopLiveController.shared.isPreview == false {
                //                self.liveStreamViewController?.viewModel.sendPipActive(pipType: .APP)
            }
        }
    }
    
    func willChangePreview() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            guard let slWindow = self.shopLiveWindow,
                  let liveVC = self.liveStreamViewController else {
                return
            }
            
            self.isWindowChanging = true
            
            if self.osPictureInPictureController != nil {
                self.osPictureInPictureController?.delegate = nil
                self.osPictureInPictureController = nil
            }
            
            ShopLiveController.windowStyle = .inAppPip
            self.delegate?.handleCommand?("willShopLiveOff", with: ["style": self._lastStyle.rawValue])
            self.delegate?.handleCommand?( ShopLiveViewTrackEvent.pipWillAppear.name, with: ["lastStyle": self._lastStyle.rawValue , "currentStyle": self.style.rawValue, "isPreview": ShopLiveController.shared.isPreview])
            
            liveVC.view.backgroundColor = .clear
            
            let pipSize: CGRect = self.pipPosition(with: self.pipScale, position: self.getPipPosition())
            
            if self.needAnimateToChangePreivew {
                ShopLiveController.webInstance?.isHidden = false
            } else {
                self.shopLiveWindow?.isHidden = true
            }
            
            
            self.showShadow()
            slWindow.layer.masksToBounds = true
            slWindow.rootViewController?.view.layer.masksToBounds = true
            
            slWindow.layer.cornerRadius = self.inAppPipConfiguration?.pipRadius ?? 10
            
            self.videoWindowPanGestureRecognizer?.isEnabled = true
            self.videoWindowTapGestureRecognizer?.isEnabled = true
            self.videoWindowSwipeDownGestureRecognizer?.isEnabled = false
            
            if windowAnimator != nil {
                windowAnimator?.stopAnimation(false)
                windowAnimator?.finishAnimation(at: .current)
                windowAnimator = nil
            }
            
            let animateDuration = self.needAnimateToChangePreivew ? 0.3 : 0
            windowAnimator = UIViewPropertyAnimator(duration: animateDuration, curve: .easeOut)
            windowAnimator?.addAnimations { [weak self] in
                guard let self = self else { return }
                liveVC.setStatusBarVisiblityOnFullScreen(isVisible: true)
                liveVC.updatePlayerViewToPipMode()
                
                slWindow.rootViewController?.view.layer.cornerRadius = self.inAppPipConfiguration?.pipRadius ?? 10
                slWindow.rootViewController?.view.backgroundColor = .clear
                slWindow.frame = pipSize
                slWindow.setNeedsLayout()
                slWindow.layoutIfNeeded()
            }
            windowAnimator?.addCompletion({ [weak self] position in
                guard let self = self, position == .end else { return }
                self.liveStreamViewController?.setInAppViewVisible(true)
                liveVC.setCloseButtonVisible(liveVC.viewModel.getUseCloseBtnIsEnabled())
                slWindow.isHidden = false
                slWindow.layer.masksToBounds = true
                liveVC.view.layer.masksToBounds = true
                liveVC.view.clipsToBounds = true
                liveVC.view.frame = slWindow.bounds
                
                if self.needAnimateToChangePreivew {
                    ShopLiveController.shared.playControl = .play
                }
                
                ShopLiveController.shared.videoExpanded = true
                self.needAnimateToChangePreivew = false
                self.handleWindowChangeCommand()
                self._style = .pip
                self.delegate?.handleCommand?("didShopLiveOff", with: ["style": self._lastStyle.rawValue])
                self.delegate?.handleCommand?( ShopLiveViewTrackEvent.pipDidAppear.name, with: ["lastStyle": self.style.name, "currentStyle": self.style.name, "isPreview": ShopLiveController.shared.isPreview,"from": #function])
                self.showPreviewCoverView()
                if ShopLiveController.shared.webInstance == nil {
                    liveVC.setupOverayWebview()
                }
                ShopLiveController.shared.webInstance?.isHidden = true
                self.windowAnimator = nil
            })
            windowAnimator?.startAnimation()
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
            
            self.liveStreamViewController?.shopliveHideKeyboard_SL()
            
            self.videoWindowPanGestureRecognizer?.isEnabled = false
            self.videoWindowTapGestureRecognizer?.isEnabled = false
            self.videoWindowSwipeDownGestureRecognizer?.isEnabled = true
            ShopLiveController.webInstance?.isHidden = false
            
            self.hideShadow()
            
            shopLiveWindow.rootViewController?.view.backgroundColor = .black
            
            shopLiveWindow.layer.cornerRadius = 0
            shopLiveWindow.rootViewController?.view.layer.cornerRadius = 0
            shopLiveWindow.setNeedsLayout()
            shopLiveWindow.layoutIfNeeded()
            
            self.liveStreamViewController?.setInAppViewVisible(false)
            self.liveStreamViewController?.setCloseButtonVisible(false)
        }
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
    
    private func getNearestPipPinPosition(currentPipCenter: CGPoint) -> ShopLive.PipPosition {
        guard let mainWindow = self.mainWindow else { return .bottomRight }
        guard let shopLiveWindow = self.shopLiveWindow else { return .bottomRight }
        
        var centerOfPins: [ShopLive.PipPosition: CGPoint] = [:]
        
        let allowedPinPositions: Set<ShopLive.PipPosition> = Set(self.liveStreamViewController?.viewModel.getAllowedPipPinPositions() ?? [.topLeft, .topRight, .bottomLeft, .bottomRight])
        
        
        let screenSize = UIScreen.main.bounds.size
        let safeAreaInsets = mainWindow.safeAreaInsets
        let pipSize = shopLiveWindow.frame.size
        let pipEdgeInsets: UIEdgeInsets = ShopLiveConfiguration.UI.pipPadding
        let pipFloatingOffset: UIEdgeInsets = ShopLiveConfiguration.UI.pipFloatingOffset
        let pipFloatingOffsetBottom: CGFloat = isKeyboardShow ? 0 : pipFloatingOffset.bottom
        let keyboardHeight: CGFloat = isKeyboardShow ? ShopLiveController.shared.keyboardHeight : 0
        
        let leftCenterX = safeAreaInsets.left + pipEdgeInsets.left + pipFloatingOffset.left + (pipSize.width / 2)
        let rightCenterX = screenSize.width - safeAreaInsets.right - pipEdgeInsets.right - (pipSize.width / 2) - pipFloatingOffset.right
        let midCenterX = screenSize.width / 2
        
        //실제 Pip가 이동가능한 높이
        let actualViewHeight = (screenSize.height - (keyboardHeight + safeAreaInsets.top + pipEdgeInsets.top + pipFloatingOffset.top))
        let isOutOfScreen = actualViewHeight < pipSize.height
        
        var topCenterY: CGFloat
        var bottomCenterY: CGFloat
        var middleCenterY: CGFloat
        
        if isOutOfScreen {
            topCenterY = screenSize.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - (pipSize.height / 2) - keyboardHeight - pipFloatingOffsetBottom
            middleCenterY = screenSize.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - (pipSize.height / 2) - keyboardHeight - pipFloatingOffsetBottom
            bottomCenterY = screenSize.height - safeAreaInsets.bottom - pipEdgeInsets.bottom - (pipSize.height / 2) - keyboardHeight - pipFloatingOffsetBottom
        }
        else {
            topCenterY = safeAreaInsets.top + pipEdgeInsets.top + pipFloatingOffset.top + (pipSize.height / 2)
            middleCenterY = (screenSize.height - keyboardHeight - safeAreaInsets.bottom - pipEdgeInsets.bottom - pipFloatingOffsetBottom ) / 2
            middleCenterY = (screenSize.height - keyboardHeight) / 2
            bottomCenterY = screenSize.height - (safeAreaInsets.bottom + pipEdgeInsets.bottom  + keyboardHeight + pipFloatingOffsetBottom + (pipSize.height / 2))
        }
        
        
        centerOfPins[.topLeft]      = .init(x: leftCenterX, y: topCenterY)
        centerOfPins[.topCenter]    = .init(x: midCenterX, y: topCenterY)
        centerOfPins[.topRight]     = .init(x: rightCenterX, y: topCenterY)
        
        centerOfPins[.middleLeft]   = .init(x: leftCenterX, y: middleCenterY)
        centerOfPins[.middleCenter] = .init(x: midCenterX, y: middleCenterY)
        centerOfPins[.middleRight]  = .init(x: rightCenterX, y: middleCenterY)
        
        centerOfPins[.bottomLeft]   = .init(x: leftCenterX, y: bottomCenterY)
        centerOfPins[.bottomCenter] = .init(x: midCenterX, y: bottomCenterY)
        centerOfPins[.bottomRight]  = .init(x: rightCenterX, y: bottomCenterY)
        
        var nearestDist: Float = 1000_000_000
        var nearestPin: ShopLive.PipPosition = .topCenter
        for (key,value) in centerOfPins {
            if allowedPinPositions.contains(key) {
                let dist = hypotf(Float((value.x - currentPipCenter.x)), Float((value.y - currentPipCenter.y)))
                if dist <= nearestDist {
                    nearestDist = dist
                    nearestPin = key
                }
            }
        }
        
        return nearestPin
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
            
            
            //|| ShopLiveController.shared.isPreview -> 무신사 요청 사항으로 preview 일때도 swipeOut할 수 있게 수정 2024/08/02
            guard liveStreamViewController?.viewModel.getEnablePipSwipeOut() ?? false == true  else { return }
            guard let mainWindow = self.mainWindow else { return }
            let mainWindowHeight: CGFloat = mainWindow.bounds.height - (isKeyboardShow ? ShopLiveController.shared.keyboardHeight : 0)
            let safeAreaInset = mainWindow.safeAreaInsets
            let pipEdgeInsets: UIEdgeInsets = ShopLiveConfiguration.UI.pipPadding
            let pipFloatingOffset: UIEdgeInsets = ShopLiveConfiguration.UI.pipFloatingOffset
            
            let minXLimit = pipFloatingOffset.left + pipEdgeInsets.left
            let maxXLimit = mainWindow.bounds.width - pipFloatingOffset.right - pipEdgeInsets.right
            let minYLimit = pipFloatingOffset.top + pipEdgeInsets.top + safeAreaInset.top
            let maxYLimit = (mainWindowHeight - (safeAreaInset.bottom + pipFloatingOffset.bottom + pipEdgeInsets.bottom)) + (isKeyboardShow ? liveWindow.frame.height * 0.2 : 0)
            
            let minXOff: Bool = minXLimit - centerX >= 0
            let maxXOff: Bool = centerX - maxXLimit >= 0
            let minYOff: Bool = minYLimit - centerY >= 0
            let maxYOff: Bool = centerY - maxYLimit >= 0
            
            let alpha: CGFloat = (minXOff || maxXOff || minYOff || maxYOff) ? 0.5 : 1
            
            if alpha >= 1 {
                blockLiveWindowPangestureHapticSound = false
            }
            
            if alpha < 1 && blockLiveWindowPangestureHapticSound == false {
                blockLiveWindowPangestureHapticSound = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            
            self.shopLiveWindow?.alpha = alpha
            self.liveStreamViewController?.view.alpha = alpha
            
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
            
            guard let liveStreamViewController = self.liveStreamViewController else { return }
            
            let pipPosition = liveStreamViewController.viewModel.getPipPosition()
            
            if pipPosition == .topLeft || pipPosition == .bottomLeft || pipPosition == .middleLeft {
                if velocity.x < 0 {
                    if velocity.x.magnitude > 600 {
                        if checkCenterX + velocity.x < minX {
                            checkCenterX = minX - liveWindow.frame.width
                        }
                    }
                }
            }
            else if pipPosition == .topRight || pipPosition == .bottomRight || pipPosition == .middleRight{
                if velocity.x > 0 {
                    if velocity.x.magnitude > 600 {
                        if checkCenterX + velocity.x > maxX {
                            checkCenterX = maxX + liveWindow.frame.width
                        }
                    }
                }
            }
            
            if pipPosition == .topLeft || pipPosition == .topRight || pipPosition == .topCenter{
                if velocity.y > 0 {
                    if velocity.y.magnitude > 600 {
                        if checkCenterY + velocity.y < minY {
                            checkCenterY = minY - liveWindow.frame.height
                        }
                    }
                }
            }
            else if pipPosition == .bottomLeft || pipPosition == .bottomRight || pipPosition == .bottomCenter {
                if velocity.y < 0 {
                    if velocity.y.magnitude > 600 {
                        if checkCenterY + velocity.y > maxY {
                            checkCenterY = maxY + liveWindow.frame.height
                        }
                    }
                }
            }
            
            if liveStreamViewController.viewModel.getEnablePipSwipeOut() == true {
                guard xRange.contains(checkCenterX), yRange.contains(checkCenterY) else {
                    delegate?.handleCommand?(ShopLiveController.shared.isPreview ? "CLOSE_FROM_PREVIEW" : "CLOSE_FROM_PLAY", with: nil)
                    hideShopLiveView(viewHideActionType: .onSwipeOut)
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
            
            let targetPipPosition = getNearestPipPinPosition(currentPipCenter: .init(x: centerX, y: centerY))
            
            switch targetPipPosition {
            case .bottomLeft:
                centerX = minX
                centerY = maxY
            case .bottomCenter:
                centerX = UIScreen.main.bounds.center.x
                centerY = maxY
            case .bottomRight:
                centerX = maxX
                centerY = maxY
                break
                
            case .topLeft:
                centerX = minX
                centerY = safeAreaInset.top + pipEdgeInsets.top + pipFloatingOffset.top + (liveWindow.bounds.size.height / 2)
            case .topCenter:
                centerX = UIScreen.main.bounds.center.x
                centerY = safeAreaInset.top + pipEdgeInsets.top + pipFloatingOffset.top + (liveWindow.bounds.size.height / 2)
            case .topRight:
                centerX = maxX
                centerY = safeAreaInset.top + pipEdgeInsets.top + pipFloatingOffset.top + (liveWindow.bounds.size.height / 2)
                break
                
            case .middleLeft:
                centerX = minX
                centerY = (mainWindowHeight) / 2
            case .middleCenter:
                centerX = UIScreen.main.bounds.center.x
                centerY = (mainWindowHeight) / 2
            case .middleRight:
                centerX = maxX
                centerY = (mainWindowHeight) / 2
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
                self.shopLiveWindow?.alpha = 1
                self.liveStreamViewController?.view.alpha = 1
                self.setPipPosition(pos: targetPipPosition)
                self.handleKeyboard()
                
            }
            
            animator.startAnimation()
            blockLiveWindowPangestureHapticSound = false
        default:
            break
        }
    }
    
    @objc private func swipeDownGestureHandler(_ recognizer: UISwipeGestureRecognizer) {
        guard enabledPictureInPictureMode != false,
              ShopLiveController.shared.swipeEnabled,
              !ShopLiveController.shared.isPreview,
              _style == .fullScreen
        else { return }
        guard let topViewController = UIApplication.topViewController(base: self.liveStreamViewController), topViewController.isKind(of: LiveStreamViewController.self) else {
            self.shopLiveWindow?.rootViewController?.dismiss(animated: false, completion: nil)
            return
        }
        delegate?.onEvent?(name: "swipe_pip_mode", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: [:])
        
        if ShopLiveController.shared.videoOrientation == .landscape {
            if UIScreen.isLandscape_SL {
                self.liveStreamViewController?.updateOrientation(toLandscape: false)
            } else {
                self.startCustomPictureInPicture(with: self.getPipPosition(), scale: self.pipScale)
            }
        } else {
            self.startCustomPictureInPicture(with: self.getPipPosition(), scale: self.pipScale)
        }
    }
    
    @objc private func pipTapGestureHandler(_ recognizer: UITapGestureRecognizer) {
        if blockWindowTapGesture { return }
        self.blockWindowTapGesture = true
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] timer in
            guard let self = self else { return }
            self.blockWindowTapGesture = false
        }
        if ShopLiveController.shared.isPreview {
            self.liveStreamViewController?.viewModel.sendPreviewClickDetailEventTrace()
            if let previewCallback = self.previewCallback {
                previewCallback()
            }
            else if let campaignKey = self.campaignKey {
                self.play(with: campaignKey,campaignHandler: self.shopLivePlayerCampaignHandler,brandHandler: self.shopLivePlayerBrandHandler)
            }
            return
        }
        else {
            guard _style == .pip else { return }
            stopShopLivePictureInPicture()
        }
    }
    
    
    func fetchOverlayUrl(with campaignKey: String?, isPreview: Bool, previewResolution: ShopLivePlayerPreviewResolution? = nil, completionHandler: @escaping ((URL?) -> Void)) {
        let urlComponents = URLComponents(string: ShopLiveConfiguration.AppPreference.landingUrl)
        var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()
        
        if isPreview {
            queryItems.append(URLQueryItem(name: "preview", value: "1"))
            if let resolution = previewResolution, resolution == .LIVE {
                queryItems.append(URLQueryItem(name: "useLiveUrlOnPreview", value: "1"))
            }
        }
        else {
            if let localStorage = UserDefaults.standard.string(forKey: ShopLiveDefines.shopliveData), ShopLiveConfiguration.Data.useLocalStorage {
                queryItems.append(URLQueryItem(name: ShopLiveDefines.shopliveData, value: localStorage))
            }
        }
        
        self.queryParameters.forEach { (key, value) in
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        let baseUrl = URL(string: ShopLiveConfiguration.AppPreference.landingUrl)
        let params = queryItems.queryStringRFC3986
        
        guard let url = URL(string: ShopLiveConfiguration.AppPreference.landingUrl + "?" + params) else {
            completionHandler(baseUrl)
            return
        }
        
        completionHandler(url)
    }
    
    func addObserver() {
        removeObserver()
        self.addObserver(self, forKeyPath: "_style", options: [.initial, .old, .new], context: nil)
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
        
        
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeIn)
        animator.addAnimations {
            shopLiveWindow.frame = pipPosition
            shopLiveWindow.setNeedsLayout()
            shopLiveWindow.layoutIfNeeded()
        }
        
        animator.startAnimation()
    }
    
    
    
    
    private var backgroundPlayerBlockTimer: Timer?
    private func setBackgroundPlayerBlockTimer(){
        invalidateAndResetbackgroundPlayerBlockTimer()
        if ShopLiveController.windowStyle == .osPip {
            return
        }
        backgroundPlayerBlockTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            guard let player = ShopLiveController.player else {
                timer.invalidate()
                return
            }
            //무신사 이슈로 인해서 추가한 코드
            //무신사 이슈: preview 상태일때 앱을 죽여버려도 계속 player가 남아서 무소음으로 재생을 하고 있어서 네트워크 사용량이 엄청 많이 나간적이 있음
            //앱이 완전 킬된 상태여서 상태파악이 힘드므로 PLAYER가 deallocated 될때까지 .pause를 하는 로직
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
            self.liveStreamViewController?.viewModel.blockLiveStreamKeepUpTimerWhenAppTransitioningToBackground()
            break
        case UIApplication.didEnterBackgroundNotification:
            self.liveStreamViewController?.onBackground()
            self.setBackgroundPlayerBlockTimer()
            self.startOsPictureInPicture()
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
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
        default:
            break
        }
    }
    
    private func sendCommandChangeToPip() {
        guard !ShopLiveController.shared.isPreview else { return }
        self.delegate?.handleCommand?("CHANGE_TO_PIP", with: nil)
    }
}
//MARK: - shadowOnOffFunction
extension ShopLiveBase {
    private func showShadow() {
        guard let slWindow = self.shopLiveWindow,
              let liveVC = self.liveStreamViewController else { return }
        slWindow.backgroundColor = .clear
        slWindow.layer.shadowColor = UIColor.black.cgColor
        slWindow.layer.shadowOpacity = 0.5
        slWindow.layer.shadowOffset = .zero
        slWindow.layer.shadowRadius = 6
        slWindow.layer.masksToBounds = false
        liveVC.view.layer.masksToBounds = false
    }
    
    private func hideShadow() {
        guard let slWindow = self.shopLiveWindow,
              let liveVC = self.liveStreamViewController else { return }
        slWindow.layer.shadowColor = nil
        slWindow.layer.shadowOpacity = 0.0
        slWindow.layer.shadowOffset = .zero
        slWindow.layer.shadowRadius = 0
        slWindow.layer.masksToBounds = true
        liveVC.view.layer.masksToBounds = true
    }
}
//MARK: - customerPreviewConverView
extension ShopLiveBase {
    func showPreviewCoverView() {
        guard let coverView = self.customerPreviewCoverView,
              let liveStreamViewController else { return }
        coverView.isHidden = false
        if let superView = coverView.superview {
            if liveStreamViewController.view !== superView {
                liveStreamViewController.inAppPipView.addSubview(coverView)
                setCustomerPreviewCoverViewLayout()
            }
        }
        else {
            liveStreamViewController.inAppPipView.addSubview(coverView)
            setCustomerPreviewCoverViewLayout()
        }
    }
    
    private func setCustomerPreviewCoverViewLayout() {
        guard let coverView = self.customerPreviewCoverView,
              let liveStreamViewController else { return }
        
        coverView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            coverView.topAnchor.constraint(equalTo: liveStreamViewController.inAppPipView.topAnchor),
            coverView.leadingAnchor.constraint(equalTo: liveStreamViewController.inAppPipView.leadingAnchor),
            coverView.trailingAnchor.constraint(equalTo: liveStreamViewController.inAppPipView.trailingAnchor),
            coverView.bottomAnchor.constraint(equalTo: liveStreamViewController.inAppPipView.bottomAnchor)
        ])
        liveStreamViewController.inAppPipView.bringSubviewToFront(liveStreamViewController.closeButton)
    }
    
    func hidePreviewCoverView() {
        self.customerPreviewCoverView?.isHidden = true
    }
}
extension ShopLiveBase: ShopLiveComponent {
    
    func forceStartWithPortraitMode(_ isForced: Bool) {
        self.isForceStartWithPortraitMode = isForced
    }
    
    func setResizeMode(mode: ShopliveSDKCommon.ShopLiveResizeMode) {
        self.customerVideoResizeMode = mode
        self.liveStreamViewController?.viewModel.setResizeMode(mode: mode)
    }
    
    func setEnabledOSPictureInPictureMode(isEnabled: Bool) {
        self.enabledOSPictureInPictureMode = isEnabled
    }
    
    func getPreviewSize(inAppPipConfiguration: ShopLiveInAppPipConfiguration, videoRatio: CGSize) -> CGSize {
        self.checkInAppPipConfigSize(config: inAppPipConfiguration)
        return self.calculatePipSize(inAppPipConfiguration: inAppPipConfiguration, scale: self.pipScale, defSize: videoRatio)
    }
    
    func addSubViewToPreview(subView: UIView) {
        self.customerPreviewCoverView?.isHidden = true
        self.customerPreviewCoverView?.removeFromSuperview()
        self.customerPreviewCoverView = nil
        self.customerPreviewCoverView = subView
    }
    
    func setShareScheme(_ scheme: String?, shareDelegate: ShopLivePlayerShareDelegate?) {
        if scheme == nil {
            guard shareDelegate != nil else {
                print("When `scheme` not used, `custom` must be used, `custom` can not be null")
                return
            }
        }
        if let shareDelegate = shareDelegate {
            self.shareDelegate = shareDelegate
        }
        else {
            self.shareDelegate = self
        }
        ShopLiveController.shared.shareScheme = scheme
    }
    
    func setStatusBarVisibility(isVisible: Bool) {
        self.statusBarVisibility = isVisible
    }
    
    func getStatusBarVisibility() -> Bool {
        return self.statusBarVisibility
    }
    
    func getPipPosition() -> ShopLive.PipPosition {
        if let liveStreamViewController = self.liveStreamViewController {
            return liveStreamViewController.viewModel.getPipPosition()
        }
        if let config = self.inAppPipConfiguration, let pos = config.pipPosition {
            return pos
        }
        return ShopLiveController.shared.initialPipPosition
    }
    
    func setPipPosition(pos: ShopLive.PipPosition) {
        liveStreamViewController?.viewModel.setPipPosition(position: pos)
    }
    
    func setInAppPipConfiguration(config: ShopLiveInAppPipConfiguration) {
        self.checkInAppPipConfigSize(config: config)
        self.inAppPipConfiguration = config
    }
    
    private func checkInAppPipConfigSize(config: ShopLiveInAppPipConfiguration) {
        if let pipSize = config.pipSize {
            if let maxSize = pipSize.pipMaxSize, maxSize >= UIScreen.main.bounds.width {
                config.pipSize = .init(pipMaxSize: 200)
            }
            else if let fixHeight = pipSize.pipFixedheight, fixHeight >= UIScreen.main.bounds.height {
                config.pipSize = .init(pipFixedWidth: 200)
            }
            else if let fixWidth = pipSize.pipFixedWidth, fixWidth >= UIScreen.main.bounds.width {
                config.pipSize = .init(pipFixedWidth: 200)
            }
        }
    }
    
    func setMixWithOthers(isMixAudio: Bool) {
        ShopLiveConfiguration.SoundPolicy.useMixWithOthers = isMixAudio
    }
    
    func setAudioSessionCategory(category: AVAudioSession.Category) {
        ShopLiveConfiguration.SoundPolicy.audioSessionCategory = category
    }
    
    func setEnabledPictureInPictureMode(isEnabled: Bool){
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
    
    // 1.5.10 부터 deprecate 처리
    func setKeepAspectOnTabletPortrait(_ keep: Bool) { }
    
    var playerWindow: ShopliveWindow? {
        return self.shopLiveWindow
    }
    
    var viewController: ShopLiveViewController? {
        return self.liveStreamViewController
    }
    
    func close(actionType: ShopLiveViewHiddenActionType) {
        self.hideShopLiveView(viewHideActionType: actionType)
    }
    
    func setChatViewFont(inputBoxFont: UIFont?, sendButtonFont: UIFont?) {
        ShopLiveConfiguration.UI.inputBoxFont = inputBoxFont
        ShopLiveConfiguration.UI.sendButtonFont = sendButtonFont
    }
    
    func hookNavigation(navigation: @escaping ((URL) -> Void)) {
        ShopLiveController.shared.hookNavigation = nil
        ShopLiveController.shared.hookNavigation = navigation
    }
    
    func onTerminated() {
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
    }
    
    func preview(
        with campaignKey: String?,
        referrer: String? = nil,
        resolution: ShopLivePlayerPreviewResolution,
        campaignHandler: ((ShopLivePlayerCampaign) -> ())?,
        brandHandler: ((ShopLivePlayerBrand) -> ())?,
        completion: (() -> Void)?
    ) {
        checkForceStartWithPortraitMode()
        if let campaignKey = campaignKey, ShopLiveController.windowStyle == .osPip {
            self.reservedPlayInfo = (.inAppPip, campaignKey  , referrer, campaignHandler, brandHandler)
            self.previewCallback = completion
            self.shopLivePlayerCampaignHandler = campaignHandler
            self.shopLivePlayerBrandHandler = brandHandler
            return
        }
        
        self.shopLivePlayerCampaignHandler = campaignHandler
        self.shopLivePlayerBrandHandler = brandHandler
        
        if ShopLiveController.shared.isPreview == true && ShopLiveController.windowStyle == .inAppPip &&
            campaignKey == ShopLiveController.shared.campaignKey &&
            ShopLiveController.timeControlStatus == .playing {
            return
        }
        
        ShopLiveController.shared._playerMode = .preview
        let delay = ShopLiveController.shared.execusedClose ? 0.8: 0.0
        throttle.callAsFunction {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                   guard let self else { return }
                   self.resetQueryParameters()
                   
                   ShopLiveController.shared.execusedClose = false
                   guard ShopLiveCommon.getAccessKey() != nil else { return }
                   
                   let audioSessionManager = SLAudioSessionManager.shared
                   if self._style == .unknown {
                       audioSessionManager.customerAudioCategoryOptions = audioSessionManager.currentCategoryOptions
                   }
                   
                   audioSessionManager.setCategory(category: ShopLiveConfiguration.SoundPolicy.audioSessionCategory, options: .mixWithOthers)
                   
                   if let referrer = referrer {
                       self.queryParameters["referrer"] = String(referrer.prefix(1024))
                   }
                   
                   self.queryParameters["_from"] = "sdk_direct"
                   
                   ShopLiveController.shared.campaignKey = campaignKey ?? ""
                   
                   self.delegate?.onEvent?(name: "player_start", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: ["type": "preview"])
                   
                   self.addObserver()
                   
                   
                   if !ShopLiveController.shared.isPreview && ShopLiveController.windowStyle == .normal {
                       if ShopLiveController.shared.isSameCampaign {
                           self.liveStreamViewController?.takeSnapShot(completion: {
                               self.startCustomPictureInPicture(with: self.getPipPosition(), scale: self.pipScale)
                           })
                       } else {
                           self.startCustomPictureInPicture(with: self.getPipPosition(), scale: self.pipScale)
                       }
                   }
                   
                   ShopLiveController.shared.isPreview = true
                   
                   self.previewCallback = completion
                   self.campaignKey = campaignKey
                   self.fetchOverlayUrl(with: campaignKey,isPreview: true,previewResolution: resolution) { [weak self] url in
                       guard let url = url,
                             let self = self else {
                           self?.removeObserver()
                           return
                       }
                       self.windowChangeCommand = .none
                       self.isWindowChanging = false
                       
                       //가로에서 세로, 세로에서 가로로 갈때도 분기를 쳐줘야 함.
                       if ShopLiveController.windowStyle == .inAppPip && (windowAnimator?.isRunning ?? false) == false {
                           self.changePlayerItemOnlyInPreview(url: url, resolution: resolution)
                       }
                       else {
                           self.callShopLiveViewFromPreview(url: url,resolution: resolution)
                       }
                   }
            }
        } onCancel: { }
    }
    
    private func changePlayerItemOnlyInPreview(url: URL,resolution: ShopLivePlayerPreviewResolution) {
        guard let accessKey = ShopLiveCommon.getAccessKey(),
              let vc = self.liveStreamViewController,
              ShopLiveController.shared.isPreview else { return }
        //TODO: - enablePreviewSound
        ShopLiveController.shared.setSoundMute(isMuted: ShopLiveConfiguration.SoundPolicy.isPreviewMute)
        
        videoWindowPanGestureRecognizer?.isEnabled = ShopLiveController.shared.isPreview ? true : false
        videoWindowTapGestureRecognizer?.isEnabled = ShopLiveController.shared.isPreview ? true : false
        videoWindowSwipeDownGestureRecognizer?.isEnabled = ShopLiveController.shared.isPreview ? false : true
        let oldVideoRatio = ShopLiveController.shared.videoRatio
        
        vc.viewModel.setPreviewResolution(resolution: resolution)
        self.osPictureInPictureController = nil
        vc.viewModel.updatePlayerItemWithLiveUrlFetchAPI(
            accessKey: accessKey,
            campaignKey: ShopLiveController.shared.campaignKey,
            isPreview: true
        ) { [weak self] _ in
            guard let self = self else { return }
            vc.viewModel.overayUrl = url
            vc.reload()
            
            //오리엔테이션이 변형되었으면 shopLiveWindow의 frame을 계산해서 다시 세팅해줘야함
            if oldVideoRatio.width != ShopLiveController.shared.videoRatio.width {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let pipPosition: CGRect = self.pipPosition(with: self.pipScale, position: self.getPipPosition())
                    self.shopLiveWindow?.frame = pipPosition
                }
            }
        }
        
    }
    
    private func callShopLiveViewFromPreview(url: URL,resolution: ShopLivePlayerPreviewResolution){
        self.showShopLiveView(with: url,isPreview: true) { [weak self] in
            guard let self = self else { return }
            //TODO: - enablePreviewSound
            ShopLiveController.shared.setSoundMute(isMuted: ShopLiveConfiguration.SoundPolicy.isPreviewMute)
            if let ak = ShopLiveCommon.getAccessKey(),
               let vc = self.liveStreamViewController,
               ShopLiveController.shared.isPreview {
                vc.viewModel.setPreviewResolution(resolution: resolution)
                vc.viewModel.updatePlayerItemWithLiveUrlFetchAPI(
                    accessKey: ak,
                    campaignKey: ShopLiveController.shared.campaignKey,
                    isPreview: true
                ) { isSuccess in
                    guard isSuccess else { return }
                    self.updatePictureInPicture()
                }
            }
        }
    }
    
    @objc func play(with campaignKey: String?, referrer: String? = nil, campaignHandler: ((ShopLivePlayerCampaign) -> ())?, brandHandler: ((ShopLivePlayerBrand) -> ())?) {
        checkForceStartWithPortraitMode()
        hidePreviewCoverView()
        if let campaignKey = campaignKey, ShopLiveController.windowStyle == .osPip {
            self.reservedPlayInfo = (.normal, campaignKey, referrer,campaignHandler, brandHandler )
            self.shopLivePlayerCampaignHandler = campaignHandler
            self.shopLivePlayerBrandHandler = brandHandler
            return
        }
        
        self.shopLivePlayerCampaignHandler = campaignHandler
        self.shopLivePlayerBrandHandler = brandHandler
        
        ShopLiveController.shared._playerMode = .play
        let delay = ShopLiveController.shared.execusedClose ? 0.8 : 0.0
        throttle.callAsFunction {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self else { return }
                resetQueryParameters()
                ShopLiveController.shared.execusedClose = false
                guard ShopLiveCommon.getAccessKey() != nil else { return }
                
                if let referrer = referrer {
                    queryParameters["referrer"] = String(referrer.prefix(1024))
                }
                
                ShopLiveController.shared.campaignKey = campaignKey ?? ""
                
                needExecuteFullScreen = ShopLiveController.shared.isPreview
                
                let audioSessionManager = SLAudioSessionManager.shared
                if _style == .unknown {
                    audioSessionManager.customerAudioCategoryOptions = audioSessionManager.currentCategoryOptions
                }
                
                let categoryOption: AVAudioSession.CategoryOptions = ShopLiveConfiguration.SoundPolicy.useMixWithOthers ? .mixWithOthers: audioSessionManager.customerAudioCategoryOptions
                
                audioSessionManager.setCategory(category: ShopLiveConfiguration.SoundPolicy.audioSessionCategory, options: categoryOption)
                
                if needExecuteFullScreen {
                    queryParameters["_from"] = "sdk_preview"
                    delegate?.onEvent?(name: "preview_to_player_mode", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: [:])
                } else {
                    queryParameters["_from"] = "sdk_direct"
                }
                delegate?.onEvent?(name: "player_start", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: ["type": "normal"])
                ShopLiveController.shared.isPreview = false
                addObserver()
                campaignChanged = (campaignKey != self.campaignKey)
                self.campaignKey = campaignKey
                
                fetchOverlayUrl(with: campaignKey,isPreview: false) { [weak self] url in
                    guard let self, let url else {
                        self?.removeObserver()
                        return
                    }
                    windowChangeCommand = .none
                    isWindowChanging = false
                    callShowShopLiveViewFromPlay(url: url)
                }
            }
        } onCancel: { }
    }
    
    private func callShowShopLiveViewFromPlay(url: URL) {
        self.showShopLiveView(with: url,isPreview: false) { [weak self] in
            guard let self = self else { return }
            if let ak = ShopLiveCommon.getAccessKey(),
               let vc = self.liveStreamViewController,
               ShopLiveController.shared.isPreview == false {
                vc.refreshSnapShotImageViewAndBackgroundPosterImageWebViewWhenPlayCalled()
                vc.viewModel.updatePlayerItemWithLiveUrlFetchAPI(
                    accessKey: ak,
                    campaignKey: ShopLiveController.shared.campaignKey,
                    isPreview: false
                ) { isSuccess in
                    guard let playerFrame = vc.viewModel.getEstimatedPlayerFrameForFullScreenOnInitalize(), isSuccess else {
                        return
                    }
                    DispatchQueue.main.async {
                        vc.updatePlayerViewFrameFromApp(targetFrame: playerFrame)
                    }
                }
            }
        }
    }
    
    func checkForceStartWithPortraitMode() {
        if isForceStartWithPortraitMode {
            if #available(iOS 16.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
        }
    }
    
    
    @objc func reloadLive() {
        guard ShopLiveCommon.getAccessKey() != nil else { return }
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
            
            let fixedScale = fixPipWidth / (UIScreen.isLandscape_SL ? UIScreen.main.bounds.height: UIScreen.main.bounds.width)
            return (fixedScale >= 0.0 && fixedScale <= 1.0) ? fixedScale: (fixedScale < 0 ? 0.0: 1.0)
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
        self.liveStreamViewController?.shopliveHideKeyboard_SL()
        
        
    }
    
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        ShopLiveController.playControl = .resume
        ShopLiveController.webInstance?.sendEventToWeb(event: .onPipModeChanged, true)
        
        if !ShopLiveConfiguration.UI.keepWindowStyleOnReturnFromOsPip {
            didChangeOSPIP()
        }
        self.liveStreamViewController?.setIsOsPipFailedHasOccured(hasOccured: false)
    }
    
    public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        setupOsPictureInPicture()
        if !ShopLiveController.isReplayMode && ShopLiveController.timeControlStatus == .playing {
            ShopLiveController.webInstance?.sendEventToWeb(event: .reloadBtn, false, false)
        }
        
        if ShopLiveConfiguration.UI.keepWindowStyleOnReturnFromOsPip {
            let prevWindowStyle = ShopLiveController.shared.prevWindowStyle
            _style = prevWindowStyle == .normal ? .fullScreen: prevWindowStyle == .inAppPip ? .pip: .unknown
            if _style == .fullScreen || _style == .unknown {
                //해당 시점에서 previewCoverView hidden처리를 하는 이유는 , didStop에서 처리하면 잠깐 보였다가 사라지는 현상이 있음
                self.hidePreviewCoverView()
            }
            ShopLiveController.windowStyle = prevWindowStyle
        } else {
            _style = .fullScreen
            self.hidePreviewCoverView()
            self.liveStreamViewController?.setVideoLayerGravityOnOsPipRestoration()
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
            self.hideShopLiveView(viewHideActionType: .onRestoringPip)
        }
        else if let reservedPlayInfo = self.reservedPlayInfo {
            if reservedPlayInfo.playStyle == .normal {
                self.play(with: reservedPlayInfo.campaignKey,referrer: reservedPlayInfo.referrer,campaignHandler: reservedPlayInfo.campaignHandler,brandHandler: reservedPlayInfo.brandHandler)
            }
            else if reservedPlayInfo.playStyle == .inAppPip {
                let resolution = liveStreamViewController?.viewModel.getCurrentPreviewResolution() ?? .PREVIEW
                self.preview(with: reservedPlayInfo.campaignKey, referrer: reservedPlayInfo.referrer, resolution: resolution, campaignHandler: reservedPlayInfo.campaignHandler, brandHandler: reservedPlayInfo.brandHandler , completion: previewCallback)
            }
            self.reservedPlayInfo = nil
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
                self.startFromCampaignFullscreen(animationDuration: 0.1,onOsPipRestoration: true)
            }
            self.isWindowChanging = false
        }
        ShopLiveController.webInstance?.sendEventToWeb(event: .onPipModeChanged, false)
        
        isRestoredPip = false
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        self.liveStreamViewController?.setIsOsPipFailedHasOccured(hasOccured: true)
        self.osPictureInPictureController = nil
    }
    
    
    
    private func resetQueryParameters() {
        queryParameters.removeAll()
    }
}

extension ShopLiveBase: LiveStreamViewControllerDelegate {
    
    func handleShopLivePlayerCampaign(campaign: ShopLivePlayerCampaign) {
        shopLivePlayerCampaignHandler?(campaign)
    }
    
    func handleShopLivePlayerBrand(brand: ShopLivePlayerBrand) {
        shopLivePlayerBrandHandler?(brand)
    }
    
    func resetPictureInPicture() {
        if osPictureInPictureController == nil {
            setupOsPictureInPicture()
        }
    }
    
    func log(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any]) {
        
        var param: [String: Any] = ["campaignKey": campaign]
        for (key, value) in payload {
            param.updateValue(value, forKey: key)
        }
        
        delegate?.onEvent?(name: name, feature: feature, campaign: campaign, payload: payload)
        delegate?.handleReceivedCommand?(name, data: param)
    }
    
    func handleReceivedCommand(_ command: String, with payload: [String: Any]?) {
        delegate?.handleReceivedCommand?(command, data: payload)
    }
    
    
    func changeOrientation(to orientation: ShopLiveDefines.ShopLiveOrientaion) {
        self.inRotating = true
        if _style == .pip, ShopLiveController.windowStyle == .inAppPip {
            updatePip(isRotation: true)
        } else {

            self.liveStreamViewController?.updatePlayerViewFrameFromChangeOrientation(targetWindowStyle :ShopLiveController.windowStyle)
            self.shopLiveWindow?.layoutIfNeeded()
            
            
            let orientation = UIScreen.currentOrientation_SL.angl_SLe
            
            let param: Dictionary = Dictionary<String, Any>.init(
                dictionaryLiteral: ("top", UIScreen.safeArea_SL.top),
                ("left", UIScreen.safeArea_SL.left),
                ("right", UIScreen.safeArea_SL.right),
                ("bottom", UIScreen.safeArea_SL.bottom),
                ("orientation", orientation)
            )
            
            self.liveStreamViewController?.sendCommandMessage(command: "SET_SAFE_AREA_MARGIN", payload: param)
        }
    }
    
    func finishRotation() {
        self.inRotating = false
        
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear)
        animator.addAnimations {
            ShopLiveController.shared.webInstance?.alpha = 1
        }
        animator.addCompletion { [weak self] position in
            guard let self = self, position == .end else { return }
            guard self.inRotating == false else { return }
            self.shopLiveWindow?.layer.masksToBounds = false
            self.liveStreamViewController?.setCloseDimLayerVisible(true)
        }
        
        animator.startAnimation()
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
    
    
    func onSetUserName(_ payload: [String: Any]) {
        delegate?.onSetUserName?(payload)
    }
    
    func campaignInfo(campaignInfo: [String: Any]) {
        delegate?.handleCampaignInfo?(campaignInfo: campaignInfo)
    }
    
    func didChangeCampaignStatus(status: String) {
        delegate?.handleChangeCampaignStatus?(status: status)
    }
    
    func onError(code: String, message: String) {
        delegate?.handleError?(code: code, message: message)
    }
    
    func didTouchCustomAction(id: String, type: String, payload: Any?) {
        _delegate?.handleCustomAction?(with: id, type: type, payload: payload) { [weak self] customActionResult in
            self?.liveStreamViewController?.didCompleteCustomAction(with: customActionResult)
            self?.liveStreamViewController?.didCompleteCustomAction(with: id)
        }
    }
    
    func didTouchPipButton() {
        startShopLivePictureInPicture()
    }
    
    func didTouchCloseButton() {
        hideShopLiveView(viewHideActionType: .onBtnTapped)
    }
    
    func didTouchNavigation(with url: URL) {
        guard let hookNavigation = ShopLiveController.shared.hookNavigation else {
            switch ShopLiveConfiguration.UI.nextActionTypeOnHandleNavigation {
            case .PIP:
                startCustomPictureInPicture(with: self.getPipPosition(), scale: self.pipScale)
            case .CLOSE:
                close(actionType: .onNavigationHandleClose)
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
        _delegate?.handleDownloadCoupon?(with: couponId) { [weak self] result in
            self?.liveStreamViewController?.didCompleteDownLoadCoupon(couponId: couponId, couponResult: result)
        }
    }
    
    func handleCommand(_ command: String, with payload: Any?) {
        _delegate?.handleCommand?(command, with: payload)
    }
    
    func requestHandleShare(data: ShopLivePlayerShareData) {
        //고객이 ShopLivePlayerShareDelegate를 채택하면 고객쪽으로 이벤트가 내려감
        shareDelegate.handleShare(data: data)
    }
}

extension ShopLiveBase: ShopLiveControllerDelegate {
    func setPresentationStyle(style: ShopLive.PresentationStyle) {
        self._style = style
    }
}
//고객이 ShopLivePlayerShareDelegate를 채택하면 고객쪽으로 이벤트가 내려감
extension ShopLiveBase: ShopLivePlayerShareDelegate {
    func handleShare(data: ShopLivePlayerShareData) {
        guard let url = data.url else {
            onError(code: "9001", message: "share.url.empty.error".localizedString())
            return
        }
        liveStreamViewController?.openOSShareSheet(url: URL(string: url))
    }
}
