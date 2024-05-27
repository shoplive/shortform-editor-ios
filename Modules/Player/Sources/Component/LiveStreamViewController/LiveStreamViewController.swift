//
//  LiveStreamViewController.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/04.
//

import UIKit
import WebKit
import AVKit
import MediaPlayer
import ExternalAccessory
import Foundation
import ShopliveSDKCommon

internal final class LiveStreamViewController: SLViewController {

    @objc dynamic lazy var viewModel: LiveStreamViewModel = LiveStreamViewModel()
    weak var delegate: LiveStreamViewControllerDelegate?

    var webViewConfiguration: WKWebViewConfiguration?
    let audioSession = AVAudioSession.sharedInstance()
    var audioSessionObservationInfo: UnsafeMutableRawPointer?
    var audioLevel: Float = 0.0
    var voiceOverIsOn: Bool = UIAccessibility.isVoiceOverRunning
    private var needSeek: Bool = false
    var minimumPipViewWidth: CGFloat = 60
    var hasKeyboard: Bool = false
    var lastKeyboardHeight: CGFloat = 0
    weak var popoverController: UIPopoverPresentationController?

    //뷰 계층
    //playerView
    // - backgroundPosterImageView
    // - snapShotImageView
    //overlayView
    var overlayView: OverlayWebView?
    var backgroundPosterImageWebView: SLWKWebView?
    var snapShotImageView: SLImageView?
    var playerView: ShopLivePlayerView?
    
    var playerLayer: AVPlayerLayer? {
        return playerView?.playerLayer
    }
    
    var playerTopConstraint: NSLayoutConstraint!
    var playerLeadingConstraint: NSLayoutConstraint!
    var playerRightConstraint: NSLayoutConstraint!
    var playerBottomConstraint: NSLayoutConstraint!
    
    var posterTopContraint: NSLayoutConstraint?
    var posterLeftContraint: NSLayoutConstraint?
    var posterRightContraint: NSLayoutConstraint?
    var posterBottomContraint: NSLayoutConstraint?
    
    var snapshotTopContraint: NSLayoutConstraint?
    var snapshotLeftContraint: NSLayoutConstraint?
    var snapshotRightContraint: NSLayoutConstraint?
    var snapshotBottomContraint: NSLayoutConstraint?
    
    lazy var inAppPipView: SLView = {
        let view = SLView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    lazy var pipDimLayer: CAGradientLayer = {
        let layer0 = CAGradientLayer()
        layer0.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor,
          UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        ]

        layer0.startPoint = CGPoint(x: 0.5, y: 0)
        layer0.endPoint = CGPoint(x: 0.5, y: 0.9)
        return layer0
    }()
    lazy var pipDim: SLLabel = {
        let view = SLLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.addSublayer(pipDimLayer)
        return view
    }()
    
    lazy var closeButton: SLButton = {
        let view = SLButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(ShopLiveSDKAsset.closebutton.image, for: .normal)
        view.addTarget(self, action: #selector(inAppPipCloseBtnTapped), for: .touchUpInside)
        return view
    }()
    var closeButtonTopConstraint: NSLayoutConstraint?
    var closeButtonLeadingConstraint: NSLayoutConstraint?
    
    lazy var indicatorView: SLActivityIndicatorView = {
        let activityIndicator = SLActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            activityIndicator.style = UIActivityIndicatorView.Style.large
        } else {
            activityIndicator.style = .whiteLarge
        }
        return activityIndicator
    }()

    lazy var customIndicator: SLLoadingIndicator = {
        let view = SLLoadingIndicator()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var chatConstraint: NSLayoutConstraint!
    lazy var chatInputView: ShopLiveChattingWriteView = {
        let chatView = ShopLiveChattingWriteView()
        chatView.isHidden = true
        chatView.translatesAutoresizingMaskIntoConstraints = false
        chatView.delegate = self
        return chatView
    }()
    lazy var chatInputBG: SLView = {
        let chatBG = SLView()
        chatBG.translatesAutoresizingMaskIntoConstraints = false
        chatBG.backgroundColor = .white
        chatBG.isHidden = true
        return chatBG
    }()

    
    
    private var forceStatusBarLightContent : Bool = true
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if self.forceStatusBarLightContent {
            return .lightContent
        }
        else {
            return .default
        }
    }
    
    private var statusBarVisibility : Bool = true
    override var prefersStatusBarHidden: Bool {
        return !statusBarVisibility
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.setVc(vc: self)
        setupView()
        setupLiveStreamViewController()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard viewModel.getUseCloseBtnIsEnabled() else { return }
        pipDim.layer.cornerRadius = viewModel.getPipCornerRadius()
        updateCloseButtonDim()
    }
    
