//
//  LiveStreamViewModel.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/04.
//

import Foundation
import AVKit
import Network
import ShopliveSDKCommon
import MediaPlayer

protocol LiveStreamViewModelDelegate : NSObjectProtocol {
    func requestTakeSnapShotView()
    func requestHideOrShowLoading(isHidden : Bool)
    func reloadWebView(with url : URL)
    func sendNetworkCapabilityOnChanged(networkCapability : String)
    func getCurrentWebViewUrl() -> URL?
    func updateSnapShotImageViewFrameWithRatio(ratio : CGSize)
    func requestHideOrShowSnapShotImageView(isHidden : Bool)
    func requestHideOrShowBackgroundPosterImageWebView(isHidden : Bool)
}

final class LiveStreamViewModel: NSObject {
    
    weak var delegate : LiveStreamViewModelDelegate?
    
    var overayUrl: URL?
    
    weak var liveStreamViewController : LiveStreamViewController?
    
    private var networkMonitor : NetworkMonitor?
    private var urlAsset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private var perfMeasurements: PerfMeasurements?
    private var playerErrorObserver : ShopLiveAVPlayerErrorObserver?
    var retryManager : LiveStreamRetryManager?
    
    
    private var loadedTimeRangeStalledQueue : [Double] = []
    
    private var liveKeepUpTimer : Any?
    private var playTimeObserver: Any?
    private var actualVideoRenderRectTimeObserver : Any?
    private var isLLHLS : Bool = true
    private var streamEdgeType : String?
    
    private var liveKeepUpBufferEndurance : Double = 5
    private var useLiveKeepUpTimerOnInApp : Bool = true
    private var useLiveKeepUpTimerOnOsPip : Bool = true
    private var liveKeepUpBufferStack : [Double] = []
    private var liveKeepUpBufferSize : Int = 3
    private var liveKeepUpTimerFrequency : Double = 3
    private var liveKeepUpTimerBaseFrequency : Double = 0
    private var liveKeepUpTimerPreviousCurrentTime : Double?
    private var liveKeepUpSeekOccured : Bool = false
    
    private var inAppPipConfiguration : ShopLiveInAppPipConfiguration?
    private var lastPipPosition : ShopLive.PipPosition?
    private var isWebViewDidCompleteLoading : Bool = false
    var isAlreadyPlayedOnce : Bool = false
    private var osPipFailedErrorHasOccured : Bool = false
    private var currentNetworkCapability : String = ""
    private var playerLoadingStartTime : Double = 0
    private var playerLoadingAvailableCheckSourceTimer : DispatchSourceTimer?
    
    //stream data
    private var streamActivityType : StreamActivityType = .ready
    private var campaignId : String = ""
    private var shopliveSessionId : String? = nil
    private var lastSentOnVideoError : ShopLiveAVPlayerErrorObserver.ErrorCase = .none
    private var currentPreviewResolution : ShopLivePlayerPreviewResolution = .PREVIEW
    
    //viewdata
    private var actualVideoRenderedRect : CGRect = .zero
    
    /**
     api에서 아무데이터 없거나 할때 쓰임 setConf에서 updatePictureInPicture하기 위해서 있음
     */
    private var isUpdatePictureInPictureNeedInSetConfInitialized : Bool = false
    
    private var customVideoResizeMode : ShopLiveResizeMode?
    //resizeMode Fit으로 시작할때 처음 snapShot이 바탕화면에 보이기때문에 처음 스냅샵은 찍지 않도록 함
    private var blockFirstSnapShotForResizeModeFit : Bool = true
    //web에서 set_video_position으로 playerView의 frame이 변경될경우 실제 videoRect가 이전 것으로 인식되어 깨지는 경우 방지하기 위한 변수
    private var blockSnapShotWhenPlayerViewFrameUpdatedByWeb : Bool = false
    
    private let notificationQueue = DispatchQueue(label: "com.shoplive.player.notificationQueue")
    
    override init() {
        super.init()
        setupLiveStreamViewModel()
    }
    
    private func setupLiveStreamViewModel() {
        self.shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        ShopLiveController.shared.addPlayerDelegate(delegate: self)
        retryManager = LiveStreamRetryManager()
        retryManager?.delegate = self
        isAlreadyPlayedOnce = false
        self.setUpNetworkMonitor()
        self.liveStreamViewController = nil
        
    }
    
    func teardownLiveStreamViewModel() {
        
        if ShopLiveController.shared.isPreview {
            self.sendPreviewDismiss()
        }
        else {
            self.sendDetailDismiss()
        }
        
        self.shopliveSessionId = nil
        ShopLiveController.shared.removePlayerDelegate(delegate: self)
        inAppPipConfiguration = nil
        playerErrorObserver = nil
        retryManager = nil
        removePlaytimeObserver()
        removeLiveStreamKeepUpTimer()
//        removeAcutalVideoRectPlayPeriodicTimeObserver()
        resetPlayer()
        self.delegate = nil
        
        overayUrl = nil
        isWebViewDidCompleteLoading = false
        networkMonitor = nil
        playerLoadingStartTime = 0
        playerLoadingAvailableCheckSourceTimer = nil
        self.campaignId = ""
        self.shopliveSessionId = nil
    }
    
    
    private func setUpNetworkMonitor() {
        self.networkMonitor = nil
        self.networkMonitor = NetworkMonitor()
        guard let nw = self.networkMonitor else { return }
        nw.resultHandler = { [weak self] result in
            guard let self = self else { return }
            if case .statusChanged(let type ) = result {
                switch type {
                case .cellular:
                    self.currentNetworkCapability = "CELLULAR"
                    break
                case .wifi:
                    self.currentNetworkCapability = "WIFI"
                    break
                case .disconnected, .none:
                    self.currentNetworkCapability = "NONE"
                    break
                }
                self.delegate?.sendNetworkCapabilityOnChanged(networkCapability: self.currentNetworkCapability)
            }
        }
        
    }
    
