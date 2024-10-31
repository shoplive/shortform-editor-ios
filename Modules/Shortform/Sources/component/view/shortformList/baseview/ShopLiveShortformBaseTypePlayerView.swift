//
//  ShopLiveShortformTypeListPlayerView.swift
//  matrix-shortform-ios
//
//  Created by sangmin han on 2023/04/28.
//

import Foundation
import UIKit
import AVFoundation
import ShopliveSDKCommon



protocol ShopLiveShortformBaseTypePlayerViewDelegate : NSObject {
    func onPlayerViewError(error : Error)
    func onPlayerChangedToCacheFile()
    func onPlayerDidStartPlaying()
    func onPlayerIsReadyToPlay(isReady : Bool)
}
/**
 숏폼 목록 비디오 플레이어뷰
 */
class ShopLiveShortformBaseTypePlayerView : UIView {
    
    
    lazy private var playerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.addSublayer(playerLayer)
        view.backgroundColor = .clear
        return view
    }()
    
    private var playerLayer : AVPlayerLayer = {
        let playLayer = AVPlayerLayer()
        playLayer.videoGravity = .resizeAspectFill
        playLayer.backgroundColor = UIColor.clear.cgColor
        return playLayer
    }()
    
    private var player = SLAVLoopPlayer()
    private var isPlaying : Bool = false
    private var isReadyToPlay : Bool = false
    private weak var delegate : ShopLiveShortformBaseTypePlayerViewDelegate?
    private var kvoObservedCounter : Int = 0
    private var previousPlayerTimeControlStatus : AVPlayer.TimeControlStatus = .paused
    private var indexPath : IndexPath?
    
    
    init(frame : CGRect,delegate : ShopLiveShortformBaseTypePlayerViewDelegate?){
        super.init(frame: frame)
        self.delegate = delegate
        setLayout()
        self.playerLayer.player = player
        player.delegate = self
        kvoObservedCounter = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.removeAvPlayerObserver()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer.frame = playerView.bounds
    }
    
    func setIndexPath(indexPath : IndexPath) {
        self.indexPath = indexPath
    }
    
    func setVideoUrl(urlString : String?){
        self.playerLayer.player = player
        guard let urlString = urlString, var url = URL(string: urlString) else { return }
        if ShopliveMP4CachingManager.shared.isVideoMP4(url: url) {
            if let cached = AVAssetDownloadManager.shared.getCachedData(with: urlString) {
                url = cached
            }
            let asset = AVURLAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            self.player.replaceCurrentItem(with: playerItem)
        }
        else {
            ShopliveMP4CachingManager.shared.downloadVideo(url: url) { [weak self] playerItem in
                guard let self = self else { return }
                self.player.replaceCurrentItem(with: playerItem)
                self.isPlaying = false
                self.isReadyToPlay = true
                self.removeAvPlayerObserver()
                self.setupAvPlayerObserver()
            }
        }
    }
    
    func start()  {
        if self.isReadyToPlay && self.player.timeControlStatus != .playing {
            isPlaying = true
            self.player.play()
        }
    }
    
    func pause(){
        if isPlaying {
            isPlaying = false
            self.player.pause()
        }
    }
        
    func refreshPlayer(){
        self.player.pause()
        self.isPlaying = false
        self.isReadyToPlay = false
        self.playerLayer.player = nil
        self.player.replaceCurrentItem(with: nil)
    }
    
    func getIsReadyToPlay() -> Bool {
        return self.isReadyToPlay
    }
    
    private func setupAvPlayerObserver() {
        kvoObservedCounter += 1
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
    }
    
    private func removeAvPlayerObserver() {
        if kvoObservedCounter <= 0 {
            kvoObservedCounter = 0
            return
        }
        kvoObservedCounter -= 1
        player.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus" {
            if player.timeControlStatus == .playing && previousPlayerTimeControlStatus != .playing &&
                self.isReadyToPlay && self.isPlaying {
                previousPlayerTimeControlStatus = .playing
                delegate?.onPlayerDidStartPlaying()
            }
            else if player.timeControlStatus == .paused {
                previousPlayerTimeControlStatus = .paused
            }
        }
    }
    
    func setVideoCache(originUrl : String, cacheUrl : URL) {
        self.player.changeToCacheFile(originUrl: originUrl, cacheUrl: cacheUrl)
    }
}
extension ShopLiveShortformBaseTypePlayerView : SLAVLoopPlayerDelegate {
    func onSLAVLoopPlayerError(error: Error) {
        self.isReadyToPlay = false
        if let urlAsset = player.currentItem?.asset as? AVURLAsset {
            ShopLiveLogger.debugLog("[ShopLiveShortformSDK] avplayer error : \(error.localizedDescription) with \(urlAsset.url.absoluteString)")
        }
        self.delegate?.onPlayerViewError(error: error)
    }
    
    func onSLAVLoopPlayerDidChangeToCacheFile() {
        self.delegate?.onPlayerChangedToCacheFile()
    }
    
    func onSLAVLoopPlayerItemReady(isReady: Bool) {
        self.delegate?.onPlayerIsReadyToPlay(isReady: isReady)
    }
}
extension ShopLiveShortformBaseTypePlayerView {
    private func setLayout(){
        self.addSubview(playerView)
        
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: self.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
