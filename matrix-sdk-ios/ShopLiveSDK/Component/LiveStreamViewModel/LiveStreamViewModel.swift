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


protocol LiveStreamViewModelDelegate : NSObjectProtocol {
    func requestTakeSnapShotView()
    func requestHideOrShowLoading(hide : Bool)
    func reloadWebView(with url : URL)
}

internal final class LiveStreamViewModel: NSObject {

    weak var delegate : LiveStreamViewModelDelegate?
    
    var overayUrl: URL?
    
    var campaignKey: String?
    
    weak var liveStreamViewController : LiveStreamViewController?
    
    private var urlAsset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private var perfMeasurements: PerfMeasurements?
    private var playerErrorObserver : ShopLiveAVPlayerErrorObserver?
    var retryManager : LiveStreamRetryManager?
    private var playTimeObserver: Any?
    private var loadedTimeRangeStalledQueue : [Double] = []
    private var liveKeepUpTimer : Any?
    private var blockLiveKeeupTimer : Bool = false
    private var liveKeepUpTimerBlockDuration : Double = 2.0
    private var inAppPipConfiguration : ShopLiveInAppPipConfiguration?
    private var lastPipPosition : ShopLive.PipPosition?
    private var isWebViewDidCompleteLoading : Bool = false
    var isAlreadyPlayedOnce : Bool = false
    private var osPipFailedErrorHasOccured : Bool = false
//    private var 
    /**
     api에서 아무데이터 없거나 할때 쓰임 setConf에서 updatePictureInPicture하기 위해서 있음
     */
    private var isUpdatePictureInPictureNeedInSetConfInitialized : Bool = false
    
    deinit {
        ShopLiveLogger.debugLog("iveStreamViewModel deinited")
        teardownLiveStreamViewModel()
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
        campaignKey = nil
        isWebViewDidCompleteLoading = false
    }
    
    
    func updatePlayerItemWithLiveUrlFetchAPI(accessKey : String, campaignKey : String,isPreview : Bool, completion : @escaping(() -> ())) {
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
            playerErrorObserver = ShopLiveAVPlayerErrorObserver(player: ShopLiveController.player!)
            playerErrorObserver?.delegate = self
            startLiveStreamKeepUpTimer()
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
            ShopLiveController.playerItem?.preferredForwardBufferDuration = 5
            if ShopLiveController.playControl != .pause, ShopLiveController.playControl != .play, ShopLiveController.windowStyle != .osPip {
                if ShopLiveController.isReplayMode && ShopLiveController.playControl == .resume { return }
                if ShopLiveController.isReplayMode, let duration = ShopLiveController.duration {
                    ShopLiveViewLogger.shared.addLog(log: .init(logType: .interface, log: "[ON_VIDEO_DURATION_CHANGED] duration total: \(duration)  CMTimeGetSeconds(duration): \(CMTimeGetSeconds(duration))"))
                    ShopLiveController.webInstance?.sendEventToWeb(event: .onVideoDurationChanged, CMTimeGetSeconds(duration))
                }
                ShopLiveController.retryPlay = false
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
        playTimeObserver = ShopLiveController.player?.addPeriodicTimeObserver(forInterval: time, queue: nil) { [weak self] (time) in
            guard let self = self else { return }
            let curTime = CMTimeGetSeconds(time)
            self.checkLoadedTimeRangeStalled()
            ShopLiveController.shared.currentPlayTime = time
            ShopLiveController.webInstance?.sendEventToWeb(event: .onVideoTimeUpdated, curTime)
        }
    }
    
    private func checkLoadedTimeRangeStalled(){
        if ShopLiveController.isReplayMode { return }
        if let loadedTimeRange = ShopLiveController.playerItem?.loadedTimeRanges.first as? CMTimeRange {
            if self.loadedTimeRangeStalledQueue.isEmpty {
                self.loadedTimeRangeStalledQueue.append(loadedTimeRange.start.seconds)
            }
            else if let last = loadedTimeRangeStalledQueue.last {
                if last != loadedTimeRange.start.seconds {
                    self.loadedTimeRangeStalledQueue.removeAll()
                    self.loadedTimeRangeStalledQueue.append(loadedTimeRange.start.seconds)
                }
                else {
                    self.loadedTimeRangeStalledQueue.append(loadedTimeRange.start.seconds)
                }
            }
        }
        if ShopLiveController.timeControlStatus == .playing && self.loadedTimeRangeStalledQueue.count >= 16 {
            self.loadedTimeRangeStalledQueue.removeAll()
            self.delegate?.requestTakeSnapShotView()
            self.retryManager?.setIsBuffering(isBuffering: true)
            self.retryManager?.reserveRetry(waitSecond: 0)
        }
    }
    
    private func removePlaytimeObserver() {
        if let playTimeObserver = self.playTimeObserver {
            ShopLiveController.player?.removeTimeObserver(playTimeObserver)
            self.playTimeObserver = nil
        }
    }
    
    private func startLiveStreamKeepUpTimer() {
        if ShopLiveController.isReplayMode { return  }
        self.removeLiveStreamKeepUpTimer()
        
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
    
    private func removeLiveStreamKeepUpTimer() {
        if liveKeepUpTimer != nil {
            ShopLiveController.player?.removeTimeObserver(liveKeepUpTimer!)
            liveKeepUpTimer = nil
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
    
    func setVc(vc : LiveStreamViewController){
        self.liveStreamViewController = vc
    }
    
    func setIsOsPipFailedHasOccured(hasOccured : Bool) {
        self.osPipFailedErrorHasOccured = hasOccured
    }
    
    func getIsOsPipFailedHasOccured() -> Bool {
        return self.osPipFailedErrorHasOccured
    }
    
    /**
        Initialize web client
            - Sending the required data using URL for Web Client initialization
     */
    func getOverLayUrlWithInfosAttached() -> URL? {
        guard let baseUrl = overayUrl else { return nil }
        let urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()

        if let authToken = ShopLiveCommon.getUserJWT(), !authToken.isEmpty {
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
            
            if let additional = user.custom, !additional.isEmpty {
                additional.forEach { (key: String, value: Any) in
                    if let value = value as? String {
                        queryItems.append(URLQueryItem(name: key, value: value))
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
        
        if let utm_source = ShopLiveCommon.getUtmSource() {
            queryItems.append(URLQueryItem(name: "utm_source", value: utm_source))
        }
        if let utm_content = ShopLiveCommon.getUtmCampaign() {
            queryItems.append(URLQueryItem(name: "utm_content", value: utm_content))
        }
        if let utm_campaign = ShopLiveCommon.getUtmContent() {
            queryItems.append(URLQueryItem(name: "utm_campaign", value: utm_campaign))
        }
        if let utm_medium = ShopLiveCommon.getUtmMedium() {
            queryItems.append(URLQueryItem(name: "utm_medium", value: utm_medium))
        }
        
        queryItems.append(URLQueryItem(name: "osType", value: "i"))
        queryItems.append(URLQueryItem(name: "osVersion", value: ShopLiveDefines.osVersion))
        queryItems.append(URLQueryItem(name: "device", value: ShopLiveDefines.deviceIdentifier))

        if let scm: String = ShopLiveController.shared.shareScheme {
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
                        self.delegate?.requestHideOrShowLoading(hide: false)
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
                self.delegate?.requestHideOrShowLoading(hide: false)
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
        self.updatePlayerItem(with: url)
    }
    
    func reloadWebViewInRetry(with url: URL) {
        delegate?.reloadWebView(with: url)
    }
    func requestHideOrShowLoading(hide: Bool) {
        self.delegate?.requestHideOrShowLoading(hide: hide)
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
}
