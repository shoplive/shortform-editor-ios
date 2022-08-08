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

enum ShopLivePlayerObserveValue: String {
    case videoUrl = "videoUrl"
    case timeControlStatus = "player.timeControlStatus"
    case isPlayable = "urlAsset.isPlayable"
    case playerItemStatus = "playerItem.status"
    case isPlaybackLikelyToKeepUp = "playerItem.isPlaybackLikelyToKeepUp"
    case playControl = "playControl"
    case isHiddenOverlay = "isHiddenOverlay"
    case overlayUrl = "overlayUrl"
    case isMuted = "player.isMuted"
    case loadedTimeRanges = "player.currentItem.loadedTimeRanges"
    case isPlaying = "isPlaying"
    case retryPlay = "retryPlay"
    case releasePlayer = "releasePlayer"
    case takeSnapShot = "takeSnapShot"
    case loading = "loading"
}

enum ShopLiveWindowStyle {
    case none
    case inAppPip
    case osPip
    case normal
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

final class ShopLiveController: NSObject {
    static let shared = ShopLiveController()

    private override init() {
        super.init()
    }

    deinit {
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
    var newStartPlay: Bool = false
    var campaignStatus: ShopLiveCampaignStatus = .close
    var isSuccessCampaignJoin: Bool = false
    var keepSnapshot: Bool = false
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
    @objc dynamic var takeSnapShot: Bool = true
    @objc dynamic var isPreview: Bool = false
    @objc dynamic var loading: Bool = false
    
    var isMuted: Bool = ShopLiveConfiguration.SoundPolicy.isMuted
    var isStartedCampaign: Bool = false

    var playerResumeCount: Int = 0
    
    var playerMode: ShopLive.PlayerMode {
        if isStartedCampaign {
            return isPreview ? .preview : .play
        } else {
            return .none
        }
    }
    
    lazy var currentPlayTime: Int64? = nil {
        didSet {
            // ShopLiveLogger.debugLog("seek current play time didSet: \(currentPlayTime)")
        }
    }
    var shareScheme: String? = nil
    var needReload: Bool = false
    var needSeek: Bool = false
    var keyboardHeight: CGFloat = .zero
    var lastPipPlaying: Bool = false
    var screenLock: Bool = false
    
    var keepOrientationWhenPlayStart: Bool = false

    var snapShot: UIImage? = nil
    var streamUrl: URL? {
        didSet {
            ShopLiveController.videoUrl = streamUrl
        }
    }
    var windowStyle: ShopLiveWindowStyle = .normal
    var customShareAction: (() -> Void)?
    var hookNavigation: ((URL) -> Void)?
    var webInstance: ShopLiveWebView?
    var pipAnimating: Bool = false
    var swipeEnabled: Bool = false
    var lastPipPosition: ShopLive.PipPosition = .default
    var lastPipScale: CGFloat = 2/5
    var fixedPipWidth: CGFloat?
    var inRotating: Bool = false
    var videoOrientation: ShopLiveDefines.ShopLiveOrientaion {
        switch supportOrientation {
        case .portrait, .unknown:
            return .portrait
        case .landscape:
            return .landscape
        }
    }
    var supportOrientation: ShopLive.VideoOrientation = .unknown
    var videoExpanded: Bool = true
    
    lazy var videoRatio: CGSize = videoOrientation == .landscape ? CGSize(width: 16, height: 9) : CGSize(width: 9, height: 16)
    var videoFrame: (portrait: CGRect?, landscape: (expanded: CGRect?, standard: CGRect?)) = (portrait: nil, landscape: (expanded: nil, standard: nil))
    
    var prevLandscapeOrientation: UIDeviceOrientation = .landscapeLeft
    var lastOrientaion: ShopLiveDefines.ShopLiveOrientaion = .portrait
    
    var videoCenterCrop: Bool {
        set {
            self._videoCenterCrop = newValue
        }
        get {
            return self.videoExpanded && UIScreen.isLandscape && videoOrientation == .landscape ? _videoCenterCrop : false
        }
    }
    
    private var _videoCenterCrop: Bool = false
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let key = ShopLivePlayerObserveValue(rawValue: keyPath), let _ = change?[.newKey] else { return }
        switch key {
        case .loadedTimeRanges:
            if let loadedTimeRanges = change?[.newKey] as? [NSValue], let timeRange = loadedTimeRanges.last as? CMTimeRange {
                let timeLoaded = Int(timeRange.duration.value) / Int(timeRange.duration.timescale)
                if timeLoaded >= 4 && ShopLiveController.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                    ShopLiveController.playControl = .play
                }
            }
            break
        case .videoUrl, .isPlayable, .playControl, .isHiddenOverlay, .overlayUrl, .isPlaying, .releasePlayer, .takeSnapShot, .timeControlStatus:
            postPlayerObservers(key: key)
            break
        case .loading:
            postPlayerObservers(key: key)
            break
        case .playerItemStatus:
            postPlayerObservers(key: key)
            break
        case .isMuted:
            
            if let old: Bool = change?[.oldKey] as? Bool, let new: Bool = change?[.newKey] as? Bool {
                if old != new {
                    postPlayerObservers(key: key)
                }
            } else {
                postPlayerObservers(key: key)
            }
            break
        case .retryPlay:
            if let old: Bool = change?[.oldKey] as? Bool, let new: Bool = change?[.newKey] as? Bool {
                if old != new {
                    guard let videoUrl = ShopLiveController.streamUrl, !videoUrl.absoluteString.isEmpty && videoUrl.absoluteString != "null" else {
                        // ShopLiveLogger.debugLog("\(keyPath): guard return - videoUrl: \(String(describing: ShopLiveController.streamUrl))")
                        return
                    }
                    postPlayerObservers(key: key)
                }
            } else {
                postPlayerObservers(key: key)
            }
            break
        default:
            break
        }
    }

