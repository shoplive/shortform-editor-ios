//
//  ShopLivePreview.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/5/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit
import WebKit

    
public class ShopLivePlayerPreview : UIView , SLReactor {
  
    public enum Action {
        case initialize
        case start(accessKey : String, campaignKey : String, referrer : String?)
        case setMuted(Bool)
        case setReferrer(String?)
        case setResolutionType(ShopLivePlayerPreviewResolution)
        case play
        case pause
        case stop
        case close
        case retry
        case setCornerRadius(CGFloat)
        case useCloseButton(Bool)
        case setEnabledVolumeKey(isEnabledVolumeKey : Bool)
        case setResizeMode(ShopLiveResizeMode)
    }
    
    public enum Result {
        case log(name : String, feature : ShopLiveLog.Feature, campaignKey : String , payload : [String : Any]?)
        case handleReceivedCommand(command : String, payload : [String : Any]?)
        case avPlayerTimeControlStatus(AVPlayer.TimeControlStatus)
        case avPlayerItemStatus(AVPlayerItem.Status)
        case requestShowAlertController(UIAlertController)
        case didChangeCampaignStatus(ShopLiveCampaignStatus)
        case onError(code : String, message : String)
        case handleCommand(command : String, payload : Any?)
        case onSetUserName(payload : [String : Any])
        case handleShare(data : ShopLivePlayerShareData)
        case didChangeCampaignInfo([String : Any])
        case didChangeVideoDimension(CGSize)
        case handleShopLivePlayerCampaign(ShopLivePlayerCampaign)
        case handleShopLivePlayerBrand(ShopLivePlayerBrand)
    }
    
    var webViewConfiguration: WKWebViewConfiguration?
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
    
    var snapShotWidthAnc : NSLayoutConstraint?
    var snapShotheightAnc : NSLayoutConstraint?
    
    var viewModel = ShopLivePlayerPreviewViewModel()
    private var referrer : String?
    public var resultHandler: ((Result) -> ())?
    
