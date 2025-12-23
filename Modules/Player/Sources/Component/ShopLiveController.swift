//
//  ShopLiveController.swift
//  ShopLivePlayer
//
//  Created by ShopLive on 2021/08/01.
//

import Foundation
import AVKit
import WebKit
import UIKit
import VideoToolbox
import ShopliveSDKCommon

enum ShopLivePlayerObserveValue: String {
    case videoUrl = "videoUrl"
    case timeControlStatus = "player.timeControlStatus"
    case isPlayable = "urlAsset.isPlayable"
    case playerItemStatus = "playerItem.status"
    case isPlaybackLikelyToKeepUp = "playerItem.isPlaybackLikelyToKeepUp"
    case playControl = "playControl"
    case isHiddenOverlay = "isHiddenOverlay"
    case overlayUrl = "overlayUrl"
    case loadedTimeRanges = "player.currentItem.loadedTimeRanges"
    case retryPlay = "retryPlay"
    case releasePlayer = "releasePlayer"
}

enum ShopLiveWindowStyle {
    case none
    case inAppPip
    case osPip
    case normal
    
    var name: String {
        switch self {
        case .none:
            return "none"
        case .inAppPip:
            return "inAppPip"
        case .osPip:
            return "osPip"
        case .normal:
            return "normal"
        }
    }
    
}

enum StreamActivityType: String, CaseIterable {
    case ready = "READY"
    case rehearsal = "REHEARSAL"
    case live = "LIVE"
    case replay = "REPLAY"
    case closed = "CLOSED"
}

protocol ShopLivePlayerDelegate {
    var identifier: String { get }
    func isEqualTo(_ other: ShopLivePlayerDelegate) -> Bool

    func updatedValue(key: ShopLivePlayerObserveValue)
}

extension ShopLivePlayerDelegate where Self: Equatable {
    func isEqualTo(_ other: ShopLivePlayerDelegate) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}
 
protocol ShopLiveControllerDelegate: NSObjectProtocol {
    func setPresentationStyle(style: ShopLive.PresentationStyle )
}

final class ShopLiveController: NSObject {
    static let shared = ShopLiveController()

    weak var delegate: ShopLiveControllerDelegate?
    
    private override init() {
        super.init()
    }

    deinit {
        if let timebaseRateChangedObservation = timebaseRateChangedNotificateObservation {
            NotificationCenter.default.removeObserver(timebaseRateChangedObservation)
        }
        if let playbackStalledObservation = playbackStalledNotificateObservation {
            NotificationCenter.default.removeObserver(playbackStalledObservation)
        }
    }

    var campaignKey: String {
        set {
            self.isSameCampaign = (newValue == self.currentCampaignKey)
            self.currentCampaignKey = newValue
        }
        get {
            return currentCampaignKey
        }
    }

    var execusedClose: Bool = false
    private var currentCampaignKey: String = ""
    
    var posterUrl: String = ""
    
    var isSameCampaign: Bool = false
    var campaignStatus: ShopLiveCampaignStatus = .close
    
    var isSuccessCampaignJoin: Bool = false
    private var playerDelegates: [ShopLivePlayerDelegate?] = []
    @objc dynamic var playItem: ShopLivePlayItem? = .init()
    @objc dynamic var playerItem: ShopLivePlayerItem? = .init()
    @objc dynamic var playControl: ShopLiveConfiguration.SLPlayControl = .none
    var isReplayMode: Bool = false
    @objc dynamic var isHiddenOverlay: Bool = false
    @objc dynamic var overlayUrl: URL? = nil
    @objc dynamic var isPlaying: Bool = false
    @objc dynamic var retryPlay: Bool = false
    @objc dynamic var releasePlayer: Bool = false
    @objc dynamic var isPreview: Bool = false
    @objc var isMuted: Bool = ShopLiveConfiguration.SoundPolicy.isMutedWhenStart
    
    var playerResumeCount: Int = 0
    
    var _playerMode: ShopLive.PlayerMode = .none
    
    var playerMode: ShopLive.PlayerMode {
        return _playerMode
    }
    
