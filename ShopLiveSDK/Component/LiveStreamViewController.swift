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

internal final class LiveStreamViewController: UIViewController {

    @objc dynamic lazy var viewModel: LiveStreamViewModel = LiveStreamViewModel()
    weak var delegate: LiveStreamViewControllerDelegate?

    var webViewConfiguration: WKWebViewConfiguration?

    private var inBuffering: Bool = true
    private var needSeek: Bool = false
    private var requireRetryCheck = false

    private var overlayView: OverlayWebView?
    private var imageView: UIImageView?
    private var snapShotView: UIImageView?
    private var voiceOverIsOn: Bool = UIAccessibility.isVoiceOverRunning
    
    private weak var popoverController: UIPopoverPresentationController?
    
    private lazy var indicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
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

    private var playerView: ShopLivePlayerView = .init()
    
    private var playerTopConstraint: NSLayoutConstraint!
    private var playerLeadingConstraint: NSLayoutConstraint!
    private var playerRightConstraint: NSLayoutConstraint!
    private var playerBottomConstraint: NSLayoutConstraint!
    
    private var posterTopContraint: NSLayoutConstraint?
    private var posterLeftContraint: NSLayoutConstraint?
    private var posterRightContraint: NSLayoutConstraint?
    private var posterBottomContraint: NSLayoutConstraint?
    
    private var snapshotTopContraint: NSLayoutConstraint?
    private var snapshotLeftContraint: NSLayoutConstraint?
    private var snapshotRightContraint: NSLayoutConstraint?
    private var snapshotBottomContraint: NSLayoutConstraint?

    private var pausedResumeCount: Int = 0
    
    private var playTimeObserver: Any?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var playerLayer: AVPlayerLayer {
        return playerView.playerLayer
    }

    override func removeFromParent() {
        super.removeFromParent()
        overlayView?.delegate = nil

        overlayView?.removeFromSuperview()
        imageView?.removeFromSuperview()
        playerView.removeFromSuperview()

        overlayView = nil
        imageView = nil
        
        tearDownLiveStreamViewController()
    }

    private func addPlayTimeObserver() {
        ShopLiveLogger.debugLog("addPlayTimeObserver")
        removePlaytimeObserver()
        let time = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        playTimeObserver = ShopLiveController.player?.addPeriodicTimeObserver(forInterval: time, queue: nil) { (time) in
            let curTime = CMTimeGetSeconds(time)

            ShopLiveController.shared.currentPlayTime = Int64(curTime)
            ShopLiveController.webInstance?.sendEventToWeb(event: .onVideoTimeUpdated, curTime)
        }
    }

    private func removePlaytimeObserver() {
        if let playTimeObserver = self.playTimeObserver {
            ShopLiveController.player?.removeTimeObserver(playTimeObserver)
            self.playTimeObserver = nil
        }
    }

    @objc func audioRouteChangeListener(notification: NSNotification) {
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt

        let audioSession = AVAudioSession.sharedInstance()
        var isEarphoneHeadphone: Bool = false
        let currentRoute = audioSession.currentRoute
        if currentRoute.outputs.count != 0 {
            let earphones: [AVAudioSession.Port] = [.headphones, .headsetMic, .bluetoothA2DP, .bluetoothHFP]
            currentRoute.outputs.forEach { description in
                if !earphones.filter({$0 == description.portType}).isEmpty {
                    isEarphoneHeadphone = true
                    return
                }
            }
        }
        
        switch audioRouteChangeReason {
        case AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue:
            if isEarphoneHeadphone {
                #if MUSINSA
                delegate?.log(name: "audio_gain", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, parameter: [:])
                #endif
                updateHeadPhoneStatus(plugged: true)
            }
        case AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue:
            if !isEarphoneHeadphone {
#if MUSINSA
                delegate?.log(name: "audio_loss", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, parameter: [:])
#endif
                updateHeadPhoneStatus(plugged: false)
            }
        default:
            break
        }
    }

    private func updateHeadPhoneStatus(plugged: Bool) {
        if !ShopLiveConfiguration.SoundPolicy.keepPlayVideoOnHeadphoneUnplugged {
            ShopLiveController.playControl = plugged ? .resume : .pause
        } else {
            ShopLiveController.playControl = .resume
        }
    }

