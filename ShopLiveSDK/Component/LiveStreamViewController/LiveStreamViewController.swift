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
    var playerView: ShopLivePlayerView = .init()
    
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

        layer0.locations = [0, 1]
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
        return layer0
    }()
    lazy var pipDim: SLLabel = {
        let view = SLLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.addSublayer(pipDimLayer)
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var closeButton: SLButton = {
        let view = SLButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        let bundle = Bundle(for: type(of: self))
        let closebuttonImage = UIImage(named: "closebutton", in: bundle, compatibleWith: nil)
        view.setImage(closebuttonImage, for: .normal)
        view.addTarget(self, action: #selector(didTouchCloseButton), for: .touchUpInside)
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

    var playerLayer: AVPlayerLayer {
        return playerView.playerLayer
    }
    
    override func removeFromParent() {
        super.removeFromParent()
        overlayView?.delegate = nil

        overlayView?.removeFromSuperview()
        backgroundPosterImageWebView?.removeFromSuperview()
        playerView.removeFromSuperview()

        overlayView = nil
        backgroundPosterImageWebView = nil
        
        tearDownLiveStreamViewController()
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
        updateCloseButtonDim()
    }
    
    deinit {
        
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
    }

    func updateChattingWriteView() {
        chatInputView.updateChattingWriteView()
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
    
    
    
    func updateImageConstraint(from: CGRect) {
        guard let bgImageView = self.backgroundPosterImageWebView else { return }
        let ratio = ShopLiveController.shared.videoRatio.width / ShopLiveController.shared.videoRatio.height
        let screenSize = UIScreen.main.bounds
        let imageFrame = CGSize(width: screenSize.width - from.origin.x - from.size.width, height: screenSize.height - from.origin.y - from.size.height)
        
        let imageFrameRatio = imageFrame.width / imageFrame.height
        var posterConstraints : UIEdgeInsets = .zero
        var snapShotConstraints : UIEdgeInsets = .zero
        
        guard ShopLiveController.windowStyle != .inAppPip else {
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
                let videoZoomed: Bool = self.playerView.playerLayer.videoGravity == .resizeAspectFill
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
        pipDimLayer.bounds = inAppPipView.bounds.insetBy(dx: -0.5*inAppPipView.bounds.size.width, dy: -0.5*inAppPipView.bounds.size.height)
        pipDimLayer.position = inAppPipView.center
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
        shopliveHideKeyboard()
    }
    
    func showBackgroundPoster() {
        backgroundPosterImageWebView?.isHidden = false
    }
    
    func setCloseDimLayerVisible(_ visible: Bool) {
        self.inAppPipView.layer.masksToBounds = !visible
        self.pipDim.layer.masksToBounds = !visible
        self.pipDimLayer.masksToBounds = !visible
    }

    override func shopliveHideKeyboard() {
        super.shopliveHideKeyboard()
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
    
    func updateVideoFit(centerCrop: Bool = false, immediately: Bool = false, imageUpdate: Bool = true) {
        self.playerView.playerLayer.videoGravity = centerCrop ? .resizeAspectFill : .resizeAspect
        playerTopConstraint.constant = 0
        playerLeadingConstraint.constant = 0
        playerRightConstraint.constant = 0
        playerBottomConstraint.constant = 0
        if imageUpdate {
            self.updateImageConstraint(from: .zero)
        }
        
        if immediately {
            self.playerView.setNeedsLayout()
            self.playerView.layoutIfNeeded()
        }
    }
    
    func changeVideoGravity(centerCrop: Bool) {
        if let playerFrame = UIScreen.isLandscape ? ( ShopLiveController.shared.videoExpanded ? ShopLiveController.shared.videoFrame.landscape.expanded : ShopLiveController.shared.videoFrame.landscape.standard) : ShopLiveController.shared.videoFrame.portrait {
            self.updatePlayerFrame(centerCrop: ShopLiveController.shared.videoCenterCrop, playerFrame: playerFrame, immediately: false)

            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) { [weak self] in
                self?.updateVideoConstraint()
            } completion: { _ in

            }

        }
    }
    
    func updateVideoFrame(immeadiately: Bool, fitTopArea: Bool = false) {
        guard !ShopLiveController.shared.isPreview else { return }
        
        if ShopLiveController.shared.videoOrientation == .landscape {
            if ShopLiveController.windowStyle == .inAppPip {
                self.updateVideoFit(centerCrop: true, immediately: immeadiately)
            } else {
                if fitTopArea {
                    setVideoDefaultFrame()
                    return
                }
                if let playerFrame = UIScreen.isLandscape ? ( ShopLiveController.shared.videoExpanded ? ShopLiveController.shared.videoFrame.landscape.expanded : ShopLiveController.shared.videoFrame.landscape.standard) : ShopLiveController.shared.videoFrame.portrait {
                    
                    self.updatePlayerFrame(centerCrop: ShopLiveController.shared.videoCenterCrop, playerFrame: playerFrame, immediately: immeadiately)
                }
            }
        } else {
            self.updateVideoFit(centerCrop: true, immediately: immeadiately)
            self.playerView.playerLayer.videoGravity = UIScreen.isLandscape ? .resizeAspect : (UIDevice.isIpad ? (ShopLiveConfiguration.UI.keepAspectOnTabletPortrait ? .resizeAspect : .resizeAspectFill) : .resizeAspectFill)
            self.updateImageConstraint(from: .zero)
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
            self.updatePlayerFrame()
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
            playerView.playerLayer.videoGravity = UIScreen.isLandscape ? .resizeAspect : (UIDevice.isIpad ? (ShopLiveConfiguration.UI.keepAspectOnTabletPortrait ? .resizeAspect : .resizeAspectFill) : .resizeAspectFill)
            ShopLiveController.shared.webInstance?.alpha = 0
        }
        
        if ShopLiveController.shared.lastOrientaion.direction != currentOrientation {
            self.shopliveHideKeyboard()
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
}

extension LiveStreamViewController {
    func hideSnapShotView(){
        print("[HASSAN LOG] hideSnapShotView")
        self.snapShotImageView?.isHidden = true
    }
    
    func takeSnapShot(completion : (() -> ())? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            ShopLiveController.shared.getSnapShot { image in
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
}
extension LiveStreamViewController : ShopLivePlayerDelegate {
    var identifier: String {
        return "LiveStreamViewController"
    }
    
    func updatedValue(key: ShopLivePlayerObserveValue) {
        
    }
    
    func processLoadingIndicator(hide : Bool){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if hide == false {
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
}
extension LiveStreamViewController : LiveStreamViewModelDelegate {
    func requestTakeSnapShotView() {
        self.takeSnapShot()
    }
    
    func reloadWebView(with url: URL) {
        self.overlayView?.reload(with: url)
    }
    
}
//MARK: - ViewSetUp functions
extension LiveStreamViewController {
    private func setUpBackgroundPosterImageWebView() {
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
    
    private func setupPlayerView() {
        view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.playerLayer.player = playerView.player
        playerView.playerLayer.needsDisplayOnBoundsChange = true
        
        if ShopLiveController.shared.videoOrientation == .portrait {
            if UIScreen.isLandscape {
                playerView.playerLayer.videoGravity = .resizeAspect
            }
            else if UIDevice.isIpad && ShopLiveConfiguration.UI.keepAspectOnTabletPortrait {
                playerView.playerLayer.videoGravity = .resizeAspect
            }
            else if UIDevice.isIpad && ShopLiveConfiguration.UI.keepAspectOnTabletPortrait == false {
                playerView.playerLayer.videoGravity = .resizeAspectFill
            }
            else {
                playerView.playerLayer.videoGravity = .resizeAspectFill
            }
        } else {
            playerView.playerLayer.videoGravity = .resizeAspect
        }
        
        
        ShopLiveController.shared.playerItem?.player = playerView.player
        ShopLiveController.shared.playerItem?.playerLayer = playerLayer
       
        playerTopConstraint     = playerView.topAnchor.constraint(equalTo: view.topAnchor)
        playerLeadingConstraint = playerView.leftAnchor.constraint(equalTo: view.leftAnchor)
        playerRightConstraint   = playerView.rightAnchor.constraint(equalTo: view.rightAnchor)
        playerBottomConstraint  = playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([playerTopConstraint, playerLeadingConstraint, playerRightConstraint, playerBottomConstraint])
    }
    
    
    func setupOverayWebview() {

        let overlayView = OverlayWebView(with: webViewConfiguration)
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
        if ShopLiveConfiguration.UI.isCustomIndicator {
            self.playerView.addSubviews(customIndicator)
            let customIndicatorWidth = NSLayoutConstraint.init(item: customIndicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
            let customIndicatorHeight = NSLayoutConstraint.init(item: customIndicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
            let customIndicatorCenterXConstraint = NSLayoutConstraint.init(item: customIndicator, attribute: .centerX, relatedBy: .equal, toItem: self.playerView, attribute: .centerX, multiplier: 1.0, constant: 0)
            let customIndicatorCenterYConstraint = NSLayoutConstraint.init(item: customIndicator, attribute: .centerY, relatedBy: .equal, toItem: self.playerView, attribute: .centerY, multiplier: 1.0, constant: 0)

            customIndicator.addConstraints([customIndicatorWidth, customIndicatorHeight])
            self.playerView.addConstraints([customIndicatorCenterXConstraint, customIndicatorCenterYConstraint])

            customIndicator.configure(images: ShopLiveConfiguration.UI.customIndicatorImages)
        } else {
            self.playerView.addSubviews(indicatorView)
            let indicatorWidth = NSLayoutConstraint.init(item: indicatorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
            let indicatorHeight = NSLayoutConstraint.init(item: indicatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
            let centerXConstraint = NSLayoutConstraint.init(item: indicatorView, attribute: .centerX, relatedBy: .equal, toItem: self.playerView, attribute: .centerX, multiplier: 1.0, constant: 0)
            let centerYConstraint = NSLayoutConstraint.init(item: indicatorView, attribute: .centerY, relatedBy: .equal, toItem: self.playerView, attribute: .centerY, multiplier: 1.0, constant: 0)

            indicatorView.addConstraints([indicatorWidth, indicatorHeight])
            self.playerView.addConstraints([centerXConstraint, centerYConstraint])
            indicatorView.color = ShopLiveConfiguration.UI.color

        }
        
        self.playerView.bringSubviewToFront(indicatorView)
    }
    
}