    func updatePlayerItemWithLiveUrlFetchAPI(accessKey : String, campaignKey : String,isPreview : Bool, completion : @escaping((Bool) -> ())) {
        LiveUrlFetchAPI(campaignKey: campaignKey)
            .request { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let model):
                    var url : URL
                    

                    if let activityType = model.activityType {
                        self.setStreamActivityType(type: activityType)
                    }
                    
                    self.campaignId = String(model.campaignId)
                    
                    if isPreview {
                        self.sendPreviewShow()
                    }
                    else {
                        self.sendDetailShow()
                    }
                    
                    if let aspectRatio = model.videoAspectRatio {
                        self.parseRatioStringAndSetData(ratio: aspectRatio)
                    }
                    
                    if isPreview && self.currentPreviewResolution == .LIVE, let urlString = model.liveUrl,  let liveUrl = URL(string: urlString) {
                         url = liveUrl
                    }
                    else if isPreview, let urlString = model.previewLiveUrl, let previewUrl = URL(string: urlString) {
                        url = previewUrl
                    }
                    else if let urlString = model.liveUrl,  let liveUrl = URL(string: urlString)  {
                        url = liveUrl
                    }
                    else {
                        self.isUpdatePictureInPictureNeedInSetConfInitialized = true
                        return
                    }
                    
                    DispatchQueue.main.async {
                        ShopLiveController.streamUrl = self.checkIfLiveUrlContainsPreviewQueryAndAppendIfNotExistInPreviewMode(url: url)
                        completion(true)
                    }
                    break
                case .failure(_):
                    self.isUpdatePictureInPictureNeedInSetConfInitialized = true
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    break
                }
            }
    }
    
    
    func updatePlayerItem(with url: URL,from : String = #function) {
        guard ShopLiveController.player != nil else { return }
        resetPlayer()
        playerLoadingStartTime = Date().timeIntervalSince1970
        let asset = AVURLAsset(url: addQueryForLiveUrl(url: url) )
        let playerItem = AVPlayerItem(asset: asset)
        
        setSoundMuteStateOnFirstPlay()
        
        if asset.isPlayable {
            ShopLiveController.shared.playItem?.perfMeasurements = PerfMeasurements(playerItem: playerItem)
            let metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil)
            metadataOutput.setDelegate(self, queue: DispatchQueue.main)
            playerItem.add(metadataOutput)
            
            if #available(iOS 13.0, *) {
                playerItem.automaticallyPreservesTimeOffsetFromLive = true
                playerItem.configuredTimeOffsetFromLive = asset.minimumTimeOffsetFromLive
            }
            
            if #available(iOS 14.0, *) {
                playerItem.startsOnFirstEligibleVariant = true
            }
            
            if #available(iOS 14.5, *) {
                playerItem.variantPreferences = .scalabilityToLosslessAudio
            }
            
            
            if ShopLiveController.isReplayMode {
                playerItem.preferredForwardBufferDuration = 2.5
            }
            playerItem.audioTimePitchAlgorithm = .timeDomain
            
            ShopLiveController.playerItem = playerItem
            self.playerItem = playerItem
            NotificationCenter.default.addObserver(forName: .TimebaseEffectiveRateChangedNotification, object: self.playerItem?.timebase, queue: .main) { [weak self] notification in
                guard let self else { return }
                if let timebase = ShopLiveController.timebase {
                    let rate = CMTimebaseGetRate(timebase)
                    self.perfMeasurements?.rateChanged(rate: rate)
                }
            }
            NotificationCenter.default.addObserver(forName: .AVPlayerItemPlaybackStalled, object: self.playerItem, queue: .main) { [weak self] notification in
                guard let self else { return }
                if let _ = ShopLiveController.playerItem {
                    self.perfMeasurements?.playbackStalled()
                }
            }
            ShopLiveController.shared.playerItem?.player?.replaceCurrentItem(with: playerItem)
            playerErrorObserver = ShopLiveAVPlayerErrorObserver(player: ShopLiveController.player!)
            playerErrorObserver?.delegate = self
            addPlayTimeObserver()
        }
        
    }
    
    
    private func addQueryForLiveUrl(url : URL) -> URL {
        guard var urlComponents = URLComponents(string: url.absoluteString) else { return url }
        var addQueryItems : [URLQueryItem] = []
        
        for (key, value) in AVPlayerHeaderMaker.defaultHeaders {
            let queryItem = URLQueryItem(name: key, value: String(describing: value ))
            addQueryItems.append(queryItem)
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
    
    ///reset and stop player
    func resetPlayer() {
        guard ShopLiveController.player != nil else { return }
        if ShopLiveController.player?.currentItem == nil {
            return
        }
        //다른 동영상 보다가 replay를 보는 경우에 currentPlayTime이 초기화 되지 않아서, 처음부터 시작하지 않는 현상 방지
        if ShopLiveController.shared.isSameCampaign == false {
            ShopLiveController.shared.currentPlayTime = nil
        }
        self.playerItem = nil
        ShopLiveController.videoUrl = nil
        ShopLiveController.player?.currentItem?.asset.cancelLoading()
        ShopLiveController.player?.cancelPendingPrerolls()
        ShopLiveController.player?.replaceCurrentItem(with: nil)
        ShopLiveController.playerItem = nil
        ShopLiveController.urlAsset = nil
        ShopLiveController.shared.playItem?.perfMeasurements = nil
        
        ShopLiveController.perfMeasurements?.playbackEnded()
        ShopLiveController.perfMeasurements = nil
        
        notificationQueue.sync {
            NotificationCenter.default.removeObserver(self, name: .TimebaseEffectiveRateChangedNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: nil)
        }
        
        ShopLiveController.playControl = .none
    }
    
    
    func reloadVideo() {
        guard let url = ShopLiveController.streamUrl else {
            resetPlayer()
            return
        }
        updatePlayerItem(with: url)
    }
    
    func seek(to: CMTime) {
        ShopLiveController.shared.currentPlayTime = to
        ShopLiveController.player?.seek(to: to)
    }

    func parseRatioStringAndSetData(ratio : String?) {
        if let ratio = ratio {
            let parseRatio = ratio.split(separator: ":")
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
        }
        else {
            ShopLiveController.shared.videoRatio = ShopLiveDefines.defVideoRatio
            ShopLiveController.shared.supportOrientation = .portrait
        }
    }
    
    func getEstimatedPlayerFrameForFullScreenOnInitalize() -> CGRect? {
        guard isWebViewDidCompleteLoading == false else {
            return nil
        }
        //가로모드는 api호출해서 사용하는 거 안하기로 협의 되었음
        guard ShopLiveController.shared.videoRatio.width < ShopLiveController.shared.videoRatio.height else {
            return nil
        }
        
        var originX : CGFloat = 0
        if UIDevice.isIpad {
            originX = UIScreen.leftSafeArea
        }
        else {
            originX = UIScreen.isLandscape ? UIScreen.topSafeArea : UIScreen.leftSafeArea
        }
        let originY : CGFloat = 0
        
        //playerFrame의 오른쪽 인셋
        var width : CGFloat = 0.0
        //playerFrame의 아래쪽 인셋
        var height : CGFloat = 0.0
        
        width = 0
        height = 0
        ShopLiveController.shared.videoFrame.portrait = CGRect(x: originX, y: originY, width: width, height: height)
        
        return .init(x: originX, y: originY, width: width, height: height)
    }
    
    //첫 로딩 후1초 이후에 프로그래스바를 보여달라는 지그재그 요청 사항 반영 함수
    func checkIsLoadingAvailable(isHidden : Bool) {
        let currentTime = Date().timeIntervalSince1970
        
        if isHidden == true {
            self.playerLoadingAvailableCheckSourceTimer?.cancel()
            self.playerLoadingAvailableCheckSourceTimer = nil
            self.delegate?.requestHideOrShowLoading(isHidden: isHidden)
        }
        
        if playerLoadingStartTime != 0 && Int(currentTime) - Int(playerLoadingStartTime) >= 1 {
            self.delegate?.requestHideOrShowLoading(isHidden: isHidden)
        }
        else if self.playerLoadingAvailableCheckSourceTimer == nil && isHidden == false {
            self.playerLoadingAvailableCheckSourceTimer = DispatchSource.makeTimerSource()
            self.playerLoadingAvailableCheckSourceTimer?.schedule(deadline: .now() + .seconds(1))
            self.playerLoadingAvailableCheckSourceTimer?.setEventHandler(handler: { [weak self] in
                guard let starTime = self?.playerLoadingStartTime else { return }
                let currentTime = Date().timeIntervalSince1970
                if Int(currentTime) - Int(starTime) >= 1 && self?.playerLoadingAvailableCheckSourceTimer != nil {
                    self?.delegate?.requestHideOrShowLoading(isHidden: false)
                    self?.playerLoadingAvailableCheckSourceTimer = nil
                }
            })
            self.playerLoadingAvailableCheckSourceTimer?.activate()
        }
    }
    
    func checkIfSnapShotImageFrameNeedReCalculation() {
        guard ShopLiveController.windowStyle == .normal else { return }
        if let current = liveStreamViewController?.playerView?.playerLayer?.videoRect {
            if current != .zero && current.width != 0 && current.height != 0 &&
                ShopLiveController.windowStyle == .normal {
                //프리뷰 inAppPip를 제외시키는 이유는 preview 자체 크기로 인해서 videoRect가 결정이 되서
                self.actualVideoRenderedRect = current
            }
        }
        let width = self.actualVideoRenderedRect.width
        let height = self.actualVideoRenderedRect.height
        self.delegate?.updateSnapShotImageViewFrameWithRatio(ratio: CGSize.init(width: width, height: height))
    }
    
    func checkIfLiveUrlContainsPreviewQueryAndAppendIfNotExistInPreviewMode(url : URL) -> URL {
        if ShopLiveController.shared.isPreview == false {
            return url
        }
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
    
}
//MARK: -eventTraceManager
extension LiveStreamViewModel {
    func sendDetailShow() {
        ShoplivePlayerEventTraceManager.detailPlayerShow(campaignId: self.campaignId, shopliveSessionId: self.shopliveSessionId, activityType: self.streamActivityType)
    }
    
    func sendDetailDismiss() {
        ShoplivePlayerEventTraceManager.detailPlayerDismiss(campaignId: self.campaignId, shopliveSessionId: self.shopliveSessionId, activityType: self.streamActivityType, streamEdgeType: self.streamEdgeType)
    }
    
    func sendPreviewShow() {
        ShoplivePlayerEventTraceManager.previewShow(campaignId: self.campaignId, shopliveSessionId: self.shopliveSessionId, activityType: self.streamActivityType)
    }
    
    func sendPreviewDismiss() {
        ShoplivePlayerEventTraceManager.previewDismiss(campaignId: self.campaignId, shopliveSessionId: self.shopliveSessionId, activityType: self.streamActivityType, streamEdgeType: self.streamEdgeType)
    }
    
    func sendPreviewClickDetailEventTrace() {
        ShoplivePlayerEventTraceManager.previewClickDetail(campaignId: self.campaignId, shopliveSessionId: self.shopliveSessionId, activityType: self.streamActivityType, streamEdgeType: self.streamEdgeType)
    }
    
    func sendPlayerToPipMode() {
        ShoplivePlayerEventTraceManager.playerToPip(campaignId: self.campaignId, shopliveSessionId: self.shopliveSessionId, activityType: self.streamActivityType, streamEdgeType: self.streamEdgeType)
    }
    
    func sendPipToPlayerMode() {
        ShoplivePlayerEventTraceManager.pipToPlayer(campaignId: self.campaignId, shopliveSessionId: self.shopliveSessionId, activityType: self.streamActivityType, streamEdgeType: self.streamEdgeType)
    }
    
}

extension LiveStreamViewModel: ShopLivePlayerDelegate {
    var identifier: String {
        return "LiveStreamViewModel"
    }
    
    func updatedValue(key: ShopLivePlayerObserveValue) {
        switch key {
        case .videoUrl:
            guard let videoUrl = ShopLiveController.videoUrl else { return }
            updatePlayerItem(with: videoUrl)
            break
        case .playerItemStatus:
            handlePlayerItemStatus()
            break
        case .releasePlayer:
            resetPlayer()
            break
        case .playControl:
            self.handlePlayControl()
        case .timeControlStatus:
            handleTimeControlStatus()
        case .retryPlay:
            handleRetry()
        default:
            break
        }
    }
    
    private func handlePlayerItemStatus() {
        switch ShopLiveController.playerItemStatus {
        case .readyToPlay:
            
            if ShopLiveController.isReplayMode {
                ShopLiveController.playerItem?.preferredForwardBufferDuration = 5
            }
            if ShopLiveController.playControl != .pause, ShopLiveController.playControl != .play, ShopLiveController.windowStyle != .osPip {
                if ShopLiveController.isReplayMode && ShopLiveController.playControl == .resume { return }
                if ShopLiveController.isReplayMode, let duration = ShopLiveController.duration {
                    ShopLiveController.webInstance?.sendEventToWeb(event: .onVideoDurationChanged, CMTimeGetSeconds(duration))
                }
                ShopLiveController.retryPlay = false
                setSoundMuteStateOnFirstPlay()
                self.play()
                
                if let current = liveStreamViewController?.playerView?.playerLayer?.videoRect {
                    if current != .zero && current.width != 0 && current.height != 0 &&
                        ShopLiveController.windowStyle == .normal {
                        //프리뷰 inAppPip를 제외시키는 이유는 preview 자체 크기로 인해서 videoRect가 결정이 되서
                        self.actualVideoRenderedRect = current
                    }
                }
                self.delegate?.requestTakeSnapShotView()
            }
        case .failed:
            
            ShopLiveController.retryPlay = true
            break
        default:
            break
        }
    }
    
    private func setSoundMuteStateOnFirstPlay() {
        if isAlreadyPlayedOnce == false {
            var isMuted = ShopLiveController.shared.isPreview ? !ShopLiveConfiguration.SoundPolicy.previewSoundEnabled : ShopLiveConfiguration.SoundPolicy.isMutedWhenStart
            if SLAudioSessionManager.shared.audioSession.outputVolume == 0 {
                isMuted = true
            }
            ShopLiveController.shared.setSoundMute(isMuted: isMuted)
        }
    }
    
    private func handlePlayControl() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
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
    }
    
    func handleTimeControlStatus() {
        switch ShopLiveController.timeControlStatus {
        case .playing:
            self.handleTimeControlStatusPlaying()
            break
        case .paused:
            self.handleTimeControlStatusPaused()
            break
        case .waitingToPlayAtSpecifiedRate:
            self.handleTimeControlStatusWaitingToPlay()
            break
        @unknown default:
            break
        }
    }
}
//MARK: - PeriodicTimerObserver logics
extension LiveStreamViewModel {
    //MARK: - sending infos to web
    private func addPlayTimeObserver() {
        removePlaytimeObserver()
        let time = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        playTimeObserver = ShopLiveController.player?.addPeriodicTimeObserver(forInterval: time, queue: nil) { (time) in
            let curTime = CMTimeGetSeconds(time)
            //            self.checkLoadedTimeRangeStalled()
            ShopLiveController.shared.currentPlayTime = time
            
            ShopLiveController.webInstance?.sendEventToWeb(event: .onVideoTimeUpdated, curTime)
        }
    }
    
    
    // ts 파일 개수 변화에 따른 사이드 이펙트가 너무 큰 로직이라 제거
    // replay 7초 무한 새로고침 현상 원인코드
    //    private func checkLoadedTimeRangeStalled(){
    //        if ShopLiveController.isReplayMode { return }
    //        if let loadedTimeRange = ShopLiveController.playerItem?.loadedTimeRanges.first as? CMTimeRange {
    //            if self.loadedTimeRangeStalledQueue.isEmpty {
    //                self.loadedTimeRangeStalledQueue.append(loadedTimeRange.start.seconds)
    //            }
    //            else if let last = loadedTimeRangeStalledQueue.last {
    //                if last != loadedTimeRange.start.seconds {
    //                    self.loadedTimeRangeStalledQueue.removeAll()
    //                    self.loadedTimeRangeStalledQueue.append(loadedTimeRange.start.seconds)
    //                }
    //                else {
    //                    self.loadedTimeRangeStalledQueue.append(loadedTimeRange.start.seconds)
    //                }
    //            }
    //        }
    //        if ShopLiveController.timeControlStatus == .playing && self.loadedTimeRangeStalledQueue.count >= 16 {
    //            self.loadedTimeRangeStalledQueue.removeAll()
    //            self.delegate?.requestTakeSnapShotView()
    //            self.retryManager?.setIsBuffering(isBuffering: true)
    //            self.retryManager?.reserveRetry(waitSecond: 0)
    //        }
    //    }
    
    private func removePlaytimeObserver() {
        if let playTimeObserver = self.playTimeObserver {
            ShopLiveController.player?.removeTimeObserver(playTimeObserver)
            self.playTimeObserver = nil
        }
    }
    
    //MARK: - liveStreamKeepUptimer logics
    func startLiveStreamKeepUpTimer() {
        self.removeLiveStreamKeepUpTimer()
        if self.useLiveKeepUpTimerOnInApp == false && ShopLiveController.windowStyle != .osPip { return }
        if self.useLiveKeepUpTimerOnOsPip == false && ShopLiveController.windowStyle == .osPip { return }
        if ShopLiveController.isReplayMode { return  }

        let time = CMTime(seconds: liveKeepUpTimerFrequency, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        liveKeepUpTimer = ShopLiveController.player?.addPeriodicTimeObserver(forInterval: time, queue: DispatchQueue.global(qos: .background)) { [weak self] time in
            guard let self = self else { return }
            guard self.checkLiveKeepUpTimerFiredMultipleTime() else { return }
            if ShopLiveController.player?.timeControlStatus != .playing {
                return
            }
            guard let (loadedStartTime ,loadedEndTime, seekableEndTime, currenTime, averageBuffer ) = self.getInfosForLiveKeepUpTimer() else { return }
            if self.isLLHLS {
                self.liveKeepUpTimerForLLHLS(loadStartTime: loadedStartTime, seekEndTime: seekableEndTime, currentTime: currenTime)
            }
            else {
                self.liveKeepUpTimerForHLS(loadEndTime: loadedEndTime, seekEndTime: seekableEndTime, currentTime: currenTime, averageBuffer: averageBuffer)
            }
        }
    }
    
    private func checkLiveKeepUpTimerFiredMultipleTime() -> Bool {
        guard let player = ShopLiveController.player else { return false }
        let currentTime = floor(player.currentTime().seconds)
        if self.liveKeepUpTimerPreviousCurrentTime == nil {
            self.liveKeepUpTimerPreviousCurrentTime = currentTime
        }
        else if let prevCurrentTime = self.liveKeepUpTimerPreviousCurrentTime, prevCurrentTime == currentTime {
            return false
        }
        else if let prevCurrentTime = self.liveKeepUpTimerPreviousCurrentTime, prevCurrentTime != currentTime {
            self.liveKeepUpTimerPreviousCurrentTime = currentTime
        }
        return true
    }
    
    private func getInfosForLiveKeepUpTimer() -> (loadeStartTime : CMTime, loadedEndTime : CMTime, seekableEndTime : CMTime, currentTime : Double, averageBuffer : Double)? {
        guard let loadedTimeRange = ShopLiveController.playerItem?.loadedTimeRanges.first as? CMTimeRange,
              let currentTime = ShopLiveController.player?.currentTime().seconds,
              let seekableTimeRange = ShopLiveController.playerItem?.seekableTimeRanges.first as? CMTimeRange else { return nil }
        
        let loadedStartTime = loadedTimeRange.start.seconds
        let loadedEndTime = loadedTimeRange.end.seconds
        let seekableStartTime = seekableTimeRange.start.seconds
        let seekableEndTime = seekableTimeRange.end.seconds
        let averageBufferEndurance = caculateLiveKeepUpBufferAverage(buffer: loadedEndTime - currentTime) ?? -1
        
        return (loadedTimeRange.start, loadedTimeRange.end, seekableTimeRange.end, currentTime, averageBufferEndurance)
    }
    
    //loadedTimeRange, seekableTimeRange, currentTime을 비교해서 보면 1초짜리 ts파일의 경우 3개 정도를 seekable하게 갖고 있고 그 뒤의 3개를 loadedTimeRange로 접근이 가능한 것으로 확인
    //currentTime을 참조하면 대략 m3u8에서 2 ~ 3 번째 ts파일을 재생하고 있는 것을 알 수 있음
    //이때 loadedTimeRange.end - currentTime이 평상시면 2 ~ 3초사이의 버퍼를 가지고 있고 (딜레이 5 ~ 6 초 기준)
    // 딜레이가 8 ~ 이상 넘어가면 loadedTimeRange.end - currentTime 5초 이상 차이가 남
    // 즉 avPlayer가 추가적으로 ts 파일을  2 ~ 3개 정도 들고 있으면 하나의 m3u8의 파일이 차이난다 볼수 있고 seekableRange.end값으로 seeking하여 delay를 줄임
    // ts파일이 6개보다 많이 올 경우 버퍼를 가지고 가는 양상이 다르게 보이는 문제가 있음
    // loadedTimeRangeStart     current         loadedTimeRangeEnd
    //    |                       |                    |
    // (184.465)              (186.010)            (189.671)
    //    |      (1.545)          |                    |
    //--------------------------------------------------
    //    |                           (1.822)   |   (1.739)
    //    |                                 (187.832)
    //    |                                     |
    // seekStart                             seekEnd
    private func liveKeepUpTimerForHLS(loadEndTime : CMTime, seekEndTime : CMTime, currentTime : Double, averageBuffer : Double) {
        guard averageBuffer >= self.liveKeepUpBufferEndurance && ShopLiveController.player?.timeControlStatus != .paused && seekEndTime.seconds > currentTime else {
            if averageBuffer != -1 {
                self.liveKeepUpSeekOccured = false
            }
            return
        }
        self.liveKeepUpBufferStack.removeAll()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            ShopLiveController.player?.seek(to: seekEndTime, toleranceBefore: .init(seconds: 1, preferredTimescale: 44100), toleranceAfter: .init(seconds: 1, preferredTimescale: 44100), completionHandler: { [weak self] _ in
                self?.delegate?.requestTakeSnapShotView()
            })
        }
        if self.liveKeepUpSeekOccured {
            if self.liveKeepUpTimerFrequency >= 180 {
                self.liveKeepUpTimerFrequency = self.liveKeepUpTimerBaseFrequency
            }
            else {
                self.liveKeepUpTimerFrequency = min(180, liveKeepUpTimerFrequency * 2 )
            }
            self.liveKeepUpSeekOccured = false
            self.startLiveStreamKeepUpTimer()
        }
        else {
            self.liveKeepUpSeekOccured = true
        }
    }
    
    
    // HLS보다 단순하게 확인 가능
    // loadedTimeRange의 start 부분이 currentTime 보다 뒤에 있는 경우, 즉 미래에 있는 경우 모종의 이유로 latency가 벌어졌다고 추측할 수 있음
    // 따라서 currnentTime = loadStartTime.seconds < 0 이 될 경우 latency를 줄이기 위해서 앞으로 땡겨감
    // llHLS의 경우 격차 정도가 HLS와는 다르게 1초 이내로 차이가 남(0.5, 0.45 정도)
    // 영상 시작시간 초반 10초 동안은 AVPlayer에서 안정적으로 버퍼를 받지 않았기 때문에 이 로직이 작동하면 버벅이는 현상이 발생함. 1.5.8 버전 이후에 개선 되었음
    private func liveKeepUpTimerForLLHLS(loadStartTime : CMTime, seekEndTime : CMTime, currentTime : Double) {
        if  currentTime - loadStartTime.seconds < 0 && ShopLiveController.player?.timeControlStatus != .paused && currentTime >= 10 {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                ShopLiveController.player?.seek(to: seekEndTime, toleranceBefore: .init(seconds: 1, preferredTimescale: 44100), toleranceAfter: .init(seconds: 1, preferredTimescale: 44100), completionHandler: { [weak self] _ in
                    self?.delegate?.requestTakeSnapShotView()
                })
            }
            if self.liveKeepUpSeekOccured {
                if liveKeepUpTimerFrequency >= 180 {
                    self.liveKeepUpTimerFrequency = self.liveKeepUpTimerBaseFrequency
                }
                else {
                    self.liveKeepUpTimerFrequency = min(180, liveKeepUpTimerFrequency * 2 )
                }
                self.liveKeepUpSeekOccured = false
                self.startLiveStreamKeepUpTimer()
            }
            else {
                self.liveKeepUpSeekOccured = true
            }
        }
        else {
            self.liveKeepUpSeekOccured = false
        }
    }
    
    private func caculateLiveKeepUpBufferAverage(buffer : Double) -> Double? {
        if liveKeepUpBufferStack.count >= liveKeepUpBufferSize {
            liveKeepUpBufferStack.remove(at: 0)
        }
        liveKeepUpBufferStack.append(buffer)
        if liveKeepUpBufferStack.count < liveKeepUpBufferSize {
            return nil
        }
        return liveKeepUpBufferStack.reduce(0, +) / Double(liveKeepUpBufferSize)
    }
    
    private func removeLiveStreamKeepUpTimer() {
        if liveKeepUpTimer != nil {
            ShopLiveController.player?.removeTimeObserver(liveKeepUpTimer!)
            liveKeepUpTimer = nil
        }
        self.liveKeepUpTimerPreviousCurrentTime = nil
    }
    
    func blockLiveStreamKeepUpTimerWhenAppTransitioningToBackground() {
        self.liveKeepUpBufferStack.removeAll()
    }
    
}
extension LiveStreamViewModel: AVPlayerItemMetadataOutputPushDelegate {
    func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        
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
            ShopLiveController.shared.webInstance?.sendEventToWeb(event: .onVideoMetadataUpdated, payloads.toJson())
        }
    }
}
//MARK: -getter
extension LiveStreamViewModel {
    func getShopliveSessionId() -> String? {
        return self.shopliveSessionId
    }
    
