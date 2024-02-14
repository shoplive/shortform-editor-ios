//
//  SLVideoPlayer.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation
import AVKit

protocol SLPlayerDelegate: AnyObject {
    func didChangePlayerReadyToPlay()
    func didEndPlaying()
}

class ShortformView: UIView {
    
}

class SLVideoPlayer: NSObject {
    weak var delegate: SLPlayerDelegate?
    private(set) var playerItem: AVPlayerItem?
    private lazy var player: AVPlayer = {
        let player = AVPlayer()
        player.isMuted = false
        return player
    }()
    
    private lazy var playerLayer: AVPlayerLayer = {
        return AVPlayerLayer(player: player)
    }()
    
    private lazy var backgroundView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var playerView: SLVideoPlayerView = {
        let view = SLVideoPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        backgroundView.fit_SL()
        view.player = player
        view.sendSubviewToBack(backgroundView)
        view.backgroundColor = .black
        return view
    }()
}
