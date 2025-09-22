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

protocol ShopLivePreviewModelDelegate: NSObjectProtocol {
    func getCurrentWebViewUrl() -> URL?
}

final class ShopLivePlayerPreviewViewModel: NSObject, SLReactor {
    
    private let publicLogPrefix = "PLAYERPREVIEW-VIEWMODEL"
    var indexPath: IndexPath?
    private var overlayUrl: URL?
    private var currentNetworkCapability: String = ""
    private var isMuted: Bool = true
//    ShopLiveConfiguration.SoundPolicy.isMutedWhenStart
    private var player: AVPlayer?
    private var urlAsset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private var videoOutput: AVPlayerItemVideoOutput?
    private var playerLayer: AVPlayerLayer?
    private var currentPlayCommand: PlayControlManager.PlayCommand = .none
    private var refreshTimer: DispatchSourceTimer? // 30초우에 preview 갱신하는 타이머
    
    

    private var previewUrl: URL?
//    private var liveUrl: URL?
    
    private var playTimeObserver: Any?
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var playerLoadedTimeRangeObserver: NSKeyValueObservation?
    private var isAlreadyPlayedOnce: Bool = false
    private var playerLoadingStartTime: Double?
    
    
    //stream data
    private var streamActivityType: StreamActivityType = .ready
    private var campaignId: String = ""
    private var shopliveSessionId: String? = nil
    private var streamEdgeType: String?
    private var currentPlayTime: CMTime?
    private var currentResolution: ShopLivePlayerPreviewResolution = .LIVE
    
    //viewdata
    private var actualVideoRenderedRect: CGRect = .zero
    private var customVideoResizeMode: ShopLiveResizeMode?
    private var useCloseButton: Bool = false
    private var isWebViewDidCompleteLoading: Bool = false
    var videoOrientation: ShopLiveDefines.ShopLiveOrientaion {
        switch supportOrientation {
        case .portrait, .unknown:
            return .portrait
        case .landscape:
            return .landscape
        }
    }
    var supportOrientation: ShopLive.VideoOrientation = .unknown
    lazy var videoRatio: CGSize = videoOrientation == .landscape ? CGSize(width: 16, height: 9): CGSize(width: 9, height: 16)
    
    //campaignState
    private var campaignStatus: ShopLiveCampaignStatus = .close
    private var campaignKey: String = ""
    private var isSuccessCampaignJoin: Bool = false
    
    
    private var playControlManager: PlayControlManager?
    private var timeControlStatusManager: TimeControlStatusManager?
    private var eventTraceManager: ShopLivePlayerEventTraceManagerImpl?
    private var retryManager: PreviewRetryManager?
    
    private weak var delegate: ShopLivePreviewModelDelegate?
    
    enum Action {
        case initialize
        case reloadOverlayWebView
        case loadOverlayWebView
        case setDelegate(ShopLivePreviewModelDelegate?)
        case setOverlayUrl(URL?)
        case setSoundMuteStateOnWebViewSetConf
        case setSoundMute(isMuted: Bool, needToSendToWeb: Bool)
        case setStreamEdgeType(type: String?)
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
        case requestTakeSnapShotWithCompletion(completion: (() -> ())?)
        case retryOnNetworkDisConnect
        case resetRetryFromWebview
        case resetPlayer
        case initPlayer(URL?)
        case setAVPlayer(AVPlayer?)
        case setAVPlayerLayer(AVPlayerLayer?)
        case setIsReplayMode(Bool)
        case setNeedSeek(Bool)
        case setNeedReload(Bool)
        case setPlaybackSpeed(Float)
        case sendPreviewShowEventTrace
        
        
        case playControlAction(PlayControlManager.PlayCommand)
        case setPlayControlActionToNone
        
    }
    
    enum Result {
        case requestShowOrHideSnapShotImageView(needToShow: Bool)
        case requestShowOrHideBackgroundPosterImageView(needToSHow: Bool)
        case requestShowOrHideOSPictureInPicture(needToShow: Bool)
        case requestSetShopLivePlayerSessionState(PlayerSessionState)
        case requestSetAlphaToWebView(alpha: CGFloat)
        