    func getUseCloseBtnIsEnabled() -> Bool {
        if let config = self.inAppPipConfiguration, let useCloseBtn = config.useCloseButton {
            return useCloseBtn
        }
        else {
            return ShopLiveConfiguration.UI.closeButton
        }
    }
    
    func getPipPosition() -> ShopLive.PipPosition {
        if let pos = self.lastPipPosition {
            return pos
        }
        else if let config = self.inAppPipConfiguration, let pos = config.pipPosition {
            return pos
        }
        else {
            return .default
        }
    }
    
    func getAllowedPipPinPositions() -> [ShopLive.PipPosition] {
        if let config = self.inAppPipConfiguration {
            return config.pipPinPositions
        }
        else {
            return [.topLeft, .topRight , .bottomLeft, .bottomRight]
        }
    }
    
    func getEnablePipSwipeOut() -> Bool {
        if let config = inAppPipConfiguration, let enablePipSwipeOut = config.enableSwipeOut {
            return enablePipSwipeOut
        }
        else {
            return ShopLiveConfiguration.UI.enablePipSwipeOut
        }
    }
    
    func getPipCornerRadius() -> CGFloat {
        return inAppPipConfiguration?.pipRadius ?? 10
    }
    
    func getIsUpdatePictureInPictureNeedInSetConfInitialized() -> Bool {
        return self.isUpdatePictureInPictureNeedInSetConfInitialized
    }
    
