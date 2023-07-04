//
//  ShopLivePlayerView.swift
//  ShopLivePlayer
//
//  Created by ShopLive on 2021/07/31.
//

import AVKit

final class ShopLivePlayerView: SLView {

    var player: ShopLivePlayer = .init()

    var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .black
    }
}