    override func removeFromParent() {
        super.removeFromParent()
        self.delegate = nil
        overlayView?.delegate = nil
        overlayView?.removeFromSuperview()
        overlayView?.teardownOverlayWebView()
        backgroundPosterImageWebView?.removeFromSuperview()
        playerView?.removeFromSuperview()
        playerView = nil
        overlayView = nil
        backgroundPosterImageWebView = nil
        tearDownLiveStreamViewController()
    }
    
    deinit {
        ShopLiveLogger.debugLog("LiveStreamViewController deinited")
    }
    
    func setupLiveStreamViewController() {
        ShopLiveController.overlayUrl = viewModel.getOverLayUrlWithInfosAttached()
        setupAudioConfig()
        addObserver()
    }
    
    func tearDownLiveStreamViewController() {
        viewModel.resetRetry()
        ShopLiveController.shared.removePlayerDelegate(delegate: self)
        removeObserver()
        teardownAudioConfig()
        viewModel.teardownLiveStreamViewModel()
    }

    func updateChattingWriteView() {
        chatInputView.updateChattingWriteView()
    }
    
    private func setupView() {
        view.backgroundColor = .black
        setupPlayerView()
        setUpBackgroundPosterImageWebView()
        setupSnapshotView()
        if let playerView = playerView {
            self.view.bringSubviewToFront(playerView)
        }
        setupOverayWebview()
        setupChatInputView()
        setupIndicator()
        setupCloseButton()
    }
    
    func setupCloseButton() {
        self.view.addSubview(inAppPipView)
        inAppPipView.fitToSuperView()
        inAppPipView.addSubview(pipDim)
        pipDim.heightAnchor.constraint(equalToConstant: 60).isActive = true
        pipDim.leadingAnchor.constraint(equalTo: inAppPipView.leadingAnchor, constant: 0).isActive = true
        pipDim.trailingAnchor.constraint(equalTo: inAppPipView.trailingAnchor, constant: 0).isActive = true
        pipDim.topAnchor.constraint(equalTo: inAppPipView.topAnchor, constant: 0).isActive = true
        
        inAppPipView.addSubview(closeButton)
        closeButtonLeadingConstraint = closeButton.leadingAnchor.constraint(equalTo: inAppPipView.leadingAnchor, constant: 8)
        closeButtonLeadingConstraint?.isActive = true
        closeButtonTopConstraint = closeButton.topAnchor.constraint(equalTo: inAppPipView.topAnchor, constant: 8)
        closeButtonTopConstraint?.isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.view.bringSubviewToFront(inAppPipView)
    }
    
    @objc private func inAppPipCloseBtnTapped(sender : UIButton) {
        overlayView?.closeWebSocket()
        delegate?.didTouchCloseButton()
        
    }
    