    func getIsOsPipFailedHasOccured() -> Bool {
        return self.osPipFailedErrorHasOccured
    }
    
    func getCurrentNetworkType() -> String {
        return self.currentNetworkCapability
    }
    
    func getStreamActivityType() -> StreamActivityType {
        return self.streamActivityType
    }
    
    func getCampaignId() -> String {
        return self.campaignId
    }
    
    func getResizeMode() -> ShopLiveResizeMode? {
        return self.customVideoResizeMode
    }
    
    
    /**
     Initialize web client
     - Sending the required data using URL for Web Client initialization
     */
    func getOverLayUrlWithInfosAttached() -> URL? {
        guard let baseUrl = overayUrl else { return nil }
        let urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()
   
        queryItems.append(URLQueryItem(name: "ak", value: ShopLiveCommon.getAccessKey()))
        queryItems.append(URLQueryItem(name: "ck", value: ShopLiveController.shared.campaignKey))
        
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
        
        
        if let scm: String = ShopLiveController.shared.shareScheme, scm.isEmpty == false {
            queryItems.append(URLQueryItem(name: "shareUrl", value: scm))
        }
        
        queryItems.append(URLQueryItem(name: "appVersion", value: ShopLiveConfiguration.AppPreference.appVersion ?? UIApplication.appVersion()))
        
        queryItems.append(URLQueryItem(name: "manualRotation", value: "false"))
        
        ShopLiveConfiguration.Data.customParameters.forEach { (key: String, value: Any) in
            queryItems.append(URLQueryItem(name: key, value: "\(value)"))
        }
        
        let urlString: String = ShopLiveConfiguration.AppPreference.landingUrl
        guard let params = URLUtil.query(queryItems) else {
            return URL(string: urlString)
        }
        
        guard let url = URL(string: urlString + "?" + params) else {
            return URL(string: urlString)
        }
        
        return url
    }
    