    private func setupAudioConfig() {
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(audioRouteChangeListener(notification:)),
                name: AVAudioSession.routeChangeNotification,
                object: nil)
        NotificationCenter.default.addObserver(self,
                           selector: #selector(handleInterruption),
                           name: AVAudioSession.interruptionNotification,
                           object: AVAudioSession.sharedInstance())

    }
    
    private func teardownAudioConfig() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
    }

    @objc func handleInterruption(notification: Notification) {
        ShopLiveLogger.debugLog("handleInterruption")

        guard let userInfo = notification.userInfo,
                let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                    return
            }

          if type == .began {
#if MUSINSA
              delegate?.log(name: "audio_loss", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, parameter: [:])
#endif
            ShopLiveController.playControl = .pause
          } else {
              guard userInfo[AVAudioSessionInterruptionOptionKey] != nil else {
                return
            }

            do {
                try AVAudioSession.sharedInstance().setActive(true)
                ShopLiveLogger.debugLog("interruption setActive")
            }
            catch let error {
                ShopLiveLogger.debugLog("interruption setActive Failed error: \(error.localizedDescription)")
            }

            guard ShopLiveConfiguration.SoundPolicy.autoResumeVideoOnCallEnded else {
                return
            }
#if MUSINSA
              delegate?.log(name: "audio_gain", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, parameter: [:])
#endif
            if ShopLiveController.isReplayMode {
                ShopLiveController.player?.play()
            } else {
                ShopLiveController.webInstance?.sendEventToWeb(event: .reloadBtn, false, false)
                
                ShopLiveController.playControl = .resume
            }
          }
    }

    var hasKeyboard: Bool = false
    private func setKeyboard(notification: Notification) {
        guard let keyboardFrameEndUserInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
              let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom else { return }

        let keyboardScreenEndFrame = keyboardFrameEndUserInfo.cgRectValue
        let keyboard = self.view.convert(keyboardScreenEndFrame, from: self.view.window)
        let height = self.view.frame.size.height
        var isHiddenView = true
        switch notification.name.rawValue {
        case "UIKeyboardWillHideNotification":
            lastKeyboardHeight = 0
            if chatInputView.isFocused() && (ShopLiveController.windowStyle == ShopLiveWindowStyle.normal) {
                self.hasKeyboard = true
                isHiddenView = false
                self.chatInputView.isHidden = false
                self.chatInputBG.isHidden = false
            }

            let param: Dictionary = Dictionary<String, Any>.init(dictionaryLiteral: ("value", hasKeyboard ? "\(self.chatInputView.frame.height)px" : "0px"), ("keyboard", hasKeyboard))
            ShopLiveController.webInstance?.sendEventToWeb(event: .setChatListMarginBottom, param.toJson())
            ShopLiveController.webInstance?.sendEventToWeb(event: .hiddenChatInput)
            chatConstraint.constant = 0
            break
        case "UIKeyboardWillShowNotification":
            hasKeyboard = (keyboard.origin.y + keyboard.size.height) > height
            lastKeyboardHeight = keyboardScreenEndFrame.height
            chatConstraint.constant = -(keyboardScreenEndFrame.height - bottomPadding)
            let param: Dictionary = Dictionary<String, Any>.init(dictionaryLiteral: ("value", "\(Int((hasKeyboard ? 0 : lastKeyboardHeight) + self.chatInputView.frame.height))px"), ("keyboard", hasKeyboard))
            ShopLiveController.webInstance?.sendEventToWeb(event: .setChatListMarginBottom, param.toJson())
            isHiddenView = false
        default:
            break
        }
        let options = UIView.AnimationOptions(rawValue: curve << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            if isHiddenView {
                self.chatInputView.isHidden = isHiddenView
                self.chatInputBG.isHidden = isHiddenView
            }
            self.view.layoutIfNeeded()
        } completion: { (isComplete) in
            if isComplete {
                self.chatInputView.focusOut()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLiveStreamViewController()
    }
    
    deinit {
    }

    private func setupView() {
        view.backgroundColor = .black

        setupBackgroundImageView()
        setupPlayerView()
        setupSnapshotView()
        setupOverayWebview()
        setupChatInputView()
        setupIndicator()
    }

    func play() {
        viewModel.play()
    }

    func pause() {
        if !ShopLiveController.isReplayMode, ShopLiveController.shared.windowStyle == .osPip {
            ShopLiveController.shared.needReload = true
        }
        ShopLiveController.player?.pause()
        ShopLiveController.isReplayMode ? ShopLiveController.webInstance?.sendEventToWeb(event: .setIsPlayingVideo(isPlaying: false), false) : ShopLiveController.webInstance?.sendEventToWeb(event: .reloadBtn, true, true)
    }

    func stop() {
        viewModel.stop()
    }

    func resume() {
        if ShopLiveController.shared.windowStyle == .osPip, !ShopLiveController.shared.lastPipPlaying {
            return
        }
        ShopLiveController.isReplayMode ? ShopLiveController.webInstance?.sendEventToWeb(event: .setIsPlayingVideo(isPlaying: true), true) : ShopLiveController.webInstance?.sendEventToWeb(event: .reloadBtn, false, false)
        viewModel.resume()
    }

    func reload() {
        ShopLiveController.overlayUrl = playUrl
    }

    func didCompleteDownLoadCoupon(with couponId: String) {
        overlayView?.didCompleteDownloadCoupon(with: couponId)
    }

    func didCompleteDownLoadCoupon(with couponResult: ShopLiveCouponResult) {
        overlayView?.didCompleteDownloadCoupon(with: couponResult)
    }
    
    @available(*, deprecated, message: "use didCompleteDownLoadCoupon(with couponResult: ShopLiveCouponResult) instead")
    func didCompleteDownLoadCoupon(with couponResult: CouponResult) {
        overlayView?.didCompleteDownloadCoupon(with: couponResult)
    }

    func didCompleteCustomAction(with id: String) {
        overlayView?.didCompleteCustomAction(with: id)
    }

    func didCompleteCustomAction(with customActionResult: ShopLiveCustomActionResult) {
        overlayView?.didCompleteCustomAction(with: customActionResult)
    }
    
    @available(*, deprecated, message: "use didCompleteCustomAction(with customActionResult: ShopLiveCustomActionResult) instead")
    func didCompleteCustomAction(with customActionResult: CustomActionResult) {
        overlayView?.didCompleteCustomAction(with: customActionResult)
    }

    func hideBackgroundPoster() {
        imageView?.isHidden = true
        shopliveHideKeyboard()
    }

    func showBackgroundPoster() {
        imageView?.isHidden = false
    }

    override func shopliveHideKeyboard() {
        super.shopliveHideKeyboard()
        self.chatInputView.isHidden = true
        self.chatInputBG.isHidden = true
    }

    func onTerminated() {
        overlayView?.closeWebSocket()
    }

    func onBackground() {
        ShopLiveLogger.debugLog("onBackground()")
        guard ShopLiveController.windowStyle != .osPip else { return }
        ShopLiveController.playControl = .pause
        overlayView?.sendEventToWeb(event: .onBackground)
    }

    func onForeground() {
        ShopLiveLogger.debugLog("onForeground()")
        guard ShopLiveController.windowStyle != .osPip else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if ShopLiveController.timeControlStatus == .paused {
                if !ShopLiveController.isReplayMode {
                    ShopLiveController.webInstance?.sendEventToWeb(event: .reloadBtn, false, false)
                    ShopLiveController.playControl = .resume
                }
            } else {
                if !ShopLiveController.isReplayMode {
                    ShopLiveController.shared.needSeek = true
                    ShopLiveController.playControl = .resume
                }
            }

            self.overlayView?.sendEventToWeb(event: .onForeground)
        }
    }

    private func setupSnapshotView() {
        let snapImageView = UIImageView()
        snapImageView.isHidden = true
        snapImageView.contentMode = .scaleAspectFill
        playerView.addSubview(snapImageView)
        snapImageView.translatesAutoresizingMaskIntoConstraints = false
        let centerXConstraint: NSLayoutConstraint = .init(item: snapImageView, attribute: .centerX, relatedBy: .equal, toItem: playerView, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint: NSLayoutConstraint = .init(item: snapImageView, attribute: .centerY, relatedBy: .equal, toItem: playerView, attribute: .centerY, multiplier: 1, constant: 0)
        let topConstraint: NSLayoutConstraint = .init(item: snapImageView, attribute: .top, relatedBy: .equal, toItem: playerView, attribute: .top, multiplier: 1, constant: 0)
        let leftConstraint: NSLayoutConstraint = .init(item: snapImageView, attribute: .left, relatedBy: .equal, toItem: playerView, attribute: .left, multiplier: 1, constant: 0)
        let bottomConstraint: NSLayoutConstraint = .init(item: snapImageView, attribute: .bottom, relatedBy: .equal, toItem: playerView, attribute: .bottom, multiplier: 1, constant: 0)
        let rightConstraint: NSLayoutConstraint = .init(item: snapImageView, attribute: .right, relatedBy: .equal, toItem: playerView, attribute: .right, multiplier: 1, constant: 0)

        topConstraint.priority = .init(rawValue: 999)
        leftConstraint.priority = .init(rawValue: 999)
        rightConstraint.priority = .init(rawValue: 999)
        bottomConstraint.priority = .init(rawValue: 999)
        
        snapshotTopContraint = topConstraint
        snapshotLeftContraint = leftConstraint
        snapshotRightContraint = rightConstraint
        snapshotBottomContraint = bottomConstraint
        
        playerView.addConstraints([
            topConstraint, leftConstraint, rightConstraint, bottomConstraint, centerXConstraint, centerYConstraint
        ])
        
        snapImageView.layer.masksToBounds = true
        snapImageView.clipsToBounds = true
        self.snapShotView = snapImageView
    }
    
    private func updateImageConstraint(from: CGRect) {
        if let bgImageView = self.imageView {
            let ratio = ShopLiveController.shared.videoRatio.width / ShopLiveController.shared.videoRatio.height
            let screenSize = UIScreen.main.bounds
            let imageFrame = CGSize(width: screenSize.width - from.origin.x - from.size.width, height: screenSize.height - from.origin.y - from.size.height)
            
            let imageFrameRatio = imageFrame.width / imageFrame.height

            guard ShopLiveController.shared.windowStyle != .inAppPip else { return }
            
            if ShopLiveController.shared.videoOrientation == .portrait {
                if !ShopLiveConfiguration.UI.keepAspectOnTabletPortrait {
                    if UIScreen.isLandscape {
                        self.imageView?.clipsToBounds = true
                        self.imageView?.layer.masksToBounds = true
                        let letterSpacing = (imageFrame.width - (imageFrame.height * (ShopLiveController.shared.videoRatio.width / ShopLiveController.shared.videoRatio.height))) / 2
                        posterTopContraint?.constant = 0
                        posterBottomContraint?.constant = 0
                        posterLeftContraint?.constant = letterSpacing
                        posterRightContraint?.constant = -letterSpacing
                        
                        snapshotTopContraint?.constant = 0
                        snapshotBottomContraint?.constant = 0
                        snapshotLeftContraint?.constant = letterSpacing
                        snapshotRightContraint?.constant = -letterSpacing
                    } else {
                        self.imageView?.clipsToBounds = false
                        self.imageView?.layer.masksToBounds = false
                        
                        let letterSpacing = (imageFrame.width - (imageFrame.height * (ShopLiveController.shared.videoRatio.width / ShopLiveController.shared.videoRatio.height))) / 2
                        posterTopContraint?.constant = 0
                        posterBottomContraint?.constant = 0
                        posterLeftContraint?.constant = letterSpacing
                        posterRightContraint?.constant = -letterSpacing
                        
                        snapshotTopContraint?.constant = 0
                        snapshotBottomContraint?.constant = 0
                        snapshotLeftContraint?.constant = letterSpacing
                        snapshotRightContraint?.constant = -letterSpacing
                    }
                } else {
                    if UIScreen.isLandscape {
                        let letterSpacing = (imageFrame.width - (imageFrame.height * (ShopLiveController.shared.videoRatio.width / ShopLiveController.shared.videoRatio.height))) / 2
                        posterTopContraint?.constant = 0
                        posterBottomContraint?.constant = 0
                        posterLeftContraint?.constant = letterSpacing
                        posterRightContraint?.constant = -letterSpacing
                        
                        snapshotTopContraint?.constant = 0
                        snapshotBottomContraint?.constant = 0
                        snapshotLeftContraint?.constant = letterSpacing
                        snapshotRightContraint?.constant = -letterSpacing
                    } else {
                        if imageFrameRatio == ratio {
                            posterTopContraint?.constant = 0
                            posterBottomContraint?.constant = 0
                            posterLeftContraint?.constant = 0
                            posterRightContraint?.constant = 0
                            
                            snapshotTopContraint?.constant = 0
                            snapshotBottomContraint?.constant = 0
                            snapshotLeftContraint?.constant = 0
                            snapshotRightContraint?.constant = 0
                        } else {
                            let letterSpacing = (imageFrame.width - (imageFrame.height * (ShopLiveController.shared.videoRatio.width / ShopLiveController.shared.videoRatio.height))) / 2
                            posterTopContraint?.constant = 0
                            posterBottomContraint?.constant = 0
                            posterLeftContraint?.constant = letterSpacing
                            posterRightContraint?.constant = -letterSpacing
                            
                            snapshotTopContraint?.constant = 0
                            snapshotBottomContraint?.constant = 0
                            snapshotLeftContraint?.constant = letterSpacing
                            snapshotRightContraint?.constant = -letterSpacing
                        }
                    }
                }
                #if EBAY
                    bgImageView.clipsToBounds = true
                    bgImageView.layer.masksToBounds = true
                #else
                if ShopLiveController.shared.videoOrientation == .portrait {
                    if ShopLiveConfiguration.UI.keepAspectOnTabletPortrait {
                        bgImageView.clipsToBounds = true
                        bgImageView.layer.masksToBounds = true
                    }
                } else {
                    bgImageView.clipsToBounds = true
                    bgImageView.layer.masksToBounds = true
                }
                #endif
            } else {
                self.imageView?.clipsToBounds = true
                self.imageView?.layer.masksToBounds = true
                if imageFrameRatio == ratio {
                    posterTopContraint?.constant = 0
                    posterBottomContraint?.constant = 0
                    posterLeftContraint?.constant = 0
                    posterRightContraint?.constant = 0
                    
                    snapshotTopContraint?.constant = 0
                    snapshotBottomContraint?.constant = 0
                    snapshotLeftContraint?.constant = 0
                    snapshotRightContraint?.constant = 0
                } else {
                    if imageFrameRatio < ratio  {
                        let letterSpacing = (imageFrame.height - (imageFrame.width * (ShopLiveController.shared.videoRatio.height / ShopLiveController.shared.videoRatio.width))) / 2
                        posterTopContraint?.constant = letterSpacing
                        posterBottomContraint?.constant = -letterSpacing
                        posterLeftContraint?.constant = 0
                        posterRightContraint?.constant = 0
                        
                        snapshotTopContraint?.constant = letterSpacing
                        snapshotBottomContraint?.constant = -letterSpacing
                        snapshotLeftContraint?.constant = 0
                        snapshotRightContraint?.constant = 0
                    } else {
                        let letterSpacing = (imageFrame.width - (imageFrame.height * (ShopLiveController.shared.videoRatio.width / ShopLiveController.shared.videoRatio.height))) / 2
                        posterTopContraint?.constant = 0
                        posterBottomContraint?.constant = 0
                        posterLeftContraint?.constant = letterSpacing
                        posterRightContraint?.constant = -letterSpacing
                        
                        snapshotTopContraint?.constant = 0
                        snapshotBottomContraint?.constant = 0
                        snapshotLeftContraint?.constant = letterSpacing
                        snapshotRightContraint?.constant = -letterSpacing
                    }
                }
            }
        }
    }
    
    private func setupBackgroundImageView() {
        let imageView = UIImageView()
        playerView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let ratio = ShopLiveController.shared.videoRatio.width / ShopLiveController.shared.videoRatio.height
        
        let centerXConstraint: NSLayoutConstraint = .init(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: playerView, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint: NSLayoutConstraint = .init(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: playerView, attribute: .centerY, multiplier: 1, constant: 0)
        let topConstraint: NSLayoutConstraint = .init(item: imageView, attribute: .top, relatedBy: .equal, toItem: playerView, attribute: .top, multiplier: 1, constant: 0)
        let leftConstraint: NSLayoutConstraint = .init(item: imageView, attribute: .left, relatedBy: .equal, toItem: playerView, attribute: .left, multiplier: 1, constant: 0)
        let bottomConstraint: NSLayoutConstraint = .init(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: playerView, attribute: .bottom, multiplier: 1, constant: 0)
        let rightConstraint: NSLayoutConstraint = .init(item: imageView, attribute: .right, relatedBy: .equal, toItem: playerView, attribute: .right, multiplier: 1, constant: 0)

        topConstraint.priority = .init(rawValue: 999)
        leftConstraint.priority = .init(rawValue: 999)
        rightConstraint.priority = .init(rawValue: 999)
        bottomConstraint.priority = .init(rawValue: 999)
        
        posterTopContraint = topConstraint
        posterLeftContraint = leftConstraint
        posterRightContraint = rightConstraint
        posterBottomContraint = bottomConstraint
        
        playerView.addConstraints([
            topConstraint, leftConstraint, rightConstraint, bottomConstraint, centerXConstraint, centerYConstraint
        ])

        #if EBAY
            imageView.clipsToBounds = true
            imageView.layer.masksToBounds = true
        #else
            if ShopLiveConfiguration.UI.keepAspectOnTabletPortrait {
                imageView.clipsToBounds = true
                imageView.layer.masksToBounds = true
            }
        #endif
        
        self.imageView = imageView
        
        playerView.sendSubviewToBack(imageView)
    }

    private let bottomItemSpacing: CGFloat = 21
    private func setupOverayWebview() {
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

    private func setupPlayerView() {
        playerView.playerLayer.player = playerView.player
        if ShopLiveController.shared.videoOrientation == .portrait {
            playerView.playerLayer.videoGravity = UIScreen.isLandscape ? .resizeAspect : (UIDevice.isIpad ? (ShopLiveConfiguration.UI.keepAspectOnTabletPortrait ? .resizeAspect : .resizeAspectFill) : .resizeAspectFill)
        } else {
            playerView.playerLayer.videoGravity = .resizeAspect
        }
        
        playerView.playerLayer.needsDisplayOnBoundsChange = true
        ShopLiveController.shared.playerItem?.player = playerView.player
        ShopLiveController.shared.playerItem?.playerLayer = playerLayer
        view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        
        playerTopConstraint = playerView.topAnchor.constraint(equalTo: view.topAnchor)
        playerLeadingConstraint = playerView.leftAnchor.constraint(equalTo: view.leftAnchor)
        playerRightConstraint = playerView.rightAnchor.constraint(equalTo: view.rightAnchor)
        playerBottomConstraint = playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([playerTopConstraint, playerLeadingConstraint, playerRightConstraint, playerBottomConstraint])
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        ShopLiveLogger.debugLog("viewWillTransition")
        
        guard ShopLiveController.windowStyle != .osPip else { return }
        
        if let popoverController = self.popoverController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: size.width * 0.5, y: size.height * 0.5, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        if ShopLiveController.shared.videoOrientation == .portrait {
            playerView.playerLayer.videoGravity = UIScreen.isLandscape ? .resizeAspect : (UIDevice.isIpad ? (ShopLiveConfiguration.UI.keepAspectOnTabletPortrait ? .resizeAspect : .resizeAspectFill) : .resizeAspectFill)
        }
        
        if !(ShopLiveController.shared.lastOrientaion == .landscape && UIScreen.isLandscape) {
            ShopLiveController.shared.videoCenterCrop = false
        }
        
        let currentOrientation: ShopLiveDefines.ShopLiveOrientaion = UIScreen.isLandscape ? .landscape : .portrait
        if ShopLiveController.shared.lastOrientaion != currentOrientation {
            self.shopliveHideKeyboard()
        }
        
        ShopLiveController.shared.lastOrientaion = currentOrientation
        
        coordinator.animate { _ in
            self.delegate?.changeOrientation(to: currentOrientation)
        } completion: { _ in
            self.delegate?.finishRotation()
        }
        
    }
    
    private var chatConstraint: NSLayoutConstraint!
    private lazy var chatInputView: ShopLiveChattingWriteView = {
        let chatView = ShopLiveChattingWriteView()
        chatView.isHidden = true
        chatView.translatesAutoresizingMaskIntoConstraints = false
        chatView.delegate = self
        return chatView
    }()

    private lazy var chatInputBG: UIView = {
            let chatBG = UIView()
            chatBG.translatesAutoresizingMaskIntoConstraints = false
            chatBG.backgroundColor = .white
            chatBG.isHidden = true
            return chatBG
        }()

    private var lastKeyboardHeight: CGFloat = 0

    private func setupChatInputView() {
        view.addSubview(chatInputView)

        chatConstraint = NSLayoutConstraint.init(item: chatInputView, attribute: .bottom, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0)
        let chatLeading = NSLayoutConstraint.init(item: chatInputView, attribute: .leading, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1.0, constant: 0)
        let chatTrailing = NSLayoutConstraint.init(item: chatInputView, attribute: .trailing, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .trailing, multiplier: 1.0, constant: 0)

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
            self.customIndicator.startAnimating()
        } else {
            self.playerView.addSubviews(indicatorView)
            let indicatorWidth = NSLayoutConstraint.init(item: indicatorView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
            let indicatorHeight = NSLayoutConstraint.init(item: indicatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
            let centerXConstraint = NSLayoutConstraint.init(item: indicatorView, attribute: .centerX, relatedBy: .equal, toItem: self.playerView, attribute: .centerX, multiplier: 1.0, constant: 0)
            let centerYConstraint = NSLayoutConstraint.init(item: indicatorView, attribute: .centerY, relatedBy: .equal, toItem: self.playerView, attribute: .centerY, multiplier: 1.0, constant: 0)

            indicatorView.addConstraints([indicatorWidth, indicatorHeight])
            self.playerView.addConstraints([centerXConstraint, centerYConstraint])
            indicatorView.color = ShopLiveConfiguration.UI.color

            indicatorView.startAnimating()
        }
        
        self.playerView.bringSubviewToFront(indicatorView)
    }

    private func loadOveray() {
        ShopLiveController.overlayUrl = playUrl
    }

    /**
        Initialize web client
            - Sending the required data using URL for Web Client initialization
     */
    private var playUrl: URL? {
        guard let baseUrl = viewModel.overayUrl else { return nil }
        let urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()

        if let authToken = viewModel.authToken, !authToken.isEmpty {
            queryItems.append(URLQueryItem(name: "tk", value: authToken))
        }
        
        if let name = viewModel.user?.name, !name.isEmpty {
            queryItems.append(URLQueryItem(name: "userName", value: name))
        }
        if let userId = viewModel.user?.id, !userId.isEmpty {
            queryItems.append(URLQueryItem(name: "userId", value: userId))
        }
        if let gender = viewModel.user?.gender, gender != .unknown {
            queryItems.append(URLQueryItem(name: "gender", value: gender.description))
        }
        if let age = viewModel.user?.age, age > 0 {
            queryItems.append(URLQueryItem(name: "age", value: String(age)))
        }

        if let additional = viewModel.user?.getParams(), !additional.isEmpty {
            additional.forEach { (key: String, value: String) in
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }

        queryItems.append(URLQueryItem(name: "osType", value: "i"))
        queryItems.append(URLQueryItem(name: "osVersion", value: ShopLiveDefines.osVersion))
        queryItems.append(URLQueryItem(name: "device", value: ShopLiveDefines.deviceIdentifier))

        if let scm: String = ShopLiveController.shared.shareScheme {
            queryItems.append(URLQueryItem(name: "shareUrl", value: scm))
        }
        
        queryItems.append(URLQueryItem(name: "appVersion", value: ShopLiveConfiguration.AppPreference.appVersion ?? UIApplication.appVersion()))

        if ShopLiveConfiguration.AppPreference.useLocalLanding {
            let bundle = Bundle(for: type(of: self))
            guard let bundleMainUrl = bundle.url(forResource: "web/ebay_sdk", withExtension: "html") else {
                return nil
            }

            guard let params = URLUtil.query(queryItems) else {
                return bundleMainUrl
            }
            
            guard let url = URL(string: "?" + params, relativeTo: bundleMainUrl) else {
                return bundleMainUrl
            }

            ShopLiveLogger.debugLog("play url: \(url)")
            return url
        } else {
            let urlString: String = ShopLiveConfiguration.AppPreference.landingUrl
            ShopLiveLogger.debugLog("shoplive landingUrl : \(urlString)")
            guard let params = URLUtil.query(queryItems) else {
                return URL(string: urlString)
            }

            guard let url = URL(string: urlString + "?" + params) else {

                return URL(string: urlString)
            }

            ShopLiveLogger.debugLog("play url: \(url)")
            return url
        }
    }

    func addObserver() {
        ShopLiveController.shared.addPlayerDelegate(delegate: self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(voiceOverStatusChanged), name: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil)
    }
    
    @objc func voiceOverStatusChanged() {
        self.voiceOverIsOn = UIAccessibility.isVoiceOverRunning
        self.updateVoiceOverStatus()
    }

    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func handleNotification(_ notification: Notification) {
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            guard chatInputView.isFocused() else { return }
            self.chatInputView.isHidden = false
            self.chatInputBG.isHidden = false
            self.setKeyboard(notification: notification)
            break
        case UIResponder.keyboardWillHideNotification:
            self.setKeyboard(notification: notification)
            break
        default:
            break
        }
    }

    private var retryTimer: Timer?
    private var retryCount: Int = 0
    private func resetRetry() {
        retryTimer?.invalidate()
        retryTimer = nil
        retryCount = 0
    }

    func handleRetryPlay() {
        resetRetry()
        if ShopLiveController.retryPlay {
            retryTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                self.retryCount += 1

                if ShopLiveController.windowStyle != .osPip {
                    if ShopLiveController.shared.streamUrl == nil {
                        self.resetRetry()
                        return
                    }

                    if (self.retryCount < 20 && self.retryCount % 2 == 0) || (self.retryCount >= 20 && self.retryCount % 5 == 0) {
                        if let videoUrl = ShopLiveController.streamUrl {
                            self.viewModel.updatePlayerItem(with: videoUrl)
                        } else {
                            ShopLiveController.retryPlay = false
                            ShopLiveController.shared.takeSnapShot = false
                        }
                    }
                } else {
                    if (self.retryCount < 20 && self.retryCount % 2 == 0) || (self.retryCount >= 20 && self.retryCount % 5 == 0) {
                        if !self.inBuffering {
                            ShopLiveController.shared.seekToLatest()
                            ShopLiveController.playControl = .resume
                            ShopLiveController.retryPlay = false
                            ShopLiveController.shared.takeSnapShot = false
                        }
                    }
                }
            }
        }
    }
    
    private func changeOrientation(toLandscape: Bool) {
        let orientation = toLandscape ? (UIScreen.isLandscape ? UIDevice.current.orientation.rawValue : UIInterfaceOrientation.landscapeRight.rawValue) : (UIScreen.isLandscape ? UIInterfaceOrientation.portrait.rawValue : UIDevice.current.orientation.rawValue)
        
        guard UIScreen.currentOrientation.deviceOrientation.rawValue != orientation else { return }
        
        UIDevice.current.setValue(orientation, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
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
        
        self.imageView?.layoutIfNeeded()
        self.snapShotView?.layoutIfNeeded()
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
        self.playerView.playerLayer.videoGravity = centerCrop ? .resizeAspectFill : .resizeAspect
    }
    
    func updateVideoFrame(immeadiately: Bool, fromPreview: Bool = false) {
        guard !ShopLiveController.shared.isPreview else { return }
        
        if ShopLiveController.shared.videoOrientation == .landscape {
            if ShopLiveController.windowStyle == .inAppPip {
                self.updateVideoFit(centerCrop: true, immediately: immeadiately)
            } else {
                if fromPreview {
                    setVideoDefaultFrame()
                }
                
                if let playerFrame = UIScreen.isLandscape ? ( ShopLiveController.shared.videoExpanded ? ShopLiveController.shared.videoFrame.landscape.expanded : ShopLiveController.shared.videoFrame.landscape.standard) : ShopLiveController.shared.videoFrame.portrait {
                    self.updatePlayerFrame(centerCrop: ShopLiveController.shared.videoCenterCrop, playerFrame: playerFrame, immediately: immeadiately)
                }
            }
        } else {
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
}

extension LiveStreamViewController: OverlayWebViewDelegate {
#if MUSINSA
    func log(name: String, feature: ShopLiveLog.Feature, campaign: String, parameter: [String : String]) {
        delegate?.log(name: name, feature: feature, campaign: campaign, parameter: parameter)
    }
#endif
    
    func updateVideoExpanded() {
        guard UIScreen.isLandscape, ShopLiveController.shared.videoOrientation == .landscape else { return }
        self.updateVideoFrame(immeadiately: false)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
        self.updateVideoConstraint()
        } completion: { _ in
            self.delegate?.resetPictureInPicture()
        }
    }
    
    func updateOrientation(toLandscape: Bool) {
        self.changeOrientation(toLandscape: toLandscape)
        
        if ShopLiveController.shared.newStartPlay {
            ShopLiveController.shared.newStartPlay = false
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                let param: Dictionary = Dictionary<String, Any>.init(dictionaryLiteral: ("top", UIScreen.safeArea.top), ("left", UIScreen.safeArea.left),
                                                                     ("right", UIScreen.safeArea.right), ("bottom", UIScreen.safeArea.bottom), ("orientation", UIScreen.currentOrientation.angle))
                
                self.sendCommandMessage(command: "SET_SAFE_AREA_MARGIN", payload: param)
            }
        }
    }
    
    func updatePlayerFrame(centerCrop: Bool = false, playerFrame: CGRect = .zero, immediately: Bool = false) {
        guard playerFrame != .zero else {
            updateVideoFit(centerCrop: centerCrop, immediately: immediately)
            return
        }
        
        self.playerView.playerLayer.videoGravity = centerCrop ? .resizeAspectFill : .resizeAspect
        
        playerTopConstraint.constant = playerFrame.origin.y
        playerLeadingConstraint.constant = playerFrame.origin.x
        playerRightConstraint.constant = -playerFrame.size.width
        playerBottomConstraint.constant = -playerFrame.size.height
        
        self.updateImageConstraint(from: playerFrame)
        if immediately {
            self.playerView.setNeedsLayout()
            self.playerView.layoutIfNeeded()
        }
    }
    
    func updateVideoConstraint() {
        self.playerView.layoutIfNeeded()
    }
    
    func handleReceivedCommand(_ command: String, with payload: Any?) {
        delegate?.handleReceivedCommand(command, with: payload)
    }

    func onSetUserName(_ payload: [String : Any]) {
        delegate?.onSetUserName(payload)
    }

    func didChangeCampaignStatus(status: String) {
        delegate?.didChangeCampaignStatus(status: status)
    }

    func onError(code: String, message: String) {
        delegate?.onError(code: code, message: message)
    }

    func didTouchCustomAction(id: String, type: String, payload: Any?) {
        ShopLiveLogger.debugLog("id \(id) type \(type) payload: \(String(describing: payload))")
        delegate?.didTouchCustomAction(id: id, type: type, payload: payload)
    }

    func shareAction(url: URL?) {
        guard let originUrl = url?.absoluteString as? NSString, let decodeUrl = originUrl.removingPercentEncoding, let shareUrl = URL(string: decodeUrl) else { return }

        let shareAll:[Any] = [shareUrl]
        let activityViewController = UIActivityViewController(activityItems: shareAll , applicationActivities: nil)
        popoverController = activityViewController.popoverPresentationController
        popoverController?.sourceView = self.view
        if UIDevice.isIpad {
            popoverController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController?.permittedArrowDirections = []
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }

    func didTouchShareButton(with url: URL?) {
        guard let custom = ShopLiveController.shared.customShareAction else {
            shareAction(url: url)
            return
        }
        custom()
    }

    func didTouchBlockView() {
        shopliveHideKeyboard()
    }

    func replay(with size: CGSize) {
        ShopLiveController.isReplayMode = true
        delegate?.replay(with: size)
    }

    func didTouchCoupon(with couponId: String) {
        delegate?.didTouchCoupon(with: couponId)
    }

    func didTouchMuteButton(with isMuted: Bool) {
        if !ShopLiveController.shared.isPreview {
            ShopLiveController.shared.isMuted = isMuted
        }
        
        ShopLiveController.player?.isMuted = ShopLiveController.shared.isPreview ? true : isMuted
    }

    func reloadVideo() {
        viewModel.resume()
    }

    func setVideoCurrentTime(to: CMTime) {
        viewModel.seek(to: to)
    }

    func didUpdatePoster(with url: URL) {
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: url) else { return }
            guard let image = UIImage(data: imageData) else { return }
            DispatchQueue.main.async {
                self.imageView?.image = image
            }
        }
    }

    func didUpdateVideo(with url: URL) {
        ShopLiveController.streamUrl = url
        ShopLiveController.player?.isMuted = ShopLiveController.shared.isPreview ? true : ShopLiveConfiguration.SoundPolicy.isMuted
        if ShopLiveController.isReplayMode, let time = ShopLiveController.shared.currentPlayTime {
            ShopLiveController.player?.seek(to: .init(value: time, timescale: 1))
        }
        showBackgroundPoster()
    }

    func didTouchPlayButton() {
        play()
    }

    func didTouchPauseButton() {
        pause()
    }

    func didTouchPlayButton(with isPlaying: Bool) {
        isPlaying ? play() : pause()
    }

    func didTouchNavigation(with url: URL) {
        delegate?.didTouchNavigation(with: url)
    }

    func updatePipStyle(with style: ShopLive.PresentationStyle) {
        overlayView?.updatePipStyle(with: style)
    }

    @objc func didTouchPipButton() {
        delegate?.didTouchPipButton()
    }

    @objc func didTouchCloseButton() {
        overlayView?.closeWebSocket()
        delegate?.didTouchCloseButton()
    }
    
    func handleCommand(_ command: String, with payload: Any?) {
        let interface = WebInterface.WebFunction.init(rawValue: command)
        switch interface  {
        case .setConf:
            let payload = payload as? [String : Any]
            let placeHolder = payload?["chatInputPlaceholderText"] as? String
            let sendText = payload?["chatInputSendText"] as? String
            let chatInputMaxLength = payload?["chatInputMaxLength"] as? Int
            let campaignInfo = payload?["campaignInfo"] as? [String : Any]
            
            if let videoAspectRatio = payload?["videoAspectRatio"] as? String {
                let parseRatio = videoAspectRatio.split(separator: ":")
                if parseRatio.isEmpty {
                    ShopLiveController.shared.videoRatio = ShopLiveDefines.defVideoRatio
                    ShopLiveController.shared.supportOrientation = .portrait
                } else {
                    if parseRatio.count == 2, let width = Int(parseRatio[0]), let height = Int(parseRatio[1]) {
                        ShopLiveController.shared.videoRatio = CGSize(width: width, height: height)
                        ShopLiveController.shared.supportOrientation = width > height ? .landscape : .portrait
                    } else {
                        ShopLiveController.shared.videoRatio = ShopLiveDefines.defVideoRatio
                        ShopLiveController.shared.supportOrientation = .portrait
                    }
                }
            } else {
                ShopLiveController.shared.videoRatio = ShopLiveDefines.defVideoRatio
                ShopLiveController.shared.supportOrientation = .portrait
            }
            
            if ShopLiveController.shared.windowStyle == .inAppPip || ShopLiveController.shared.windowStyle == .normal {
                delegate?.updatePictureInPicture()
            }
            
            ShopLiveController.shared.swipeEnabled = true
            
            if let isReplay = payload?["isReplay"] as? Bool {
                ShopLiveController.isReplayMode = isReplay
            }
            ShopLiveConfiguration.UI.chatInputPlaceholderString = placeHolder ?? "chat.placeholder".localizedString()
            ShopLiveConfiguration.UI.chatInputSendString = sendText ?? "chat.send.title".localizedString()
            ShopLiveConfiguration.UI.chatInputMaxLength = chatInputMaxLength ?? 200
            updateChattingWriteView()
            ShopLiveController.shared.isStartedCampaign = true
            delegate?.campaignInfo(campaignInfo: campaignInfo ?? [:])
            break
        case .showChatInput:
            chatInputView.focus()
            break
        case .written:
            if (payload as? Int ?? 1) == 0 { chatInputView.clearChatText() }
            break
        default:
            delegate?.handleCommand(command, with: payload)
            break
        }
    }
    
    func updateVoiceOverStatus() {
        self.sendCommandMessage(command: "SET_USE_SCREEN_READER", payload: ["useScreenReader" : self.voiceOverIsOn])
    }
    
    func sendCommandMessage(command: String, payload: [String : Any]?) {
        guard let payload = payload else {
            return
        }

        var message: [String : Any] = [:]

        message["command"] = command
        message["payload"] = payload

        ShopLiveController.webInstance?.sendEventToWeb(event: .sendCommandMessage, message.toJson() ?? "", false)
    }
}

extension LiveStreamViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))

        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                present(alertController, animated: true, completion: nil)
            }
        }
        else {
            present(alertController, animated: true, completion: nil)
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))

        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                present(alertController, animated: true, completion: nil)
            }
        }
        else {
            present(alertController, animated: true, completion: nil)
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)

        alertController.addTextField { (textField) in
            textField.text = defaultText
        }

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                present(alertController, animated: true, completion: nil)
            }
        }
        else {
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension LiveStreamViewController: ShopLiveChattingWriteDelegate {
    func didTouchSendButton() {
        let message: Dictionary = Dictionary<String, Any>.init(dictionaryLiteral: ("message", chatInputView.chatText))
        overlayView?.sendEventToWeb(event: .write, message.toJson())
        chatInputView.clearChatText()
    }

    func updateHeight() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            let param: Dictionary = Dictionary<String, Any>.init(dictionaryLiteral: ("value", "\(Int((self.hasKeyboard ? 0 : self.lastKeyboardHeight) + self.chatInputView.frame.height))px"), ("keyboard", self.hasKeyboard))
            ShopLiveController.webInstance?.sendEventToWeb(event: .setChatListMarginBottom, param.toJson())
        })
    }
}