    func updateImageConstraint(from: CGRect,targetWindowStyle : ShopLiveWindowStyle) {
        guard let bgImageView = self.backgroundPosterImageWebView else { return }
        ShopLiveLogger.tempLog("VideoRatio \(ShopLiveController.shared.videoRatio)")
       
        let ratio = ShopLiveController.shared.videoRatio.width / ShopLiveController.shared.videoRatio.height
        let screenSize = UIScreen.main.bounds
        let imageFrame = CGSize(width: screenSize.width - from.origin.x - from.size.width, height: screenSize.height - from.origin.y - from.size.height)
        
        let imageFrameRatio = imageFrame.width / imageFrame.height
        var posterConstraints : UIEdgeInsets = .zero
        var snapShotConstraints : UIEdgeInsets = .zero
        
        guard targetWindowStyle != .inAppPip else {
            posterConstraints = .zero
            snapShotConstraints = .zero
            return
        }
        
        if ShopLiveController.shared.videoOrientation == .portrait {
            if !ShopLiveConfiguration.UI.keepAspectOnTabletPortrait {
                if UIScreen.isLandscape {
                    self.backgroundPosterImageWebView?.clipsToBounds = true
                    self.backgroundPosterImageWebView?.layer.masksToBounds = true
                    let letterSpacing = (imageFrame.width - (imageFrame.height * (ShopLiveController.shared.videoRatio.width / ShopLiveController.shared.videoRatio.height))) / 2
                    posterConstraints = .init(top: 0, left: letterSpacing, bottom: 0, right: -letterSpacing)
                    snapShotConstraints = .init(top: 0, left: letterSpacing, bottom: 0, right: -letterSpacing)
                } else {
                    self.backgroundPosterImageWebView?.clipsToBounds = false
                    self.backgroundPosterImageWebView?.layer.masksToBounds = false
                    
                    let letterSpacing = (imageFrame.width - (imageFrame.height * (ShopLiveController.shared.videoRatio.width / ShopLiveController.shared.videoRatio.height))) / 2
                    posterConstraints = .init(top: 0, left: letterSpacing, bottom: 0, right: -letterSpacing)
                    snapShotConstraints = .init(top: 0, left: letterSpacing, bottom: 0, right: -letterSpacing)
                }
            } else {
                if UIScreen.isLandscape {
                    let letterSpacing = (imageFrame.width - (imageFrame.height * (ShopLiveController.shared.videoRatio.width / ShopLiveController.shared.videoRatio.height))) / 2
                    posterConstraints = .init(top: 0, left: letterSpacing, bottom: 0, right: -letterSpacing)
                    snapShotConstraints = .init(top: 0, left: letterSpacing, bottom: 0, right: -letterSpacing)
                } else {
                    if imageFrameRatio == ratio {
                        posterConstraints = .zero
                        snapShotConstraints = .zero
                    } else {
                        let letterSpacing = (imageFrame.width - (imageFrame.height * (ShopLiveController.shared.videoRatio.width / ShopLiveController.shared.videoRatio.height))) / 2
                        posterConstraints = .init(top: 0, left: letterSpacing, bottom: 0, right: -letterSpacing)
                        snapShotConstraints = .init(top: 0, left: letterSpacing, bottom: 0, right: -letterSpacing)
                    }
                }
            }
            if ShopLiveController.shared.videoOrientation == .portrait {
                if ShopLiveConfiguration.UI.keepAspectOnTabletPortrait {
                    bgImageView.clipsToBounds = true
                    bgImageView.layer.masksToBounds = true
                }
            } else {
                bgImageView.clipsToBounds = true
                bgImageView.layer.masksToBounds = true
            }
        }
        else {
            self.backgroundPosterImageWebView?.clipsToBounds = true
            self.backgroundPosterImageWebView?.layer.masksToBounds = true
            if imageFrameRatio == ratio {
                posterConstraints = .zero
                snapShotConstraints = .zero
            } else {
                let videoZoomed: Bool = (self.playerView?.playerLayer?.videoGravity ?? .resizeAspect) == .resizeAspectFill
                if imageFrameRatio < ratio  {
                    let letterSpacing = (imageFrame.height - (imageFrame.width * (ShopLiveController.shared.videoRatio.height / ShopLiveController.shared.videoRatio.width))) / 2
                    posterConstraints = .init(top: letterSpacing, left: 0, bottom: -letterSpacing, right: 0)
                    
                    snapShotConstraints = .init(top: ShopLiveController.shared.videoExpanded ? (videoZoomed ? 0 : letterSpacing) : letterSpacing,
                                                left: 0,
                                                bottom: ShopLiveController.shared.videoExpanded ? (videoZoomed ? 0 : -letterSpacing) : -letterSpacing,
                                                right: 0)
                    
                } else {
                    let letterSpacing = (imageFrame.width - (imageFrame.height * (ShopLiveController.shared.videoRatio.width / ShopLiveController.shared.videoRatio.height))) / 2
                    posterConstraints = .init(top: 0, left: letterSpacing, bottom: 0, right: -letterSpacing)
                    snapShotConstraints = .init(top: 0,
                                                left: ShopLiveController.shared.videoExpanded ? (videoZoomed ? 0 : letterSpacing) : letterSpacing,
                                                bottom: 0,
                                                right: ShopLiveController.shared.videoExpanded ? (videoZoomed ? 0 : -letterSpacing) : -letterSpacing)
                }
            }
        }
        posterTopContraint?.constant = posterConstraints.top
        posterBottomContraint?.constant = posterConstraints.bottom
        posterLeftContraint?.constant = posterConstraints.left
        posterRightContraint?.constant = posterConstraints.right
        
        snapshotTopContraint?.constant = snapShotConstraints.top
        snapshotBottomContraint?.constant = snapShotConstraints.bottom
        snapshotLeftContraint?.constant = snapShotConstraints.left
        snapshotRightContraint?.constant = snapShotConstraints.right
        
    }

    
    func updateCloseButtonDim() {
        pipDimLayer.frame = pipDim.frame
    }
    
    func setCloseButtonVisible(_ visible: Bool) {
        guard viewModel.getUseCloseBtnIsEnabled() else {
            inAppPipView.isHidden = true
            return
        }
        
        let inappPipViewWidth = inAppPipView.frame.width
        if inappPipViewWidth < minimumPipViewWidth {
            inAppPipView.isHidden = true
        } else {
            let constraintGap = (inappPipViewWidth - minimumPipViewWidth) / 25
            let gap = 4 + (constraintGap > 4 ? 4 : constraintGap)
            closeButtonTopConstraint?.constant = gap
            closeButtonLeadingConstraint?.constant = gap
            self.view.bringSubviewToFront(inAppPipView)
            inAppPipView.isHidden = !visible
            updateCloseButtonDim()
        }
    }

    func hideBackgroundPoster() {
        backgroundPosterImageWebView?.isHidden = true
        shopliveHideKeyboard_SL()
    }
    
    func showBackgroundPoster() {
        backgroundPosterImageWebView?.isHidden = false
    }
    
