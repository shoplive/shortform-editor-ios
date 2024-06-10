//
//  ShortsVideoPlayer2.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2/1/24.
//

import Foundation
import UIKit
import AVKit
import VideoToolbox
import ShopliveSDKCommon



enum SLShortsVideoPlayerObserveValue: String {
    case playerItemStatus = "status"
    case timeControlStatus = "timeControlStatus"

    var keyPath: String {
        return self.rawValue
    }
}

class ShortsVideoPlayer2 : SLReactor {
    
    enum Action {
        case emptyPlayerItem
    }
    
    enum Result {
        case videoPlayerItemSetComplete
    }
    
    
    var resultHandler: ((Result) -> ())?
    
    private var videoUrl : URL
    private var player : AVPlayer?
    private var videoAsset : AVURLAsset?
    private var playerItem : AVPlayerItem?
    private var videoOutput : AVPlayerItemVideoOutput?
    
    private var preferredForwardBufferDuration : Double?
    
    
    init(videoUrl: URL, preferredForwardBufferDuration: Double? = 2.5) {
        self.videoUrl = videoUrl
        self.preferredForwardBufferDuration = preferredForwardBufferDuration
        self.configure(videoUrl: videoUrl)
    }
    
    deinit {
        playerItem = nil
        videoAsset = nil
        player = nil
        ShopLiveLogger.debugLog("ShortsVideoPlayer2 deinited")
    }
    
    
    func action(_ action: Action) {
        switch action {
        case .emptyPlayerItem:
            self.onEmptyPlayerItem()
        }
    }
    
    private func onEmptyPlayerItem() {
        player?.replaceCurrentItem(with: nil)
    }
    
}
extension ShortsVideoPlayer2 {
    
    func configure(videoUrl : URL,preferredForwardBufferDuration: Double? = 2.5){
        if ShopliveMP4CachingManager.shared.isVideoMP4(url: videoUrl) {
            ShopliveMP4CachingManager.shared.downloadVideo(url: videoUrl) { [weak self] playerItem in
                guard let self = self else { return }
                playerItem.preferredForwardBufferDuration = self.preferredForwardBufferDuration ?? 0
                self.videoAsset = playerItem.asset as? AVURLAsset
                self.setPlayerItem(asset: self.videoAsset)
                self.setVideoOutput()
                if self.player == nil {
                    self.player = AVPlayer(playerItem: playerItem)
                }
                else {
                    self.player?.replaceCurrentItem(with: playerItem)
                }
                self.resultHandler?( .videoPlayerItemSetComplete )
            }
        }
        else {
            self.setVideoAsset(videoUrl: videoUrl)
            self.setPlayerItem(asset: videoAsset)
            self.setVideoOutput()
            playerItem?.preferredForwardBufferDuration = self.preferredForwardBufferDuration ?? 0
            if self.player == nil {
                self.player = AVPlayer(playerItem: playerItem)
            }
            else {
                self.player?.replaceCurrentItem(with: playerItem)
            }
            resultHandler?( .videoPlayerItemSetComplete )
        }
    }
    
    func reload(){
        configure(videoUrl: self.videoUrl)
    }
    
    
    private func setVideoAsset(videoUrl : URL){
        let asset = AVURLAsset(url: videoUrl)
        self.videoAsset = asset
    }
    
    private func setPlayerItem(asset : AVAsset?) {
        guard let asset = asset else { return }
        let playerItem = AVPlayerItem(asset: asset)
        self.playerItem = playerItem
    }
    
    private func setVideoOutput() {
        let properties : [String : Any] = [
            (kVTCompressionPropertyKey_RealTime as String): kCFBooleanTrue ?? true,
            (kVTCompressionPropertyKey_ProfileLevel as String): kVTProfileLevel_H264_High_AutoLevel,
            (kVTCompressionPropertyKey_AllowFrameReordering as String): true,
            (kVTCompressionPropertyKey_H264EntropyMode as String): kVTH264EntropyMode_CABAC,
            (kVTCompressionPropertyKey_PixelTransferProperties as String): [
                (kVTPixelTransferPropertyKey_ScalingMode as String): kVTScalingMode_Trim
            ]
        ]
        self.videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: properties)
        if let videoOutput = self.videoOutput {
            self.playerItem?.add(videoOutput)
        }
    }
    
}
extension ShortsVideoPlayer2 {
    func seekTo(time : CMTime,toleranceBefore : CMTime, toleranceAfter : CMTime, completionHandler: @escaping ((Bool) -> Void)) {
        player?.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
    }
    
    func addPeriodicTimeObserver(forInterval : CMTime, queue : DispatchQueue?, using : @escaping( (CMTime) -> Void ) ) -> Any? {
       return player?.addPeriodicTimeObserver(forInterval: forInterval, queue: queue, using: using)
    }
    
    func addBoundaryTimeObserver(forTimes : [NSValue], queue : DispatchQueue?, using : @escaping( () -> Void ) ) {
        player?.addBoundaryTimeObserver(forTimes: forTimes, queue: queue, using: using)
    }
    
    func removeTimeObserver(observer : Any) {
        player?.removeTimeObserver(observer)
    }
    
    func setMute(isMuted : Bool) {
        player?.isMuted = isMuted
    }
    
    func setPreferredForwardBufferDuration(duration : Double?) {
        self.playerItem?.preferredForwardBufferDuration = duration ?? 0
    }
}
//MARK: - getter
extension ShortsVideoPlayer2 {
    
    func getAVPlayer() -> AVPlayer? {
        return self.player
    }
    
    func getAVPlayerItem() -> AVPlayerItem? {
        return self.playerItem
    }
    
    func getVideoDuration() -> Double {
        return self.videoAsset?.duration.seconds ?? -1
    }
    
    func getCurrentTime() -> Double? {
        return self.player?.currentTime().seconds
    }
    
    func getCurrentCMTime() -> CMTime? {
        return self.player?.currentTime()
    }
    
    func getVideoSize() -> CGSize? {
        guard let track = self.videoAsset?.tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
    func getSnapShot(completion : @escaping (UIImage?) -> Void ) {
        guard let videoOutput = self.videoOutput,
              let currentItem = self.player?.currentItem else { return }

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
    
    func getIsMuted() -> Bool? {
        return player?.isMuted
    }
}