extension LiveStreamViewController: ShopLivePlayerDelegate {
    var identifier: String {
        return "LiveStreamViewController"
    }

    func handlePlayControl() {
        switch ShopLiveController.playControl {
        case .play:
            self.play()
        case .pause:
            self.pause()
        case .resume:
            self.resume()
        case .stop:
            self.stop()
        default:
            break
        }
    }
    
    func doSnapShot() {
        ShopLiveController.shared.getSnapShot { image in
                self.snapShotView?.image = image
                self.snapShotView?.isHidden = false
            }
    }
    
    func takeSnapShot(on: Bool) {
        guard !ShopLiveController.shared.keepSnapshot else {
            return
        }
        
        DispatchQueue.main.async {
            if on {
                ShopLiveController.shared.getSnapShot { image in
                    self.snapShotView?.image = image
                    self.snapShotView?.isHidden = false
                    ShopLiveController.playControl = .play
                }
            } else {
                self.snapShotView?.isHidden = true
            }
        }
    }

    func handleLoading() {
        if ShopLiveController.loading {
            if ShopLiveConfiguration.UI.isCustomIndicator {
                customIndicator.configure(images: ShopLiveConfiguration.UI.customIndicatorImages)
                customIndicator.startAnimating()
            } else {
                indicatorView.isHidden = false
                indicatorView.color = ShopLiveConfiguration.UI.color
                indicatorView.startAnimating()
            }
        } else {
            if ShopLiveConfiguration.UI.isCustomIndicator {
                customIndicator.stopAnimating()
            } else {
                indicatorView.stopAnimating()
            }
        }
    }