    func setCloseDimLayerVisible(_ visible: Bool) {
        self.inAppPipView.layer.masksToBounds = !visible
        self.pipDim.layer.masksToBounds = !visible
        self.pipDimLayer.masksToBounds = !visible
    }

    override func shopliveHideKeyboard_SL() {
        super.shopliveHideKeyboard_SL()
        self.chatInputView.resignFirstResponder()
        self.chatInputView.isHidden = true
        self.chatInputBG.isHidden = true
    }
    
    
    func updateImageFit() {
        posterTopContraint?.constant = 0
        posterBottomContraint?.constant = 0
        posterLeftContraint?.constant = 0
        posterRightContraint?.constant = 0
        
        snapshotTopContraint?.constant = 0
        snapshotBottomContraint?.constant = 0
        snapshotLeftContraint?.constant = 0
        snapshotRightContraint?.constant = 0
        
        self.backgroundPosterImageWebView?.layoutIfNeeded()
        self.snapShotImageView?.layoutIfNeeded()
    }
    
    func updateVideoFit(centerCrop: Bool = false, immediately: Bool = false, imageUpdate: Bool = true, targetWindowStyle : ShopLiveWindowStyle?) {
        if let playerLayer = playerView?.playerLayer {
            playerLayer.videoGravity = centerCrop ? .resizeAspectFill : .resizeAspect
        }
        playerTopConstraint.constant = 0
        playerLeadingConstraint.constant = 0
        playerRightConstraint.constant = 0
        playerBottomConstraint.constant = 0
        if imageUpdate {
            if let targetWindowStyle = targetWindowStyle {
                self.updateImageConstraint(from: .zero,targetWindowStyle: targetWindowStyle)
            }
            else {
                self.updateImageConstraint(from: .zero,targetWindowStyle: ShopLiveController.windowStyle)
            }
            
        }
        
        if immediately {
            if let playerView = playerView {
                playerView.setNeedsLayout()
                playerView.layoutIfNeeded()
            }
        }
    }
    
    func changeVideoGravity(centerCrop: Bool) {
        if let playerFrame = UIScreen.isLandscape ? ( ShopLiveController.shared.videoExpanded ? ShopLiveController.shared.videoFrame.landscape.expanded : ShopLiveController.shared.videoFrame.landscape.standard) : ShopLiveController.shared.videoFrame.portrait {
            self.updatePlayerFrame(centerCrop: ShopLiveController.shared.videoCenterCrop, playerFrame: playerFrame, immediately: false,targetWindowStyle: nil)
            
            let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
            animator.addAnimations { [weak self] in
                guard let self = self else { return }
                self.updateVideoConstraint()
            }
            
            animator.startAnimation()
        }
    }
    
    /**
        OsPip에서 올라올때 사용
     */
    func setVideoLayerGravityOnOsPipRestoration(){
        guard let playerView = playerView else { return }
        playerView.playerLayer?.videoGravity = self.getVideoLayerGravityForCurrentVideoType()
    }
    
    /**
        현재 디바이스, 디바이스 상태, 옵션에 맞는 videoGravity를 가지고 옴
     */
    func getVideoLayerGravityForCurrentVideoType() -> AVLayerVideoGravity {
        if UIDevice.isIpad && ShopLiveConfiguration.UI.keepAspectOnTabletPortrait {
            return .resizeAspect
        }
        else if UIDevice.isIpad && ShopLiveConfiguration.UI.keepAspectOnTabletPortrait == false {
            return .resizeAspectFill
        }
        else if UIScreen.isLandscape {
            return .resizeAspect
        }
        else {
            if let resizeMode = viewModel.getResizeMode() {
                if resizeMode == .CENTER_CROP {
                    return .resizeAspectFill
                }
                else {
                    return .resizeAspect
                }
            }
            else {
                return .resizeAspectFill
            }
        }
    }
    
    /**
     player video gravity 설정과 관련해서는 ShopLiveBase.play() 쪽도 같이
     */
    func updateVideoFrame(immeadiately: Bool, fitTopArea: Bool = false, targetWindowStyle : ShopLiveWindowStyle) {
        guard !ShopLiveController.shared.isPreview else { return }
        
        if ShopLiveController.shared.videoOrientation == .landscape {
            if targetWindowStyle == .inAppPip {
                self.updateVideoFit(centerCrop: true, immediately: immeadiately,targetWindowStyle: targetWindowStyle)
            } else {
                if fitTopArea {
                    setVideoDefaultFrame()
                    return
                }
                if let playerFrame = UIScreen.isLandscape ? ( ShopLiveController.shared.videoExpanded ? ShopLiveController.shared.videoFrame.landscape.expanded : ShopLiveController.shared.videoFrame.landscape.standard) : ShopLiveController.shared.videoFrame.portrait {
                    
                    self.updatePlayerFrame(centerCrop: ShopLiveController.shared.videoCenterCrop, playerFrame: playerFrame, immediately: immeadiately,targetWindowStyle: targetWindowStyle)
                }
            }
        } else {
            //Ipad는 가로세로 상관 없이 keepOn꺼져 있으면 꽉채우는 방식으로 진행
            let isCenterCrop = self.getVideoLayerGravityForCurrentVideoType() == .resizeAspectFill ? true : false
            self.updateVideoFit(centerCrop: isCenterCrop,immediately: immeadiately,targetWindowStyle: targetWindowStyle)
            
            self.updateImageConstraint(from: .zero,targetWindowStyle: targetWindowStyle)
        }
    }
    