    override init(frame : CGRect) {
        super.init(frame:.zero)
        self.clipsToBounds = true
        viewModel.action( .setAudioSessonCategory )
        bindViewModel()
        self.setLayout()
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    deinit {
        self.cleanUpOverlayWebView()
        ShopLiveLogger.memoryLog("ShopLivePreview deinit")
    }
    
    private func cleanUpOverlayWebView() {
        overlayView?.delegate = nil
        overlayView?.removeFromSuperview()
        overlayView?.teardownOverlayWebView()
        overlayView = nil
    }
    
    public func action(_ action: Action) {
        switch action {
        case .initialize:
            self.onInitialize()
        case .start(let accessKey, let campaignKey,referrer : let referrer):
            self.onStart(accessKey: accessKey, campaignKey: campaignKey, referrer : referrer)
        case .setMuted(let isMuted):
            self.onSetIsMuted(isMuted: isMuted)
        case .setReferrer(let referrer):
            self.onSetReferrer(referrer: referrer)
        case .setResolutionType(let resolution):
            self.onSetResolutionType(resolution : resolution)
        case .play:
            self.onPlay()
        case .pause:
            self.onPause()
        case .stop:
            self.onStop()
        case .close:
            self.onClose()
        case .retry:
            self.onRetry()
        case .setCornerRadius(let cornerRadius):
            self.onSetCornerRadius(cornerRadius: cornerRadius)
        case .useCloseButton(let useCloseButton):
            self.onUseCloseButton(useCloseButton: useCloseButton)
        case .setEnabledVolumeKey(isEnabledVolumeKey: let isEnabledVolumeKey):
            self.onSetEnabledVolumeKey(isEnabledVolumeKey: isEnabledVolumeKey)
        case .setResizeMode(let resizeMode):
            self.onSetResizeMode(resizeMode : resizeMode)
        }
    }
    
    private func onInitialize() {
        viewModel.action( .initialize )
        viewModel.action( .setDelegate(self) )
        if let player = playerView?.player { 
            viewModel.action( .setAVPlayer( player) )
        }
        if let playerLayer = playerView?.playerLayer {
            viewModel.action( .setAVPlayerLayer(playerLayer) )
        }
    }
    
    private func onStart(accessKey : String, campaignKey : String,referrer : String?) {
        self.referrer = referrer
        ShopLiveCommon.setAccessKey(accessKey: accessKey)
        viewModel.action( .setCampaignKey(campaignKey) )
        guard let previewOverlayUrl = fetchOverlayUrl(with: campaignKey) else { return }
        self.viewModel.action( .setOverlayUrl(previewOverlayUrl) )
        self.viewModel.action( .loadOverlayWebView )
    }
    
    
    private func onSetIsMuted(isMuted : Bool) {
        viewModel.action( .setSoundMute(isMuted: isMuted, needToSendToWeb: true) )
    }
    
    private func onSetResolutionType(resolution : ShopLivePlayerPreviewResolution) {
        viewModel.action( .setResolution(resolution) )
    }
    
    private func onSetReferrer(referrer : String?) {
        self.referrer = referrer
    }
    
    private func onPlay() {
        if viewModel.getPlayerItem() == nil {
            viewModel.action( .reloadVideo )
        }
        else {
            viewModel.action(.playControlAction(.play))
        }
    }
    
    private func onPause() {
        viewModel.action(.playControlAction(.pause))
    }
    
    private func onStop() {
        viewModel.action(.playControlAction(.stop) )
    }
    
    private func onClose() {
        viewModel.action( .tearDownViewModel )
        self.removeFromSuperview()
    }
    
    private func onRetry() {
        viewModel.action( .loadOverlayWebView )
    }
    
    private func onSeekTo(time : CMTime) {
        viewModel.action( .seekTo(time) )
    }
    
    private func onSetCornerRadius(cornerRadius : CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.setNeedsDisplay()
    }
    
    private func onUseCloseButton(useCloseButton : Bool) {
        
    }
    
    private func onSetEnabledVolumeKey(isEnabledVolumeKey : Bool) {
        ShopLiveConfiguration.SoundPolicy.isEnabledVolumeKeyInPreview = isEnabledVolumeKey
    }
    
    private func onSetResizeMode(resizeMode : ShopLiveResizeMode) {
        playerView?.playerLayer?.videoGravity = resizeMode == .CENTER_CROP ? .resizeAspectFill : .resizeAspect
    }
}
extension ShopLivePlayerPreview {
    private func bindViewModel() {
        viewModel.resultHandler = { [weak self] result in
            switch result {
            case .sendEventToWeb(event: let event, param: _, wrapping: _, dedicatedCompletionType: _):
                if event.functionString == WebInterface.onVideoTimeUpdated.functionString ||
                    event.functionString == WebInterface.onVideoMetadataUpdated.functionString {
                    break
                }
                ShopLiveLogger.tempLog("viewModel result \(result)")
            default:
                ShopLiveLogger.tempLog("viewModel result \(result)")
            }
           
            guard let self = self else { return }
            switch result {
            case .requestShowOrHideSnapShotImageView(needToShow: let needToShow):
                self.onViewModelRequestShowOrHideSnapShotImageView(needToShow: needToShow)
            case .requestShowOrHideBackgroundPosterImageView(needToSHow: let needToSHow):
                self.onViewModelRequestShowOrHideBackgroundPosterImageView(needToShow: needToSHow)
            case .requestShowOrHideOSPictureInPicture(needToShow:_):
                break
            case .requestSetShopLivePlayerSessionState(_):
                break
            case .requestSetAlphaToWebView(alpha:_):
                break
            case .reloadWebView(url: let url):
                self.onViewModelReloadWebView(url : url)
            case .sendNetworkCapabilityOnChanged(networkCapability: let networkCapability):
                self.onViewModelsendNetworkCapabilityOnChanged(networkCapability: networkCapability)
            case .updateSnapShotImageViewFrameWithRatio(ratio: let ratio):
                self.onViewModelUpdateSnapShotImageViewFrameWithRatio(ratio: ratio)
            case .log(name: let name, feature: let feature, campaignKey: let campaignKey, payload: let payload):
                self.onViewModelLog(name: name, feature: feature, campaignKey: campaignKey, payload: payload)
            case .sendEventToWeb(event: let event, param: let param, wrapping: let wrapping, dedicatedCompletionType: let dedicatedCompletionType):
                self.onViewModelSendEventToWeb(event: event, param: param, wrapping: wrapping, dedicatedCompletionType: dedicatedCompletionType)
            case .sendCommandMessageToWeb(command: let command, payload: let payload):
                self.onViewModelSendCommandMessageToWeb(command: command, payload: payload)
            case .setSnapShotImage(let image):
                self.onViewModelSetSnapShotImage(image: image)
            case .didChangeAVPlayerTimeControlStatus(let status):
                self.onViewModelDidChangeAVPlayerTimeControlStatus(status: status)
            case .didChangeAVPlayerItemStatus(let status):
                self.onViewModelDidChangeAVPlayerItemStatus(status: status)
            case .didChangeVideoDimension(let videoDimension):
                self.onViewModelDidChangeVideoDimension(videoDimension : videoDimension)
            }
        }
    }
    