    var currentPlayTime: CMTime? = nil
    var shareScheme: String? = nil
    var needReload: Bool = false
    var needSeek: Bool = false
    var keyboardHeight: CGFloat = .zero
    var lastPipPlaying: Bool = false
    var screenLock: Bool = false
    /**
     가로 모드 방송에서 stopCustomPictureInPicture실핼될때 setVideoPosition받아서 애니메이션 처리 필요, 자세한 이유는 pr:  https://github.com/shoplive/matrix-sdk-ios/pull/318  댓글 참조
     */
    var needForceSetVideoPositionUpdate: Bool = false
    var keepOrientationWhenPlayStart: Bool = false

    var snapShot: UIImage? = nil
    var streamUrl: URL? {
        didSet {
            ShopLiveController.videoUrl = streamUrl
        }
    }
    private var windowStyle: ShopLiveWindowStyle = .normal
    var prevWindowStyle: ShopLiveWindowStyle = .none
    var hookNavigation: ((URL) -> Void)?
    var webInstance: ShopLiveWebView? {
        didSet {
            if webInstance == nil {
                delegate?.setPresentationStyle(style: .unknown)
            }
        }
    }
    
    var swipeEnabled: Bool = true
    
    @available(iOS,deprecated, message:"레거시 용도로 곧 없앨거고 inAppPipConfiguration으로 모든걸 대체 할 계획")
    var initialPipPosition: ShopLive.PipPosition = .default
    @available(iOS,deprecated, message:"레거시 용도로 곧 없앨거고 inAppPipConfiguration으로 모든걸 대체 할 계획")
    var lastPipScale: CGFloat = 2/5
    @available(iOS,deprecated, message:"레거시 용도로 곧 없앨거고 inAppPipConfiguration으로 모든걸 대체 할 계획")
    var fixedPipWidth: CGFloat?
    
    
    var inRotating: Bool = false
    var willStartPip: Bool = false
    
    var videoOrientation: ShopLiveDefines.ShopLiveOrientaion {
        switch supportOrientation {
        case .portrait, .unknown:
            return .portrait
        case .landscape:
            return .landscape
        }
    }
    var supportOrientation: ShopLive.VideoOrientation = .unknown
    
    var lastOrientaion: (direction: ShopLiveDefines.ShopLiveOrientaion, orientation: UIDeviceOrientation) = ((UIScreen.isLandscape_SL ? .landscape: .portrait, UIScreen.currentOrientation_SL.deviceOrientation_SL))
    
    var videoExpanded: Bool = true
    
    lazy var videoRatio: CGSize = videoOrientation == .landscape ? CGSize(width: 16, height: 9): CGSize(width: 9, height: 16)
    var videoFrame: (portrait: CGRect?, landscape: (expanded: CGRect?, standard: CGRect?)) = (portrait: nil, landscape: (expanded: nil, standard: nil))
    
    private var videoUrlObservation: NSKeyValueObservation?
    private var urlAssetObservation: NSKeyValueObservation?
    private var isPlayableObservation: NSKeyValueObservation?
    private var playerItemObservation: NSKeyValueObservation?
    private var playerItemStatusObservation: NSKeyValueObservation?
    private var playerObservation: NSKeyValueObservation?
    private var timeControlStatusObservation: NSKeyValueObservation?
    private var currentItemObservation: NSKeyValueObservation?
    private var loadedTimeRangesObservation: NSKeyValueObservation?
    private var isHiddenOverlayObservation: NSKeyValueObservation?
    private var overlayUrlObservation: NSKeyValueObservation?
    private var playControlObservation: NSKeyValueObservation?
    private var retryPlayObservation: NSKeyValueObservation?
    private var releasePlayerObservation: NSKeyValueObservation?
    
    private var timebaseRateChangedNotificateObservation: NSObjectProtocol?
    private var playbackStalledNotificateObservation: NSObjectProtocol?

    func addPlayerDelegate(delegate: ShopLivePlayerDelegate) {
        guard self.playerDelegates.filter({ $0?.identifier == delegate.identifier }).isEmpty else { return }
        if self.playerDelegates.isEmpty {
            self.addPlayerObserver()
        }
        self.playerDelegates.append(delegate)
    }


