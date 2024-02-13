//
//  VideoPlayer.swift
//  matrix-shortform-ios
//
//  Created by Vincent on 1/25/23.
//

import Foundation
import AVKit

public protocol SLShortsVideoPlayerDelegate: AnyObject {
    func handlePlayerItemStatus(_ status: AVPlayerItem.Status)
    func handleTimeControlStatus(_ status: AVPlayer.TimeControlStatus)
    func handleDidPlayToEndTime(video: ShopLiveShortform.ShortsVideo?)
    func onVideoTimeUpdated(time: Float64)
}

enum SLShortsVideoPlayerObserveValue: String {
    case playerItemStatus = "status"
    case timeControlStatus = "timeControlStatus"
    
    var keyPath: String {
        return self.rawValue
    }
}

extension ShopLiveShortform {
    class VideoPlayerView: UIView {
        
        override static var layerClass: AnyClass { AVPlayerLayer.self }
        
        private weak var player: AVPlayer? {
            get { playerLayer.player }
            set { playerLayer.player = newValue }
        }
        
        private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
        
        deinit {
            // print("VideoPlayerView deinit")
            self.player = nil
        }
        
        func setPlayer(player: AVPlayer?) {
            self.player = player
        }
        
        func setVideoGravity(gravity: AVLayerVideoGravity) {
            self.playerLayer.videoGravity = gravity
        }
        
        func play() {
            self.player?.play()
        }
        
        func pause() {
            self.player?.pause()
        }
        
        func replay() {
            // print("replay isMuted \(self.player?.isMuted)")
            self.player?.seek(to: .zero)
            self.player?.play()
        }
        
        func stop() {
            self.player?.pause()
            self.player?.seek(to: .zero)
        }
        
        func getCurrentTime() -> Double? {
            return self.player?.currentTime().seconds
        }
    }
}

extension ShopLiveShortform {
    open class VideoPlayer: NSObject {
        
        public weak var playerDelegate: SLShortsVideoPlayerDelegate?
        
        private(set) weak var shortsVideo: ShortsVideo? = nil
        private var inSeeking: Bool = false
        
        var videoDuration: Float64? {
            guard let durationTime = shortsVideo?.player?.currentItem?.asset.duration else {
                return nil
            }
            return CMTimeGetSeconds(durationTime)
        }

        
        lazy var playerView: VideoPlayerView? = {
            let view = VideoPlayerView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setVideoGravity(gravity: UIDevice.current.userInterfaceIdiom == .pad ? .resizeAspect : .resizeAspectFill)
            return view
        }()
        
        private var playTimeObserver: Any?
        private var boundaryTimerObserver: Any?
        
        public var timeUpdateInterval: Double = 0.1
        
        public func setShortsVideo(video: ShortsVideo) {
            playerView?.setPlayer(player: video.player)
            self.teardownObserver()
            self.setupObserver(video: video)
            self.shortsVideo = video
        }
        
        public override init() {
            
        }
        
        func teardown() {
            stop()
            detach()
            teardownObserver()
            shortsVideo = nil
        }
        
        deinit {
            teardown()
        }
        
        func snapShot(completion: @escaping (UIImage?)->Void) {
            self.shortsVideo?.getSnapShot(completion: { image in
                completion(image)
            })
        }
        
        func setMute(_ mute: Bool) {
            shortsVideo?.player?.isMuted = mute
        }
        
