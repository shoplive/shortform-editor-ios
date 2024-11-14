//
//  ShopLivePreviewViewModel.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/5/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit
import CoreVideo
import VideoToolbox

protocol ShopLivePreviewModelDelegate : NSObjectProtocol {
    func getCurrentWebViewUrl() -> URL?
}


class ShopLivePlayerPreviewViewModel : NSObject, SLReactor {
    
    
    private var overlayUrl : URL?
    private var currentNetworkCapability : String = ""
    private var isMuted : Bool = ShopLiveConfiguration.SoundPolicy.isMutedWhenStart
    private var player : AVPlayer?
    private var urlAsset : AVURLAsset?
    private var playerItem : AVPlayerItem?
    private var videoOutput : AVPlayerItemVideoOutput?
    private var playerLayer : AVPlayerLayer?
    private var currentPlayCommand : PlayControlManager.PlayCommand = .none
    private var refreshTimer : DispatchSourceTimer? // 30초우에 preview 갱신하는 타이머
    
    

    private var previewUrl : URL?
//    private var liveUrl : URL?
    
    private var playTimeObserver: Any?
    private var playerItemStatusObserver : NSKeyValueObservation?
    private var playerLoadedTimeRangeObserver : NSKeyValueObservation?
    private var isAlreadyPlayedOnce : Bool = false
    private var playerLoadingStartTime : Double?
    
    
    //stream data
    private var streamActivityType : StreamActivityType = .ready
    private var campaignId : String = ""
    private var shopliveSessionId : String? = nil
    private var streamEdgeType : String?
    private var currentPlayTime : CMTime?
    private var currentResolution : ShopLivePlayerPreviewResolution = .LIVE
    
    //viewdata
    private var actualVideoRenderedRect : CGRect = .zero
    private var customVideoResizeMode : ShopLiveResizeMode?
    private var useCloseButton : Bool = false
    private var isWebViewDidCompleteLoading : Bool = false
    var videoOrientation: ShopLiveDefines.ShopLiveOrientaion {
        switch supportOrientation {
        case .portrait, .unknown:
            return .portrait
        case .landscape:
            return .landscape
        }
    }
    var supportOrientation: ShopLive.VideoOrientation = .unknown
    lazy var videoRatio: CGSize = videoOrientation == .landscape ? CGSize(width: 16, height: 9) : CGSize(width: 9, height: 16)
    
    //campaignState
    private var campaignStatus : ShopLiveCampaignStatus = .close
    private var campaignKey : String = ""
    private var isSuccessCampaignJoin : Bool = false
    
    
    private var playControlManager : PlayControlManager?
    private var timeControlStatusManager : TimeControlStatusManager?
    private var eventTraceManager : ShopLivePlayerEventTraceManagerImpl?
    private var retryManager : ShopLivePreviewRetryManager?
    
    private weak var delegate : ShopLivePreviewModelDelegate?
    
    enum Action {
        case initialize
        case reloadOverlayWebView
        case loadOverlayWebView
        case setDelegate(ShopLivePreviewModelDelegate?)
        case setOverlayUrl(URL?)
        case setSoundMuteStateOnWebViewSetConf
        case setSoundMute(isMuted : Bool, needToSendToWeb : Bool)
        case setStreamEdgeType(type : String?)
        case setCampaignId(String)
        case setCampaignKey(String)
        case setCampaignStatus(ShopLiveCampaignStatus)
        case setStreamActivityType(String)
        case setWebViewLoadingCompleted(Bool)
        case setResizeMode(ShopLiveResizeMode)
        case setRefreshTimer
        case setResolution(ShopLivePlayerPreviewResolution)
        case setAudioSessonCategory
        case parseRatioStringAndSetData(String)
        case tearDownViewModel
        
        //hls전용
        case reloadVideo
        case seekTo(CMTime)
        case seekToLatest
        case didUpdateVideoUrl(URL?)
        case requestTakeSnapshot
        case requestTakeSnapShotWithCompletion(completion : (() -> ())?)
        case retryOnNetworkDisConnect
        case resetRetryFromWebview
        case resetPlayer
        case initPlayer(URL?)
        case setAVPlayer(AVPlayer?)
        case setAVPlayerLayer(AVPlayerLayer?)
        case setIsReplayMode(Bool)
        case setNeedSeek(Bool)
        case setNeedReload(Bool)
//        case setPreviewURl(URL?)
//        case setLiveUrl(URL?)
        case setPlaybackSpeed(Float)
        case sendPreviewShowEventTrace
        
        
        case playControlAction(ShopLivePlayerControlAction)
        
    }
    
    enum Result {
        case requestShowOrHideSnapShotImageView(needToShow : Bool)
        case requestShowOrHideBackgroundPosterImageView(needToSHow : Bool)
        case requestShowOrHideOSPictureInPicture(needToShow : Bool)
        case requestSetShopLivePlayerSessionState(PlayerSessionState)
        case requestSetAlphaToWebView(alpha : CGFloat)
        
        case reloadWebView(url : URL)
        case sendNetworkCapabilityOnChanged(networkCapability : String)
        case updateSnapShotImageViewFrameWithRatio(ratio : CGSize)
        
        
        case log(name : String, feature : ShopLiveLog.Feature, campaignKey : String , payload : [String : Any]?)
        case sendEventToWeb(event : WebInterface, param : Any?, wrapping : Bool = false, dedicatedCompletionType : DedicatedWebViewCommandCompletionType?)
        case sendCommandMessageToWeb(command : String, payload : [String : Any]?)
        case setSnapShotImage(UIImage?)
        
        case didChangeAVPlayerTimeControlStatus(AVPlayer.TimeControlStatus)
        case didChangeAVPlayerItemStatus(AVPlayerItem.Status)        
        case didChangeVideoDimension(CGSize)
    }
    
    
    var resultHandler: ((Result) -> ())?
    
    
    override init(){
        super.init()
        playControlManager = PlayControlManager()
        timeControlStatusManager = TimeControlStatusManager()
        retryManager = ShopLivePreviewRetryManager(delegate: self)
        self.bindPlayControlManager()
        self.bindTimeControlStatusManager()
        self.bindRetryManager()
        self.bindAudioSessionManager()
        self.shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        self.eventTraceManager?.stateAction( .setShopLiveSessionId(self.shopliveSessionId))
    }
    