    private func onViewModelRequestShowOrHideSnapShotImageView(needToShow : Bool) {
        self.snapShotImageView?.isHidden = needToShow ? false : true
    }
    
    func onViewModelRequestShowOrHideBackgroundPosterImageView(needToShow : Bool) {
        self.backgroundPosterImageWebView?.isHidden = needToShow ? false : true
    }
    
    private func onViewModelRequestSetShopLivePlayerSessionState() {
        
    }
    
    private func onViewModelRequestSetAlphaToWebView(alpha : CGFloat) {
        
    }
    
    private func onViewModelReloadWebView(url : URL?) {
        if let url = url {
            self.overlayView?.reload(with: url)
        }
        else {
            self.overlayView?.reload()
        }
    }
    
    private func onViewModelsendNetworkCapabilityOnChanged(networkCapability : String) {
        overlayView?.sendCommandMessage(command: WebInterface.onNetworkChangeCapability.functionString, payload: ["capability" : networkCapability])
    }
    
    private func onViewModelUpdateSnapShotImageViewFrameWithRatio(ratio : CGSize) {
        guard let snapShotImageView = self.snapShotImageView,
              let widthAnc = self.snapShotWidthAnc,
              let heightAnc = self.snapShotheightAnc,
              let playerView = self.playerView else { return }
        
        let videoRatio = viewModel.getVideoRatio()
        if ratio.width == 0 || ratio.height == 0 {
            return
        }
        self.snapShotImageView?.isHidden = false
        
        var newWidthAnc : NSLayoutConstraint?
        var newHeightAnc : NSLayoutConstraint?
        
        if floor(ratio.height) == floor(playerView.frame.height) {
            if (ratio.width) > playerView.frame.width {
                (newWidthAnc, newHeightAnc) = redrawSnapShotOnSameHeightAndHorizontalFit(ratio: ratio)
            }
            else {
                guard needSnapShotReDraw(base: playerView.frame.height, isHorizontal: false, ratio: ratio.width / ratio.height) else { return }
                (newWidthAnc, newHeightAnc) = redrawSnapShotOnSameHeightAndHorizontalScaled(ratio: ratio)
            }
        }
        else if floor(ratio.width) == floor(playerView.frame.width) {
            if ratio.height > playerView.frame.height {
                (newWidthAnc, newHeightAnc) = redrawSnapShotOnSameWithAndVerticalFit(ratio: ratio)
            }
            else {
                guard needSnapShotReDraw(base: playerView.frame.width, isHorizontal: true, ratio: ratio.height / ratio.width) else { return }
                (newWidthAnc, newHeightAnc) = redrawSnapShotOnSameWidthAndVerticalScaled(ratio: ratio)
            }
        }
        else if videoRatio.width > videoRatio.height {
            let standardRatio = videoRatio.width / videoRatio.height
            let videoRatio = ratio.width / ratio.height
            if standardRatio > videoRatio {
                guard needSnapShotReDraw(base: playerView.frame.height, isHorizontal: false, ratio: ratio.width / ratio.height) else { return }
                (newWidthAnc, newHeightAnc) = redrawSnapShotOnHorizontalModeAndVerticalFit(ratio : ratio)
            }
            else {
                guard needSnapShotReDraw(base: playerView.frame.width, isHorizontal: true, ratio: ratio.height / ratio.width) else { return }
                (newWidthAnc, newHeightAnc) = redrawSnapShotOnHorizontalModelAndHorizontalFit(ratio : ratio)
            }
        }
        else {
            let standardRatio = videoRatio.height / videoRatio.width
            let videoRatio = ratio.height / ratio.width
            if standardRatio > videoRatio {
                guard needSnapShotReDraw(base: playerView.frame.height, isHorizontal: false, ratio: ratio.width / ratio.height) else { return }
                (newWidthAnc, newHeightAnc) = redrawSnapShotOnVerticalModeAndVerticalFit(ratio : ratio)
            }
            else {
                guard needSnapShotReDraw(base: playerView.frame.width, isHorizontal: true, ratio: ratio.height / ratio.width) else { return }
                (newWidthAnc, newHeightAnc) = redrawSnapShotOnVerticalModeAndHorizontalFit(ratio : ratio)
            }
        }

        widthAnc.isActive = false
        heightAnc.isActive = false
        snapShotImageView.removeConstraints([widthAnc,heightAnc])
        self.snapShotWidthAnc = newWidthAnc
        self.snapShotheightAnc = newHeightAnc
        self.snapShotWidthAnc?.isActive = true
        self.snapShotheightAnc?.isActive = true
    }
    
