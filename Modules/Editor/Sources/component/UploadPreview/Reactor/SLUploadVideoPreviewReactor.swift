//
//  SLUploadVideoPreviewReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/15/23.
//

import Foundation
import AVKit
import ShopliveSDKCommon
import UIKit


class SLUploadVideoPreviewReactor : NSObject, SLReactor {
    
    
    enum Action {
        case setUrl(String)
        
        case seekTo(CMTime)
        case toggleVideoPlayOrPause
        
        case viewDidLoad
    }
    
    enum Result {
        case setAVplayer(AVPlayer)
        
        case setPlayBtnIsHidden(Bool)
        case setSLiderMinimumValue(Float)
        case setSliderMaximumValue(Float)
        case updateSliderCurrentValue(Float64)
    }
    
    
    private var player : AVPlayer?
    private var isSeeking : Bool = false
    private var isPlaying : Bool = false
    private var boundaryTimeObserver : Any?
    private var playTimeObserver : Any?
    private var isTimeControlStatusObserved : Bool = false
    private var isPlayItemStatusObserved : Bool = false
    private var videoUrl : String?
    
    
    
    var resultHandler: ((Result) -> ())?
    
    
    
    deinit {
        
    }
    
    func action(_ action: Action) {
        switch action {
        case .viewDidLoad:
            self.onViewDidLoad()
        case .setUrl(let url):
            self.onSetUrl(url: url)
        case .seekTo(let time):
            self.onSeekTo(time: time)
        case .toggleVideoPlayOrPause:
            self.onToggleVideoPlayOrPause()
        }
    }
    
    private func onViewDidLoad() {
        guard let videoUrl = videoUrl else { return }
        guard let url = URL(string: videoUrl) else { return }
        let asset = AVURLAsset(url: url)
        let playItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playItem)
        
        
        resultHandler?( .setAVplayer(self.player!) )
        
        self.player?.play()
        
        self.addPlayTimeObserver()
        self.addPlayerItemStatusObserver()
        self.addTimeControlStatusObserver()
    }
    
    private func onSetUrl(url: String){
        self.videoUrl = url
    }
    
    private func onSeekTo(time : CMTime) {
        self.isSeeking = true
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero,completionHandler: { [weak self] done  in
            guard done else { return }
            self?.isSeeking = false
        })
    }
    
    private func onToggleVideoPlayOrPause() {
        if isPlaying {
            player?.pause()
            resultHandler?( .setPlayBtnIsHidden(false) )
        }
        else {
            player?.play()
        }
    }
    
}
extension SLUploadVideoPreviewReactor {
    
    private func addPlayerEndBoundaryObserver(time : CMTime) {
        self.removePlayerEndBoundaryObserver()
        boundaryTimeObserver = player?.addBoundaryTimeObserver(forTimes: [NSValue(time: time)], queue: nil, using: { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.player?.seek(to: .zero)
                self.player?.play()
            }
        })
    }
    
    private func removePlayerEndBoundaryObserver() {
        if let boundaryTimeObserver = self.boundaryTimeObserver {
            player?.removeTimeObserver(boundaryTimeObserver)
            self.boundaryTimeObserver = nil
        }
    }
    
    private func addPlayTimeObserver() {
        self.removePlayTimeObserver()
        let time = CMTime(seconds: 0.01 , preferredTimescale: 44100)
        playTimeObserver = player?.addPeriodicTimeObserver(forInterval: time, queue: nil) { [weak self] (time) in
            guard let self = self else { return }
//            let curTime = CMTimeGetSeconds(time)
            guard !self.isSeeking else { return }
            if let playTime = player?.currentItem?.currentTime() {
                self.resultHandler?( .updateSliderCurrentValue(Float64(playTime.seconds)))
            }
        }
    }
    
    private func removePlayTimeObserver() {
        if let playTimeObserver = self.playTimeObserver {
            player?.removeTimeObserver(playTimeObserver)
            self.playTimeObserver = nil
        }
    }
    
    private func addPlayerItemStatusObserver() {
        self.removePlayerItemStatusObserver()
        guard let playerItem = player?.currentItem else { return }
        self.isPlayItemStatusObserved = true
        playerItem.addObserver(self, forKeyPath: "status", context: nil)
        
    }
    
    private func removePlayerItemStatusObserver() {
        guard let playerItem = player?.currentItem, isPlayItemStatusObserved else { return }
        playerItem.removeObserver(self, forKeyPath: "status")
    }
    
    
    private func addTimeControlStatusObserver() {
        self.removeTimeControlStatusObserver()
        guard let player = self.player else { return }
        self.isTimeControlStatusObserved = true
        player.addObserver(self, forKeyPath: "timeControlStatus", context: nil)
    }
    
    private func removeTimeControlStatusObserver() {
        guard let player = self.player, isTimeControlStatusObserved else { return }
        player.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        
        if keyPath == "status" {
            self.onPlayerItemStatusReadyToPlay()
        }
        else if keyPath == "timeControlStatus" {
            self.onTimeControlStatusChanged()
        }
    }
    
    private func onPlayerItemStatusReadyToPlay() {
        guard let duration = player?.currentItem?.duration else { return }
        let seconds = CMTimeGetSeconds(duration)
        
        resultHandler?( .setSLiderMinimumValue(0) )
        resultHandler?( .setSliderMaximumValue(Float(seconds)))
        self.addPlayerEndBoundaryObserver(time: duration)
        
    }
    
    private func onTimeControlStatusChanged() {
        guard let status = player?.timeControlStatus else { return }
        switch status {
        case .paused:
            isPlaying = false
        case .playing:
            isPlaying = true
            resultHandler?( .setPlayBtnIsHidden(true) )
        default:
            break
        }
    }
    
    
}




