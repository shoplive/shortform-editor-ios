//
//  LiveStreamViewModel.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/04.
//

import Foundation
import AVKit
import Network


internal final class LiveStreamViewModel: NSObject {

    var overayUrl: URL?
    var accessKey: String?
    var campaignKey: String?
    var authToken: String? = nil
    var user: ShopLiveUser? = nil
    
    private var urlAsset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private var perfMeasurements: PerfMeasurements?
    
    private var liveKeepUpTimer : Any?
    private var blockLiveKeeupTimer : Bool = false
    private var liveKeepUpTimerBlockDuration : Double = 2.0
    private var inAppPipConfiguration : ShopLiveInAppPipConfiguration?
    private var lastPipPosition : ShopLive.PipPosition?
    private var isWebViewDidCompleteLoading : Bool = false
    /**
     api도입되면서 가로모드일때만 setConf에서 delegate.updatePictureInPicture를 불러야함
     */
    private var isUpdatePictureInPictureNeedInSetConfInitialized : Bool = false
    
    
    
    
    
    deinit {
        teardownLiveStreamViewModel()
    }
    
    override init() {
        super.init()
        setupLiveStreamViewModel()
    }

    private func setupLiveStreamViewModel() {
        ShopLiveController.shared.addPlayerDelegate(delegate: self)
    }
    