    deinit {
        ShopLiveLogger.tempLog("ShopLivePreviewViewModel deinit")
    }
    
    func action(_ action: Action) {
        ShopLiveLogger.tempLog("viewmodel action \(action)")
        switch action {
        case .initialize:
            onInitialize()
        case .setDelegate(let delegate):
            onSetDelegate(delegate : delegate)
        case .reloadOverlayWebView:
            onReloadOverlayWebView()
        case .loadOverlayWebView:
            onLoadOverlayWebView()
        case .retryOnNetworkDisConnect:
            onRetryOnNetworkDisConnect()
        case .setOverlayUrl(let uRL):
            onSetOverlayUrl(url: uRL)
        case .setSoundMuteStateOnWebViewSetConf:
            onSetSoundMuteStateOnWebViewSetConf()
        case .setSoundMute(let isMuted, let needToSendToWeb):
            onSetSoundMute(isMuted: isMuted, needToSendToWeb: needToSendToWeb)
        case .setStreamEdgeType(let type):
            onSetStreamEdgeType(type: type)
        case .setCampaignId(let campaignId):
            onSetCampaignId(campaignId: campaignId)
        case .setCampaignKey(let campaignKey):
            onSetCampaignKey(campaignKey: campaignKey)
        case .setCampaignStatus(let status):
            onSetCampaignStatus(status: status)
        case .setResizeMode(let mode):
            onSetResizeMode(mode: mode)
        case .setStreamActivityType(let type):
            onSetStreamActivityType(type: type)
        case .setWebViewLoadingCompleted(let isCompleted):
            onSetWebViewLoadingCompleted(isCompleted: isCompleted)
        case .setRefreshTimer:
            onSetRefreshTimer()
        case .setResolution(let resolution):
            self.onSetResolution(resolution : resolution)
        case .setAudioSessonCategory:
            self.onSetAudioSessionCategory()
        case .parseRatioStringAndSetData(let ratio):
            onParseRatioStringAndSetData(ratio: ratio)
        case .tearDownViewModel:
            onTearDownViewModel()
            
            
            
            //MARK: - hls actions
        case .reloadVideo:
            onReloadVideo()
        case .seekTo(let time): // CMTime
            onSeekTo(time: time)
        case .seekToLatest:
            onSeekToLatest()
        case .didUpdateVideoUrl(let url): // URL
            onDidUpdateVideoUrl(url: url)
        case .requestTakeSnapshot:
            onRequestTakeSnapshot()
        case .requestTakeSnapShotWithCompletion(let completion): // (() -> ())?
            onRequestTakeSnapShotWithCompletion(completion: completion)
        case .resetRetryFromWebview:
            onResetRetryFromWebview()
        case .resetPlayer:
            onResetPlayer()
        case .initPlayer(let url): // URL?
            onInitPlayer(url: url)
        case .setAVPlayer(let player): // AVPlayer?
            onSetAVPlayer(player: player)
        case .setAVPlayerLayer(let layer):
            onSetAVPlayerLayer(layer : layer)
        case .setIsReplayMode(let isReplayMode): // Bool
            onSetIsReplayMode(isReplayMode: isReplayMode)
        case .setNeedSeek(let needSeek): // Bool
            onSetNeedSeek(needSeek: needSeek)
        case .setNeedReload(let needReload): // bool
            onSetNeedReload(needReload: needReload)
//        case .setPreviewURl(let url): // URL?
//            onSetPreviewURL(url: url)
//        case .setLiveUrl(let url): // URL?
//            onSetLiveUrl(url: url)
        case .playControlAction(let playControl):
            onPlayControlAction(action : playControl)
        case .setPlaybackSpeed(let speed):
            self.onSetPlaybackSpeed(speed : speed)
        case .sendPreviewShowEventTrace:
            self.onSendPreviewShowEventTrace()
        }
    }
    
    private func onInitialize() {
        self.previewUrl = nil
        self.playerItem = nil
        self.currentPlayCommand = .stop
        self.removePlayTimeObserver()
        self.isAlreadyPlayedOnce = false
        removeAVPlayerObserver()
        retryManager?.action( .stopRetry )
        campaignKey = ""
        campaignId = ""
        shopliveSessionId = nil
        campaignStatus = .close
        isWebViewDidCompleteLoading = false
        customVideoResizeMode = nil
        useCloseButton = false
    }
    
    private func onSetDelegate(delegate : ShopLivePreviewModelDelegate?) {
        self.delegate = delegate
    }
    
    private func onReloadOverlayWebView() {
        guard let url = self.getOverLayUrlWithInfosAttached() else { return }
        resultHandler?( .reloadWebView(url: url) )
    }
    
    private func onLoadOverlayWebView() {
        guard let url = self.getOverLayUrlWithInfosAttached() else { return }
        resultHandler?( .reloadWebView(url: url) )
    }
    
    private func onRetryOnNetworkDisConnect() {
        retryManager?.action( .retryWebViewOnNetworkDisconnected )
    }
    
    private func onSetOverlayUrl(url : URL?) {
        self.overlayUrl = url
    }
    
    private func onSetSoundMuteStateOnWebViewSetConf() {
        ShopLivePlayerPreviewAudioSessionManager.shared.action( .setSoundMuteStateOnFirstPlay )
//        audioSessionManager?.action( .setSoundMuteStateOnFirstPlay )
    }
    
    private func onSetSoundMute(isMuted: Bool, needToSendToWeb: Bool) {
        player?.isMuted = isMuted
        if needToSendToWeb {
            resultHandler?( .sendEventToWeb(event: .setVideoMute(isMuted: isMuted), param: isMuted, wrapping: false, dedicatedCompletionType: .isMuted))
        }
    }
    
    private func onSetStreamEdgeType(type : String?) {
        self.streamEdgeType = type
        eventTraceManager?.stateAction( .setStreamEdgeType(type) )
    }
    
