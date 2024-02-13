//
//  ShortsVideo.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 2023/07/27.
//

import Foundation
import AVKit
import VideoToolbox

public class ShortsVideo {
    public var videoUrl: URL
    public var player: AVPlayer?
    private(set) var videoAsset: AVURLAsset?
    private(set) var playerItem: AVPlayerItem?
    private(set) var videoOutput: AVPlayerItemVideoOutput?
    
    private(set) var maxBufferDuration: Double
    public var seekNotificationEnabled: Bool = true
    
    public init(videoUrl: URL, maxBufferDuration: Double = 2) {
        let videoAsset = AVURLAsset(url: videoUrl)
        self.videoAsset = videoAsset
        
        let _playerItem = AVPlayerItem(asset: videoAsset)
        self.playerItem = _playerItem
        let properties:[String: Any] = [
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
        
        self.maxBufferDuration = maxBufferDuration
        
        _playerItem.preferredForwardBufferDuration = maxBufferDuration
        
        self.videoUrl = videoUrl
        self.player = AVPlayer(playerItem: _playerItem)
    }
    
    deinit {
        playerItem = nil
        videoAsset = nil
        player = nil
        // print("ShortsVideo deinit")
    }
    
    public func getVideoDuration() -> Double {
        return self.videoAsset?.duration.seconds ?? -1
    }
    
    func configure(videoUrl: URL) {
        self.videoUrl = videoUrl
        
        let videoAsset = AVURLAsset(url: videoUrl)
        self.videoAsset = videoAsset
        
        let _playerItem = AVPlayerItem(asset: videoAsset)
        self.playerItem = _playerItem
        
        _playerItem.preferredForwardBufferDuration = self.maxBufferDuration
        
        self.player?.replaceCurrentItem(with: _playerItem)
    }
    
    func reload() {
        self.configure(videoUrl: self.videoUrl)
    }
    
    private var workItem: DispatchWorkItem?
    
    public func seekTo(time: CMTime) {
        self.workItem?.cancel()
        self.player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    public func getVideoSize() -> CGSize? {
        guard let track = self.videoAsset?.tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
    func getSnapShot(completion: @escaping (UIImage?) -> Void) {
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
}
