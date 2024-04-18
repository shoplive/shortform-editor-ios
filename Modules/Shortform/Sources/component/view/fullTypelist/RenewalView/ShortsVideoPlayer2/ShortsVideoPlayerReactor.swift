//
//  ShortsVideoPlayerReactor.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2/1/24.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import VideoToolbox
import ShopliveSDKCommon


class ShortsVideoPlayerReactor : NSObject, SLReactor {
    
    
    enum Action {
        case initPlayer(URL)
        case setVideoUrl(URL)
        case reloadVideo
        case seekTo(CMTime)
        case requestSnapShot
        case requestSnapShotForWindow
        
        case play
        case replay
        case pause
        case stop
        
        case setMute(Bool)
    }
    
    enum Result {
        case setPlayerToLayer(AVPlayer)
        case snapShotComplete(UIImage?)
        case snapShotCompleteForWindow(UIImage?)
        case videoTimeUpdated(CMTime)
        case videoDidPlayToEnd
        
        case timeControlStatusChanged(AVPlayer.TimeControlStatus)
        case playerItemStatusChanged(AVPlayerItem.Status)
    }
    
    
    private var shortsVideoPlayer : ShortsVideoPlayer2?
    private var playTimeObserver : Any?
    private var timeupdateInterval : Double = 0.1
    private var isSeeking : Bool = false
    private var didRegisterPlayerItemStatusObserver : Bool = false
    private var didRegisterPlayerTimeControlstatusObserver : Bool = false
    
    
    var resultHandler: ((Result) -> ())?
    
    override init() {
        super.init()
        
    }
    
    deinit {
        self.removePlayTimeObserver()
        self.removeVideoEndDetectObserver()
        self.removePlayerStatusObserver()
        ShopLiveLogger.debugLog("shortsvideoplayerreactor deinited")
    }
    
    func action(_ action: Action) {
        switch action {
        case .play:
            self.onPlay()
        case .replay:
            self.onReplay()
        case .pause:
            self.onPause()
        case .stop:
            self.onStop()
        case .initPlayer(let url):
            self.onInitPlayer(videoUrl: url)
        case .setVideoUrl(let url):
            self.onSetVideoUrl(videoUrl: url)
        case .reloadVideo:
            self.onReloadVideo()
        case .seekTo(let time):
            self.onSeekTo(time: time)
        case .requestSnapShot:
            self.onRequestSnapShot()
        case .requestSnapShotForWindow:
            self.onRequestSnapShotForWindow()
        case .setMute(let isMute):
            self.onSetMute(isMute: isMute)
        }
    }
    
    private func onPlay() {
        shortsVideoPlayer?.getAVPlayer()?.play()
    }
    
    private func onReplay() { 
        shortsVideoPlayer?.seekTo(time: .zero, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { _ in
        })
        shortsVideoPlayer?.getAVPlayer()?.play()
    }
    
    private func onPause() {
        shortsVideoPlayer?.getAVPlayer()?.pause()
    }
    
    private func onStop() {
        shortsVideoPlayer?.getAVPlayer()?.pause()
        shortsVideoPlayer?.seekTo(time: .zero, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { _ in
        })
    }
    
    private func onInitPlayer(videoUrl : URL){
        if let shortsVideoPlayer = shortsVideoPlayer {
            shortsVideoPlayer.configure(videoUrl: videoUrl)
        }
        else {
            shortsVideoPlayer = ShortsVideoPlayer2(videoUrl: videoUrl)
        }
        
        if let player = shortsVideoPlayer?.getAVPlayer() {
            resultHandler?( .setPlayerToLayer(player) )
        }
        setPlayTimeObserver()
        setUpPlayerStatusObserver()
        setVideoEndDetectObserver()
    }
    
    private func onSetVideoUrl(videoUrl : URL) {
        shortsVideoPlayer?.configure(videoUrl: videoUrl)
        setPlayTimeObserver()
        setUpPlayerStatusObserver()
    }
    
    private func onReloadVideo() {
        shortsVideoPlayer?.reload()
    }
    
    private func onSeekTo(time : CMTime) {
        isSeeking = true
        let tolerance = CMTime(seconds: 1, preferredTimescale: 44100)
        self.shortsVideoPlayer?.seekTo(time: time, toleranceBefore: tolerance, toleranceAfter: tolerance, completionHandler: { [weak self] isFinished in
            guard let self = self else { return }
            self.isSeeking = false
        })
    }
    