        case reloadWebView(url: URL)
        case sendNetworkCapabilityOnChanged(networkCapability: String)
        case updateSnapShotImageViewFrameWithRatio(ratio: CGSize)
        
        
        case log(name: String, feature: ShopLiveLog.Feature, campaignKey: String , payload: [String: Any]?)
        case sendEventToWeb(event: WebInterface, param: Any?, wrapping: Bool = false)
        case sendCommandMessageToWeb(command: String, payload: [String: Any]?)
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
        retryManager = PreviewRetryManager(delegate: self)
        self.bindPlayControlManager()
        self.bindTimeControlStatusManager()
        self.bindRetryManager()
        self.bindAudioSessionManager()
        self.shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        self.eventTraceManager?.stateAction( .setShopLiveSessionId(self.shopliveSessionId))
    }
    
    func action(_ action: Action) {
        switch action {
        case .initialize:
            onInitialize()
            
        case .setDelegate(let delegate):
            self.delegate = delegate
            
        case .reloadOverlayWebView:
            onReloadOverlayWebView()
            
        case .loadOverlayWebView:
            guard let url = self.getOverLayUrlWithInfosAttached() else { return }
            resultHandler?( .reloadWebView(url: url) )
            
        case .retryOnNetworkDisConnect:
            retryManager?.action( .retryWebViewOnNetworkDisconnected )
            
        case let .setOverlayUrl(url):
            self.overlayUrl = url
            
        case .setSoundMuteStateOnWebViewSetConf:
            PlayerPreviewAudioSessionManager.shared.action( .setSoundMuteStateOnFirstPlay(isMuted: self.isMuted) )
            
        case .setSoundMute(let isMuted, let needToSendToWeb):
            onSetSoundMute(isMuted: isMuted, needToSendToWeb: needToSendToWeb)
            
        case .setStreamEdgeType(let type):
            self.streamEdgeType = type
            eventTraceManager?.stateAction( .setStreamEdgeType(type) )
            
        case .setCampaignId(let campaignId):
            eventTraceManager?.stateAction(.setCampaignId(campaignId))
            self.campaignId = campaignId
            
        case .setCampaignKey(let campaignKey):
            self.campaignKey = campaignKey
            
        case .setCampaignStatus(let status):
            self.campaignStatus = status
            
        case .setResizeMode(let mode):
            self.customVideoResizeMode = mode
            
        case .setStreamActivityType(let type):
            onSetStreamActivityType(type: type)
            
        case .setWebViewLoadingCompleted(let isCompleted):
            self.isWebViewDidCompleteLoading = isCompleted
            
        case .setRefreshTimer:
            setRefreshTimer()
            
        case .setResolution(let resolution):
            self.currentResolution = resolution
            
        case .setAudioSessonCategory:
            PlayerPreviewAudioSessionManager.shared.action( .setAudioSessionCategory )
            
        case let .parseRatioStringAndSetData(ratio):
            onParseRatioStringAndSetData(ratio: ratio)
            
        case .tearDownViewModel:
            onTearDownViewModel()
            
            //MARK: - hls actions
        case .reloadVideo:
            onReloadVideo()
            
        case .seekTo(let time): // CMTime
            onSeekTo(time: time)
            
        case .seekToLatest:
            playControlManager?.action( .seekToLatest )
            
        case .didUpdateVideoUrl(let url): // URL
            onDidUpdateVideoUrl(url: url)
            
        case .requestTakeSnapshot:
            onRequestTakeSnapshot()
            
        case .requestTakeSnapShotWithCompletion(let completion): // (() -> ())?
            onRequestTakeSnapShotWithCompletion(completion: completion)
            
        case .resetRetryFromWebview:
            onResetRetryFromWebview()
            
        case .resetPlayer:
            self.resetPlayer()
            
        case .initPlayer(let url): // URL?
            guard let url = url else { return }
            playControlManager?.setLiveURL(url)
            self.updatePlayerItem(with: url)
            
        case .setAVPlayer(let player): // AVPlayer?
            self.player = player
            
        case .setAVPlayerLayer(let layer):
            self.playerLayer = layer
            
        case .setIsReplayMode(let isReplayMode): // Bool
            PlayerPreviewAudioSessionManager.shared.action( .setIsReplayMode(isReplayMode))
            playControlManager?.setIsReplayMode(by: isReplayMode)
            
        case .setNeedSeek(let needSeek): // Bool
            playControlManager?.setNeedSeek(needSeek)
            
        case .setNeedReload(let needReload): // bool
            playControlManager?.setNeedReload(needReload)
            
        case .playControlAction(let command):
            playControlManager?.action(.controlPlayer(command))
        case .setPlaybackSpeed(let speed):
            self.player?.rate = speed
            
        case .sendPreviewShowEventTrace:
            eventTraceManager?.eventTraceAction( .previewShow )
            
        case .setPlayControlActionToNone:
            self.currentPlayCommand = .none
            playControlManager?.setPlayCommandToNone()
        }
    }
    