    private func onSetCampaignId(campaignId : String) {
        eventTraceManager?.stateAction( .setCampaignId(campaignId) )
        self.campaignId = campaignId
    }
    
    private func onSetCampaignKey(campaignKey : String) {
        self.campaignKey = campaignKey
    }
    
    private func onSetCampaignStatus(status : ShopLiveCampaignStatus) {
        self.campaignStatus = status
    }
    
    private func onSetResizeMode(mode : ShopLiveResizeMode?) {
        self.customVideoResizeMode = mode
    }
    
    private func onSetStreamActivityType(type : String) {
        for aType in StreamActivityType.allCases {
            if aType.rawValue == type {
                self.streamActivityType = aType
                eventTraceManager?.stateAction( .setStreamActivityType(aType) )
            }
        }
    }
    
    private func onSetWebViewLoadingCompleted(isCompleted : Bool) {
        self.isWebViewDidCompleteLoading = isCompleted
    }
    
    private func onSetAudioSessionCategory() {
        ShopLivePlayerPreviewAudioSessionManager.shared.action( .setAudioSessionCategory )
    }
    
    private func onSetResolution(resolution : ShopLivePlayerPreviewResolution) {
        self.currentResolution = resolution
    }
    
    private func onSetRefreshTimer() {
        self.setRefreshTimer()
    }
    
    func onParseRatioStringAndSetData(ratio : String?) {
        if let ratio = ratio {
            let parseRatio = ratio.split(separator: ":")
            if parseRatio.isEmpty {
                videoRatio = ShopLiveDefines.defVideoRatio
                supportOrientation = .portrait
            } else {
                if parseRatio.count == 2, let width = Int(parseRatio[0]), let height = Int(parseRatio[1]) {
                    videoRatio = CGSize(width: width, height: height)
                    supportOrientation = width > height ? .landscape : .portrait
                } else {
                    videoRatio = ShopLiveDefines.defVideoRatio
                    supportOrientation = .portrait
                }
            }
        }
        else {
            videoRatio = ShopLiveDefines.defVideoRatio
            supportOrientation = .portrait
        }
        resultHandler?( .didChangeVideoDimension(videoRatio) )
    }
    
    private func onTearDownViewModel() {
        invalidateRefreshTimer()
        eventTraceManager?.eventTraceAction( .previewDismiss )
        retryManager?.delegate = nil
        retryManager = nil
        timeControlStatusManager?.action( .cleanUpMemory )
        delegate = nil
        removePlayTimeObserver()
        resetPlayer()
        
    }
    
    private func onSetNeedSeek(needSeek: Bool) {
        playControlManager?.action( .setNeedSeek(needSeek) )
    }
    
    private func onSetNeedReload(needReload: Bool) {
        playControlManager?.action( .setNeedReload(needReload) )
    }
    
//    private func onSetPreviewURL(url: URL?) {
//        self.previewUrl = url
//        self.playControlManager?.action( .setLiveUrl(url) )
//    }
    
    private func onSetPlaybackSpeed(speed : Float) {
        self.player?.rate = speed
    }
    
    private func onSendPreviewShowEventTrace() {
        eventTraceManager?.eventTraceAction( .previewShow )
    }
    
    private func onPlayControlAction(action : ShopLivePlayerControlAction) {
        playControlManager?.playControlAction(action)
    }
    
    private func onCheckIfSnapShotImageFrameNeedReCalculation() {
        if let current = playerLayer?.videoRect {
            if current != .zero && current.width != 0 && current.height != 0 {
                //프리뷰 inAppPip를 제외시키는 이유는 preview 자체 크기로 인해서 videoRect가 결정이 되서
                self.actualVideoRenderedRect = current
            }
        }
        let width = self.actualVideoRenderedRect.width
        let height = self.actualVideoRenderedRect.height
        
        if let viewFrame = playerLayer?.frame.size, (width <= (viewFrame.width * 0.5) && height <= (viewFrame.height * 0.5)) {
            self.resultHandler?( .setSnapShotImage(nil) )
        }
        else {
            self.resultHandler?( .updateSnapShotImageViewFrameWithRatio(ratio: CGSize.init(width: width, height: height)) )
        }
    }
    
    private func onReloadVideo() {
        guard let url = self.previewUrl else {
            resetPlayer()
            return
        }
        updatePlayerItem(with: url)
    }
    
    private func onSeekTo(time: CMTime) {
        ShopLiveLogger.tempLog("[HLSVIEMODEL] seekTO \(time)")
        self.currentPlayTime = time
        playControlManager?.action( .seekTo(time) )
    }
    
    private func onSeekToLatest() {
        ShopLiveLogger.tempLog("[HLSVIEMODEL] seekToLatest")
        playControlManager?.action( .seekToLatest )
    }
    
    private func onDidUpdateVideoUrl(url: URL?) {
        guard let url = url else {
            self.player?.replaceCurrentItem(with: nil)
            self.previewUrl = nil
            self.resetPlayer()
            return
        }
        
        if let oldUrl = self.previewUrl, oldUrl.absoluteString == url.absoluteString {
            return
        }
        self.onRequestTakeSnapshot()
        let previewQueryAddedUrl = self.checkIfLiveUrlContainsPreviewQueryAndAppendIfNotExist(url: url)
        self.previewUrl = previewQueryAddedUrl
        playControlManager?.action( .setLiveUrl(previewQueryAddedUrl) )
        self.updatePlayerItem(with: previewQueryAddedUrl)
        if let playControlManager = playControlManager,
           playControlManager.getIsReplayMode(), let startTime = self.currentPlayTime {
            playControlManager.action( .seekTo(startTime) )
        }
    }
    
