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

protocol LiveStreamViewControllerDelegate: AnyObject {
    func didTouchPipButton()
    func didTouchCustomAction(id: String, type: String, payload: Any?)
    func didTouchCloseButton()
    func didTouchNavigation(with url: URL)
    func didTouchCoupon(with couponId: String)
    func handleCommand(_ command: String, with payload: Any?)
    func campaignInfo(campaignInfo: [String: Any])
    func didChangeCampaignStatus(status: String)
    func onError(code: String, message: String)
    func onSetUserName(_ payload: [String: Any])
    func handleReceivedCommand(_ command: String, with payload: [String: Any]?)
    func changeOrientation(to: ShopLiveDefines.ShopLiveOrientaion)
    func updatePictureInPicture()
    func finishRotation()
    func resetPictureInPicture()
    
    func log(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any])
    func requestHandleShare(data: ShopLivePlayerShareData)
    func handleShopLivePlayerCampaign(campaign: ShopLivePlayerCampaign)
    func handleShopLivePlayerBrand(brand: ShopLivePlayerBrand)
}

final class LiveStreamViewController: SLViewController {

    var viewModel: LiveStreamViewModel = LiveStreamViewModel()
    weak var delegate: LiveStreamViewControllerDelegate?

    var webViewConfiguration: WKWebViewConfiguration?
    var audioSessionObservationInfo: UnsafeMutableRawPointer?
    var audioLevel: Float = 0.0
    var voiceOverIsOn: Bool = UIAccessibility.isVoiceOverRunning
    
    var hasKeyboard: Bool = false
    var lastKeyboardHeight: CGFloat = 0
    weak var popoverController: UIPopoverPresentationController?

    //뷰 계층
    //playerView
    // - backgroundPosterImageView
    // - snapShotImageView
    //overlayView
    lazy var overlayView = OverlayWebView(with: webViewConfiguration, removeStaticInstanceWithDeinit: true)
    var backgroundPosterImageWebView: ShopLiveBackgroundPosterImageWebView = {
        let view = ShopLiveBackgroundPosterImageWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isOpaque = false
        view.backgroundColor = .black
        view.layer.masksToBounds = true
        view.clipsToBounds = true
        return view
    }()
    var snapShotImageView : SLImageView = {
        let imageView = SLImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.isHidden = true
        return imageView
    }()
    var playerView = ShopLivePlayerView()
    
    var playerTopConstraint: NSLayoutConstraint!
    var playerLeadingConstraint: NSLayoutConstraint!
    var playerRightConstraint: NSLayoutConstraint!
    var playerBottomConstraint: NSLayoutConstraint!

    var snapShotWidthAnc: NSLayoutConstraint?
    var snapShotheightAnc: NSLayoutConstraint?
    
    lazy var inAppPipView: SLView = {
        let view = SLView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    private lazy var pipDimLayer: CAGradientLayer = {
        let layer0 = CAGradientLayer()
        layer0.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor,
          UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        ]

        layer0.startPoint = CGPoint(x: 0.5, y: 0)
        layer0.endPoint = CGPoint(x: 0.5, y: 0.9)
        return layer0
    }()
    
    private lazy var pipDim: SLLabel = {
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
        view.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        view.isHidden = true
        return view
    }()
    