    private func onViewModelLog(name : String, feature : ShopLiveLog.Feature, campaignKey : String , payload : [String : Any]?) {
        resultHandler?( .log(name: name, feature: feature, campaignKey: campaignKey, payload: payload))
    }
    
    private func onViewModelSendEventToWeb(event : WebInterface, param : Any?, wrapping : Bool = false, dedicatedCompletionType : DedicatedWebViewCommandCompletionType?) {
        self.overlayView?.sendEventToWeb(event: event, param, wrapping)
    }
    
    private func onViewModelSendCommandMessageToWeb(command : String, payload : [String : Any]?) {
        self.overlayView?.sendCommandMessage(command: command, payload: payload )
    }
    
    private func onViewModelSetSnapShotImage(image : UIImage?) {
        self.snapShotImageView?.image = image
    }
    
    private func onViewModelDidChangeAVPlayerTimeControlStatus(status : AVPlayer.TimeControlStatus) {
        resultHandler?( .avPlayerTimeControlStatus(status) )
    }
    
    private func onViewModelDidChangeAVPlayerItemStatus(status : AVPlayerItem.Status) {
        resultHandler?( .avPlayerItemStatus(status) )
    }
    
    private func onViewModelDidChangeVideoDimension(videoDimension : CGSize) {
        resultHandler?( .didChangeVideoDimension(videoDimension) )
    }
}
extension ShopLivePlayerPreview {
    func fetchOverlayUrl(with campaignKey : String?) -> URL? {
        let urlComponents = URLComponents(string: ShopLiveConfiguration.AppPreference.landingUrl)
        var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "preview", value: "1"))
        
        if self.viewModel.getCurrentResolution() == .LIVE {
            queryItems.append(URLQueryItem(name: "useLiveUrlOnPreview", value: "1"))
        }
      
        if let referrer = self.referrer {
            queryItems.append(URLQueryItem(name: "referrer", value: String(referrer.prefix(1024))))
        }
        queryItems.append(URLQueryItem(name: "_from", value: "sdk_direct"))
        
        
        let baseUrl = URL(string: ShopLiveConfiguration.AppPreference.landingUrl)
        guard let params = URLUtil.query(queryItems) else {
            return baseUrl
        }
        