        private func setupObserver(video: ShortsVideo?) {
            guard let shortsVideo = video else { return }
            
            self.teardownObserver()
            
            if let playerItem = shortsVideo.playerItem {
                playerItem.addObserver(self, forKeyPath: SLShortsVideoPlayerObserveValue.playerItemStatus.keyPath, options: .new, context: nil)
            }
            
            shortsVideo.player?.addObserver(self, forKeyPath: SLShortsVideoPlayerObserveValue.timeControlStatus.keyPath, options: .new, context: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("reloadVideo"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("stopVideo"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("muteShorts"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("seekStart"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("seekFinished"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: shortsVideo.playerItem)
            
            let time = CMTime(seconds: timeUpdateInterval , preferredTimescale: 44100)
            
            playTimeObserver = shortsVideo.player?.addPeriodicTimeObserver(forInterval: time, queue: nil) { [weak self] (time) in
                guard let self = self else { return }
                let curTime = CMTimeGetSeconds(time)
                guard !self.inSeeking else { return }
                
                if let playTime = shortsVideo.player?.currentItem?.currentTime(), self.inSeeking == false {
                    self.playerDelegate?.onVideoTimeUpdated(time: playTime.seconds)
                }
            }
            
        }
        
        public func setStopTime(time: CMTime) {
            self.removeStopTimer()
            boundaryTimerObserver = shortsVideo?.player?.addBoundaryTimeObserver(forTimes: [NSValue(time: time)], queue: nil, using: { [weak self] in
                guard let self = self, let shortsVideo = self.shortsVideo else { return }
                self.pause()
                self.playerDelegate?.handleDidPlayToEndTime(video: shortsVideo)
            })
        }
        
        public func getCurrentTime() -> Double? {
            return self.playerView?.getCurrentTime()
        }
        
        private func removeStopTimer() {
            if let boundaryTimerObserver = self.boundaryTimerObserver {
                shortsVideo?.player?.removeTimeObserver(boundaryTimerObserver)
                self.boundaryTimerObserver = nil
            }
        }
        
        private func teardownObserver() {
            guard let shortsVideo = self.shortsVideo else {
                return
            }
            
            if let playerItem = shortsVideo.playerItem {
                playerItem.safeRemoveObserver_SL(self, forKeyPath: SLShortsVideoPlayerObserveValue.playerItemStatus.keyPath)
            }
            
            shortsVideo.player?.safeRemoveObserver_SL(self, forKeyPath: SLShortsVideoPlayerObserveValue.timeControlStatus.keyPath)
            
            tearDownNotificationCenter()
            NotificationCenter.default.removeObserver(self)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("reloadVideo"), object: nil)
            
            if let playTimeObserver = self.playTimeObserver {
                shortsVideo.player?.removeTimeObserver(playTimeObserver)
                self.playTimeObserver = nil
            }
            
            if let boundaryTimerObserver = self.boundaryTimerObserver {
                shortsVideo.player?.removeTimeObserver(boundaryTimerObserver)
                self.boundaryTimerObserver = nil
            }
        }
        
        private func tearDownNotificationCenter(){
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("reloadVideo"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("stopVideo"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("muteShorts"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("seekStart"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("seekFinished"), object: nil)
        }
        
        @objc func handleNotification(_ notification: Notification) {
            switch notification.name {
            case NSNotification.Name.AVPlayerItemDidPlayToEndTime:
                if let shortsVideo = self.shortsVideo, let item = notification.object as? AVPlayerItem, item == shortsVideo.playerItem {
                    playerDelegate?.handleDidPlayToEndTime(video: shortsVideo)
                }
                break
            case NSNotification.Name("reloadVideo"):
                shortsVideo?.reload()
                break
            case NSNotification.Name("stopVideo"):
                stop()
                break
            case NSNotification.Name("muteShorts"):
                guard let isMuted = notification.userInfo?["isMuted"] as? Bool else {
                    return
                }
                
                setMute(isMuted)
                break
            case NSNotification.Name("seekStart"):
                self.inSeeking = true
                break
            case NSNotification.Name("seekFinished"):
                self.inSeeking = false
                break
            default:
                break
            }
        }
        
        public func play() {
            playerView?.play()
        }
        
        public func pause() {
            playerView?.pause()
        }
        
        public func replay() {
            playerView?.replay()
        }
        
        public func stop() {
            playerView?.stop()
        }
        
        private func reload() {
            shortsVideo?.reload()
        }
        
        public func seekTo(time: CMTime) {
            shortsVideo?.seekTo(time: time)
        }
        
        public func setVideoGravity(_ videoGravity: AVLayerVideoGravity) {
            self.playerView?.setVideoGravity(gravity: videoGravity)
        }
        
        public func attach(parent: UIView) {
            if let playerView = playerView {
                parent.addSubview(playerView)
                playerView.fit_SL()
                parent.bringSubviewToFront(playerView)
            }
        }
        
        public func detach() {
            self.playerView?.removeFromSuperview()
            self.playerView = nil
        }
        
        public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard let keyPath = keyPath, let key = SLShortsVideoPlayerObserveValue(rawValue: keyPath), let _ = change?[.newKey] else { return }
            
            switch key {
            case .timeControlStatus:
                guard let newValue: Int = change?[.newKey] as? Int else { return }
                guard let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue) else { return }
                playerDelegate?.handleTimeControlStatus(newStatus)
                break
            case .playerItemStatus:
                guard let newValue: Int = change?[.newKey] as? Int else { return }
                guard let newStatus = AVPlayerItem.Status(rawValue: newValue) else { return }
                
                playerDelegate?.handlePlayerItemStatus(newStatus)
                break
            }
        }
    }
}