    private func onInitialize() {
        self.previewUrl = nil
        self.playerItem = nil
        self.currentPlayCommand = .none
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
    
    private func onReloadOverlayWebView() {
        guard let url = self.getOverLayUrlWithInfosAttached() else { return }
        resultHandler?( .reloadWebView(url: url) )
    }
    
    private func onSetSoundMute(isMuted: Bool, needToSendToWeb: Bool) {
        self.isMuted = isMuted
        player?.isMuted = isMuted
        if needToSendToWeb {
            resultHandler?( .sendEventToWeb(event: .setVideoMute(isMuted: isMuted), param: isMuted, wrapping: false))
        }
    }
    
    private func onSetStreamActivityType(type: String) {
        for aType in StreamActivityType.allCases {
            if aType.rawValue == type {
                self.streamActivityType = aType
                eventTraceManager?.stateAction( .setStreamActivityType(aType) )
            }
        }
    }
    
    private func onParseRatioStringAndSetData(ratio: String?) {
        if let ratio = ratio {
            let parseRatio = ratio.split(separator: ":")
            if parseRatio.isEmpty {
                videoRatio = ShopLiveDefines.defVideoRatio
                supportOrientation = .portrait
            } else {
                if parseRatio.count == 2, let width = Int(parseRatio[0]), let height = Int(parseRatio[1]) {
                    videoRatio = CGSize(width: width, height: height)
                    supportOrientation = width > height ? .landscape: .portrait
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
        self.currentPlayCommand = .none
        playControlManager?.setPlayCommandToNone()
        removePlayTimeObserver()
        resetPlayer()
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
        self.currentPlayTime = time
        playControlManager?.action( .seekTo(time) )
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
        playControlManager?.setLiveURL(previewQueryAddedUrl)
        self.updatePlayerItem(with: previewQueryAddedUrl)
        if let playControlManager = playControlManager,
           playControlManager.isReplayMode, let startTime = self.currentPlayTime {
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
    
    private func onUpdatePlayBackSpeed(rate: Float) {
        self.player?.rate = rate
    }
    
    private func onResetRetryFromWebview() {
        if playerItem?.status == .readyToPlay {
            retryManager?.action( .stopRetry )
        }
    }
}
extension ShopLivePlayerPreviewViewModel {
    private func updatePlayerItem(with url: URL,from: String = #function) {
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
        
        if playControlManager?.isReplayMode ?? false {
            playerItem.preferredForwardBufferDuration = 2.5
        }
        
        playerItem.audioTimePitchAlgorithm = .timeDomain
        
        self.playerItem = playerItem
        self.player?.replaceCurrentItem(with: playerItem)
        if let player = self.player {
            addAVPlayerObserver()
            playControlManager?.setAVPlayer(player)
            playControlManager?.setAVPlayerItem(playerItem)
            
            
            timeControlStatusManager?.action( .setAVPlayer(player) )
            timeControlStatusManager?.action( .setAVPlayerItem(playerItem) )
            timeControlStatusManager?.action( .setCampaignStatus(campaignStatus) )
            timeControlStatusManager?.action( .setIsReplayMode(playControlManager?.isReplayMode ?? false) )
            timeControlStatusManager?.action( .startObserving )
        }
        addPlayTimeObserver()
        setVideoOutput()
    }
    
    private func setSoundMuteStateOnFirstPlay() {
        guard timeControlStatusManager?.getIsAlreadyPlayedOnce() == false else { return }
        PlayerPreviewAudioSessionManager.shared.action( .setSoundMuteStateOnFirstPlay(isMuted: self.isMuted) )
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
    
    private func addQueryForLiveUrl(url: URL) -> URL {
        guard var urlComponents = URLComponents(string: url.absoluteString) else { return url }
        var addQueryItems: [URLQueryItem] = []
        
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
    
    private func checkIfLiveUrlContainsPreviewQueryAndAppendIfNotExist(url: URL) -> URL {
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
extension ShopLivePlayerPreviewViewModel : AVPlayerItemMetadataOutputPushDelegate {
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
            resultHandler?( .sendEventToWeb(event: .onVideoMetadataUpdated, param: payloads.toJson_SL(), wrapping: false))
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
            self?.resultHandler?( .sendEventToWeb(event: .onVideoTimeUpdated, param: curTime, wrapping: false))
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
                self.onPlayerItemStatusChanged(status: playerItem.status)
            })
        }
    }
    
    private func removeAVPlayerObserver(from: String = #function) {
        playerItemStatusObserver?.invalidate()
        playerItemStatusObserver = nil
        playerLoadedTimeRangeObserver?.invalidate()
        playerLoadedTimeRangeObserver = nil
    }
    
    //MARK: -playerIteStatusChanged
    private func onPlayerItemStatusChanged(status: AVPlayerItem.Status) {
        if .readyToPlay == status {
            self.onPlayerItemStatusReadyToPlay()
        }
        resultHandler?( .didChangeAVPlayerItemStatus(status) )
    }
    
    private func onPlayerItemStatusReadyToPlay() {
        self.player?.isMuted = isMuted
        guard let pm = playControlManager else { return }
        if pm.currentPlayCommand != .pause,
           pm.currentPlayCommand != .play {
            if pm.currentPlayCommand == .resume { return }
            if let duration = pm.getVideoDuration(),
               pm.isReplayMode {
                resultHandler?( .sendEventToWeb(event: .onVideoDurationChanged, param: CMTimeGetSeconds(duration), wrapping: false))
            }
            pm.action(.controlPlayer(.pause))
            retryManager?.action( .stopRetry )
            self.onRequestTakeSnapshot()
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
                let nilAvoided = (additional  as [String: Any?]).filter({ $0.value != nil })
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
        let params = queryItems.queryStringRFC3986
        
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
        return playControlManager?.isReplayMode ?? false
    }
    
    public func getNeedSeek() -> Bool {
        return playControlManager?.needSeek ?? false
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
        return playControlManager?.currentPlayCommand ?? .none
    }
}
//MARK: - bind PlayControlManager
extension ShopLivePlayerPreviewViewModel {
    private func bindPlayControlManager() {
        playControlManager?.resultHandler = { [weak self] result in
            guard let self else { return }
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
            case .sendEventToWeb(event: let event, param: let param, wrapping: let wrapping):
                self.onPlayControlManagerSendEventToWeb(event: event, param: param, wrapping: wrapping)
            }
        }
    }
    
    
    private func onPlayControlManagerDidChangeCurrentPlayCommand(playCommand: PlayControlManager.PlayCommand) {
        self.currentPlayCommand = playCommand
        timeControlStatusManager?.action( .setCurrentPlayCommand(playCommand) )
    }
    
    private func onPlayControlManagerRequestInitPlayer(url: URL?) {
        guard let url = url else { return }
        self.previewUrl = url
        self.updatePlayerItem(with: url)
    }
    
    private func onPlayControlManagerRequestSetCurrentPlayTime(time: CMTime?) {
        self.currentPlayTime = time
    }
    
    private func onPlayControlManagerRequestSetNeedReload(needReload: Bool) {
        //
    }
    
    private func onPlayControlManagerResetPlay() {
        self.resetPlayer()
    }
    
    private func onPlayControlManagerSendEventToWeb(event: WebInterface, param: Any?, wrapping: Bool = false) {
        self.resultHandler?( .sendEventToWeb(event: event, param: param, wrapping: wrapping))
    }
}
//MARK: - bind timeControlStatus
extension ShopLivePlayerPreviewViewModel {
    private func bindTimeControlStatusManager() {
        timeControlStatusManager?.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .requestPlayControl(let command):
                playControlManager?.action(.controlPlayer(command))
            case .requestRetry(delay: let delay):
                retryManager?.action( .startRetry(delayed: delay) )
            case .requestRetryOnNetworkDisConnected:
                retryManager?.action( .retryWebViewOnNetworkDisconnected )
            case .requestSetNeedSeek(let needSeek):
                playControlManager?.setNeedSeek(needSeek)
            case .requestShowOrHideBackgroundPosterImageView(needToShow: let needToShow):
                self.resultHandler?( .requestShowOrHideBackgroundPosterImageView(needToSHow: needToShow) )
            case .requestShowOrHideLoading:
                break
            case .requestStopRetry:
                retryManager?.action( .stopRetry )
            case .requestTakeSnapShot:
                self.onRequestTakeSnapshot()
            case .sendEventToWeb(event: let event, param: let param, wrapping: let wrapping):
                self.onTimeControlStatusManagerSendEventToWeb(event: event, param: param, wrapping: wrapping)
            case .sendVideoError(errorCase: let errorCase, reason: let reason):
                break
            case .timeControlStatusDidChange(let timeControlStatus):
                self.onTimeControlStatusManagerTimeControlStatusDidChange(status: timeControlStatus)
            }
        }
    }

    private func onTimeControlStatusManagerSendEventToWeb(event: WebInterface, param: Any?, wrapping: Bool = false) {
        self.resultHandler?( .sendEventToWeb(event: event, param: param, wrapping: wrapping))
    }
    
    private func onTimeControlStatusManagerTimeControlStatusDidChange(status: AVPlayer.TimeControlStatus) {
        resultHandler?( .didChangeAVPlayerTimeControlStatus(status) )
    }
}
extension ShopLivePlayerPreviewViewModel: PreviewRetryManagerDelegate {
    private func bindRetryManager(){
        retryManager?.resultHandler = { [weak self] result in
            guard let self else { return }
            switch result {
            case .playerItemCancelPendingSeek:
                player?.currentItem?.cancelPendingSeeks()
            case .requestSeekToLatest:
                playControlManager?.action( .seekToLatest )
            case .requestResume:
                break
            case .reloadWebView:
                self.onRetryManagerReloadWebView()
            case .updatePlayerItem:
                guard let url = self.previewUrl else { return }
                self.updatePlayerItem(with: url)
            case .requestHideOrShowLoading:
                break
            }
        }
    }
    
    private func onRetryManagerReloadWebView() {
        guard let url = self.getOverLayUrlWithInfosAttached() else { return }
        resultHandler?( .reloadWebView(url: url) )
    }
    
    func getCurrentPreviewUrl() -> URL? {
        return self.previewUrl
    }
}
//MARK: - bind audioSessionManager
extension ShopLivePlayerPreviewViewModel {
    private func bindAudioSessionManager() {
        PlayerPreviewAudioSessionManager.shared.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .log(name: let name, feature: let feature, payload: let payload):
                self.onAudioSessionManagerLog(name: name, feature: feature, campaignKey: campaignKey, payload: payload)
            case .setIsMuted(isMuted: let isMuted):
                self.onAudioSessionManagerSetIsMute(isMuted: isMuted)
            case .sendEventToWeb(event: let event, param: let param, wrapping: let wrapping):
                self.onAudioSessionManagerSendEventToWeb(event: event, param: param,wrapping: wrapping)
            case .sendCommandToWeb(command: let command, payload: let payload):
                self.onAudioSessionManagerSendCommandToWeb(command: command, payload: payload)
            case .requestVideoPlay:
                playControlManager?.action(.controlPlayer(.play))
            case .requestVideoPause:
                playControlManager?.action(.controlPlayer(.pause))
            case .requestVideoResume:
                playControlManager?.action(.controlPlayer(.resume))
            case .requestVideoStop:
                playControlManager?.action(.controlPlayer(.stop))
            }
        }
    }
    
    private func onAudioSessionManagerLog(name: String, feature: ShopLiveLog.Feature, campaignKey: String , payload: [String: Any]?) {
        resultHandler?( .log(name: name, feature: feature, campaignKey: campaignKey, payload: payload))
    }
    
    private func onAudioSessionManagerSetIsMute(isMuted: Bool){
        self.isMuted = isMuted
        DispatchQueue.main.async { [weak self] in
            self?.player?.isMuted = isMuted
        }
    }
    
    private func onAudioSessionManagerSendEventToWeb(event: WebInterface, param: Any?, wrapping: Bool = false) {
        resultHandler?( .sendEventToWeb(event: event, param: param, wrapping: wrapping))
    }
    
    private func onAudioSessionManagerSendCommandToWeb(command: String, payload: [String: Any]?) {
        resultHandler?( .sendCommandMessageToWeb(command: command, payload: payload) )
    }
}