    func getBlockSnapShotWhenPlayerViewFrameUpdatedByWeb() -> Bool {
        return blockSnapShotWhenPlayerViewFrameUpdatedByWeb
    }
    
    func getCurrentPreviewResolution() -> ShopLivePlayerPreviewResolution {
        return self.currentPreviewResolution
    }
}

//MARK: -setter
extension LiveStreamViewModel {
    func setStreamEdgeType(type : String?) {
        self.streamEdgeType = type
    }
    
    func setCampaignId(campaignId : Int) {
        self.campaignId = String(campaignId)
    }
    
    func setInAppPipConfiguration(config : ShopLiveInAppPipConfiguration?) {
        self.inAppPipConfiguration = config
    }
    
    func setPipPosition(position : ShopLive.PipPosition) {
        self.lastPipPosition = position
    }
    
    func setWebViewLoadingCompleted(isCompleted : Bool) {
        self.isWebViewDidCompleteLoading = isCompleted
    }
    
    func setIsUpdatePictureInPictureNeedInSetConfInitialized(isNeeded : Bool) {
        self.isUpdatePictureInPictureNeedInSetConfInitialized = isNeeded
    }
    
    func setVc(vc : LiveStreamViewController) {
        self.liveStreamViewController = vc
    }
    
    func setIsOsPipFailedHasOccured(hasOccured : Bool) {
        self.osPipFailedErrorHasOccured = hasOccured
    }
    
