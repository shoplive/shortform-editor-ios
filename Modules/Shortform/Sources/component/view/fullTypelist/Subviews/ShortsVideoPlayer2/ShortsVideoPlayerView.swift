//
//  ShortsVideoPlayerView.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2/1/24.
//

import Foundation
import UIKit
import AVKit
import VideoToolbox
import ShopliveSDKCommon



class ShortsVideoPlayerView : UIView, SLReactor {
    typealias ShortsMode = ShopLiveShortform.ShortsMode
    
    enum Action {
        case initPlayerView(URL)
        case emptyPlayer
        case requestSnapShot
        case requestSnapShotForWindow
        case setVideoGravity(AVLayerVideoGravity)
        case setShortsMode(ShortsMode)
        
        case play
        case pause
        case replay
        case stop
        case seekTo(CMTime)
        
        case setMute(Bool)
        case setPreferredForwardBufferDuration(Double)
        case removePlayerStatusObserver
    }
    
    enum Result {
        case snapShotComplete(UIImage?)
        case snapShotCompleteForWindow(UIImage?)
        case videoTimeUpdated(CMTime)
        case videoDidPlayToEnd
        case playerItemStatusChanged(AVPlayerItem.Status)
        case timeControlStatusChanged(AVPlayer.TimeControlStatus)
        case playerItemSetComplete
        case requestHideSnapShotFormWindow
    }
    
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    
    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    
    private let reactor = ShortsVideoPlayerReactor()
    
    var resultHandler: ((Result) -> ())?
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.playerLayer.backgroundColor = UIColor.clear.cgColor
        bindReactor()
        setLayout()
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    deinit {
        ShopLiveLogger.debugLog("shortsvideoplayerview deinited")
    }
    
}
//MARK: - getter
extension ShortsVideoPlayerView {
    func getVideoDuration() -> Double {
        return reactor.getVideoDuration()
    }
    
    func getCurrentTime() -> Double? {
        return reactor.getCurrentTime()
    }
    
    func getCurrentCMTime() -> CMTime? {
        return reactor.getCurrentCMTime()
    }
}
//MARK: - view Action
extension ShortsVideoPlayerView {
    func action(_ action: Action) {
        switch action {
        case .emptyPlayer:
            self.onEmptyPlayer()
        case .initPlayerView(let videoUrl):
            self.onInitPlayerView(videoURl: videoUrl)
        case .requestSnapShot:
            self.onRequestSnapShot()
        case .requestSnapShotForWindow:
            self.onRequestSnapShotForWindow()
        case .setVideoGravity(let gravity):
            self.onSetVideoGravity(gravity: gravity)
        case .play:
            self.onPlay()
        case .replay:
            self.onReplay()
        case .pause:
            self.onPause()
        case .stop:
            self.onStop()
        case .seekTo(let time):
            self.onSeekTo(time: time)
        case .setMute(let isMute):
            self.onSetMute(isMute: isMute)
        case .setShortsMode(let shortsMode):
            self.onSetShortsMode(shortsMode: shortsMode)
        case .setPreferredForwardBufferDuration(let duration):
            self.onSetPreferredForwardBufferDuration(duration: duration)
        case .removePlayerStatusObserver:
            self.onRemovePlayerStatusObserver()
        }
    }
    
    private func onEmptyPlayer() {
        reactor.action( .emptyPlayer )
    }
    
    private func onInitPlayerView(videoURl : URL) {
        reactor.action( .initPlayer(videoURl) )
    }
    
    private func onRequestSnapShot() {
        reactor.action( .requestSnapShot )
    }
    
    private func onRequestSnapShotForWindow() {
        reactor.action( .requestSnapShotForWindow )
    }
    
    private func onSetVideoGravity(gravity : AVLayerVideoGravity) {
        self.playerLayer.videoGravity = gravity
    }
    
    private func onPlay() {
        reactor.action( .play )
    }
    
    private func onReplay() {
        reactor.action( .replay )
    }
    
    private func onPause() {
        reactor.action( .pause )
    }
    
    private func onStop() {
        reactor.action( .stop )
    }
    
    private func onSeekTo(time : CMTime) {
        reactor.action( .seekTo(time) )
    }
    
    private func onSetMute(isMute : Bool) {
        reactor.action( .setMute(isMute) )
    }
    
    private func onSetShortsMode(shortsMode : ShortsMode) {
        reactor.action( .setShortsMode(shortsMode) )
    }
    
    private func onSetPreferredForwardBufferDuration(duration : Double) {
        reactor.action( .setPreferredForwardBufferDuration(duration) )
    }
    
    private func onRemovePlayerStatusObserver() {
        reactor.action( .removePlayerStatusObserver )
    }
}
//MARK: - Reactor bind
extension ShortsVideoPlayerView {
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .setPlayerToLayer(let player):
                self.onSetPlayerToLayer(player: player)
            case .snapShotComplete(let snapShot):
                self.onSnapShotComplete(snapShot: snapShot)
            case .snapShotCompleteForWindow(let snapShot):
                self.onSnapShotCompleteForWindow(snapShot: snapShot)
            case .videoTimeUpdated(let time):
                self.onVideoTimeUpdated(time: time)
            case .videoDidPlayToEnd:
                self.onVideoDidPlayToEnd()
            case .timeControlStatusChanged(let status):
                self.onTimeControlStatusChanged(status: status)
            case .playerItemStatusChanged(let status):
                self.onPlayerItemStatusChanged(status: status)
            case .playerItemSetComplete:
                self.onPlayerItemSetComplete()
            case .requestHideSnapShotForWindow:
                self.onRequestHideSnapShotForWindow()
            }
        }
    }
    
    private func onSetPlayerToLayer(player : AVPlayer) {
        self.playerLayer.player = player
    }
    
    private func onSnapShotComplete(snapShot : UIImage?) {
        resultHandler?( .snapShotComplete(snapShot) )
    }
    
    private func onSnapShotCompleteForWindow(snapShot : UIImage?) {
        resultHandler?( .snapShotCompleteForWindow(snapShot) )
    }
    
    private func onVideoTimeUpdated(time : CMTime) {
        resultHandler?( .videoTimeUpdated(time) )
    }
    
    private func onVideoDidPlayToEnd() {
        resultHandler?( .videoDidPlayToEnd )
    }
    
    private func onTimeControlStatusChanged(status : AVPlayer.TimeControlStatus) {
        resultHandler?( .timeControlStatusChanged(status) )
    }
    
    private func onPlayerItemStatusChanged(status : AVPlayerItem.Status) {
        resultHandler?( .playerItemStatusChanged(status) )
    }
    
    private func onPlayerItemSetComplete() {
        resultHandler?( .playerItemSetComplete )
    }
    
    private func onRequestHideSnapShotForWindow() {
        resultHandler?( .requestHideSnapShotFormWindow )
    }
}
extension ShortsVideoPlayerView {
    private func setLayout() {
        /* no - op  */
    }
}