    private func onRequestTakeSnapshot() {
        guard let videoOutput = self.videoOutput,
              let currentItem = self.player?.currentItem,
              campaignStatus != .close else { return }
        
        self.onCheckIfSnapShotImageFrameNeedReCalculation()
        
        let currentTime = currentItem.currentTime()
        if let buffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
            let ciImage = CIImage(cvPixelBuffer: buffer)
            let imgRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
            if let videoImage = CIContext().createCGImage(ciImage, from: imgRect) {
                let image = UIImage.init(cgImage: videoImage)
                resultHandler?( .setSnapShotImage(image) )
            } else {
                resultHandler?( .setSnapShotImage(nil) )
            }
        }
    }
    
    private func onRequestTakeSnapShotWithCompletion(completion: (() -> ())?) {
        guard let videoOutput = self.videoOutput,
              let currentItem = self.player?.currentItem,
              campaignStatus != .close else { return }
        self.onCheckIfSnapShotImageFrameNeedReCalculation()
        
        let currentTime = currentItem.currentTime()
        if let buffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
            let ciImage = CIImage(cvPixelBuffer: buffer)
            let imgRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
            if let videoImage = CIContext().createCGImage(ciImage, from: imgRect) {
                let image = UIImage.init(cgImage: videoImage)
                resultHandler?( .setSnapShotImage(image) )
                
            } else {
                resultHandler?( .setSnapShotImage(nil) )
            }
        }
        completion?()
    }
    
    private func onUpdatePlayBackSpeed(rate : Float) {
        self.player?.rate = rate
    }
    
    private func onResetRetryFromWebview() {
        if playerItem?.status == .readyToPlay {
            retryManager?.action( .stopRetry )
        }
    }
    
    private func onResetPlayer() {
        self.resetPlayer()
    }
    
    private func onInitPlayer(url : URL?) {
        guard let url = url else { return }
        playControlManager?.action( .setLiveUrl(url) )
        self.updatePlayerItem(with: url)
    }
    
    private func onSetAVPlayer(player : AVPlayer?) {
        self.player = player
    }
    
    private func onSetAVPlayerLayer(layer: AVPlayerLayer?) {
        self.playerLayer = layer
    }
    
    private func onSetIsReplayMode(isReplayMode : Bool){
        ShopLivePlayerPreviewAudioSessionManager.shared.action( .setIsReplayMode(isReplayMode) )
        playControlManager?.action( .setIsReplayMode(isReplayMode) )
    }
}
extension ShopLivePlayerPreviewViewModel {
    private func updatePlayerItem(with url: URL,from : String = #function) {
        ShopLiveLogger.tempLog("[UPDATEPLAYERITEM] url \(url) from \(from)")
        guard self.player != nil else { return }
        resetPlayer()
        playerLoadingStartTime = Date().timeIntervalSince1970
        let queryAddedUrl = addQueryForLiveUrl(url: url)
        let asset = AVURLAsset(url:  queryAddedUrl)
        
        let playerItem = AVPlayerItem(asset: asset)
        
        setSoundMuteStateOnFirstPlay()
              
        let metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil)
        metadataOutput.setDelegate(self, queue: DispatchQueue.main)
        playerItem.add(metadataOutput)
        
        if #available(iOS 14.0, *) {
            playerItem.startsOnFirstEligibleVariant = true
        }
        
        if #available(iOS 14.5, *) {
            playerItem.variantPreferences = .scalabilityToLosslessAudio
        }
        
        if playControlManager?.getIsReplayMode() ?? false {
            playerItem.preferredForwardBufferDuration = 2.5
        }
        
        playerItem.audioTimePitchAlgorithm = .timeDomain
        
        self.playerItem = playerItem
        self.player?.replaceCurrentItem(with: playerItem)
        if let player = self.player {
            addAVPlayerObserver()
            playControlManager?.action( .setAVPlayer(player) )
            playControlManager?.action( .setAVPlayerItem(playerItem) )
            
            
            timeControlStatusManager?.action( .setAVPlayer(player) )
            timeControlStatusManager?.action( .setAVPlayerItem(playerItem) )
            timeControlStatusManager?.action( .setCampaignStatus(campaignStatus) )
            timeControlStatusManager?.action( .setIsReplayMode(playControlManager?.getIsReplayMode() ?? false) )
            timeControlStatusManager?.action( .startObserving )
        }
        addPlayTimeObserver()
        setVideoOutput()
    }
    
    private func setSoundMuteStateOnFirstPlay() {
        guard timeControlStatusManager?.getIsAlreadyPlayedOnce() == false else { return }
        ShopLivePlayerPreviewAudioSessionManager.shared.action( .setSoundMuteStateOnFirstPlay )
    }
    
    /**
     playerItem이 새롭게 할당될때마다 호출해야함(기존 로직에 의하면)
     */
    private func setVideoOutput() {
        if let oldVideoOutput = self.videoOutput {
            player?.currentItem?.remove(oldVideoOutput)
            self.videoOutput = nil
        }
        
        let properties:[String: Any] = [
            (kVTCompressionPropertyKey_RealTime as String): kCFBooleanTrue ?? true,
                    (kVTCompressionPropertyKey_ProfileLevel as String): kVTProfileLevel_H264_High_AutoLevel,
                    (kVTCompressionPropertyKey_AllowFrameReordering as String): true,
                    (kVTCompressionPropertyKey_H264EntropyMode as String): kVTH264EntropyMode_CABAC,
                    (kVTCompressionPropertyKey_PixelTransferProperties as String): [
                        (kVTPixelTransferPropertyKey_ScalingMode as String): kVTScalingMode_Trim
                    ]
                ]
        self.videoOutput = AVPlayerItemVideoOutput.init(pixelBufferAttributes: properties)
        guard let newVideoOutPut = self.videoOutput else { return }
        player?.currentItem?.add(newVideoOutPut)

    }
    
    private func addQueryForLiveUrl(url : URL) -> URL {
        guard var urlComponents = URLComponents(string: url.absoluteString) else { return url }
        var addQueryItems : [URLQueryItem] = []
        
        for (key, value) in AVPlayerHeaderMaker.defaultHeaders {
            if key != "Authorization" {
                let queryItem = URLQueryItem(name: key, value: String(describing: value ))
                addQueryItems.append(queryItem)
            }
        }
        if let queryItems = urlComponents.queryItems {
            urlComponents.queryItems = queryItems + addQueryItems
        }
        else {
            urlComponents.queryItems = addQueryItems
        }
        
        guard let urlString = urlComponents.url?.absoluteString,
              let percentEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let resultUrl = URL(string: percentEncoded) else {
            return url
        }
        
        return resultUrl
    }
    
    private func checkIfLiveUrlContainsPreviewQueryAndAppendIfNotExist(url : URL) -> URL {
        guard var urlComponents = URLComponents(string: url.absoluteString) else { return url }
        
        for query in urlComponents.queryItems ?? [] {
            if query.name == "preview" {
               return url
            }
        }
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + [URLQueryItem(name: "preview", value: "1")]
        guard let urlString = urlComponents.url?.absoluteString,
              let percentEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let resultUrl = URL(string: percentEncoded) else {
            return url
        }
        return resultUrl
    }
    
    
    private func resetPlayer() {
        retryManager?.action( .stopRetry )
        player?.pause()
        player?.currentItem?.asset.cancelLoading()
        player?.cancelPendingPrerolls()
        player?.replaceCurrentItem(with: nil)
        playerItem = nil
    }
    
    private func setRefreshTimer() {
        self.invalidateRefreshTimer()
        self.resultHandler?( .setSnapShotImage(nil) )
        self.resultHandler?( .requestShowOrHideBackgroundPosterImageView(needToSHow: true) )
        refreshTimer = DispatchSource.makeTimerSource()
        refreshTimer?.schedule(deadline: .now() + 30.0, repeating: .never)
        refreshTimer?.setEventHandler(handler: { [weak self] in
            DispatchQueue.main.async {
                self?.onReloadOverlayWebView()
                self?.refreshTimer = nil
            }
        })
        refreshTimer?.resume()
    }
    
    private func invalidateRefreshTimer() {
        if refreshTimer != nil && refreshTimer!.isCancelled == false {
            refreshTimer?.cancel()
            refreshTimer = nil
        }
    }
}
extension ShopLivePlayerPreviewViewModel  : AVPlayerItemMetadataOutputPushDelegate {
    public func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        let payloads: NSMutableDictionary = .init()
        var timedMeta: String = "[timedMeta]\n"
        groups.forEach { group in
            group.items.forEach { item in
                if let key = item.key as? String, let datav = item.value as? Data {
                    timedMeta += "\(key): \(String(describing: item.value)) \n"
                    payloads[key] = datav.base64EncodedString()
                }
            }
        }
        
