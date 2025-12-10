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
    
    private var shareSheetWindow: UIWindow?

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
        view.imageView?.contentMode = .scaleAspectFit
        view.addTarget(self, action: #selector(inAppPipCloseBtnTapped), for: .touchUpInside)
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
    
    private var closeButtonBlurView: UIView?
    
    private var inAppPipBadgeConstraint: [NSLayoutConstraint] = []
    private var closeButtonConstraints: [NSLayoutConstraint] = []
    private var closeButtonBlurViewConstraints: [NSLayoutConstraint] = []
    
    private let badgeHeightRatio: CGFloat = 0.15
    private let maxBadgeHeight: CGFloat = 26
    
    private let minTextBoxHeight: CGFloat = 26

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
            return
        }
        
        guard inAppPipView.frame.width > 0 else {
            return
        }
        
        if !inAppPipBadgeConstraint.isEmpty {
            NSLayoutConstraint.deactivate(inAppPipBadgeConstraint)
        }
        
        // inApp PIP width 값의 0.15배가 26보다 높을 경우 badge의 height는 26보다 커지면 안되기에 min 처리
        let calculatedBadgeHeight = inAppPipView.frame.width * badgeHeightRatio
        let multiplier = min(calculatedBadgeHeight, maxBadgeHeight)
        
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
        shareSheetWindow?.isHidden = true
        shareSheetWindow?.rootViewController = nil
        shareSheetWindow = nil
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
            pipDim.leadingAnchor.constraint(equalTo: inAppPipView.leadingAnchor),
            pipDim.trailingAnchor.constraint(equalTo: inAppPipView.trailingAnchor),
            pipDim.topAnchor.constraint(equalTo: inAppPipView.topAnchor),
        ])
        
        inAppPipView.addSubview(inAppPipBadgeView)
        inAppPipView.addSubview(inAppPipTextBoxView)
        
        inAppPipView.addSubview(closeButton)
        
        if let closeButtonConfig = viewModel.getInAppPipConfiguration()?.closeButtonConfig {
            updateCloseButtonConfig(closeButtonConfig)
        } else {
            updateCloseButtonConfig(
                ShopLiveCloseButtonConfig(
                    position: .topLeft,
                    width: 30,
                    height: 30,
                    offsetX: 3,
                    offsetY: 3,
                    color: .white,
                    shadowOffsetX: nil,
                    shadowOffsetY: nil,
                    shadowBlur: nil,
                    shadowBlurStyle: nil,
                    shadowColor: nil,
                    imageStr: nil
                )
            )
        }
        
        self.view.bringSubviewToFront(inAppPipView)
    }
    
    private func setInAppPipBadge(_ badgeConfig: InAppPipDisplayEntity) {
        
        let horizontalAlignment = badgeConfig.layout.horizontalToAlignment() ?? .RIGHT
        let verticalAlignment = badgeConfig.layout.verticalToAlignment() ?? .TOP
        
        
        let horizontalPadding = badgeConfig.padding.horizontal
        let verticalPadding = badgeConfig.padding.vertical
        
        let constraints = makeInAppPipConstraints(
            for: inAppPipBadgeView,
            in: inAppPipView,
            horizontalAlignment: horizontalAlignment,
            verticalAlignment: verticalAlignment,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding
        )
        
        let configMaxWidth = CGFloat(badgeConfig.size?.maxWidth ?? 112)
        
        inAppPipBadgeConstraint = [
            inAppPipBadgeView.widthAnchor.constraint(lessThanOrEqualToConstant: configMaxWidth)
        ]
        
        NSLayoutConstraint.activate(constraints + inAppPipBadgeConstraint)
        
        inAppPipBadgeView.action(.hiddenBadge(!badgeConfig.active))
        inAppPipBadgeView.action(.setBadge(badgeConfig.imageUrl))
        
        inAppPipBadgeView.action(
            .setAlignment(
                useCloseButton: viewModel.getInAppPipConfiguration()?.useCloseButton ?? false,
                horizontalAlignment: horizontalAlignment,
                verticalAlignment: verticalAlignment,
            )
        )
    }
    
    private func setInAppPipTextBox(_ textBoxConfig: InAppPipDisplayEntity) {
        
        let horizontal = textBoxConfig.layout.horizontalToAlignment() ?? .RIGHT
        let vertical = textBoxConfig.layout.verticalToAlignment() ?? .TOP
        
        let horizontalPadding = textBoxConfig.padding.horizontal
        let verticalPadding = textBoxConfig.padding.vertical
        
        let constraints = makeInAppPipConstraints(
            for: inAppPipTextBoxView,
            in: inAppPipView,
            horizontalAlignment: horizontal,
            verticalAlignment: vertical,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding
        )
        
        let configFontSize = CGFloat(textBoxConfig.font?.size ?? 12)
        let configFontColor = textBoxConfig.font?.color ?? "#ffffff"
        
        let configBorderRadius = CGFloat(textBoxConfig.box?.borderRadius ?? 8)
        let configBackgroundColor = textBoxConfig.box?.backgroundColor ?? "#000000"
        let configPaddingX = CGFloat(textBoxConfig.box?.paddingX ?? 8)
        let configPaddingY = CGFloat(textBoxConfig.box?.paddingY ?? 6)
        
        NSLayoutConstraint.activate(constraints + [ inAppPipTextBoxView.heightAnchor.constraint(greaterThanOrEqualToConstant: minTextBoxHeight) ])
        
        inAppPipTextBoxView.action(.hiddenTextBox(!textBoxConfig.active))
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
    
    private func makeInAppPipConstraints(
        for subview: UIView,
        in superview: UIView,
        horizontalAlignment: InAppPipDisplayHorizontalAlignment,
        verticalAlignment: InAppPipDisplayVerticalAlignment,
        horizontalPadding: CGFloat,
        verticalPadding: CGFloat
    ) -> [NSLayoutConstraint] {
        switch (horizontalAlignment, verticalAlignment) {
        case (.LEFT, .TOP):
            return [
                subview.topAnchor.constraint(equalTo: superview.topAnchor, constant: verticalPadding),
                subview.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: horizontalPadding),
                subview.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -horizontalPadding)
            ]
        case (.CENTER, .TOP):
            return [
                subview.topAnchor.constraint(equalTo: superview.topAnchor, constant: verticalPadding),
                subview.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                subview.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor, constant: horizontalPadding),
                subview.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -horizontalPadding)
            ]
        case (.RIGHT, .TOP):
            return [
                subview.topAnchor.constraint(equalTo: superview.topAnchor, constant: verticalPadding),
                subview.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -horizontalPadding),
                subview.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor, constant: horizontalPadding)
            ]
        case (.LEFT, .CENTER):
            return [
                subview.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                subview.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: horizontalPadding),
                subview.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -horizontalPadding)
            ]
        case (.CENTER, .CENTER):
            return [
                subview.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                subview.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                subview.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor, constant: horizontalPadding),
                subview.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -horizontalPadding)
            ]
        case (.RIGHT, .CENTER):
            return [
                subview.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                subview.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -horizontalPadding),
                subview.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor, constant: horizontalPadding)
            ]
        case (.LEFT, .BOTTOM):
            return [
                subview.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -verticalPadding),
                subview.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: horizontalPadding),
                subview.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -horizontalPadding)
            ]
        case (.CENTER, .BOTTOM):
            return [
                subview.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -verticalPadding),
                subview.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                subview.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor, constant: horizontalPadding),
                subview.trailingAnchor.constraint(lessThanOrEqualTo: superview.trailingAnchor, constant: -horizontalPadding)
            ]
        case (.RIGHT, .BOTTOM):
            return [
                subview.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -verticalPadding),
                subview.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -horizontalPadding),
                subview.leadingAnchor.constraint(greaterThanOrEqualTo: superview.leadingAnchor, constant: horizontalPadding)
            ]
        }
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
            
            ShopLiveCommon.setShopLiveOrientation(orientation: toLandscape ? [.landscapeLeft, .landscapeRight] : .portrait)
            
            if #available(iOS 16.0, *) {
                self.setNeedsUpdateOfSupportedInterfaceOrientations()
                self.navigationController?.setNeedsUpdateOfSupportedInterfaceOrientations()
                
                let mask: UIInterfaceOrientationMask = toLandscape ? [.landscapeLeft, .landscapeRight] : .portrait
                if let windowScene = (self.view.window?.windowScene) ?? (UIApplication.shared.connectedScenes.first as? UIWindowScene) {
                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: mask))
                }
                
                UIViewController.attemptRotationToDeviceOrientation()
            } else {
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
        
        guard let decodeUrl = urlString.trimmingCharacters(in: .whitespacesAndNewlines).removingPercentEncoding,
              let shareUrl = URL(string: decodeUrl) else { return }

        let shareWindow = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            if let windowScene = self.view.window?.windowScene {
                shareWindow.windowScene = windowScene
            }
        }
        shareWindow.windowLevel = .statusBar // ShopLiveWindow (.statusBar - 1) 보다 높음
        shareWindow.backgroundColor = .clear
        
        let hostVC = UIViewController()
        hostVC.view.backgroundColor = .clear
        shareWindow.rootViewController = hostVC
        shareWindow.makeKeyAndVisible()
        self.shareSheetWindow = shareWindow
        
        let shareItems: [Any] = [shareUrl]
        let activityViewController = SLActivityViewController(activityItems: shareItems, applicationActivities: nil)
        
        // iPad popover 설정
        if UIDevice.isIpad {
            if let popover = activityViewController.popoverPresentationController {
                popover.sourceView = hostVC.view
                popover.sourceRect = CGRect(x: hostVC.view.bounds.midX, y: hostVC.view.bounds.midY, width: 1, height: 1)
                popover.permittedArrowDirections = []
            }
        }
        
        activityViewController.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.shareSheetWindow?.isHidden = true
            self?.shareSheetWindow?.rootViewController = nil
            self?.shareSheetWindow = nil
            self?.view.window?.makeKey()
        }
        
        hostVC.present(activityViewController, animated: true, completion: nil)
    }
    
    func updateCloseButtonConfig(_ config: ShopLiveCloseButtonConfig?) {
        guard let config else {
            updateCloseButtonConstraints()
            return
        }
        updateCloseButtonConstraints(config: config)
        
        let width = config.width ?? 36
        let height = config.height ?? 36
        let targetSize = CGSize(width: width, height: height)
                
        if let imageStr = config.imageStr, !imageStr.isEmpty {
            if let imageUrl = URL(string: imageStr) {
                URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            guard let self,
                                  let resizedImage = image.resizeImageTo_SL(size: targetSize)?.withRenderingMode(.alwaysTemplate) else { return }
                            self.closeButton.setImage(resizedImage, for: .normal)
                            self.applyBlurAndShadowEffect(with: resizedImage, config: config)
                        }
                    } else {
                        DispatchQueue.main.async {
                            guard let self,
                                  let resizedImage = ShopLiveSDKAsset.closebutton.image.resizeImageTo_SL(size: targetSize)?.withRenderingMode(.alwaysTemplate) else { return }
                            self.closeButton.setImage(resizedImage, for: .normal)
                            self.applyBlurAndShadowEffect(with: resizedImage, config: config)
                        }
                    }
                }.resume()
            } else {
                guard let resizedImage = ShopLiveSDKAsset.closebutton.image.resizeImageTo_SL(size: targetSize)?.withRenderingMode(.alwaysTemplate) else { return }
                closeButton.setImage(resizedImage, for: .normal)
                applyBlurAndShadowEffect(with: resizedImage, config: config)
            }
        } else {
            guard let resizedImage = ShopLiveSDKAsset.closebutton.image.resizeImageTo_SL(size: targetSize)?.withRenderingMode(.alwaysTemplate) else { return }
            closeButton.setImage(resizedImage, for: .normal)
            applyBlurAndShadowEffect(with: resizedImage, config: config)
        }
        closeButton.tintColor = config.color
    }
    
    private func applyBlurAndShadowEffect(with image: UIImage, config: ShopLiveCloseButtonConfig) {
        closeButtonBlurView?.removeFromSuperview()
        closeButtonBlurView = nil
        closeButton.backgroundColor = .clear
        guard let superview = closeButton.superview else { return }

        let shadowBlur = config.shadowBlur ?? 0
        let shadowBlurStyle = config.shadowBlurStyle ?? .normal
        let shadowColor = config.shadowColor ?? .clear
        
        var targetImage = image.withRenderingMode(.alwaysTemplate)
        targetImage = self.imageWithBlurMask(image: targetImage, style: shadowBlurStyle, color: shadowColor) ?? UIImage()
        
        let copiedImageView = UIImageView(image: targetImage)
        copiedImageView.translatesAutoresizingMaskIntoConstraints = false
        copiedImageView.contentMode = .scaleAspectFit
        copiedImageView.tintColor = shadowColor
        copiedImageView.backgroundColor = .clear
        superview.insertSubview(copiedImageView, belowSubview: closeButton)
        
        copiedImageView.layer.masksToBounds = false
        copiedImageView.clipsToBounds = false
        
        let constraints = [
            copiedImageView.topAnchor.constraint(equalTo: closeButton.topAnchor, constant: config.shadowOffsetY ?? 0),
            copiedImageView.leadingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: config.shadowOffsetX ?? 0),
            copiedImageView.widthAnchor.constraint(equalTo: closeButton.widthAnchor),
            copiedImageView.heightAnchor.constraint(equalTo: closeButton.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        closeButtonBlurViewConstraints = constraints
        
        configureShadowLayer(for: copiedImageView, config: config, shadowBlur: shadowBlur, shadowColor: shadowColor)
        closeButtonBlurView = copiedImageView
        scheduleShadowPathUpdate(for: copiedImageView, config: config)
    }
    
    // MARK: - Shadow Configuration
    
    private func configureShadowLayer(for imageView: UIImageView, config: ShopLiveCloseButtonConfig, shadowBlur: CGFloat, shadowColor: UIColor) {
        let width = config.width ?? imageView.bounds.width
        let height = config.height ?? imageView.bounds.height
        let cornerRadius = min(width, height) / 2
        let opacity: Float = Float(min(shadowBlur / 10, 1))
        imageView.layer.shadowOpacity = opacity
        imageView.layer.shadowRadius = cornerRadius
        imageView.layer.shadowColor = shadowColor.cgColor
        imageView.layer.shadowOffset = .zero
    }
    
    private func scheduleShadowPathUpdate(for imageView: UIImageView, config: ShopLiveCloseButtonConfig) {
        imageView.layer.shadowPath = nil
        
        DispatchQueue.main.async { [weak imageView] in
            guard let imageView = imageView, imageView.superview != nil else { return }
            
            let width = config.width ?? imageView.bounds.width
            let height = config.height ?? imageView.bounds.height
            guard width > 0, height > 0 else { return }
            
            let cornerRadius = min(width, height) / 2
            let shadowRect = CGRect(x: 0, y: 0, width: width, height: height)
            imageView.layer.shadowPath = UIBezierPath(
                roundedRect: shadowRect,
                cornerRadius: cornerRadius
            ).cgPath
        }
    }
    
    private func updateCloseButtonConstraints(config: ShopLiveCloseButtonConfig? = nil) {
        if !closeButtonConstraints.isEmpty {
            NSLayoutConstraint.deactivate(closeButtonConstraints)
            closeButtonConstraints.removeAll()
        }
        
        let defaultConfig = ShopLiveCloseButtonConfig()
        let position = config?.position ?? defaultConfig.position ?? .topLeft
        let offsetX = config?.offsetX ?? defaultConfig.offsetX ?? 0
        let offsetY = config?.offsetY ?? defaultConfig.offsetY ?? 0
        let width = config?.width ?? defaultConfig.width ?? 36
        let height = config?.height ?? defaultConfig.height ?? 36
        
        var constraints: [NSLayoutConstraint] = []
        
        switch position {
        case .topLeft:
            constraints.append(closeButton.leadingAnchor.constraint(equalTo: inAppPipView.leadingAnchor, constant: offsetX))
            constraints.append(closeButton.topAnchor.constraint(equalTo: inAppPipView.topAnchor, constant: offsetY))
        case .topRight:
            constraints.append(closeButton.trailingAnchor.constraint(equalTo: inAppPipView.trailingAnchor, constant: offsetX))
            constraints.append(closeButton.topAnchor.constraint(equalTo: inAppPipView.topAnchor, constant: offsetY))
        }
        
        constraints.append(closeButton.widthAnchor.constraint(equalToConstant: width))
        constraints.append(closeButton.heightAnchor.constraint(equalToConstant: height))
        
        closeButtonConstraints = constraints
        NSLayoutConstraint.activate(closeButtonConstraints)
    }
    
    func imageWithBlurMask(image: UIImage?, style: ShopLiveBlurMaskStyle, color: UIColor?) -> UIImage? {
        guard let image = image else { return nil }
        
        let radius: CGFloat
        switch style {
        case .solid:
            radius = 2
        default:
            radius = 4
        }
        
        guard let inputCIImage = CIImage(image: image), radius > 0 else { return image }
        
        let clampFilter = CIFilter(name: "CIAffineClamp")
        clampFilter?.setValue(inputCIImage, forKey: kCIInputImageKey)
        clampFilter?.setValue(CGAffineTransform.identity, forKey: kCIInputTransformKey)
        guard let clampedImage = clampFilter?.outputImage else { return image }
        
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(clampedImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(radius, forKey: kCIInputRadiusKey)
        guard var blurredImage = blurFilter?.outputImage else { return image }
        
        if let color = color {
            let colorFilter = CIFilter(name: "CIConstantColorGenerator")
            let ciColor = CIColor(color: color)
            colorFilter?.setValue(ciColor, forKey: kCIInputColorKey)
            
            if let colorOutput = colorFilter?.outputImage {
                let colorTintFilter = CIFilter(name: "CISourceInCompositing")
                colorTintFilter?.setValue(colorOutput, forKey: kCIInputImageKey)
                colorTintFilter?.setValue(blurredImage, forKey: kCIInputBackgroundImageKey)
                if let tintedBlur = colorTintFilter?.outputImage {
                    blurredImage = tintedBlur
                }
            }
        }
        
        var outputImage: CIImage?
        switch style {
        case .normal, .solid:
            outputImage = blurredImage
            
        case .inner:
            let compositor = CIFilter(name: "CISourceInCompositing")
            compositor?.setValue(blurredImage, forKey: kCIInputImageKey)
            compositor?.setValue(inputCIImage, forKey: kCIInputBackgroundImageKey)
            outputImage = compositor?.outputImage
            
        case .outer:
            let compositor = CIFilter(name: "CISourceOutCompositing")
            compositor?.setValue(blurredImage, forKey: kCIInputImageKey)
            compositor?.setValue(inputCIImage, forKey: kCIInputBackgroundImageKey)
            outputImage = compositor?.outputImage
        }
        
        guard let finalImage = outputImage else { return image }
        let padding = radius * 3
        let renderRect = inputCIImage.extent.insetBy(dx: -padding, dy: -padding)
        
        let ciContext = CIContext(options: nil)
        guard let cgImage = ciContext.createCGImage(finalImage, from: renderRect) else {
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
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
    
    func updateInAppPipDisplayLayout(_ model: InAppPipDisplaysEntity?) {

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
