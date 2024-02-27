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
}

internal final class LiveStreamViewModel: NSObject {
    
    weak var delegate : LiveStreamViewModelDelegate?
    
    var overayUrl: URL?
    
    weak var liveStreamViewController : LiveStreamViewController?
    
    private var networkMonitor : NetworkMonitor?
    private var urlAsset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private var perfMeasurements: PerfMeasurements?
    private var playerErrorObserver : ShopLiveAVPlayerErrorObserver?
    var retryManager : LiveStreamRetryManager?
    private var playTimeObserver: Any?
    
    private var loadedTimeRangeStalledQueue : [Double] = []
    
    private var liveKeepUpTimer : Any?
    private var isLLHLS : Bool = true
    
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
    
    
    
    /**
     api에서 아무데이터 없거나 할때 쓰임 setConf에서 updatePictureInPicture하기 위해서 있음
     */
    private var isUpdatePictureInPictureNeedInSetConfInitialized : Bool = false
    
    deinit {
        ShopLiveLogger.debugLog("iveStreamViewModel deinited")
    }
    
    override init() {
        super.init()
        setupLiveStreamViewModel()
    }
    
    private func setupLiveStreamViewModel() {
        ShopLiveController.shared.addPlayerDelegate(delegate: self)
        retryManager = LiveStreamRetryManager()
        retryManager?.delegate = self
        isAlreadyPlayedOnce = false
        self.setUpNetworkMonitor()
        self.liveStreamViewController = nil
    }
    