    func setIsLLHls(isLLHLs : Bool) {
        self.isLLHLS = isLLHLs
    }
    
    func setLiveKeepUpBufferEndurance(value : Double) {
        self.liveKeepUpBufferEndurance = value
    }
    
    func setUseLiveKeepUpTimerOnInApp(isUsed : Bool) {
        self.useLiveKeepUpTimerOnInApp = isUsed
    }
    
    func setUseLiveKeepUpTimerOnOsPip(isUsed : Bool) {
        self.useLiveKeepUpTimerOnOsPip = isUsed
    }
    
    func setUseLiveKeepUpTimerBufferSize(size : Int){
        self.liveKeepUpBufferSize = size
    }
    
    func setLiveKeepUpTimerFrequency(frequency : Double) {
        self.liveKeepUpTimerFrequency = frequency
        self.liveKeepUpTimerBaseFrequency = frequency
    }
    
    func setStreamActivityType(type : String) {
        for aType in StreamActivityType.allCases {
            if aType.rawValue == type {
                self.streamActivityType = aType
            }
        }
    }
    
    func setResizeMode(mode : ShopLiveResizeMode?) {
        self.customVideoResizeMode = mode
    }
    
    func setBlockSnapShotWhenPlayerViewFrameUpdatedByWeb(block : Bool) {
        self.blockSnapShotWhenPlayerViewFrameUpdatedByWeb = block
    }
    