        if payloads.count > 0 {
            resultHandler?( .sendEventToWeb(event: .onVideoMetadataUpdated, param: payloads.toJson_SL(), wrapping: false, dedicatedCompletionType: nil))
        }
    }
}
//MARK: - PeriodicTimerObserver logics
extension ShopLivePlayerPreviewViewModel {
    private func addPlayTimeObserver() {
        removePlayTimeObserver()
        let time = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        playTimeObserver = player?.addPeriodicTimeObserver(forInterval: time, queue: nil) { [weak self] (time) in
            let curTime = CMTimeGetSeconds(time)
            self?.resultHandler?( .sendEventToWeb(event: .onVideoTimeUpdated, param: curTime, wrapping: false, dedicatedCompletionType: nil))
        }
    }
    
    private func removePlayTimeObserver() {
        if let playTimeObserver = self.playTimeObserver {
            player?.removeTimeObserver(playTimeObserver)
            self.playTimeObserver = nil
        }
    }
}
extension ShopLivePlayerPreviewViewModel {
    private func addAVPlayerObserver() {
        removeAVPlayerObserver()
        if let playerItem = self.playerItem {
            playerItemStatusObserver = playerItem.observe(\.status, options: [.initial,.new] , changeHandler: { [weak self] playerItem, value in
                guard let self = self else { return}
                self.onPlayerItemStatusChanged(status : playerItem.status)
            })
        }
        if let player = self.player {
            playerLoadedTimeRangeObserver = player.observe(\.currentItem?.loadedTimeRanges, options: [.initial,.new] , changeHandler: { [weak self] player, value  in
                guard let self = self, let value = value.newValue else { return }
                self.onLoadedTimeRangesChanged(changed: value)
            })
        }
    }
    
    private func removeAVPlayerObserver() {
        playerItemStatusObserver?.invalidate()
        playerItemStatusObserver = nil
        playerLoadedTimeRangeObserver?.invalidate()
        playerLoadedTimeRangeObserver = nil
    }
    
    //MARK: -playerIteStatusChanged
    private func onPlayerItemStatusChanged(status : AVPlayerItem.Status) {
        
        switch status {
        case .readyToPlay:
            self.onPlayerItemStatusReadyToPlay()
        case .failed:
            self.onPlayerItemStatusFailed()
        default:
            ShopLiveLogger.tempLog("[PlayerStatus] playerItem unknown")
            self.onPlayerItemStatusFailed()
            break
        }
        resultHandler?( .didChangeAVPlayerItemStatus(status) )
    }
    
    private func onPlayerItemStatusReadyToPlay() {
        guard let pm = playControlManager else { return }
        ShopLiveLogger.tempLog("[PlayerStatus] playerItemReadyToPlay")
        if pm.getCurrentPlayCommand() != .pause, pm.getCurrentPlayCommand() != .play {
            if pm.getCurrentPlayCommand() == .resume { return }
            if let duration = pm.getVideoDuration(),
               pm.getIsReplayMode() {
                resultHandler?( .sendEventToWeb(event: .onVideoDurationChanged, param: CMTimeGetSeconds(duration), wrapping: false, dedicatedCompletionType: nil))
            }
            pm.playControlAction( .pause )
            retryManager?.action( .stopRetry )
            self.onRequestTakeSnapshot()
        }
    }
    
    private func onPlayerItemStatusFailed() {
        ShopLiveLogger.tempLog("[PlayerStatus] playerItem Status failed")
        retryManager?.action( .startRetry(delayed: 2) )
    }
    