    func handleTimeControlStatus() {
        switch ShopLiveController.timeControlStatus {
        case .paused:
            if ShopLiveController.isReplayMode {
                ShopLiveController.isPlaying = false
            } else {
                if ShopLiveController.playControl != .pause {
                    if ShopLiveController.shared.windowStyle != .osPip {
                        if pausedResumeCount >= 10 {
                            pausedResumeCount = 0
                            ShopLiveController.retryPlay = true
                        } else {
                            if !ShopLiveController.retryPlay {
                                pausedResumeCount += 1
                                ShopLiveController.playControl = .resume
                            }
                        }
                    } else {
                        if !ShopLiveController.shared.screenLock {
                            ShopLiveController.shared.lastPipPlaying = false
                        }
                    }
                } else {
                    if ShopLiveController.shared.windowStyle == .osPip, !ShopLiveController.shared.screenLock {
                        ShopLiveController.shared.lastPipPlaying = false
                    }
                }
                ShopLiveController.shared.needSeek = true
            }
            break
        case .playing:
            requireRetryCheck = false
            inBuffering = false

            ShopLiveController.shared.lastPipPlaying = true

            if ShopLiveController.loading {
                ShopLiveController.loading = false
            }

            if ShopLiveController.isReplayMode {
                ShopLiveController.webInstance?.sendEventToWeb(event: .setIsPlayingVideo(isPlaying: true), true)
            }

            ShopLiveController.retryPlay = false
            ShopLiveController.shared.takeSnapShot = false
            ShopLiveController.isPlaying = true

            break
        case .waitingToPlayAtSpecifiedRate:
            if let reason = ShopLiveController.player?.reasonForWaitingToPlay {
                switch reason {
                case .toMinimizeStalls:
                    if !inBuffering {
                        ShopLiveController.shared.takeSnapShot = true
                        if !ShopLiveController.loading,
                            ShopLiveController.shared.campaignStatus != .close {
                            if ShopLiveController.windowStyle != .osPip {
                                ShopLiveController.loading = true
                            }
                            reserveRetry(waitSecond: 8)
                        }
                    }
                    break
                default:
                    break
                }
                inBuffering = true
            }
            break

        @unknown default:
            break
        }
    }

    func reserveRetry(waitSecond: Int = 5) {
        self.requireRetryCheck = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(waitSecond)) {
            if self.inBuffering, self.requireRetryCheck {
                ShopLiveController.retryPlay = true
            }
            self.requireRetryCheck = false
        }
    }

    func updatedValue(key: ShopLivePlayerObserveValue) {
        switch key {
        case .playControl:
            handlePlayControl()
            break
        case .timeControlStatus:
            handleTimeControlStatus()
            break
        case .loading:
            handleLoading()
            break
        case .takeSnapShot:
            takeSnapShot(on: ShopLiveController.shared.takeSnapShot)
            break
        case .retryPlay:
            handleRetryPlay()
            break
        default:
            break
        }
    }

    func setupLiveStreamViewController() {
        loadOveray()
        setupAudioConfig()
        addPlayTimeObserver()
        addObserver()
    }
    
    func tearDownLiveStreamViewController() {
        resetRetry()
        ShopLiveController.shared.removePlayerDelegate(delegate: self)
        removeObserver()
        teardownAudioConfig()
        removePlaytimeObserver()
    }

    func updateChattingWriteView() {
        chatInputView.updateChattingWriteView()
    }
}