    func setPreviewResolution(resolution : ShopLivePlayerPreviewResolution) {
        self.currentPreviewResolution = resolution
    }
}
extension LiveStreamViewModel : ShopLiveAVPlayerErrorObserverDelegate {
    func pauseAndWaitForBufferFromPlayerObserveError() {
        playerErrorObserver?.resetErrorCase()
    }
    
    func onStallDangerFromPlayerObserveError() {
        self.playerErrorObserver?.resetErrorCase()
    }
    
    func onMissingRenditionReport() {
        playerErrorObserver?.resetErrorCase()
        self.sendOnVideoErrorToWeb(errorCase: .missinRenditionReport , reason: "onMissingRenditionReport")
    }
    
    func onLiveStreamDisconnect() {
        self.sendOnVideoErrorToWeb(errorCase : .disconnected ,reason: "liveStreamDisconnected")
        if ShopLiveController.windowStyle == .osPip {
            self.resetPlayer()
        }
        else {
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] timer in
                guard let self = self else { return }
                self.retryManager?.setIsBuffering(isBuffering: true)
                self.retryManager?.reserveRetry(waitSecond: 0)
                if ShopLiveController.player?.timeControlStatus == .playing {
                    ShopLiveController.player?.pause()
                    self.delegate?.requestTakeSnapShotView()
                    if ShopLiveController.shared.campaignStatus != .close {
                        self.delegate?.requestHideOrShowLoading(isHidden: false)
                    }
                }
            }
        }
    }
    
    func onPlayListParseError() {
        self.sendOnVideoErrorToWeb(errorCase: .playListParseError , reason: "playListParseError")
        guard let player = ShopLiveController.player,
              let playerItem = player.currentItem,
              let urlAsset = (playerItem.asset as? AVURLAsset) else { return }
        if ShopLiveController.windowStyle != .osPip {
            self.updatePlayerItem(with: urlAsset.url)
        }
        else {
            self.resetPlayer()
        }
    }
    
    func onBandWidthExceeds() {
        playerErrorObserver?.resetErrorCase()
    }
    
    func onNoMatchingMediaFileFound() {
        self.sendOnVideoErrorToWeb(errorCase: .noMatchingMediaFileFound ,  reason: "onNoMatchingMediaFileFound")
        guard let retryManager = retryManager else { return }
        
        if retryManager.getIsBuffering() == true {
            return
        }
        self.delegate?.requestTakeSnapShotView()
        if ShopLiveController.shared.campaignStatus != .close {
            if ShopLiveController.windowStyle != .osPip {
                self.delegate?.requestHideOrShowLoading(isHidden: false)
            }
            self.retryManager?.setIsBuffering(isBuffering: true)
            self.retryManager?.reserveRetry(waitSecond: 0)
        }
    }
    
    func onUnableToGetPlayList() {
        self.sendOnVideoErrorToWeb(errorCase: .unableToGetPlayList, reason: "unableToGetPlayList")
        if ShopLiveController.windowStyle != .osPip {
            if let url = ShopLiveController.videoUrl {
                self.updatePlayerItem(with: url)
            }
        }
    }
    
    func sendOnVideoErrorToWeb(errorCase : ShopLiveAVPlayerErrorObserver.ErrorCase, reason : String) {
//        if errorCase == lastSentOnVideoError {
//            return
//        }
        lastSentOnVideoError = errorCase
        let liveUrl = ShopLiveController.streamUrl?.absoluteString ?? ""
        let payload : String = ["liveUrl" : liveUrl, "reason" : reason].toJson() ?? ""
        
        ShopLiveController.shared.webInstance?.sendEventToWeb(event: .onVideoError, payload)
    }
}
extension LiveStreamViewModel : LiveStreamRetryManagerDelegate {
    //MARK: -delegate functions
    func updatePlayerItemInRetry(with url: URL) {
        
        self.updatePlayerItem(with: url)
    }
    
    func reloadWebViewInRetry(with url: URL) {
        delegate?.reloadWebView(with: url)
    }
    func requestHideOrShowLoading(isHidden: Bool) {
        self.delegate?.requestHideOrShowLoading(isHidden: isHidden)
    }
    //End
    
    func resetRetry(triggerFromWebView : Bool = false){
        retryManager?.resetRetry(triggerFromWebView : triggerFromWebView)
    }
    
    func handleRetry(){
        retryManager?.handleRetryPlay()
    }
    
    func retryOnNetworkDisconnected(){
        guard let overayUrl = getOverLayUrlWithInfosAttached() else { return }
        retryManager?.retryOnNetworkDisconnected(with: overayUrl)
    }
    
    func getInBuffering() -> Bool {
        return retryManager?.getIsBuffering() ?? false
    }
    
    func getCurrentWebViewUrl() -> URL? {
        return delegate?.getCurrentWebViewUrl()
    }
    
    
    func setBlockRetry(block : Bool) {
        retryManager?.setBlockRetry(block: block)
    }
}