    func addPlayerDelegate(delegate: ShopLivePlayerDelegate) {
        guard self.playerDelegates.filter({ $0?.identifier == delegate.identifier }).isEmpty else { return }

        if playerDelegates.isEmpty {
            addPlayerObserver()
        }

        playerDelegates.append(delegate)
    }


    func removePlayerDelegate(delegate: ShopLivePlayerDelegate) {
        guard let index = self.playerDelegates.firstIndex(where: { $0?.identifier == delegate.identifier }) else { return }
        self.playerDelegates.remove(at: index)
        if playerDelegates.isEmpty {
            removePlayerObserver()
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
        isStartedCampaign = false
        
        playItem = nil
        playItem = .init()

        playerItem = nil
        playerItem = .init()
        
        customShareAction = nil
        hookNavigation = nil
        currentPlayTime = nil
        isReplayMode = false
        isSuccessCampaignJoin = false
        campaignStatus = .close
        webInstance = nil
        
        newStartPlay = false
        isMuted = ShopLiveConfiguration.SoundPolicy.isMuted
        ShopLiveConfiguration.UI.color = .white
        ShopLiveConfiguration.UI.customIndicatorImages.removeAll()
    }
    private func reset() {
        keepOrientationWhenPlayStart = false
        ShopLiveController.shared.prevLandscapeOrientation = .landscapeLeft
        playerResumeCount = 0
        playControl = .none
        isReplayMode = false
        isHiddenOverlay = false
        overlayUrl = nil
        isPlaying = false
        retryPlay = false
        streamUrl = nil
        releasePlayer = false
        pipAnimating = false
        windowStyle = .none
        needReload = false
        isMuted = ShopLiveConfiguration.SoundPolicy.isMuted
        
        resetVideoDatas()
    }
    
    func resetVideoDatas() {
        lastOrientaion = .portrait
        supportOrientation = .unknown
        videoRatio = ShopLiveDefines.defVideoRatio
        videoFrame = (nil, (nil, nil))
        videoCenterCrop = false
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
    }
    
    func setSoundMute(isMuted: Bool) {
        ShopLiveController.player?.isMuted = isMuted
        ShopLiveConfiguration.SoundPolicy.isMuted = isMuted
        ShopLiveController.webInstance?.sendEventToWeb(event: .setVideoMute(isMuted: isMuted), isMuted)
    }

    func seekToLatest() {
        guard let player = ShopLiveController.player else { return }
        guard let seekableRange = player.currentItem?.seekableTimeRanges.last?.timeRangeValue else { return }

        let seekableStart = CMTimeGetSeconds(seekableRange.start)
        let seekableDuration = CMTimeGetSeconds(seekableRange.duration)
        let livePosition = seekableStart + seekableDuration

        if livePosition > 0 {
            ShopLiveLogger.debugLog("time paused seekToLatest \(livePosition)")
            player.seek(to: CMTime(seconds: floor(livePosition), preferredTimescale: 1))
        }
    }

}

// MARK: ShopLive Player Section
extension ShopLiveController {
    func addPlayerObserver() {
        playItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.videoUrl.rawValue, options: .new, context: nil)
        playItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.isPlayable.rawValue, options: .new, context: nil)
        playItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.playerItemStatus.rawValue, options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.timeControlStatus.rawValue, options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.isMuted.rawValue, options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.loadedTimeRanges.rawValue, options: .new, context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.isHiddenOverlay.rawValue, options: [.initial, .new], context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.overlayUrl.rawValue, options: [.initial, .old, .new], context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.isPlaying.rawValue, options: .new, context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.playControl.rawValue, options: .new, context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.retryPlay.rawValue, options: [.old, .new], context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.releasePlayer.rawValue, options: .new, context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.takeSnapShot.rawValue, options: .new, context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.loading.rawValue, options: .new, context: nil)
    }

    func removePlayerObserver() {
        playItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.videoUrl.rawValue)
        playItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.isPlayable.rawValue)
        playItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.playerItemStatus.rawValue)
        playerItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.timeControlStatus.rawValue)
        playerItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.isMuted.rawValue)
        playerItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.loadedTimeRanges.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.isHiddenOverlay.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.overlayUrl.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.isPlaying.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.playControl.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.retryPlay.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.releasePlayer.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.takeSnapShot.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.loading.rawValue)
    }

    func postPlayerObservers(key: ShopLivePlayerObserveValue) {
//        ShopLiveLogger.debugLog("key: \(key.rawValue)")

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
                shared.playItem?.playerItem?.add(videoOutput)
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
        set {
            shared.playControl = newValue
        }
        get {
            return shared.playControl
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
            shared.windowStyle = newValue
        }
        get {
            return shared.windowStyle
        }
    }

    static var loading: Bool {
        set {
            shared.loading = newValue
        }
        get {
            return shared.loading
        }
    }

    static var isReplayFinished: Bool {
        guard ShopLiveController.isReplayMode, let totalTime = ShopLiveController.duration?.value, let currentTime = shared.currentPlayTime else {
            return false
        }

        return (totalTime / 1000) <= currentTime
    }
}