    //MARK: -loadedTimeRanges
    private func onLoadedTimeRangesChanged(changed : [NSValue]?) {
        guard let timeRange = changed?.last as? CMTimeRange else { return }
        
        let timeLoaded = Int(timeRange.duration.value) / Int(timeRange.duration.timescale)
        
        if timeLoaded > 4 && self.getTimeControlStatus() == .waitingToPlayAtSpecifiedRate {
//            self.playControlManager?.playControlAction( .play )
        }
    }
}
extension ShopLivePlayerPreviewViewModel {
    public func getOverLayUrlWithInfosAttached() -> URL? {
        guard let baseUrl = overlayUrl else { return nil }
        let urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "ak", value: ShopLiveCommon.getAccessKey()))
        queryItems.append(URLQueryItem(name: "ck", value: self.campaignKey))
        
        queryItems.append(URLQueryItem(name: "tk", value: ShopLiveCommon.getAuthTokenForPlayer() ?? ""))
        
        
        if let user = ShopLiveCommon.getUser() {
            queryItems.append(URLQueryItem(name: "userId", value: user.userId))
            if let name = user.userName, !name.isEmpty {
                queryItems.append(URLQueryItem(name: "userName", value: name))
            }
            if let gender = user.gender {
                queryItems.append(URLQueryItem(name: "gender", value: gender.rawValue))
            }
            if let age = user.age, age > 0 {
                queryItems.append(URLQueryItem(name: "age", value: String(age)))
            }
            if let userScore = user.userScore {
                queryItems.append(URLQueryItem(name: "userScore", value: String(userScore)))
            }
            
            
            if let additional = user.custom, !additional.isEmpty {
                let nilAvoided = (additional  as [String : Any?]).filter({ $0.value != nil })
                nilAvoided.forEach { (key: String, value: Any?) in
                    guard let value = value else { return }
                    if value is [Any] {
                        let resultValue = "\"" + String(describing: value) + "\""
                        if resultValue.isEmpty == false {
                            queryItems.append(URLQueryItem(name: key, value: resultValue ))
                        }
                    }
                    else {
                        let resultValue = String(describing: value)
                        if resultValue.isEmpty == false {
                            queryItems.append(URLQueryItem(name: key, value: resultValue ))
                        }
                    }
                }
            }
        }
        
        if let adid = ShopLiveCommon.getAdId(), !adid.isEmpty {
            queryItems.append(URLQueryItem(name: "adId", value: adid))
        }
        
        if let adId = ShopLiveCommon.getAdIdentifier(), !adId.isEmpty {
            queryItems.append(URLQueryItem(name: "adIdentifier", value: adId))
            queryItems.append(URLQueryItem(name: "idfa", value: adId))
        }
        
        if let shopliveSessionId = self.shopliveSessionId {
            queryItems.append(URLQueryItem(name: "shopliveSessionId", value: shopliveSessionId))
        }
        
        if let ceId = ShopLiveCommon.getCeId(), !ceId.isEmpty {
            queryItems.append(URLQueryItem(name: "ceId", value: ceId))
        }
        
        if let idfv = UIDevice.idfv_sl, idfv.isEmpty == false {
            queryItems.append(URLQueryItem(name: "idfv", value: idfv))
        }
        
        if let anondId = ShopLiveCommon.getAnonId(), !anondId.isEmpty {
            queryItems.append(URLQueryItem(name: "anonId", value: anondId))
        }
        
        queryItems.append(URLQueryItem(name: "eSlSid", value: self.shopliveSessionId ?? ""))
        
        if let utm_source = ShopLiveCommon.getUtmSource(), utm_source.isEmpty == false {
            queryItems.append(URLQueryItem(name: "utm_source", value: utm_source))
        }
        if let utm_content = ShopLiveCommon.getUtmContent(), utm_content.isEmpty == false {
            queryItems.append(URLQueryItem(name: "utm_content", value: utm_content))
        }
        if let utm_campaign = ShopLiveCommon.getUtmCampaign(), utm_campaign.isEmpty == false {
            queryItems.append(URLQueryItem(name: "utm_campaign", value: utm_campaign))
        }
        if let utm_medium = ShopLiveCommon.getUtmMedium(), utm_medium.isEmpty == false {
            queryItems.append(URLQueryItem(name: "utm_medium", value: utm_medium))
        }
        
        queryItems.append(URLQueryItem(name: "osType", value: "i"))
        queryItems.append(URLQueryItem(name: "osVersion", value: ShopLiveDefines.osVersion))
        queryItems.append(URLQueryItem(name: "device", value: ShopLiveDefines.deviceIdentifier))
        queryItems.append(URLQueryItem(name: "version", value: ShopLiveCommon.playerSdkVersion))
        
        
        queryItems.append(URLQueryItem(name: "appVersion", value: ShopLiveConfiguration.AppPreference.appVersion ?? UIApplication.appVersion()))
        
        queryItems.append(URLQueryItem(name: "manualRotation", value: "false"))
        
        ShopLiveConfiguration.Data.customParameters.forEach { (key: String, value: Any) in
            queryItems.append(URLQueryItem(name: key, value: "\(value)"))
        }
        
        let urlString: String = ShopLiveConfiguration.AppPreference.landingUrl
        guard let params = URLUtil_SL.query(queryItems) else {
            return URL(string: urlString)
        }
        
        guard let url = URL(string: urlString + "?" + params) else {
            return URL(string: urlString)
        }
        
        return url
    }
    
    public func getUseCloseBtnIsEnabled() -> Bool {
        return self.useCloseButton
    }
    
    public func getCurrentNetworkType() -> String {
        return currentNetworkCapability
    }
    
    public func getStreamActivityType() -> StreamActivityType {
        return streamActivityType
    }
    
    public func getCampaignId() -> String {
        return campaignId
    }
    
    public func getCampaignKey() -> String {
        return campaignKey
    }
    
    public func getResizeMode() -> ShopLiveResizeMode? {
        return customVideoResizeMode
    }
    
    public func getShopLiveSessionId() -> String? {
        return shopliveSessionId
    }
    
    public func getSteamEdgeTyinitializepe() -> String? {
        return streamEdgeType
    }
    
    public func getIsSuccessCampaignJoin() -> Bool {
        return isSuccessCampaignJoin
    }
    
    public func getCurrentWebViewUrl() -> URL? {
        return delegate?.getCurrentWebViewUrl()
    }
    
    public func getPlayer() -> AVPlayer? {
        return self.player
    }
    
    public func getPlayerItem() -> AVPlayerItem? {
        return self.playerItem
    }
    
    public func getIsReplayMode() -> Bool {
        return playControlManager?.getIsReplayMode() ?? false
    }
    
    public func getNeedSeek() -> Bool {
        return playControlManager?.getNeedSeek() ?? false
    }
    
    public func getTimeControlStatus() -> AVPlayer.TimeControlStatus {
        return .waitingToPlayAtSpecifiedRate
    }
    
    public func getVideoDuration() -> CMTime? {
        return playControlManager?.getVideoDuration()
    }
    
    public func getIsReplayFinished() -> Bool {
        return playControlManager?.isReplayFinised() ?? false
    }
    
    func getVideoRatio() -> CGSize {
        return videoRatio
    }
    
    func getCurrentResolution() -> ShopLivePlayerPreviewResolution {
        return self.currentResolution
    }
    
    func getCurrentPlayCommand() -> PlayControlManager.PlayCommand {
        return playControlManager?.getCurrentPlayCommand() ?? .none
    }
}
//MARK: - bind PlayControlManager
extension ShopLivePlayerPreviewViewModel {
    private func bindPlayControlManager() {
        playControlManager?.resultHandler = { [weak self] result in
            guard let self = self else { return }
            ShopLiveLogger.tempLog("[VIEWVMODEL] playControlManager result \(result)")
            switch result {
            case .didChangeCurrentPlayCommand(let playCommand):
                self.onPlayControlManagerDidChangeCurrentPlayCommand(playCommand: playCommand)
            case .requestInitPlayer(let url):
                self.onPlayControlManagerRequestInitPlayer(url: url)
            case .requestSetCurrentPlayTime(let currenTime):
                self.onPlayControlManagerRequestSetCurrentPlayTime(time: currenTime)
            case .requestSetNeedReload(let needReload):
                self.onPlayControlManagerRequestSetNeedReload(needReload: needReload)
            case .resetPlayer:
                self.onPlayControlManagerResetPlay()
            case .sendEventToWeb(event: let event, param: let param, wrapping: let wrapping, dedicatedCompletionType: let dedicatedCompletionType):
                self.onPlayControlManagerSendEventToWeb(event: event, param: param, wrapping: wrapping, dedicatedCompletionType: dedicatedCompletionType)
            }
        }
    }
    
    
    private func onPlayControlManagerDidChangeCurrentPlayCommand(playCommand : PlayControlManager.PlayCommand) {
        self.currentPlayCommand = playCommand
        timeControlStatusManager?.action( .setCurrentPlayCommand(playCommand) )
    }
    
