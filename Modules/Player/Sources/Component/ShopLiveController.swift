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

    deinit { }

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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
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
        case .playControl, .timeControlStatus, .videoUrl, .isPlayable, .isHiddenOverlay, .overlayUrl, .releasePlayer:
            postPlayerObservers(key: key)
            break
        case .playerItemStatus:
            postPlayerObservers(key: key)
            break
        case .retryPlay:
            if let old: Bool = change?[.oldKey] as? Bool, let new: Bool = change?[.newKey] as? Bool {
                if old != new {
                    guard let videoUrl = ShopLiveController.streamUrl, !videoUrl.absoluteString.isEmpty && videoUrl.absoluteString != "null" else {
                        // 
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
        
        playItem = nil
        playItem = .init()

        playerItem = nil
        playerItem = .init()
        
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
        playItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.videoUrl.rawValue, options: .new, context: nil)
        playItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.isPlayable.rawValue, options: .new, context: nil)
        playItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.playerItemStatus.rawValue, options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.timeControlStatus.rawValue, options: .new, context: nil)
        playerItem?.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.loadedTimeRanges.rawValue, options: .new, context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.isHiddenOverlay.rawValue, options: [.initial, .new], context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.overlayUrl.rawValue, options: [.initial, .old, .new], context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.playControl.rawValue, options: .new, context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.retryPlay.rawValue, options: [.old, .new], context: nil)
        self.addObserver(self, forKeyPath: ShopLivePlayerObserveValue.releasePlayer.rawValue, options: .new, context: nil)
    }

    func removePlayerObserver() {
        playItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.videoUrl.rawValue)
        playItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.isPlayable.rawValue)
        playItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.playerItemStatus.rawValue)
        playerItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.timeControlStatus.rawValue)
        playerItem?.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.loadedTimeRanges.rawValue)
        
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.isHiddenOverlay.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.overlayUrl.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.playControl.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.retryPlay.rawValue)
        self.safeRemoveObserver(self, forKeyPath: ShopLivePlayerObserveValue.releasePlayer.rawValue)
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