    func teardownLiveStreamViewModel() {
        ShopLiveController.shared.removePlayerDelegate(delegate: self)
        inAppPipConfiguration = nil
        playerErrorObserver = nil
        retryManager = nil
        removePlaytimeObserver()
        removeLiveStreamKeepUpTimer()
        resetPlayer()
        self.delegate = nil
        
        overayUrl = nil
        isWebViewDidCompleteLoading = false
        networkMonitor = nil
        playerLoadingStartTime = 0
        playerLoadingAvailableCheckSourceTimer = nil
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
                    
                    if let aspectRatio = model.videoAspectRatio {
                        self.parseRatioStringAndSetData(ratio: aspectRatio)
                    }
                    
                    if isPreview, let urlString = model.previewLiveUrl, let previewUrl = URL(string: urlString){
                        url = previewUrl
                    }
                    else if let urlString = model.liveUrl,  let liveUrl = URL(string: urlString) {
                        url = liveUrl
                    }
                    else {
                        self.isUpdatePictureInPictureNeedInSetConfInitialized = true
                        return
                    }
                    
                    DispatchQueue.main.async {
                        ShopLiveController.streamUrl = url
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
    
    
    func updatePlayerItem(with url: URL) {
        guard ShopLiveController.player != nil else { return }
        resetPlayer()
        playerLoadingStartTime = Date().timeIntervalSince1970
        let asset = AVURLAsset(url: url )
        let playerItem = AVPlayerItem(asset: asset)
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
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .TimebaseEffectiveRateChangedNotification, object: self.playerItem?.timebase)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .AVPlayerItemPlaybackStalled, object: self.playerItem)
            ShopLiveController.shared.playerItem?.player?.replaceCurrentItem(with: playerItem)
            playerErrorObserver = ShopLiveAVPlayerErrorObserver(player: ShopLiveController.player!)
            playerErrorObserver?.delegate = self
            addPlayTimeObserver()
        }
    }
    
    
    
    func resetPlayer() {
        guard ShopLiveController.player != nil else { return }
        if ShopLiveController.player?.currentItem == nil {
            return
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
        
        NotificationCenter.default.removeObserver(self, name: .TimebaseEffectiveRateChangedNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: nil)
        
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
    
    @objc func handleNotification(_ notification: Notification) {
        switch notification.name {
        case .TimebaseEffectiveRateChangedNotification:
            if let timebase = ShopLiveController.timebase {
                let rate = CMTimebaseGetRate(timebase)
                self.perfMeasurements?.rateChanged(rate: rate)
            }
            break
        case .AVPlayerItemPlaybackStalled:
            if let _ = ShopLiveController.playerItem {
                self.perfMeasurements?.playbackStalled()
            }
            break
        default:
            break
        }
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
}

extension LiveStreamViewModel: ShopLivePlayerDelegate {
    var identifier: String {
        return "LiveStreamViewModel"
    }
    
    func updatedValue(key: ShopLivePlayerObserveValue) {
        switch key {
        case .videoUrl:
            guard let videoUrl = ShopLiveController.videoUrl else { return }
            ShopLiveViewLogger.shared.addLog(log: .init(logType: .interface, log: videoUrl.absoluteString))
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
            ShopLiveLogger.debugLog("playerItem Status readyToPlay")
            if ShopLiveController.isReplayMode {
                ShopLiveController.playerItem?.preferredForwardBufferDuration = 5
            }
            if ShopLiveController.playControl != .pause, ShopLiveController.playControl != .play, ShopLiveController.windowStyle != .osPip {
                if ShopLiveController.isReplayMode && ShopLiveController.playControl == .resume { return }
                if ShopLiveController.isReplayMode, let duration = ShopLiveController.duration {
                    ShopLiveViewLogger.shared.addLog(log: .init(logType: .interface, log: "[ON_VIDEO_DURATION_CHANGED] duration total: \(duration)  CMTimeGetSeconds(duration): \(CMTimeGetSeconds(duration))"))
                    ShopLiveController.webInstance?.sendEventToWeb(event: .onVideoDurationChanged, CMTimeGetSeconds(duration))
                }
                ShopLiveController.retryPlay = false
                if isAlreadyPlayedOnce == false {
                    ShopLiveController.shared.setSoundMute(isMuted: ShopLiveConfiguration.SoundPolicy.isMutedWhenStart)
                }
                self.play()
                self.delegate?.requestTakeSnapShotView()
            }
        case .failed:
            ShopLiveLogger.debugLog("playerItem Status failed setting retry = true")
            ShopLiveController.retryPlay = true
            break
        default:
            break
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
extension LiveStreamViewModel {
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
    
    func startLiveStreamKeepUpTimer() {
        if self.useLiveKeepUpTimerOnInApp == false && ShopLiveController.windowStyle != .osPip { return }
        if self.useLiveKeepUpTimerOnOsPip == false && ShopLiveController.windowStyle == .osPip { return }
        if ShopLiveController.isReplayMode { return  }
        self.removeLiveStreamKeepUpTimer()
        
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
            ShopLiveLogger.debugLog("LiveKeepUpTimer seek fired")
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
    
    private func liveKeepUpTimerForLLHLS(loadStartTime : CMTime, seekEndTime : CMTime, currentTime : Double) {
        if  loadStartTime.seconds - currentTime < 0 && ShopLiveController.player?.timeControlStatus != .paused {
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
extension LiveStreamViewModel {
    func setInAppPipConfiguration(config : ShopLiveInAppPipConfiguration?) {
        self.inAppPipConfiguration = config
    }
    
    func getUseCloseBtnIsEnabled() -> Bool {
        if let config = self.inAppPipConfiguration, let useCloseBtn = config.useCloseButton {
            return useCloseBtn
        }
        else {
            return ShopLiveConfiguration.UI.closeButton
        }
    }
    
    
    func setPipPosition(position : ShopLive.PipPosition) {
        self.lastPipPosition = position
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
    
    func setWebViewLoadingCompleted(isCompleted : Bool) {
        self.isWebViewDidCompleteLoading = isCompleted
    }
    
    func setIsUpdatePictureInPictureNeedInSetConfInitialized(isNeeded : Bool) {
        self.isUpdatePictureInPictureNeedInSetConfInitialized = isNeeded
    }
    
    func getIsUpdatePictureInPictureNeedInSetConfInitialized() -> Bool {
        return self.isUpdatePictureInPictureNeedInSetConfInitialized
    }
    
    func setVc(vc : LiveStreamViewController) {
        self.liveStreamViewController = vc
    }
    
    func setIsOsPipFailedHasOccured(hasOccured : Bool) {
        self.osPipFailedErrorHasOccured = hasOccured
    }
    
    func getIsOsPipFailedHasOccured() -> Bool {
        return self.osPipFailedErrorHasOccured
    }
    
    func getCurrentNetworkType() -> String {
        return self.currentNetworkCapability
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
    
    /**
     Initialize web client
     - Sending the required data using URL for Web Client initialization
     */
    func getOverLayUrlWithInfosAttached() -> URL? {
        guard let baseUrl = overayUrl else { return nil }
        let urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()
        
#if DEMO
        if UserDefaults.standard.bool(forKey: "useWebLog") {
            queryItems.append(URLQueryItem(name: "__debug", value: "true"))
        }
#endif
        
        queryItems.append(URLQueryItem(name: "ak", value: ShopLiveCommon.getAccessKey()))
        queryItems.append(URLQueryItem(name: "ck", value: ShopLiveController.shared.campaignKey))
        
        if let authToken = ShopLiveCommon.getAuthToken(), !authToken.isEmpty {
            queryItems.append(URLQueryItem(name: "tk", value: authToken))
        }
        
        if let user = ShopLiveCommon.getUser() {
            queryItems.append(URLQueryItem(name: "userId", value: user.userId))
            if let name = user.name, !name.isEmpty {
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
        }
        
        if let utm_source = ShopLiveCommon.getUtmSource(), utm_source.isEmpty == false {
            queryItems.append(URLQueryItem(name: "utm_source", value: utm_source))
        }
        if let utm_content = ShopLiveCommon.getUtmCampaign(), utm_content.isEmpty == false {
            queryItems.append(URLQueryItem(name: "utm_content", value: utm_content))
        }
        if let utm_campaign = ShopLiveCommon.getUtmContent(), utm_campaign.isEmpty == false {
            queryItems.append(URLQueryItem(name: "utm_campaign", value: utm_campaign))
        }
        if let utm_medium = ShopLiveCommon.getUtmMedium(), utm_medium.isEmpty == false {
            queryItems.append(URLQueryItem(name: "utm_medium", value: utm_medium))
        }
        
        queryItems.append(URLQueryItem(name: "osType", value: "i"))
        queryItems.append(URLQueryItem(name: "osVersion", value: ShopLiveDefines.osVersion))
        queryItems.append(URLQueryItem(name: "device", value: ShopLiveDefines.deviceIdentifier))
        queryItems.append(URLQueryItem(name: "version", value: ShopLiveDefines.sdkVersion))
        
        
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
    }
    
    func onLiveStreamDisconnect() {
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
        if ShopLiveController.windowStyle != .osPip {
            if let url = ShopLiveController.videoUrl {
                self.updatePlayerItem(with: url)
            }
        }
    }
}
extension LiveStreamViewModel : LiveStreamRetryManagerDelegate {
    //MARK: -delegate functions
    func updatePlayerItemInRetry(with url: URL) {
        ShopLiveLogger.debugLog("updatePlayerItemInRetry")
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