    func removePlayerDelegate(delegate: ShopLivePlayerDelegate) {
        guard let index = self.playerDelegates.firstIndex(where: { $0?.identifier == delegate.identifier }) else { return }
        self.playerDelegates.remove(at: index)
        if self.playerDelegates.isEmpty {
            self.removePlayerObserver()
        }
    }

    func initialize() {
        isSuccessCampaignJoin = false
    }

    func releaseData() {
        playerDelegates.removeAll()
        removePlayerObserver()
        reset()
    }

    func resetOnlyFinished() {
        currentCampaignKey = ""
        isSameCampaign = false
        
        let hasObservers = !playerDelegates.isEmpty
        
        playItem = nil
        playItem = .init()

        playerItem = nil
        playerItem = .init()
        
        if hasObservers {
            removePlayerObserver()
            addPlayerObserver()
        }
        
        hookNavigation = nil
        currentPlayTime = nil
        isReplayMode = false
        isSuccessCampaignJoin = false
        campaignStatus = .close
        webInstance = nil
        prevWindowStyle = .none
        
        isMuted = ShopLiveConfiguration.SoundPolicy.isMutedWhenStart
        ShopLiveConfiguration.UI.color = .white
        ShopLiveConfiguration.UI.customIndicatorImages.removeAll()
        _playerMode = .none
    }
    private func reset() {
        keepOrientationWhenPlayStart = false
        playerResumeCount = 0
        playControl = .none
        isReplayMode = false
        isHiddenOverlay = false
        overlayUrl = nil
        isPlaying = false
        
        retryPlay = false
        streamUrl = nil
        releasePlayer = false
        windowStyle = .none
        needReload = false
        isMuted = ShopLiveConfiguration.SoundPolicy.isMutedWhenStart
        resetVideoDatas()
    }
    
    func resetVideoDatas() {
        lastOrientaion = (UIScreen.isLandscape_SL ? .landscape: .portrait, UIScreen.currentOrientation_SL.deviceOrientation_SL)
        supportOrientation = .unknown
        videoRatio = ShopLiveDefines.defVideoRatio
        videoFrame = (nil, (nil, nil))
        videoExpanded = true
    }

    func getSnapShot(completion: @escaping (UIImage?) -> Void) {
        guard let videoOutput = playItem?.videoOutput,
              let currentItem = playerItem?.player?.currentItem else { return }

        let currentTime = currentItem.currentTime()
        if let buffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
            let ciImage = CIImage(cvPixelBuffer: buffer)
            let imgRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
            if let videoImage = CIContext().createCGImage(ciImage, from: imgRect) {
                let image = UIImage.init(cgImage: videoImage)
                completion(image)
            } else {
                completion(nil)
            }
        }
        else {
            completion(nil)
        }
    }
    
    func setSoundMute(isMuted: Bool) {
        ShopLiveController.player?.isMuted = isMuted
        ShopLiveController.webInstance?.sendMuteStateToWeb(
            event: .setVideoMute(isMuted: isMuted),
            isMuted,
            completion: { success in
                if success {
                    ShopLiveController.player?.isMuted = isMuted
                }
            }
        )
    }

    func seekToLatest() {
        guard let player = ShopLiveController.player else { return }
        guard let seekableRange = player.currentItem?.seekableTimeRanges.last?.timeRangeValue else { return }
        let currentTime = player.currentTime()
        let seekEndTime = seekableRange.end
        
        if seekEndTime > currentTime && seekEndTime.isValid {
            player.seek(to: seekEndTime, toleranceBefore: .init(seconds: 1, preferredTimescale: 44100), toleranceAfter: .init(seconds: 1, preferredTimescale: 44100))
        }
    }

}