    private func onPlayControlManagerRequestInitPlayer(url : URL?) {
        guard let url = url else { return }
        self.previewUrl = url
        self.updatePlayerItem(with: url)
    }
    
    private func onPlayControlManagerRequestSetCurrentPlayTime(time : CMTime?) {
        self.currentPlayTime = time
    }
    
    private func onPlayControlManagerRequestSetNeedReload(needReload : Bool) {
        //
    }
    
    private func onPlayControlManagerResetPlay() {
        self.resetPlayer()
    }
    
    private func onPlayControlManagerSendEventToWeb(event : WebInterface, param : Any?, wrapping : Bool = false, dedicatedCompletionType : DedicatedWebViewCommandCompletionType?) {
        self.resultHandler?( .sendEventToWeb(event: event, param: param, wrapping: wrapping, dedicatedCompletionType: dedicatedCompletionType))
    }
}
//MARK: - bind timeControlStatus
extension ShopLivePlayerPreviewViewModel {
    private func bindTimeControlStatusManager() {
        timeControlStatusManager?.resultHandler = { [weak self] result in
            guard let self = self else { return }
            ShopLiveLogger.tempLog("[VIEWMODEL] timeControlStatusManager result \(result)")
            switch result {
            case .requestPlayControl(let playControl):
                self.onTimeControlStatusManagerRequestPlayControl(playControl: playControl)
            case .requestRetry(delay: let delay):
                self.onTimeControlStatusManagerRequestRetry(delay: delay)
            case .requestRetryOnNetworkDisConnected:
                self.onTimeControlStatusManagerRequestRetryOnNetworkDisConnected()
            case .requestSetNeedSeek(let needSeek):
                self.onTimeControlStatusManagerRequestSetNeedSeek(needSeek: needSeek)
            case .requestShowOrHideBackgroundPosterImageView(needToShow: let needToShow):
                self.onTimeControlStatusManagerRequestShowOrHideBackgroundPosterImageView(needToShow: needToShow)
            case .requestShowOrHideLoading(needToShow: let needToShow):
                self.onTimeControlStatusManagerRequestShowOrHideLoading(needToShow: needToShow)
            case .requestStopRetry:
                self.onTimeControlStatusManagerRequestStopRetry()
            case .requestTakeSnapShot:
                self.onRequestTakeSnapshot()
            case .sendEventToWeb(event: let event, param: let param, wrapping: let wrapping , dedicatedCompletionType: let dedicatedCompletionType):
                self.onTimeControlStatusManagerSendEventToWeb(event: event, param: param, wrapping: wrapping, dedicatedCompletionType: dedicatedCompletionType)
            case .sendVideoError(errorCase: let errorCase, reason: let reason):
                self.onTimeControlStatusManagerSendVideoError(errorCase: errorCase, reason: reason)
            case .timeControlStatusDidChange(let timeControlStatus):
                self.onTimeControlStatusManagerTimeControlStatusDidChange(status: timeControlStatus)
            }
        }
    }
    
    private func onTimeControlStatusManagerRequestPlayControl(playControl : ShopLivePlayerControlAction ) {
        playControlManager?.playControlAction( playControl )
    }
    
    private func onTimeControlStatusManagerRequestRetry(delay : Int) {
        retryManager?.action( .startRetry(delayed: delay) )
    }
    
    private func onTimeControlStatusManagerRequestRetryOnNetworkDisConnected() {
        retryManager?.action( .retryWebViewOnNetworkDisconnected )
    }
    
    private func onTimeControlStatusManagerRequestSetNeedSeek(needSeek : Bool) {
        playControlManager?.action( .setNeedSeek(needSeek) )
    }
    