        guard let url = URL(string: ShopLiveConfiguration.AppPreference.landingUrl + "?" + params) else {
            return baseUrl
        }
        
        return url
    } 

    private func redrawSnapShotOnSameHeightAndHorizontalFit(ratio : CGSize) -> (w : NSLayoutConstraint?, h : NSLayoutConstraint?) {
        guard let srcView = self.snapShotImageView else { return (nil, nil) }
        guard let playerView = self.playerView else {
            return (nil,nil)
        }
        return (srcView.widthAnchor.constraint(equalTo: playerView.widthAnchor),
                srcView.heightAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: 1))
    }
    
    private func redrawSnapShotOnSameHeightAndHorizontalScaled(ratio : CGSize) -> (w : NSLayoutConstraint?, h : NSLayoutConstraint?) {
        guard let srcView = self.snapShotImageView else { return (nil, nil) }
        guard let playerView = self.playerView else {
            return (nil,nil)
        }
        return (srcView.widthAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: ratio.width / ratio.height),
                srcView.heightAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: 1))
    }
    
    private func redrawSnapShotOnSameWithAndVerticalFit(ratio : CGSize)  -> (w : NSLayoutConstraint?, h : NSLayoutConstraint?)  {
        guard let srcView = self.snapShotImageView else { return (nil, nil) }
        guard let playerView = self.playerView else {
            return (nil,nil)
        }
        return (srcView.widthAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 1),
                srcView.heightAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: 1))
    }
    
    private func redrawSnapShotOnSameWidthAndVerticalScaled(ratio : CGSize)  -> (w : NSLayoutConstraint?, h : NSLayoutConstraint?) {
        guard let srcView = self.snapShotImageView else { return (nil, nil) }
        guard let playerView = self.playerView else {
            return (nil,nil)
        }
        return (srcView.widthAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 1),
                srcView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: ratio.height / ratio.width))
    }
    
    private func redrawSnapShotOnHorizontalModeAndVerticalFit(ratio : CGSize) -> (w : NSLayoutConstraint?, h : NSLayoutConstraint?) {
        guard let srcView = self.snapShotImageView else { return (nil, nil) }
        guard let playerView = self.playerView else {
            return (nil,nil)
        }
        return (srcView.widthAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: ratio.width / ratio.height),
                srcView.heightAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: 1))
    }
    
    private func redrawSnapShotOnHorizontalModelAndHorizontalFit(ratio : CGSize) -> (w : NSLayoutConstraint?, h : NSLayoutConstraint?) {
        guard let srcView = self.snapShotImageView else { return (nil, nil) }
        guard let playerView = self.playerView else {
            return (nil,nil)
        }
        return (srcView.widthAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 1),
                srcView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: ratio.height / ratio.width))
    }
    
    private func redrawSnapShotOnVerticalModeAndVerticalFit(ratio : CGSize) -> (w : NSLayoutConstraint?, h : NSLayoutConstraint?) {
        guard let srcView = self.snapShotImageView else { return (nil, nil) }
        guard let playerView = self.playerView else {
            return (nil,nil)
        }
        return (srcView.widthAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: ratio.width / ratio.height),
                srcView.heightAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: 1))
    }
    
    private func redrawSnapShotOnVerticalModeAndHorizontalFit(ratio : CGSize) -> (w : NSLayoutConstraint?, h : NSLayoutConstraint?) {
        guard let srcView = self.snapShotImageView else { return (nil, nil) }
        guard let playerView = self.playerView else {
            return (nil,nil)
        }
        return (srcView.widthAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 1),
                srcView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: ratio.height / ratio.width))
    }
    
    private func needSnapShotReDraw(base : CGFloat, isHorizontal : Bool, ratio : CGFloat) -> Bool {
        guard let snapShotView = self.snapShotImageView else {
            return false
        }
        var oldSize = CGSize.init(width: floor(snapShotView.frame.size.width), height: floor(snapShotView.frame.size.height))
        var newSize : CGSize
        if isHorizontal {
            newSize = .init(width: floor(base), height: floor(base * ratio))
        }
        else {
            newSize = .init(width: floor(base * ratio), height: floor(base))
        }
        return oldSize != newSize
    }
}
extension ShopLivePlayerPreview {
    private func setLayout() {
        self.setPlayerView()
        self.setBackgroundPosterImageView()
        self.setSnapShotView()
        if let playerView = self.playerView {
            self.bringSubviewToFront(playerView)
        }
        self.setUpOverlayWebView()
    }
    