// MARK: ShopLive Player Section
extension ShopLiveController {
    func addPlayerObserver() {
        if let playItem = playItem {
            videoUrlObservation = playItem.observe(\.videoUrl, options: [.new]) { [weak self] _, _ in
                self?.postPlayerObservers(key: .videoUrl)
            }
            
            urlAssetObservation = playItem.observe(\.urlAsset, options: [.new, .initial]) { [weak self] playItem, _ in
                self?.isPlayableObservation?.invalidate()
                self?.isPlayableObservation = nil
                
                if let urlAsset = playItem.urlAsset {
                    self?.isPlayableObservation = urlAsset.observe(\.isPlayable, options: [.new]) { [weak self] _, _ in
                        self?.postPlayerObservers(key: .isPlayable)
                    }
                }
            }
            
            playerItemObservation = playItem.observe(\.playerItem, options: [.new, .initial]) { [weak self] playItem, _ in
                self?.playerItemStatusObservation?.invalidate()
                self?.playerItemStatusObservation = nil
                
                if let timebaseToken = self?.timebaseRateChangedNotificateObservation {
                    NotificationCenter.default.removeObserver(timebaseToken)
                    self?.timebaseRateChangedNotificateObservation = nil
                }
                if let stalledToken = self?.playbackStalledNotificateObservation {
                    NotificationCenter.default.removeObserver(stalledToken)
                    self?.playbackStalledNotificateObservation = nil
                }
                
                if let playerItem = playItem.playerItem {
                    self?.playerItemStatusObservation = playerItem.observe(\.status, options: [.new]) { [weak self] _, _ in
                        self?.postPlayerObservers(key: .playerItemStatus)
                    }
                    
                    self?.timebaseRateChangedNotificateObservation = NotificationCenter.default.addObserver(
                        forName: .TimebaseEffectiveRateChangedNotification,
                        object: playerItem.timebase,
                        queue: nil
                    ) { _ in
                        guard let timebase = ShopLiveController.timebase else { return }
                        let rate = CMTimebaseGetRate(timebase)
                        ShopLiveController.perfMeasurements?.rateChanged(rate: rate)
                    }
                    
                    self?.playbackStalledNotificateObservation = NotificationCenter.default.addObserver(
                        forName: .AVPlayerItemPlaybackStalled,
                        object: playerItem,
                        queue: nil
                    ) { notification in
                        guard let currentPlayerItem = ShopLiveController.playerItem,
                              let notificationObject = notification.object as? AVPlayerItem,
                              currentPlayerItem === notificationObject else { return }
                        ShopLiveController.perfMeasurements?.playbackStalled()
                    }
                }
            }
        }
        
        if let playerItem = playerItem {
            playerObservation = playerItem.observe(\.player, options: [.new, .initial]) { [weak self] playerItem, _ in
                self?.timeControlStatusObservation?.invalidate()
                self?.timeControlStatusObservation = nil
                self?.currentItemObservation?.invalidate()
                self?.currentItemObservation = nil
                self?.loadedTimeRangesObservation?.invalidate()
                self?.loadedTimeRangesObservation = nil
                
                if let player = playerItem.player {
                    self?.timeControlStatusObservation = player.observe(\.timeControlStatus, options: [.new]) { [weak self] _, _ in
                        self?.postPlayerObservers(key: .timeControlStatus)
                    }
                    
                    self?.currentItemObservation = player.observe(\.currentItem, options: [.new, .initial]) { [weak self] player, _ in
                        guard let self else { return }
                        self.loadedTimeRangesObservation?.invalidate()
                        self.loadedTimeRangesObservation = nil
                        
                        if let currentItem = player.currentItem {
                            self.loadedTimeRangesObservation = currentItem.observe(\.loadedTimeRanges, options: [.new]) { item, _ in
                                guard let timeRange = item.loadedTimeRanges.last?.timeRangeValue else { return }
                                let timeLoaded = Int(timeRange.duration.value) / Int(timeRange.duration.timescale)
                                if timeLoaded >= 4 && ShopLiveController.timeControlStatus == .waitingToPlayAtSpecifiedRate && ShopLiveController.playControl != .play {
                                    ShopLiveController.playControl = .play
                                }
                            }
                        }
                    }
                }
            }
        }
        
        isHiddenOverlayObservation = observe(\.isHiddenOverlay, options: [.initial, .new]) { [weak self] _, _ in
            self?.postPlayerObservers(key: .isHiddenOverlay)
        }
        
        overlayUrlObservation = observe(\.overlayUrl, options: [.initial, .old, .new]) { [weak self] _, _ in
            self?.postPlayerObservers(key: .overlayUrl)
        }
        
        playControlObservation = observe(\.playControl, options: [.new]) { [weak self] _, _ in
            self?.postPlayerObservers(key: .playControl)
        }
        
        retryPlayObservation = observe(\.retryPlay, options: [.old, .new]) { [weak self] _, change in
            if let old: Bool = change.oldValue, let new: Bool = change.newValue {
                if old != new {
                    guard let videoUrl = ShopLiveController.streamUrl, !videoUrl.absoluteString.isEmpty else {
                        return
                    }
                    self?.postPlayerObservers(key: .retryPlay)
                }
            } else {
                self?.postPlayerObservers(key: .retryPlay)
            }
        }
        
        releasePlayerObservation = observe(\.releasePlayer, options: [.new]) { [weak self] _, _ in
            self?.postPlayerObservers(key: .releasePlayer)
        }
    }