    func setVideoDefaultFrame() {
        if UIScreen.isLandscape {
            ShopLiveController.shared.videoFrame.landscape.expanded = .zero
        } else {
            let height = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * (ShopLiveController.shared.videoRatio.height / ShopLiveController.shared.videoRatio.width))
            ShopLiveController.shared.videoFrame.portrait = .init(x: 0, y: 0, width: 0, height: height)
        }
    }
    
    func changeOrientation(toLandscape: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let orientation = toLandscape ? (UIScreen.isLandscape ? UIScreen.currentOrientation.deviceOrientation.rawValue :  ShopLiveController.shared.prevLandscapeOrientation.rawValue) : (UIScreen.isLandscape ? UIInterfaceOrientation.portrait.rawValue : UIDevice.current.orientation.rawValue)
            
            let lastOrientation = UIDevice.current.orientation
            
            guard UIScreen.currentOrientation.deviceOrientation.rawValue != orientation else { return }
            
            if #available(iOS 16.0, *) {
                self.setNeedsUpdateOfSupportedInterfaceOrientations()
                self.navigationController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let orientationMask = UIDeviceOrientation(rawValue: orientation)?.orientationMask ?? (toLandscape ? .landscape : .portrait)
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: toLandscape ? orientationMask : .portrait))
            } else {
                UIDevice.current.setValue(orientation, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
                
                if orientation != UIScreen.currentOrientation.deviceOrientation.rawValue {
                    UIDevice.current.setValue(lastOrientation.rawValue, forKey: "orientation")
                    UIViewController.attemptRotationToDeviceOrientation()
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let currentOrientation: ShopLiveDefines.ShopLiveOrientaion = UIScreen.isLandscape ? .landscape : .portrait
        if ShopLiveController.shared.supportOrientation == .landscape && !ShopLiveController.shared.willStartPip {
            self.updatePlayerFrame(targetWindowStyle: nil)
        }
        self.chatInputView.orientationChattingWritrViewConstraint()
        guard ShopLiveController.windowStyle != .osPip else {
            ShopLiveController.shared.lastOrientaion = (currentOrientation, UIScreen.currentOrientation.deviceOrientation)
            return
        }
        
        if let popoverController = self.popoverController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: size.width * 0.5, y: size.height * 0.5, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        if ShopLiveController.shared.videoOrientation == .portrait {
            if let playerLayer = playerView?.playerLayer {
                playerLayer.videoGravity = UIScreen.isLandscape ? .resizeAspect : (UIDevice.isIpad ? (ShopLiveConfiguration.UI.keepAspectOnTabletPortrait ? .resizeAspect : .resizeAspectFill) : .resizeAspectFill)
            }
            ShopLiveController.shared.webInstance?.alpha = 0
        }
        
        if ShopLiveController.shared.lastOrientaion.direction != currentOrientation {
            self.shopliveHideKeyboard_SL()
        }
        
        if UIScreen.currentOrientation.deviceOrientation.isLandscape {
            ShopLiveController.shared.prevLandscapeOrientation = UIScreen.currentOrientation.deviceOrientation
        }
        
        ShopLiveController.shared.lastOrientaion = (currentOrientation, UIScreen.currentOrientation.deviceOrientation)
        coordinator.animate { _ in
            ShopLiveController.shared.inRotating = true
            self.delegate?.changeOrientation(to: currentOrientation)
        } completion: { _ in
            ShopLiveController.shared.inRotating = false
            self.delegate?.finishRotation()
        }
    }
    
    func openOSShareSheet(url : URL?) {
        guard let urlString = url?.absoluteString, !urlString.isEmpty else {
            delegate?.onError(code: "9001", message: "share.url.empty.error".localizedString())
            return
        }
        
        guard let originUrl = urlString as? NSString, let decodeUrl = originUrl.trimmingCharacters(in: .whitespacesAndNewlines).removingPercentEncoding, let shareUrl = URL(string: decodeUrl) else { return }

        let shareAll:[Any] = [shareUrl]
        let activityViewController = SLActivityViewController(activityItems: shareAll , applicationActivities: nil)
        popoverController = activityViewController.popoverPresentationController
        popoverController?.sourceView = self.view
        if UIDevice.isIpad {
            popoverController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController?.permittedArrowDirections = []
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension LiveStreamViewController {
    func hideSnapShotView(){
        self.snapShotImageView?.isHidden = true
    }
    
    func takeSnapShot(completion : (() -> ())? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            ShopLiveController.shared.getSnapShot { image in
                if let imageWidth = image?.size.width {
                    if imageWidth < self.view.frame.size.width {
                        self.snapShotImageView?.contentMode = .scaleAspectFill
                    }
                    else {
                        self.snapShotImageView?.contentMode = .scaleAspectFit
                    }
                }
                self.snapShotImageView?.image = image
                self.snapShotImageView?.isHidden = false
                completion?()
            }
        }
    }
    
    func getIsSnapShotHidden() -> Bool {
        guard let snapShotView = self.snapShotImageView else {
            return true
        }
        return snapShotView.isHidden
    }
}
extension LiveStreamViewController {
    func updateStatuBarStyleToLightContent(){
        self.forceStatusBarLightContent = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func updateStatusBarToDefault(){
        self.forceStatusBarLightContent = false
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func setStatusBarVisiblityOnFullScreen(isVisible : Bool) {
        self.statusBarVisibility = isVisible
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func getStatusBarVisibilityOnFullScreen() -> Bool {
        return self.statusBarVisibility
    }
}
extension LiveStreamViewController : ShopLivePlayerDelegate {
    var identifier: String {
        return "LiveStreamViewController"
    }
    
    func updatedValue(key: ShopLivePlayerObserveValue) {
        
    }
}
extension LiveStreamViewController : LiveStreamViewModelDelegate {
    func requestTakeSnapShotView() {
        self.takeSnapShot()
    }
    
    func reloadWebView(with url: URL) {
        if let currentUrl = overlayView?.getCurrentUrl(), currentUrl == url {
            return
        }
        else {
            self.overlayView?.reload(with: url)
        }
    }
    
    func refreshAvPlayerLayer() {
        if let resizeMode = viewModel.getResizeMode(), UIDevice.isIpad == false, UIScreen.isLandscape == false {
            if resizeMode == .CENTER_CROP {
                playerView?.refreshLayer(videoGravity: .resizeAspectFill)
            }
            else if resizeMode == .FIT {
                playerView?.refreshLayer(videoGravity: .resizeAspect)
            }
        }
        else if let previousVideoGravity = self.playerLayer?.videoGravity {
            playerView?.refreshLayer(videoGravity: previousVideoGravity)
        }
        else {
            playerView?.refreshLayer(videoGravity: self.getVideoLayerGravityForCurrentVideoType())
        }
    }
    
    func setIsOsPipFailedHasOccured(hasOccured : Bool) {
        viewModel.setIsOsPipFailedHasOccured(hasOccured: hasOccured)
    }
    
    func sendNetworkCapabilityOnChanged(networkCapability: String) {
        self.sendNetworkCapabilityChangedToWeb(capability: networkCapability)
    }
    
    func getCurrentWebViewUrl() -> URL? {
        return self.overlayView?.getCurrentUrl()
    }
    
    func requestHideOrShowLoading(isHidden: Bool) {
        self.processLoadingIndicator(isHidden: isHidden)
    }
    
    private func processLoadingIndicator(isHidden : Bool){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if isHidden == false {
                guard ShopLiveController.shared.isPreview == false else  { return }
                if ShopLiveConfiguration.UI.isCustomIndicator {
                    self.customIndicator.configure(images: ShopLiveConfiguration.UI.customIndicatorImages)
                    self.customIndicator.startAnimating()
                }
                else {
                    self.indicatorView.isHidden = false
                    self.indicatorView.color = ShopLiveConfiguration.UI.color
                    self.indicatorView.startAnimating()
                }
            }
            else {
                if ShopLiveConfiguration.UI.isCustomIndicator {
                    self.customIndicator.stopAnimating()
                } else {
                    self.indicatorView.stopAnimating()
                }
            }
        }
    }
    
    func updateBackgroundImageConstraintsWithActualVideoRenderedRect(rect: CGRect) {
        posterTopContraint?.isActive = false
        posterLeftContraint?.isActive = false
        posterRightContraint?.isActive = false
        posterBottomContraint?.isActive = false
        
        snapshotTopContraint?.isActive = false
        snapshotLeftContraint?.isActive = false
        snapshotRightContraint?.isActive = false
        snapshotBottomContraint?.isActive = false
        
        if let bgWebView = self.backgroundPosterImageWebView {
            bgWebView.widthAnchor.constraint(equalToConstant: rect.width).isActive = true
            bgWebView.heightAnchor.constraint(equalToConstant: rect.height).isActive = true
        }
        if let snapShotImageView = self.snapShotImageView {
            snapShotImageView.widthAnchor.constraint(equalToConstant: rect.width).isActive = true
            snapShotImageView.heightAnchor.constraint(equalToConstant: rect.height).isActive = true
        }
    }
    
}
//MARK: - ViewSetUp functions
extension LiveStreamViewController {
    private func setUpBackgroundPosterImageWebView() {
        guard let playerView = playerView else { return }
        self.backgroundPosterImageWebView = SLWKWebView()
        guard let backgroundPosterImageWebView = self.backgroundPosterImageWebView else { return }
        self.view.addSubview(backgroundPosterImageWebView)
        backgroundPosterImageWebView.translatesAutoresizingMaskIntoConstraints = false
        backgroundPosterImageWebView.isOpaque = false
        backgroundPosterImageWebView.backgroundColor = .black
        backgroundPosterImageWebView.scrollView.backgroundColor = .black
        backgroundPosterImageWebView.layer.masksToBounds = true
        backgroundPosterImageWebView.clipsToBounds = true
        backgroundPosterImageWebView.scrollView.contentInsetAdjustmentBehavior = .never
        backgroundPosterImageWebView.scrollView.contentInset = .zero
       
        if ShopLiveConfiguration.UI.keepAspectOnTabletPortrait {
            backgroundPosterImageWebView.clipsToBounds = true
            backgroundPosterImageWebView.layer.masksToBounds = true
        }
        
        let centxConstraint  = backgroundPosterImageWebView.centerXAnchor.constraint(equalTo: playerView.centerXAnchor)
        let centYConstraint  = backgroundPosterImageWebView.centerYAnchor.constraint(equalTo: playerView.centerYAnchor)
        
        let topConstraint    = backgroundPosterImageWebView.topAnchor.constraint(equalTo: playerView.topAnchor)
        let leftConstraint   = backgroundPosterImageWebView.leadingAnchor.constraint(equalTo: playerView.leadingAnchor)
        let rightConstraint  = backgroundPosterImageWebView.trailingAnchor.constraint(equalTo: playerView.trailingAnchor)
        let bottomConstraint = backgroundPosterImageWebView.bottomAnchor.constraint(equalTo: playerView.bottomAnchor)
        
        topConstraint.priority = .init(rawValue: 999)
        leftConstraint.priority = .init(rawValue: 999)
        rightConstraint.priority = .init(rawValue: 999)
        bottomConstraint.priority = .init(rawValue: 999)
        
        posterTopContraint = topConstraint
        posterLeftContraint = leftConstraint
        posterRightContraint = rightConstraint
        posterBottomContraint = bottomConstraint
        
        NSLayoutConstraint.activate([ topConstraint, leftConstraint, rightConstraint, bottomConstraint, centxConstraint, centYConstraint ])
    }
    
    private func setupSnapshotView() {
        guard let playerView = playerView else { return }
        self.snapShotImageView = SLImageView()
        guard let snapShotImageView = self.snapShotImageView else { return }
        self.view.addSubview(snapShotImageView)
        snapShotImageView.translatesAutoresizingMaskIntoConstraints = false
        snapShotImageView.contentMode = .scaleAspectFill
        snapShotImageView.layer.masksToBounds = true
        snapShotImageView.clipsToBounds = true
        snapShotImageView.backgroundColor = .clear
        snapShotImageView.isHidden = true
        
        let centerXConstraint = snapShotImageView.centerXAnchor.constraint(equalTo: playerView.centerXAnchor)
        let centerYConstraint = snapShotImageView.centerYAnchor.constraint(equalTo: playerView.centerYAnchor)
        
        let topConstraint     = snapShotImageView.topAnchor.constraint(equalTo: playerView.topAnchor)
        let leftConstraint    = snapShotImageView.leadingAnchor.constraint(equalTo: playerView.leadingAnchor)
        let rightConstraint   = snapShotImageView.trailingAnchor.constraint(equalTo: playerView.trailingAnchor)
        let bottomConstraint  = snapShotImageView.bottomAnchor.constraint(equalTo: playerView.bottomAnchor)
        
        topConstraint.priority = .init(rawValue: 999)
        leftConstraint.priority = .init(rawValue: 999)
        rightConstraint.priority = .init(rawValue: 999)
        bottomConstraint.priority = .init(rawValue: 999)
        
        
        snapshotTopContraint = topConstraint
        snapshotLeftContraint = leftConstraint
        snapshotRightContraint = rightConstraint
        snapshotBottomContraint = bottomConstraint
        
        NSLayoutConstraint.activate([ topConstraint, leftConstraint, rightConstraint, bottomConstraint, centerXConstraint, centerYConstraint ])
    }
    
    func setupPlayerView() {
        if playerView == nil {
            playerView = .init()
        }
        guard let playerView = playerView else { return }
        view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.playerLayer?.player = playerView.player
        playerView.playerLayer?.needsDisplayOnBoundsChange = true
        
        if let resizeMode = viewModel.getResizeMode(), UIDevice.isIpad == false, UIScreen.isLandscape == false {
            if resizeMode == .CENTER_CROP {
                playerView.playerLayer?.videoGravity = .resizeAspectFill
            }
            else if resizeMode == .FIT {
                playerView.playerLayer?.videoGravity = .resizeAspect
            }
        }
        else if ShopLiveController.shared.videoOrientation == .portrait {
            if UIScreen.isLandscape {
                playerView.playerLayer?.videoGravity = .resizeAspect
            }
            else if UIDevice.isIpad && ShopLiveConfiguration.UI.keepAspectOnTabletPortrait {
                playerView.playerLayer?.videoGravity = .resizeAspect
            }
            else if UIDevice.isIpad && ShopLiveConfiguration.UI.keepAspectOnTabletPortrait == false {
                playerView.playerLayer?.videoGravity = .resizeAspectFill
            }
            else {
                playerView.playerLayer?.videoGravity = .resizeAspectFill
            }
        } else {
            playerView.playerLayer?.videoGravity = .resizeAspect
        }
        
        ShopLiveController.shared.playerItem?.player = playerView.player
        if let playerLayer = playerView.playerLayer {
            ShopLiveController.shared.playerItem?.playerLayer? = playerLayer
        }
        
        playerTopConstraint     = playerView.topAnchor.constraint(equalTo: view.topAnchor)
        playerLeadingConstraint = playerView.leftAnchor.constraint(equalTo: view.leftAnchor)
        playerRightConstraint   = playerView.rightAnchor.constraint(equalTo: view.rightAnchor)
        playerBottomConstraint  = playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([playerTopConstraint, playerLeadingConstraint, playerRightConstraint, playerBottomConstraint])
    }
    
    
    func resetPlayerLayer(){
        
    }
    
    func setupOverayWebview() {
        let overlayView = OverlayWebView(with: webViewConfiguration)
        overlayView.setupOverlayWebView()
        overlayView.webviewUIDelegate = self
        overlayView.delegate = self

        view.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([overlayView.topAnchor.constraint(equalTo: view.topAnchor),
                                     overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     overlayView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     overlayView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        self.overlayView = overlayView
    }
    
    private func setupChatInputView() {
        view.addSubview(chatInputView)

        chatConstraint = NSLayoutConstraint.init(item: chatInputView, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0)
        let chatLeading = NSLayoutConstraint.init(item: chatInputView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0)
        let chatTrailing = NSLayoutConstraint.init(item: chatInputView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0)

        self.view.addConstraints([
            chatLeading, chatTrailing, chatConstraint
        ])

        self.view.addSubview(chatInputBG)
        NSLayoutConstraint.activate([
                                     chatInputBG.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     chatInputBG.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)])
        self.view.addConstraints([
            NSLayoutConstraint(item: chatInputBG, attribute: .top, relatedBy: .equal, toItem: self.chatInputView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: chatInputBG, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        ])
        
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
    }

    private func setupIndicator() {
        guard let playerView = playerView else { return }
        if ShopLiveConfiguration.UI.isCustomIndicator {
            playerView.addSubviews(customIndicator)
            let customIndicatorWidth = NSLayoutConstraint.init(item: customIndicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
            let customIndicatorHeight = NSLayoutConstraint.init(item: customIndicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
            let customIndicatorCenterXConstraint = NSLayoutConstraint.init(item: customIndicator, attribute: .centerX, relatedBy: .equal, toItem: playerView, attribute: .centerX, multiplier: 1.0, constant: 0)
            let customIndicatorCenterYConstraint = NSLayoutConstraint.init(item: customIndicator, attribute: .centerY, relatedBy: .equal, toItem: playerView, attribute: .centerY, multiplier: 1.0, constant: 0)

            customIndicator.addConstraints([customIndicatorWidth, customIndicatorHeight])
            playerView.addConstraints([customIndicatorCenterXConstraint, customIndicatorCenterYConstraint])

            customIndicator.configure(images: ShopLiveConfiguration.UI.customIndicatorImages)
        } else {
            playerView.addSubviews(indicatorView)
            let indicatorWidth = NSLayoutConstraint.init(item: indicatorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
            let indicatorHeight = NSLayoutConstraint.init(item: indicatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
            let centerXConstraint = NSLayoutConstraint.init(item: indicatorView, attribute: .centerX, relatedBy: .equal, toItem: playerView, attribute: .centerX, multiplier: 1.0, constant: 0)
            let centerYConstraint = NSLayoutConstraint.init(item: indicatorView, attribute: .centerY, relatedBy: .equal, toItem: playerView, attribute: .centerY, multiplier: 1.0, constant: 0)

            indicatorView.addConstraints([indicatorWidth, indicatorHeight])
            playerView.addConstraints([centerXConstraint, centerYConstraint])
            indicatorView.color = ShopLiveConfiguration.UI.color

        }
        
        playerView.bringSubviewToFront(indicatorView)
    }
    
}