    private func setPlayerView() {
        if playerView == nil {
            playerView = .init()
        }
        guard let playerView = playerView else { return }
        self.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.playerLayer?.player = playerView.player
        playerView.playerLayer?.needsDisplayOnBoundsChange = true
       
        viewModel.action( .setAVPlayer(playerView.player) )
        if let playerLayer = playerView.playerLayer {
            playerLayer.videoGravity = .resizeAspectFill
            viewModel.action( .setAVPlayerLayer(playerLayer) )
        }
        
        playerTopConstraint     = playerView.topAnchor.constraint(equalTo: topAnchor)
        playerLeadingConstraint = playerView.leadingAnchor.constraint(equalTo: leadingAnchor)
        playerRightConstraint   = playerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        playerBottomConstraint  = playerView.bottomAnchor.constraint(equalTo: bottomAnchor)

        NSLayoutConstraint.activate([playerTopConstraint, playerLeadingConstraint, playerRightConstraint, playerBottomConstraint])
    }
    
    private func setBackgroundPosterImageView() {
        guard let playerView = playerView else { return }
        self.backgroundPosterImageWebView = SLWKWebView()
        guard let backgroundPosterImageWebView = self.backgroundPosterImageWebView else { return }
        self.addSubview(backgroundPosterImageWebView)
        backgroundPosterImageWebView.translatesAutoresizingMaskIntoConstraints = false
        backgroundPosterImageWebView.isOpaque = false
        backgroundPosterImageWebView.backgroundColor = .black
        backgroundPosterImageWebView.scrollView.backgroundColor = .black
        backgroundPosterImageWebView.layer.masksToBounds = true
        backgroundPosterImageWebView.clipsToBounds = true
        backgroundPosterImageWebView.scrollView.contentInsetAdjustmentBehavior = .never
        backgroundPosterImageWebView.scrollView.contentInset = .zero
       
        
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
    
    private func setSnapShotView() {
        guard let playerView = playerView else { return }
        self.snapShotImageView = SLImageView()
        guard let snapShotImageView = self.snapShotImageView else { return }
        self.addSubview(snapShotImageView)
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
    
    private func setUpOverlayWebView() {
        let overlayView = OverlayWebView(with: webViewConfiguration, removeStaticInstanceWithDeinit: false)
        overlayView.setupOverlayWebView()
        overlayView.webviewUIDelegate = self
        overlayView.delegate = self
        addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([overlayView.topAnchor.constraint(equalTo: topAnchor),
                                     overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     overlayView.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     overlayView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
        self.overlayView = overlayView
        self.overlayView?.alpha = 0
    }
    
}
//MARK: - ShopLivePreviewViewModelDelegate
extension ShopLivePlayerPreview : ShopLivePreviewModelDelegate {
    func getCurrentWebViewUrl() -> URL? {
        return overlayView?.getCurrentUrl()
    }
}
//MARK: - public getter
extension ShopLivePlayerPreview {
    public func isPlaying() -> Bool {
        return viewModel.getPlayer()?.timeControlStatus ?? .paused == .playing
    }
    
    public func isMuted() -> Bool {
        return viewModel.getPlayer()?.isMuted ?? true
    }
    
    public func getPlayerItemStatus() -> AVPlayerItem.Status? {
        return viewModel.getPlayerItem()?.status
    }
}