    private var inAppPipBadgeView: ShopLiveInAppPIPBadgeView = {
        let view = ShopLiveInAppPIPBadgeView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var inAppPipTextBoxView: ShopLiveInAppPipTextBoxView = {
        let view = ShopLiveInAppPipTextBoxView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var inAppPipBadgeConstraint: [NSLayoutConstraint] = []

    private lazy var indicatorView: SLActivityIndicatorView = {
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

    private lazy var customIndicator: SLLoadingIndicator = {
        let view = SLLoadingIndicator()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var chatConstraint: NSLayoutConstraint!
    lazy var chatInputView: ShopLiveChattingView = {
        let chatView = ShopLiveChattingView()
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
    
    private var forceStatusBarLightContent: Bool = true
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if self.forceStatusBarLightContent {
            return .lightContent
        }
        else {
            return .default
        }
    }
    
    private var statusBarVisibility: Bool = true
    override var prefersStatusBarHidden: Bool {
        return !statusBarVisibility
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = "live-stream-viewcontroller"
        viewModel.delegate = self
        viewModel.setVc(vc: self)
        setupView()
        setAudioAndNotificationCenter()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateInAppPipBadgeConstraint()
        guard viewModel.getUseCloseBtnIsEnabled() else { return }
        pipDim.layer.cornerRadius = viewModel.getPipCornerRadius()
        updateCloseButtonDim()
    }
    
    private func updateInAppPipBadgeConstraint() {
        guard inAppPipBadgeView.superview == inAppPipView else {
            print("Warning: inAppPipBadgeView is not a subview of inAppPipView")
            return
        }
        
        guard inAppPipView.frame.width > 0 else {
            print("Warning: inAppPipView frame width is 0")
            return
        }
        
        if !inAppPipBadgeConstraint.isEmpty {
            NSLayoutConstraint.deactivate(inAppPipBadgeConstraint)
        }
        
        let multiplier =  inAppPipView.frame.width * 0.15 > 26 ? 26 : inAppPipView.frame.width * 0.15
        
        let heightConstraint = inAppPipBadgeView.heightAnchor.constraint(equalToConstant: multiplier)
        
        inAppPipBadgeConstraint = [heightConstraint]
        NSLayoutConstraint.activate(inAppPipBadgeConstraint)
        
        inAppPipBadgeView.layoutIfNeeded()
    }
    
    override func removeFromParent() {
        super.removeFromParent()
        self.delegate = nil
        overlayView.delegate = nil
        overlayView.removeFromSuperview()
        overlayView.teardownOverlayWebView()
        backgroundPosterImageWebView.removeFromSuperview()
        playerView.removeFromSuperview()
        tearDownLiveStreamViewController()
    }
    
    func setAudioAndNotificationCenter() {
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

    func updateChattingViewPlaceholderVisibility() {
        chatInputView.updatePlaceholderVisibility()
    }
    
    private func setupView() {
        view.backgroundColor = .black
        setupPlayerView()
        setUpBackgroundPosterImageWebView()
        setupSnapshotView()
        self.view.bringSubviewToFront(playerView)
        setupOverayWebview()
        setupChatInputView()
        setupIndicator()
        setupInAppPip()
    }
    
    func setupInAppPip() {
        self.view.addSubview(inAppPipView)
        inAppPipView.fitToSuperView()
        
        inAppPipView.addSubview(pipDim)
        NSLayoutConstraint.activate([
            pipDim.heightAnchor.constraint(equalToConstant: 60),
            pipDim.leadingAnchor.constraint(equalTo: inAppPipView.leadingAnchor, constant: 0),
            pipDim.trailingAnchor.constraint(equalTo: inAppPipView.trailingAnchor, constant: 0),
            pipDim.topAnchor.constraint(equalTo: inAppPipView.topAnchor, constant: 0),
        ])
        
        inAppPipView.addSubview(inAppPipBadgeView)
        inAppPipView.addSubview(inAppPipTextBoxView)
        
        inAppPipView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: inAppPipView.leadingAnchor),
            closeButton.topAnchor.constraint(equalTo: inAppPipView.topAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        self.view.bringSubviewToFront(inAppPipView)
    }
    
    private func setInAppPipBadge(_ badgeConfig: InAppPipDisplayModel) {
        
        let horizontal = badgeConfig.layout.horizontalToAlignment()
        let vertical = badgeConfig.layout.verticalToAlignment()
        
        
        let horizontalPadding = badgeConfig.padding.horizontal
        let verticalPadding = badgeConfig.padding.vertical
        
        switch (horizontal, vertical) {
        case (.LEFT, .TOP): // 좌측 상단
            NSLayoutConstraint.activate([
                inAppPipBadgeView.topAnchor.constraint(equalTo: inAppPipView.topAnchor, constant: verticalPadding),
                inAppPipBadgeView.leadingAnchor.constraint(equalTo: inAppPipView.leadingAnchor, constant: horizontalPadding),
                inAppPipBadgeView.trailingAnchor.constraint(lessThanOrEqualTo: inAppPipView.trailingAnchor, constant: -horizontalPadding)
            ])
        case (.CENTER, .TOP): // 중앙 상단
            NSLayoutConstraint.activate([
                inAppPipBadgeView.topAnchor.constraint(equalTo: inAppPipView.topAnchor, constant: verticalPadding),
                inAppPipBadgeView.centerXAnchor.constraint(equalTo: inAppPipView.centerXAnchor),
                inAppPipBadgeView.leadingAnchor.constraint(greaterThanOrEqualTo: inAppPipView.leadingAnchor, constant: horizontalPadding),
                inAppPipBadgeView.trailingAnchor.constraint(lessThanOrEqualTo: inAppPipView.trailingAnchor, constant: -horizontalPadding)
            ])
        case (.RIGHT, .TOP): // 우측 상단
            NSLayoutConstraint.activate([
                inAppPipBadgeView.topAnchor.constraint(equalTo: inAppPipView.topAnchor, constant: verticalPadding),
                inAppPipBadgeView.trailingAnchor.constraint(equalTo: inAppPipView.trailingAnchor, constant: -horizontalPadding),
                inAppPipBadgeView.leadingAnchor.constraint(greaterThanOrEqualTo: inAppPipView.leadingAnchor, constant: horizontalPadding)
            ])
        case (.LEFT, .CENTER): // 좌측 중앙
            NSLayoutConstraint.activate([
                inAppPipBadgeView.centerYAnchor.constraint(equalTo: inAppPipView.centerYAnchor),
                inAppPipBadgeView.leadingAnchor.constraint(equalTo: inAppPipView.leadingAnchor, constant: horizontalPadding),
                inAppPipBadgeView.trailingAnchor.constraint(lessThanOrEqualTo: inAppPipView.trailingAnchor, constant: -horizontalPadding)
            ])
        case (.CENTER, .CENTER): // 중앙
            NSLayoutConstraint.activate([
                inAppPipBadgeView.centerXAnchor.constraint(equalTo: inAppPipView.centerXAnchor),
                inAppPipBadgeView.centerYAnchor.constraint(equalTo: inAppPipView.centerYAnchor),
                inAppPipBadgeView.leadingAnchor.constraint(greaterThanOrEqualTo: inAppPipView.leadingAnchor, constant: horizontalPadding),
                inAppPipBadgeView.trailingAnchor.constraint(lessThanOrEqualTo: inAppPipView.trailingAnchor, constant: -horizontalPadding)
            ])
        case (.RIGHT, .CENTER): // 우측 중앙
            NSLayoutConstraint.activate([
                inAppPipBadgeView.centerYAnchor.constraint(equalTo: inAppPipView.centerYAnchor),
                inAppPipBadgeView.trailingAnchor.constraint(equalTo: inAppPipView.trailingAnchor, constant: -horizontalPadding),
                inAppPipBadgeView.leadingAnchor.constraint(greaterThanOrEqualTo: inAppPipView.leadingAnchor, constant: horizontalPadding)
            ])
        case (.LEFT, .BOTTOM): // 좌측 하단
            NSLayoutConstraint.activate([
                inAppPipBadgeView.bottomAnchor.constraint(equalTo: inAppPipView.bottomAnchor, constant: -verticalPadding),
                inAppPipBadgeView.leadingAnchor.constraint(equalTo: inAppPipView.leadingAnchor, constant: horizontalPadding),
                inAppPipBadgeView.trailingAnchor.constraint(lessThanOrEqualTo: inAppPipView.trailingAnchor, constant: -horizontalPadding)
            ])
        case (.CENTER, .BOTTOM): // 중앙 하단
            NSLayoutConstraint.activate([
                inAppPipBadgeView.bottomAnchor.constraint(equalTo: inAppPipView.bottomAnchor, constant: -verticalPadding),
                inAppPipBadgeView.centerXAnchor.constraint(equalTo: inAppPipView.centerXAnchor),
                inAppPipBadgeView.leadingAnchor.constraint(greaterThanOrEqualTo: inAppPipView.leadingAnchor, constant: horizontalPadding),
                inAppPipBadgeView.trailingAnchor.constraint(lessThanOrEqualTo: inAppPipView.trailingAnchor, constant: -horizontalPadding)
            ])
        case (.RIGHT, .BOTTOM): // 우측 하단
            NSLayoutConstraint.activate([
                inAppPipBadgeView.bottomAnchor.constraint(equalTo: inAppPipView.bottomAnchor, constant: -verticalPadding),
                inAppPipBadgeView.trailingAnchor.constraint(equalTo: inAppPipView.trailingAnchor, constant: -horizontalPadding),
                inAppPipBadgeView.leadingAnchor.constraint(greaterThanOrEqualTo: inAppPipView.leadingAnchor, constant: horizontalPadding)
            ])
        default:
            break
        }
        
        let configMaxWidth = CGFloat(badgeConfig.size?.maxWidth ?? 112)
        
        inAppPipBadgeConstraint = [
            inAppPipBadgeView.widthAnchor.constraint(lessThanOrEqualTo: inAppPipView.widthAnchor, multiplier: 0.7),
            inAppPipBadgeView.widthAnchor.constraint(lessThanOrEqualToConstant: configMaxWidth)
        ]
        
        NSLayoutConstraint.activate(inAppPipBadgeConstraint)
        
        inAppPipBadgeView.action(.hiddenBadge(!badgeConfig.active))
        inAppPipBadgeView.action(.setBadge(URL(string: badgeConfig.imageUrl ?? "")))
        inAppPipBadgeView.action(.setAlignment(horizontal ?? .RIGHT))
    }
    
    private func setInAppPipTextBox(_ textBoxConfig: InAppPipDisplayModel) {
        
        inAppPipTextBoxView.action(.hiddenTextBox(!textBoxConfig.active))
        inAppPipTextBoxView.action(.setTitle(textBoxConfig.text))
        
        let horizontal = textBoxConfig.layout.horizontalToAlignment()
        let vertical = textBoxConfig.layout.verticalToAlignment()
        
        let horizontalPadding = textBoxConfig.padding.horizontal
        let verticalPadding = textBoxConfig.padding.vertical
        
        switch (horizontal, vertical) {
        case (.LEFT, .TOP): // 좌측 상단
            NSLayoutConstraint.activate([
                inAppPipTextBoxView.topAnchor.constraint(equalTo: inAppPipView.topAnchor, constant: verticalPadding),
                inAppPipTextBoxView.leadingAnchor.constraint(equalTo: inAppPipView.leadingAnchor, constant: horizontalPadding)
            ])
        case (.CENTER, .TOP): // 중앙 상단
            NSLayoutConstraint.activate([
                inAppPipTextBoxView.topAnchor.constraint(equalTo: inAppPipView.topAnchor, constant: verticalPadding),
                inAppPipTextBoxView.centerXAnchor.constraint(equalTo: inAppPipView.centerXAnchor),
                inAppPipTextBoxView.leadingAnchor.constraint(greaterThanOrEqualTo: inAppPipView.leadingAnchor, constant: horizontalPadding),
                inAppPipTextBoxView.trailingAnchor.constraint(lessThanOrEqualTo: inAppPipView.trailingAnchor, constant: -horizontalPadding)
            ])
        case (.RIGHT, .TOP): // 우측 상단
            NSLayoutConstraint.activate([
                inAppPipTextBoxView.topAnchor.constraint(equalTo: inAppPipView.topAnchor, constant: verticalPadding),
                inAppPipTextBoxView.trailingAnchor.constraint(equalTo: inAppPipView.trailingAnchor, constant: -horizontalPadding),
                inAppPipTextBoxView.leadingAnchor.constraint(greaterThanOrEqualTo: inAppPipView.leadingAnchor, constant: horizontalPadding)
            ])
        case (.LEFT, .CENTER): // 좌측 중앙
            NSLayoutConstraint.activate([
                inAppPipTextBoxView.centerYAnchor.constraint(equalTo: inAppPipView.centerYAnchor),
                inAppPipTextBoxView.leadingAnchor.constraint(equalTo: inAppPipView.leadingAnchor, constant: horizontalPadding)
            ])
        case (.CENTER, .CENTER): // 중앙
            NSLayoutConstraint.activate([
                inAppPipTextBoxView.centerXAnchor.constraint(equalTo: inAppPipView.centerXAnchor),
                inAppPipTextBoxView.centerYAnchor.constraint(equalTo: inAppPipView.centerYAnchor),
                inAppPipTextBoxView.leadingAnchor.constraint(greaterThanOrEqualTo: inAppPipView.leadingAnchor, constant: horizontalPadding),
                inAppPipTextBoxView.trailingAnchor.constraint(lessThanOrEqualTo: inAppPipView.trailingAnchor, constant: -horizontalPadding)
            ])
        case (.RIGHT, .CENTER): // 우측 중앙
            NSLayoutConstraint.activate([
                inAppPipTextBoxView.centerYAnchor.constraint(equalTo: inAppPipView.centerYAnchor),
                inAppPipTextBoxView.trailingAnchor.constraint(equalTo: inAppPipView.trailingAnchor, constant: -horizontalPadding),
                inAppPipTextBoxView.leadingAnchor.constraint(greaterThanOrEqualTo: inAppPipView.leadingAnchor, constant: horizontalPadding)
            ])
        case (.LEFT, .BOTTOM): // 좌측 하단
            NSLayoutConstraint.activate([
                inAppPipTextBoxView.bottomAnchor.constraint(equalTo: inAppPipView.bottomAnchor, constant: -verticalPadding),
                inAppPipTextBoxView.leadingAnchor.constraint(equalTo: inAppPipView.leadingAnchor, constant: horizontalPadding)
            ])
        case (.CENTER, .BOTTOM): // 중앙 하단 (디자인 가이드 기본값)
            NSLayoutConstraint.activate([
                inAppPipTextBoxView.bottomAnchor.constraint(equalTo: inAppPipView.bottomAnchor, constant: -verticalPadding),
                inAppPipTextBoxView.centerXAnchor.constraint(equalTo: inAppPipView.centerXAnchor),
                inAppPipTextBoxView.leadingAnchor.constraint(greaterThanOrEqualTo: inAppPipView.leadingAnchor, constant: horizontalPadding),
                inAppPipTextBoxView.trailingAnchor.constraint(lessThanOrEqualTo: inAppPipView.trailingAnchor, constant: -horizontalPadding)
            ])
        case (.RIGHT, .BOTTOM): // 우측 하단
            NSLayoutConstraint.activate([
                inAppPipTextBoxView.bottomAnchor.constraint(equalTo: inAppPipView.bottomAnchor, constant: -verticalPadding),
                inAppPipTextBoxView.trailingAnchor.constraint(equalTo: inAppPipView.trailingAnchor, constant: -horizontalPadding),
                inAppPipTextBoxView.leadingAnchor.constraint(greaterThanOrEqualTo: inAppPipView.leadingAnchor, constant: horizontalPadding)
            ])
        default:
            break
        }
        
        let configFontSize = CGFloat(textBoxConfig.font?.size ?? 12)
        let configFontColor = textBoxConfig.font?.color ?? "#ffffff"
        
        let configBorderRadius = CGFloat(textBoxConfig.box?.borderRadius ?? 8)
        let configBackgroundColor = textBoxConfig.box?.backgroundColor ?? "#000000"
        let configPaddingX = CGFloat(textBoxConfig.box?.paddingX ?? 8)
        let configPaddingY = CGFloat(textBoxConfig.box?.paddingY ?? 6)
        
        NSLayoutConstraint.activate([ inAppPipTextBoxView.heightAnchor.constraint(greaterThanOrEqualToConstant: 26) ])
        
        inAppPipTextBoxView.action(.setTitle(textBoxConfig.text))
        inAppPipTextBoxView.action(.updateStyle(
            fontSize: configFontSize,
            fontColor: configFontColor,
            roundedBoxColor: configBackgroundColor,
            borderRadius: configBorderRadius,
            paddingX: configPaddingX,
            paddingY: configPaddingY
        ))
    }
    
    @objc private func inAppPipCloseBtnTapped(sender: UIButton) {
        delegate?.didTouchCloseButton()
    }
    
    func updateCloseButtonDim() {
        pipDimLayer.frame = pipDim.frame
    }
    
    func setCloseButtonVisible(_ visible: Bool) {
        closeButton.isHidden = !visible
    }
    
    func setInAppViewVisible(_ visible: Bool) {
        inAppPipView.isHidden = !visible
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
    
    func updateOrientation(toLandscape: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 0) 전역 마스크 먼저 갱신
            ShopLiveCommon.setShopLiveOrientation(orientation: toLandscape ? [.landscapeLeft, .landscapeRight] : .portrait)
            
            if #available(iOS 16.0, *) {
                // 1) VC/내비 구조 갱신
                self.setNeedsUpdateOfSupportedInterfaceOrientations()
                self.navigationController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                
                let mask: UIInterfaceOrientationMask = toLandscape ? [.landscapeLeft, .landscapeRight] : .portrait
                // 2) iOS16+ 지오메트리 업데이트 (throw 처리)
                if let windowScene = (self.view.window?.windowScene) ?? (UIApplication.shared.connectedScenes.first as? UIWindowScene) {
                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: mask))
                }
                
                // 3) 회전 트리거
                UIViewController.attemptRotationToDeviceOrientation()
            } else {
                // iOS15 이하 폴백 (비권장이지만 실무적으로 사용)
                let orientation: UIDeviceOrientation = toLandscape ? .landscapeLeft : .portrait
                UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let currentOrientation: ShopLiveDefines.ShopLiveOrientaion = UIScreen.isLandscape_SL ? .landscape : .portrait
        guard ShopLiveController.windowStyle != .osPip else {
            ShopLiveController.shared.lastOrientaion = (currentOrientation, UIScreen.currentOrientation_SL.deviceOrientation_SL)
            return
        }
        
        if let popoverController = self.popoverController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: size.width * 0.5, y: size.height * 0.5, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        if ShopLiveController.shared.videoOrientation == .portrait {
            ShopLiveController.shared.webInstance?.alpha = 0
        }
        
        if ShopLiveController.shared.lastOrientaion.direction != currentOrientation {
            self.shopliveHideKeyboard_SL()
        }
        
        ShopLiveController.shared.lastOrientaion = (currentOrientation, UIScreen.currentOrientation_SL.deviceOrientation_SL)
        
        self.requestHideOrShowSnapShotImageView(isHidden: true)
        coordinator.animate { _ in
            ShopLiveController.shared.inRotating = true
            self.delegate?.changeOrientation(to: currentOrientation)
        } completion: { [weak self] _ in
            guard let self else { return }
            self.viewModel.checkIfSnapShotImageFrameNeedReCalculation()
            ShopLiveController.shared.inRotating = false
            self.delegate?.finishRotation()
        }
    }
    
    func openOSShareSheet(url: URL?) {
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
        self.snapShotImageView.isHidden = true
    }
    
    func takeSnapShot(completion: (() -> ())? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewModel.checkIfSnapShotImageFrameNeedReCalculation()
            ShopLiveController.shared.getSnapShot { image in
                self.calculateSnapShotImageViewContentMode(image: image)
                if let image = image {
                    self.snapShotImageView.image = image
                }
                completion?()
            }
        }
    }
    
    private func calculateSnapShotImageViewContentMode(image: UIImage?) {
        guard let image = image else { return }
        guard let resizeMode = self.viewModel.getResizeMode(), resizeMode == .FIT else {
            self.snapShotImageView.contentMode = .scaleAspectFill
            return
        }
        let viewSize = self.snapShotImageView.frame.size
        let imageSize = image.size
                
        if viewSize.width > viewSize.height { //가로모드 방송
            self.snapShotImageView.contentMode = imageSize.width > imageSize.height ? .scaleAspectFit: .scaleAspectFill
        }
        else { //세로모드 방송
            self.snapShotImageView.contentMode = imageSize.height > imageSize.width ? .scaleAspectFit: .scaleAspectFill
        }
    }
    
    
    func getIsSnapShotHidden() -> Bool {
        return snapShotImageView.isHidden
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
    
    func setStatusBarVisiblityOnFullScreen(isVisible: Bool) {
        self.statusBarVisibility = isVisible
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func getStatusBarVisibilityOnFullScreen() -> Bool {
        return self.statusBarVisibility
    }
}
extension LiveStreamViewController: ShopLivePlayerDelegate {
    var identifier: String {
        return "LiveStreamViewController"
    }
    
    func updatedValue(key: ShopLivePlayerObserveValue) {
        
    }
}
extension LiveStreamViewController: LiveStreamViewModelDelegate {
    
    func requestHideOrShowSnapShotImageView(isHidden: Bool) {
        self.snapShotImageView.isHidden = isHidden
    }
    
    func requestHideOrShowBackgroundPosterImageWebView(isHidden: Bool) {
        self.backgroundPosterImageWebView.isHidden = isHidden
    }
    
    func requestTakeSnapShotView() {
        self.takeSnapShot()
    }
    
    func reloadWebView(with url: URL) {
        if let currentUrl = overlayView.getCurrentUrl(), currentUrl == url {
            return
        }
        else {
            self.overlayView.reload(with: url)
        }
    }
    
    func setIsOsPipFailedHasOccured(hasOccured: Bool) {
        viewModel.setIsOsPipFailedHasOccured(hasOccured: hasOccured)
    }
    
    func sendNetworkCapabilityOnChanged(networkCapability: String) {
        self.sendNetworkCapabilityChangedToWeb(capability: networkCapability)
    }
    
    func getCurrentWebViewUrl() -> URL? {
        return self.overlayView.getCurrentUrl()
    }
    
    func requestHideOrShowLoading(isHidden: Bool) {
        self.processLoadingIndicator(isHidden: isHidden)
    }
    
    private func processLoadingIndicator(isHidden: Bool){
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
    
    func updateSnapShotImageViewFrameWithRatio(ratio: CGSize) {
        guard ShopLiveController.shared.campaignStatus != .close else { return }
        if let widthAnc = self.snapShotWidthAnc,
           let heightAnc = self.snapShotheightAnc,
           playerView.frame.width > 10,
           playerView.frame.height > 10 {
            
            if ratio.width == 0 || ratio.height == 0 {
                return
            }
            self.snapShotImageView.isHidden = false
            
            var newHeightAnc: NSLayoutConstraint?
            var newWidthAnc: NSLayoutConstraint?
            
            if floor(ratio.height) == floor(playerView.frame.height) {
                
                if (ratio.width) > playerView.frame.width {
                    newHeightAnc = snapShotImageView.heightAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: 1)
                    newWidthAnc = snapShotImageView.widthAnchor.constraint(equalTo: playerView.widthAnchor)
                }
                else {
                    guard needSnapShotReDraw(base: playerView.frame.height, isHorizontal: false, ratio: ratio.width / ratio.height) else { return }
                    newHeightAnc = snapShotImageView.heightAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: 1)
                    newWidthAnc = snapShotImageView.widthAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: ratio.width / ratio.height)
                }
            }
            else if floor(ratio.width) == floor(playerView.frame.width) {
                if ratio.height > playerView.frame.height {
                    newWidthAnc = snapShotImageView.widthAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 1)
                    newHeightAnc = snapShotImageView.heightAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: 1)
                }
                else {
                    guard needSnapShotReDraw(base: playerView.frame.width, isHorizontal: true, ratio: ratio.height / ratio.width) else { return }
                    newWidthAnc = snapShotImageView.widthAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 1)
                    newHeightAnc = snapShotImageView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: ratio.height / ratio.width)
                }
            }
            else if ShopLiveController.shared.videoRatio.width > ShopLiveController.shared.videoRatio.height {
                let standardRatio = ShopLiveController.shared.videoRatio.width / ShopLiveController.shared.videoRatio.height
                let videoRatio = ratio.width / ratio.height
                if standardRatio > videoRatio {
                    guard needSnapShotReDraw(base: playerView.frame.height, isHorizontal: false, ratio: ratio.width / ratio.height) else { return }
                    newHeightAnc = snapShotImageView.heightAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: 1)
                    newWidthAnc = snapShotImageView.widthAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: ratio.width / ratio.height)
                }
                else {
                    guard needSnapShotReDraw(base: playerView.frame.width, isHorizontal: true, ratio: ratio.height / ratio.width) else { return }
                    
                    newWidthAnc = snapShotImageView.widthAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 1)
                    newHeightAnc = snapShotImageView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: ratio.height / ratio.width)
                }
            }
            else {
                let standardRatio = ShopLiveController.shared.videoRatio.height / ShopLiveController.shared.videoRatio.width
                let videoRatio = ratio.height / ratio.width
                if standardRatio > videoRatio {
                    guard needSnapShotReDraw(base: playerView.frame.height, isHorizontal: false, ratio: ratio.width / ratio.height) else { return }
                    newHeightAnc = snapShotImageView.heightAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: 1)
                    newWidthAnc = snapShotImageView.widthAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: ratio.width / ratio.height)
                }
                else {
                    guard needSnapShotReDraw(base: playerView.frame.width, isHorizontal: true, ratio: ratio.height / ratio.width) else { return }
                    newWidthAnc = snapShotImageView.widthAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 1)
                    newHeightAnc = snapShotImageView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: ratio.height / ratio.width)
                }
            }
            
            widthAnc.isActive = false
            heightAnc.isActive = false
            snapShotImageView.removeConstraints([widthAnc,heightAnc])
            self.snapShotheightAnc = newHeightAnc
            self.snapShotWidthAnc = newWidthAnc
            self.snapShotheightAnc?.isActive = true
            self.snapShotWidthAnc?.isActive = true
        }
    }
    
    private func needSnapShotReDraw(base: CGFloat, isHorizontal: Bool, ratio: CGFloat) -> Bool {
        let oldSize = CGSize.init(width: floor(snapShotImageView.frame.size.width), height: floor(snapShotImageView.frame.size.height))
        var newSize : CGSize
        if isHorizontal {
            newSize = .init(width: floor(base), height: floor(base * ratio))
        }
        else {
            newSize = .init(width: floor(base * ratio), height: floor(base))
        }
        return oldSize != newSize
    }
    
    
    //shopliveBase에서 play()함수 호출 되었을때, snapShot image 날리면서, backgroundPoster다시 visible 처리 
    func refreshSnapShotImageViewAndBackgroundPosterImageWebViewWhenPlayCalled() {
        snapShotImageView.image = nil
        backgroundPosterImageWebView.isHidden = false
    }
    
    //가로 전체 화면 -> 가로 전체 화면, 채팅 나와 있을때, 플레이어 크기가 제대로 잡히지 않아서 일단 그냥 없애버리는 식으로 진행
    func refreshSnapShotImageViewWhenPlayerViewFrameUpdatedFromWebAndBlock() {
        snapShotImageView.image = nil
        viewModel.setBlockSnapShotWhenPlayerViewFrameUpdatedByWeb(block: true)
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.viewModel.setBlockSnapShotWhenPlayerViewFrameUpdatedByWeb(block: false)
        }
    }
    
    func updateInAppPipDisplayLayout(_ model: InAppPipDisplaysModel?) {
        
        print("updateInAppPipDisplayLayout is Called")
        
        if let badge = model?.badge {
            setInAppPipBadge(badge)
        }
        
        if let textBox = model?.textBox {
            setInAppPipTextBox(textBox)
        }
        
    }
    
}
//MARK: - ViewSetUp functions
extension LiveStreamViewController {
    private func setUpBackgroundPosterImageWebView() {
        self.view.addSubview(backgroundPosterImageWebView)
        
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
        
        NSLayoutConstraint.activate([ topConstraint, leftConstraint, rightConstraint, bottomConstraint, centxConstraint, centYConstraint ])
    }
    
