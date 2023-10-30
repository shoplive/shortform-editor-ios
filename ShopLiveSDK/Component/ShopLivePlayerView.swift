//
//  ShopLivePlayerView.swift
//  ShopLivePlayer
//
//  Created by ShopLive on 2021/07/31.
//

import AVKit

final class ShopLivePlayerView: SLView {

    var player: ShopLivePlayer = .init()
    
    var playerLayer : AVPlayerLayer? = AVPlayerLayer()
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.playerLayer?.backgroundColor = UIColor.clear.cgColor
        self.playerLayer?.player = player
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.playerLayer?.backgroundColor = UIColor.clear.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let playerLayer = self.playerLayer else { return }
        self.layer.addSublayer(playerLayer)
        playerLayer.frame = self.frame
        
    }
    
    deinit {
        ShopLiveLogger.debugLog("[HASSAN LOG] ShopLivePlayerView deallocated")
    }
    
    func refreshLayer(videoGravity : AVLayerVideoGravity){
        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = nil
        
        self.playerLayer = AVPlayerLayer()
        self.layer.addSublayer(self.playerLayer!)
        self.playerLayer?.videoGravity = videoGravity
        self.playerLayer?.player = player
        self.playerLayer?.frame = self.frame
    }
}
