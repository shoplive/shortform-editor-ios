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
    public var localAbsoluteUrl: URL
    public var localRelativeUrl : URL
    public var player: AVPlayer?
    private(set) var videoAsset: AVURLAsset?
    private(set) var playerItem: AVPlayerItem?
    
    
    public init(localAbsoluteUrl: URL, localRelativeUrl : URL ) {
        let videoAsset = AVURLAsset(url: localAbsoluteUrl)
        self.videoAsset = videoAsset
        
        let _playerItem = AVPlayerItem(asset: videoAsset)
        self.playerItem = _playerItem
        self.localAbsoluteUrl = localAbsoluteUrl
        self.localRelativeUrl = localRelativeUrl
        self.player = AVPlayer(playerItem: _playerItem)
    }
    
    deinit {
        playerItem = nil
        videoAsset = nil
        player = nil
    }
    
    public func getVideoDuration() -> Double {
        return self.videoAsset?.duration.seconds ?? -1
    }
    
    func configure(videoUrl: URL) {
        self.localAbsoluteUrl = videoUrl
        
        let videoAsset = AVURLAsset(url: videoUrl)
        self.videoAsset = videoAsset
        
        let _playerItem = AVPlayerItem(asset: videoAsset)
        self.playerItem = _playerItem
        
        self.player?.replaceCurrentItem(with: _playerItem)
    }
    
    public func getVideoSize() -> CGSize? {
        guard let track = self.videoAsset?.tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
}