    private func setupSnapshotView() {
        self.view.addSubview(snapShotImageView)
        
        let centerXConstraint = snapShotImageView.centerXAnchor.constraint(equalTo: playerView.centerXAnchor)
        let centerYConstraint = snapShotImageView.centerYAnchor.constraint(equalTo: playerView.centerYAnchor)
        
        let widthConstraint = snapShotImageView.widthAnchor.constraint(equalTo: playerView.widthAnchor)
        let heightConstraint = snapShotImageView.heightAnchor.constraint(equalTo: playerView.heightAnchor)

        snapShotWidthAnc = widthConstraint
        snapShotheightAnc = heightConstraint
        NSLayoutConstraint.activate([ centerXConstraint, centerYConstraint, widthConstraint, heightConstraint ])
    }
    
    func setupPlayerView() {
        view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.playerLayer?.player = playerView.player
        playerView.playerLayer?.needsDisplayOnBoundsChange = true
        
        ShopLiveController.shared.playerItem?.player = playerView.player
        if let playerLayer = playerView.playerLayer {
            ShopLiveController.shared.playerItem?.playerLayer? = playerLayer
        }
        
        playerTopConstraint = playerView.topAnchor.constraint(equalTo: view.topAnchor)
        playerLeadingConstraint = playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        playerRightConstraint = playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        playerBottomConstraint = playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([playerTopConstraint, playerLeadingConstraint, playerRightConstraint, playerBottomConstraint])
    }
    
    
    func setupOverayWebview() {
        let overlayView = OverlayWebView(with: webViewConfiguration, removeStaticInstanceWithDeinit: true)
        overlayView.setupOverlayWebView()
        overlayView.webviewUIDelegate = self
        overlayView.delegate = self

        view.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
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
            chatInputBG.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        self.view.addConstraints([
            NSLayoutConstraint(item: chatInputBG, attribute: .top, relatedBy: .equal, toItem: self.chatInputView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: chatInputBG, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        ])
        
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
    }

    private func setupIndicator() {
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