    func removePlayerObserver() {
        videoUrlObservation?.invalidate()
        videoUrlObservation = nil
        
        urlAssetObservation?.invalidate()
        urlAssetObservation = nil
        
        isPlayableObservation?.invalidate()
        isPlayableObservation = nil
        
        playerItemObservation?.invalidate()
        playerItemObservation = nil
        
        playerItemStatusObservation?.invalidate()
        playerItemStatusObservation = nil
        
        playerObservation?.invalidate()
        playerObservation = nil
        
        timeControlStatusObservation?.invalidate()
        timeControlStatusObservation = nil
        
        currentItemObservation?.invalidate()
        currentItemObservation = nil
        
        loadedTimeRangesObservation?.invalidate()
        loadedTimeRangesObservation = nil
        
        isHiddenOverlayObservation?.invalidate()
        isHiddenOverlayObservation = nil
        
        overlayUrlObservation?.invalidate()
        overlayUrlObservation = nil
        
        playControlObservation?.invalidate()
        playControlObservation = nil
        
        retryPlayObservation?.invalidate()
        retryPlayObservation = nil
        
        releasePlayerObservation?.invalidate()
        releasePlayerObservation = nil
        
        if let timebaseRateChangedObservation = timebaseRateChangedNotificateObservation {
            NotificationCenter.default.removeObserver(timebaseRateChangedObservation)
            timebaseRateChangedNotificateObservation = nil
        }
        
        if let playbackStalledObservation = playbackStalledNotificateObservation {
            NotificationCenter.default.removeObserver(playbackStalledObservation)
            playbackStalledNotificateObservation = nil
        }
    }

    func postPlayerObservers(key: ShopLivePlayerObserveValue) {
        playerDelegates.forEach { delegate in
            delegate?.updatedValue(key: key)
        }
    }
}

extension ShopLiveController {

    static var player: AVPlayer? {
        set {
            shared.playerItem?.player = newValue
        }
        get {
            return shared.playerItem?.player
        }
    }

    static var videoUrl: URL? {
        set {
            shared.playItem?.videoUrl = newValue
        }
        get {
            return shared.playItem?.videoUrl
        }
    }

    static var playerItem: AVPlayerItem? {
        set {
            shared.playItem?.playerItem = newValue
            if let videoOutput = shared.playItem?.videoOutput {
                player?.currentItem?.remove(videoOutput)
                shared.playItem?.videoOutput = nil
            }

            if let playerItem = newValue {
                let properties:[String: Any] = [
                    (kVTCompressionPropertyKey_RealTime as String): kCFBooleanTrue ?? true,
                    (kVTCompressionPropertyKey_ProfileLevel as String): kVTProfileLevel_H264_High_AutoLevel,
                    (kVTCompressionPropertyKey_AllowFrameReordering as String): true,
                    (kVTCompressionPropertyKey_H264EntropyMode as String): kVTH264EntropyMode_CABAC,
                    (kVTCompressionPropertyKey_PixelTransferProperties as String): [
                        (kVTPixelTransferPropertyKey_ScalingMode as String): kVTScalingMode_Trim
                    ]
                ]
                
                shared.playItem?.videoOutput = AVPlayerItemVideoOutput.init(pixelBufferAttributes: properties)
                if let videoOutput = shared.playItem?.videoOutput {
                    playerItem.add(videoOutput)
                }
                
                shared.playerItem?.player?.replaceCurrentItem(with: playerItem)
            } else {
                shared.playerItem?.player?.replaceCurrentItem(with: nil)
            }
        }
        get {
            return shared.playItem?.playerItem
        }
    }

