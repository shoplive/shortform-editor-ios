//
//  VideoPlayerView.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 2023/07/27.
//

import Foundation
import UIKit
import AVKit

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
}