    private func onTimeControlStatusManagerRequestShowOrHideBackgroundPosterImageView(needToShow : Bool) {
        self.resultHandler?( .requestShowOrHideBackgroundPosterImageView(needToSHow: needToShow) )
    }
    
    private func onTimeControlStatusManagerRequestShowOrHideLoading(needToShow : Bool) {
    }
    
    private func onTimeControlStatusManagerRequestStopRetry() {
        retryManager?.action( .stopRetry )
    }
    
    private func onTimeControlStatusManagerRequestTakeSnapShot() {
        self.onRequestTakeSnapshot()
    }
    
    private func onTimeControlStatusManagerSendEventToWeb(event : WebInterface, param : Any?, wrapping : Bool = false, dedicatedCompletionType : DedicatedWebViewCommandCompletionType?) {
        self.resultHandler?( .sendEventToWeb(event: event, param: param, wrapping: wrapping, dedicatedCompletionType: dedicatedCompletionType))
    }
    
    private func onTimeControlStatusManagerSendVideoError(errorCase : ShopLiveAVPlayerErrorObserver.ErrorCase, reason : String) {
        
    }
    
    private func onTimeControlStatusManagerTimeControlStatusDidChange(status : AVPlayer.TimeControlStatus) {
        resultHandler?( .didChangeAVPlayerTimeControlStatus(status) )
    }
}
extension ShopLivePlayerPreviewViewModel : ShopLivePreviewRetryManagerDelegate {
    private func bindRetryManager(){
        retryManager?.resultHandler = { [weak self] result in
            guard let self = self else { return }
            ShopLiveLogger.tempLog("[VIEWMODEL] retryManager result \(result)")
            switch result {
            case .playerItemCancelPendingSeek:
                self.onRetryManagerPlayerItemCancelPendingSeeks()
            case .requestSeekToLatest:
                self.onRetryManagerSeekToLatest()
            case .requestResume:
                self.onRetryManagerRequestResume()
            case .reloadWebView:
                self.onRetryManagerReloadWebView()
            case .updatePlayerItem:
                self.onRetryManagerUpdatePlayerItem()
            case .requestHideOrShowLoading(needToShow: let needToShow):
                self.onRetryManagerRequestHideOrShowLoading(needToShow: needToShow)
            }
        }
    }
    
    private func onRetryManagerPlayerItemCancelPendingSeeks() {
        player?.currentItem?.cancelPendingSeeks()
    }
    
    private func onRetryManagerReloadWebView() {
        guard let url = self.getOverLayUrlWithInfosAttached() else { return }
        resultHandler?( .reloadWebView(url: url) )
    }
    
    private func onRetryManagerRequestHideOrShowLoading(needToShow : Bool) {
    }
    
    private func onRetryManagerSeekToLatest() {
        self.onSeekToLatest()
    }
    
    private func onRetryManagerUpdatePlayerItem() {
        guard let url = self.previewUrl else {
            ShopLiveLogger.tempLog("[RETRYMANAGER] updatePlayerItem with null liveUrl")
            return
        }
        self.updatePlayerItem(with: url)
    }
    
    private func onRetryManagerRequestResume() {
        playControlManager?.playControlAction( .resume )
    }
    
    
    func getCurrentPreviewUrl() -> URL? {
        return self.previewUrl
    }
}
//MARK: - bind audioSessionManager
extension ShopLivePlayerPreviewViewModel {
    private func bindAudioSessionManager() {
        ShopLivePlayerPreviewAudioSessionManager.shared.resultHandler = { [weak self] result in
            guard let self = self else { return }
            ShopLiveLogger.tempLog("[VIEWMODEL] audioSessionManager result \(result)")
            switch result {
            case .log(name: let name, feature: let feature, payload: let payload):
                self.onAudioSessionManagerLog(name: name, feature: feature, campaignKey: campaignKey, payload: payload)
            case .setIsMuted(isMuted: let isMuted):
                self.onAudioSessionManagerSetIsMute(isMuted: isMuted)
            case .sendEventToWeb(event: let event, param: let param, wrapping: let wrapping):
                self.onAudioSessionManagerSendEventToWeb(event: event, param: param,wrapping: wrapping, dedicatedCompletionType: nil)
            case .sendCommandToWeb(command: let command, payload: let payload):
                self.onAudioSessionManagerSendCommandToWeb(command: command, payload: payload)
            case .requestVideoPlay:
                self.onAudioSessionManagerRequestPlayVideo()
            case .requestVideoPause:
                self.onAudioSessionManagerRequestPauseVideo()
            case .requestVideoResume:
                self.onAudioSessionManagerRequestResumeVideo()
            case .requestVideoStop:
                self.onAudioSessionManagerRequestStopVideo()
            }
        }
    }
    
    private func onAudioSessionManagerLog(name : String, feature : ShopLiveLog.Feature, campaignKey : String , payload : [String : Any]?) {
        resultHandler?( .log(name: name, feature: feature, campaignKey: campaignKey, payload: payload))
    }
    
    private func onAudioSessionManagerSetIsMute(isMuted : Bool){
        self.isMuted = isMuted
        DispatchQueue.main.async { [weak self] in
            self?.player?.isMuted = isMuted
        }
    }
    
    private func onAudioSessionManagerSendEventToWeb(event : WebInterface, param : Any?, wrapping : Bool = false, dedicatedCompletionType : DedicatedWebViewCommandCompletionType?) {
        resultHandler?( .sendEventToWeb(event: event, param: param, wrapping: wrapping, dedicatedCompletionType: dedicatedCompletionType))
    }
    
    private func onAudioSessionManagerSendCommandToWeb(command : String, payload : [String : Any]?) {
        resultHandler?( .sendCommandMessageToWeb(command: command, payload: payload) )
    }
    
    private func onAudioSessionManagerRequestPlayVideo() {
        playControlManager?.playControlAction( .play )
    }
    
    private func onAudioSessionManagerRequestPauseVideo() {
        playControlManager?.playControlAction( .pause )
    }
    
    private func onAudioSessionManagerRequestResumeVideo() {
        playControlManager?.playControlAction( .resume )
    }
    
    private func onAudioSessionManagerRequestStopVideo() {
        playControlManager?.playControlAction( .stop )
    }
    
}