    private func onRequestSnapShot() {
        shortsVideoPlayer?.getSnapShot(completion: { [weak self] snapShot in
            self?.resultHandler?( .snapShotComplete(snapShot) )
        })
    }
    
    private func onRequestSnapShotForWindow() {
        shortsVideoPlayer?.getSnapShot(completion: { [weak self] snapShot in
            self?.resultHandler?( .snapShotCompleteForWindow(snapShot) )
        })
    }
    
    private func onSetMute(isMute : Bool) {
        shortsVideoPlayer?.setMute(isMuted: isMute)
    }
}
//MARK: - Getter
extension ShortsVideoPlayerReactor {
    func getVideoDuration() -> Double {
        return shortsVideoPlayer?.getVideoDuration() ?? -1
    }
    
    func getCurrentTime() -> Double? {
        return shortsVideoPlayer?.getCurrentTime()
    }
}
//MARK: - AVPlayer Observer
extension ShortsVideoPlayerReactor {
    private func setPlayTimeObserver() {
        let interval = CMTime(seconds: timeupdateInterval, preferredTimescale: 44100)
        if playTimeObserver != nil {
            removePlayTimeObserver()
        }
        
        playTimeObserver = shortsVideoPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: nil, using: { [weak self] time in
            guard let self = self else { return }
            guard self.isSeeking == false else { return }
            self.resultHandler?( .videoTimeUpdated(time) )
        })
    }
    
    private func removePlayTimeObserver() {
        if let playTimeObserver = self.playTimeObserver {
            shortsVideoPlayer?.removeTimeObserver(observer: playTimeObserver)
            self.playTimeObserver = nil
        }
    }
    
    private func setVideoEndDetectObserver() {
        self.removeVideoEndDetectObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(onVideoPlayerDidEnd(sender: )), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: shortsVideoPlayer?.getAVPlayerItem())
    }
    
    @objc private func onVideoPlayerDidEnd(sender : Notification) {
        resultHandler?( .videoDidPlayToEnd )
    }
    
    private func removeVideoEndDetectObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: shortsVideoPlayer?.getAVPlayerItem())
    }
    
}

//MARK: - AVPlayer Status observer
extension ShortsVideoPlayerReactor {
    private func setUpPlayerStatusObserver() {
        self.removePlayerStatusObserver()
        if let playerItem = shortsVideoPlayer?.getAVPlayerItem() {
            playerItem.addObserver(self, forKeyPath: SLShortsVideoPlayerObserveValue.playerItemStatus.keyPath, options: .new, context: nil)
            self.didRegisterPlayerItemStatusObserver = true
        }
        
        if let player = shortsVideoPlayer?.getAVPlayer() {
            player.addObserver(self, forKeyPath: SLShortsVideoPlayerObserveValue.timeControlStatus.keyPath, options: .new,  context: nil)
            self.didRegisterPlayerTimeControlstatusObserver = true
        }
    }
    
    private func removePlayerStatusObserver() {
        if didRegisterPlayerItemStatusObserver, let playerItem = shortsVideoPlayer?.getAVPlayerItem() {
            playerItem.safeRemoveObserver_SL(self, forKeyPath: SLShortsVideoPlayerObserveValue.playerItemStatus.keyPath)
            didRegisterPlayerItemStatusObserver = false
        }
        
        if didRegisterPlayerTimeControlstatusObserver, let player = shortsVideoPlayer?.getAVPlayer() {
            player.safeRemoveObserver_SL(self, forKeyPath: SLShortsVideoPlayerObserveValue.timeControlStatus.keyPath)
            self.didRegisterPlayerTimeControlstatusObserver = false
        }
    }
    
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let key = SLShortsVideoPlayerObserveValue(rawValue: keyPath), let _ = change?[.newKey] else { return }
        
        switch key {
        case .timeControlStatus:
            guard let newValue: Int = change?[.newKey] as? Int else { return }
            guard let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue) else { return }
            resultHandler?( .timeControlStatusChanged(newStatus) )
        case .playerItemStatus:
            guard let newValue: Int = change?[.newKey] as? Int else { return }
            guard let newStatus = AVPlayerItem.Status(rawValue: newValue) else { return }
            resultHandler?( .playerItemStatusChanged(newStatus) )
        }
    }
}
