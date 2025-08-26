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

final class LiveStreamViewController: SLViewController {

    @objc dynamic lazy var viewModel: LiveStreamViewModel = LiveStreamViewModel()
    weak var delegate: LiveStreamViewControllerDelegate?

    var webViewConfiguration: WKWebViewConfiguration?
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
    var backgroundPosterImageWebView: ShopLiveBackgroundPosterImageWebView?
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
    
    var snapShotWidthAnc : NSLayoutConstraint?
    var snapShotheightAnc : NSLayoutConstraint?
    
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
        view.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        return view
    }()

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
        self.view.accessibilityIdentifier = "live-stream-viewcontroller"
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
        ShopLiveLogger.memoryLog("LiveStreamViewController deinited")
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
        closeButton.leadingAnchor.constraint(equalTo: inAppPipView.leadingAnchor).isActive = true
        closeButton.topAnchor.constraint(equalTo: inAppPipView.topAnchor).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        self.view.bringSubviewToFront(inAppPipView)
    }
    
    @objc private func inAppPipCloseBtnTapped(sender : UIButton) {
        delegate?.didTouchCloseButton()
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
            inAppPipView.isHidden = !visible
        } else {
            self.view.bringSubviewToFront(inAppPipView)
            inAppPipView.isHidden = !visible
            updateCloseButtonDim()
        }
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
        
        self.backgroundPosterImageWebView?.layoutIfNeeded()
        self.snapShotImageView?.layoutIfNeeded()
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
            ShopLiveController.shared.webInstance?.alpha = 0
        }
        
        if ShopLiveController.shared.lastOrientaion.direction != currentOrientation {
            self.shopliveHideKeyboard_SL()
        }
        
        if UIScreen.currentOrientation.deviceOrientation.isLandscape {
            ShopLiveController.shared.prevLandscapeOrientation = UIScreen.currentOrientation.deviceOrientation
        }
        
        ShopLiveController.shared.lastOrientaion = (currentOrientation, UIScreen.currentOrientation.deviceOrientation)
        
        self.requestHideOrShowSnapShotImageView(isHidden: true)
        coordinator.animate { _ in
            ShopLiveController.shared.inRotating = true
            self.delegate?.changeOrientation(to: currentOrientation)
        } completion: { _ in
            self.viewModel.checkIfSnapShotImageFrameNeedReCalculation()
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
            self.viewModel.checkIfSnapShotImageFrameNeedReCalculation()
            ShopLiveController.shared.getSnapShot { image in
                self.calculateSnapShotImageViewContentMode(image : image)
                if let image = image {
                    self.snapShotImageView?.image = image
                }
                completion?()
            }
        }
    }
    
    private func calculateSnapShotImageViewContentMode(image : UIImage?) {
        guard let image = image else { return }
        guard let resizeMode = self.viewModel.getResizeMode(), resizeMode == .FIT else {
            self.snapShotImageView?.contentMode = .scaleAspectFill
            return
        }
        guard let viewSize = self.snapShotImageView?.frame.size else { return }
        let imageSize = image.size
                
        if viewSize.width > viewSize.height { //가로모드 방송
            self.snapShotImageView?.contentMode = imageSize.width > imageSize.height ? .scaleAspectFit : .scaleAspectFill
        }
        else { //세로모드 방송
            self.snapShotImageView?.contentMode = imageSize.height > imageSize.width ? .scaleAspectFit : .scaleAspectFill
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
    
    func requestHideOrShowSnapShotImageView(isHidden : Bool) {
        self.snapShotImageView?.isHidden = isHidden
    }
    
    func requestHideOrShowBackgroundPosterImageWebView(isHidden: Bool) {
        self.backgroundPosterImageWebView?.isHidden = isHidden
    }
    
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
    
    func updateSnapShotImageViewFrameWithRatio(ratio : CGSize) {
        guard ShopLiveController.shared.campaignStatus != .close else { return }
        if let snapShotImageView = self.snapShotImageView,
           let widthAnc = self.snapShotWidthAnc,
           let heightAnc = self.snapShotheightAnc,
           let playerView = self.playerView,
           playerView.frame.width > 10,
           playerView.frame.height > 10 {
            
            if ratio.width == 0 || ratio.height == 0 {
                return
            }
            self.snapShotImageView?.isHidden = false
            
            var newHeightAnc : NSLayoutConstraint?
            var newWidthAnc : NSLayoutConstraint?
            
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
    
    private func needSnapShotReDraw(base : CGFloat, isHorizontal : Bool, ratio : CGFloat) -> Bool {
        guard let snapShotView = self.snapShotImageView else {
            return false
        }
        let oldSize = CGSize.init(width: floor(snapShotView.frame.size.width), height: floor(snapShotView.frame.size.height))
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
        snapShotImageView?.image = nil
        backgroundPosterImageWebView?.isHidden = false
    }
    
    //가로 전체 화면 -> 가로 전체 화면, 채팅 나와 있을때, 플레이어 크기가 제대로 잡히지 않아서 일단 그냥 없애버리는 식으로 진행
    func refreshSnapShotImageViewWhenPlayerViewFrameUpdatedFromWebAndBlock() {
        snapShotImageView?.image = nil
        viewModel.setBlockSnapShotWhenPlayerViewFrameUpdatedByWeb(block: true)
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.viewModel.setBlockSnapShotWhenPlayerViewFrameUpdatedByWeb(block: false)
        }
    }
    
}
//MARK: - ViewSetUp functions
extension LiveStreamViewController {
    private func setUpBackgroundPosterImageWebView() {
        guard let playerView = playerView else { return }
        self.backgroundPosterImageWebView = ShopLiveBackgroundPosterImageWebView()
        guard let backgroundPosterImageWebView = self.backgroundPosterImageWebView else { return }
        self.view.addSubview(backgroundPosterImageWebView)
        backgroundPosterImageWebView.translatesAutoresizingMaskIntoConstraints = false
        backgroundPosterImageWebView.isOpaque = false
        backgroundPosterImageWebView.backgroundColor = .black
        backgroundPosterImageWebView.layer.masksToBounds = true
        backgroundPosterImageWebView.clipsToBounds = true
       
        
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
        
        let widthConstraint = snapShotImageView.widthAnchor.constraint(equalTo: playerView.widthAnchor,multiplier: 1)
        let heightConstraint = snapShotImageView.heightAnchor.constraint(equalTo: playerView.heightAnchor,multiplier: 1)

        snapShotWidthAnc = widthConstraint
        snapShotheightAnc = heightConstraint
        NSLayoutConstraint.activate([ centerXConstraint, centerYConstraint, widthConstraint, heightConstraint ])

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
        
        ShopLiveController.shared.playerItem?.player = playerView.player
        if let playerLayer = playerView.playerLayer {
            ShopLiveController.shared.playerItem?.playerLayer? = playerLayer
        }
        
        playerTopConstraint     = playerView.topAnchor.constraint(equalTo: view.topAnchor)
        playerLeadingConstraint = playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        playerRightConstraint   = playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        playerBottomConstraint  = playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([playerTopConstraint, playerLeadingConstraint, playerRightConstraint, playerBottomConstraint])
    }
    
    
    func setupOverayWebview() {
        let overlayView = OverlayWebView(with: webViewConfiguration, removeStaticInstanceWithDeinit: true)
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