    private func teardownLiveStreamViewModel() {
        ShopLiveController.shared.removePlayerDelegate(delegate: self)
        resetPlayer()
        
        overayUrl = nil
        accessKey = nil
        campaignKey = nil
        authToken = nil
        user = nil
        isWebViewDidCompleteLoading = false
    }
    
    
    func updatePlayerItemWithLiveUrlFetchAPI(accessKey : String, campaignKey : String,isPreview : Bool, completion : @escaping(() -> ())) {
        LiveUrlFetchAPI.fetchUrl(accessKey: accessKey, campaignKey: campaignKey) { [weak self] result in
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
                    completion()
                }
                break
            case .failure(_):
                self.isUpdatePictureInPictureNeedInSetConfInitialized = true
                break
            }
        }
        
    }
    
    
    func updatePlayerItem(with url: URL) {
        guard ShopLiveController.player != nil else { return }
        resetPlayer()

        let asset = AVURLAsset(url: url)
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
            
            playerItem.preferredForwardBufferDuration = 2.5
            playerItem.audioTimePitchAlgorithm = .timeDomain
            
            ShopLiveController.playerItem = playerItem
            self.playerItem = playerItem
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .TimebaseEffectiveRateChangedNotification, object: self.playerItem?.timebase)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .AVPlayerItemPlaybackStalled, object: self.playerItem)
            ShopLiveController.shared.playerItem?.player?.replaceCurrentItem(with: playerItem)
            startLiveStreamKeepUpTimer()
        }
    }

    private func resetPlayer() {
        guard ShopLiveController.player != nil else { return }
        if ShopLiveController.player?.currentItem == nil {
            return
        }
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
    
    func play() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let url = ShopLiveController.streamUrl, !url.absoluteString.isEmpty, (ShopLiveController.playerItemStatus == .failed || ShopLiveController.player?.reasonForWaitingToPlay == AVPlayer.WaitingReason.evaluatingBufferingRate) {
                self.updatePlayerItem(with: url)
            }
            else {
                if ShopLiveController.isReplayMode {
                    if ShopLiveController.isReplayFinished {
                        self.seek(to: .init(value: 0, timescale: 1))
                    }
                }
                
                ShopLiveController.player?.play()
            }
        }
    }
    
    func stop() {
        resetPlayer()
    }

    func resume() {
        guard ShopLiveController.player?.timeControlStatus != .playing else { return }
        DispatchQueue.main.async {
            if ShopLiveController.isReplayMode {
                ShopLiveController.player?.play()
            }
            else if let url = ShopLiveController.streamUrl, !url.absoluteString.isEmpty {
                if ShopLiveController.shared.needSeek {
                    ShopLiveController.shared.needSeek = false
                    ShopLiveController.shared.seekToLatest()
                }
                ShopLiveController.player?.play()
            }
        }
       
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

    func handlePlayerItemStatus() {
        switch ShopLiveController.playerItemStatus {
        case .readyToPlay:
            ShopLiveLogger.debugLog("readyToPlay")
            ShopLiveLogger.debugLog("[1.3.2] readyToPlay")
            ShopLiveController.playerItem?.preferredForwardBufferDuration = 5
            if ShopLiveController.playControl != .pause, ShopLiveController.playControl != .play, ShopLiveController.windowStyle != .osPip {
                if ShopLiveController.isReplayMode && ShopLiveController.playControl == .resume { return }
                if ShopLiveController.isReplayMode, let duration = ShopLiveController.duration {
                    ShopLiveViewLogger.shared.addLog(log: .init(logType: .interface, log: "[ON_VIDEO_DURATION_CHANGED] duration total: \(duration)  CMTimeGetSeconds(duration): \(CMTimeGetSeconds(duration))"))
                    ShopLiveController.webInstance?.sendEventToWeb(event: .onVideoDurationChanged, CMTimeGetSeconds(duration))
                }
                ShopLiveController.retryPlay = false
                self.play()
            }
        case .failed:
            ShopLiveLogger.debugLog("failed")
            ShopLiveLogger.debugLog("[1.3.2] failed")
            ShopLiveLogger.debugLog("[1.3.2] failed retry true")
            ShopLiveController.retryPlay = true
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
        
        let originX : CGFloat = UIScreen.leftSafeArea
        var originY : CGFloat = 0
        
        //playerFrame의 오른쪽 인셋
        var width : CGFloat = 0.0
        //playerFrame의 아래쪽 인셋
        var height : CGFloat = 0.0
        
        let videoRatio = ShopLiveController.shared.videoRatio
        
        width = 0
        height = 0
        ShopLiveController.shared.videoFrame.portrait = CGRect(x: originX, y: originY, width: width, height: height)
        
        return .init(x: originX, y: originY, width: width, height: height)
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
        default:
            break
        }
    }
}
extension LiveStreamViewModel {
    private func startLiveStreamKeepUpTimer() {
        if liveKeepUpTimer != nil {
            ShopLiveController.player?.removeTimeObserver(liveKeepUpTimer!)
            liveKeepUpTimer = nil
        }
        
        let time = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        liveKeepUpTimer = ShopLiveController.player?.addPeriodicTimeObserver(forInterval: time, queue: nil) { [weak self] time in
            guard let self = self else { return }
            if ShopLiveController.player?.timeControlStatus != .playing {
                self.blockLiveKeeupTimer = true
                if ShopLiveController.windowStyle == .osPip {
                    self.liveKeepUpTimerBlockDuration = 10
                }
                else {
                    self.liveKeepUpTimerBlockDuration = 2
                }
               
                return
            }
            if self.blockLiveKeeupTimer == true {
                self.liveKeepUpTimerBlockDuration -= 0.5
                if self.liveKeepUpTimerBlockDuration <= 0 {
                    self.blockLiveKeeupTimer = false
                    if ShopLiveController.windowStyle == .osPip {
                        self.liveKeepUpTimerBlockDuration = 10
                    }
                    else {
                        self.liveKeepUpTimerBlockDuration = 2
                    }
                }
            }
            else {
                if let loadedTimeRange = ShopLiveController.playerItem?.loadedTimeRanges.first as? CMTimeRange,
                   let currentTime = ShopLiveController.player?.currentTime().seconds {
                    let startTime = loadedTimeRange.start.seconds
                    if currentTime - startTime <= 0 && ShopLiveController.player?.timeControlStatus != .paused {
                        self.blockLiveKeeupTimer = true
                        DispatchQueue.main.async {
                            ShopLiveController.player?.seek(to: .positiveInfinity)
                        }
                    }
                }
            }
        }
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
    
    func setWebViewLoadingCompleted(isCompleted : Bool){
        self.isWebViewDidCompleteLoading = isCompleted
    }
    
    func setIsUpdatePictureInPictureNeedInSetConfInitialized(isNeeded : Bool) {
        self.isUpdatePictureInPictureNeedInSetConfInitialized = isNeeded
    }
    
    func getIsUpdatePictureInPictureNeedInSetConfInitialized() -> Bool {
        return self.isUpdatePictureInPictureNeedInSetConfInitialized
    }
}