    static var urlAsset: AVURLAsset? {
        set {
            shared.playItem?.urlAsset = newValue
        }
        get {
            return shared.playItem?.urlAsset
        }
    }

    static var playerItemStatus: AVPlayerItem.Status {
        get {
            return shared.playItem?.playerItem?.status ?? .unknown
        }
    }
    
    static var isPlaybackLikelyToKeepUp: Bool? {
        get {
            return shared.playItem?.playerItem?.isPlaybackLikelyToKeepUp
        }
    }
    
    static var isPlaybackBufferEmpty: Bool? {
        get {
            return shared.playItem?.playerItem?.isPlaybackBufferEmpty
        }
    }
    
    static var isPlaybackBufferFull: Bool? {
        get {
            return shared.playItem?.playerItem?.isPlaybackBufferFull
        }
    }

    static var perfMeasurements: PerfMeasurements? {
        set {
            shared.playItem?.perfMeasurements = newValue
        }
        get {
            return shared.playItem?.perfMeasurements
        }
    }

    static var isReplayMode: Bool {
        set {
            shared.isReplayMode = newValue
        }
        get {
            return shared.isReplayMode
        }
    }

    static var isHiddenOverlay: Bool {
        set {
            shared.isHiddenOverlay = newValue
        }
        get {
            return shared.isHiddenOverlay
        }
    }

    static var playControl: ShopLiveConfiguration.SLPlayControl {
        get {
            return shared.playControl
        }
        set {
            if UIApplication.shared.applicationState == .background && ShopLiveController.windowStyle != .osPip {
                return
            }
            shared.playControl = newValue
        }
    }

    static var webInstance: ShopLiveWebView? {
        set {
            shared.webInstance = newValue
        }
        get {
            return shared.webInstance
        }
    }

    static var duration: CMTime? {
        return shared.playerItem?.player?.currentItem?.asset.duration
    }

    static var timeControlStatus: AVPlayer.TimeControlStatus {
        return shared.playerItem?.player?.timeControlStatus ?? .waitingToPlayAtSpecifiedRate
    }

    static var timebase: CMTimebase? {
        return shared.playItem?.playerItem?.timebase
    }

    static var overlayUrl: URL? {
        set {
            shared.overlayUrl = newValue
        }
        get {
            return shared.overlayUrl
        }
    }

    static var isPlaying: Bool {
        set {
            shared.isPlaying = newValue
        }
        get {
            return shared.isPlaying
        }
    }

    static var retryPlay: Bool {
        set {
            if ShopLiveController.streamUrl != nil {
                shared.retryPlay = newValue
            }
        }
        get {
            return shared.retryPlay
        }
    }

    static var streamUrl: URL? {
        set {
            shared.streamUrl = newValue
        }
        get {
            return shared.streamUrl
        }
    }

    static var windowStyle: ShopLiveWindowStyle {
        set {
            if shared.windowStyle != .osPip {
                shared.prevWindowStyle = shared.windowStyle
            }
            shared.windowStyle = newValue
        }
        get {
            return shared.windowStyle
        }
    }

    static var isReplayFinished: Bool {
        guard ShopLiveController.isReplayMode,
              let duration = ShopLiveController.duration,
              let currentTime = shared.currentPlayTime
        else {
            return false
        }
        let roundedCurrentTime = Int64(round(Double(currentTime.value) / 1000000000))
        return (duration.value / 1000) <= roundedCurrentTime
    }
}
