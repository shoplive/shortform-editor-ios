//
//  ShopLivePlayerView.swift
//  ShopLivePlayer
//
//  Created by ShopLive on 2021/07/31.
//

import AVKit


fileprivate class PlayerLayerContainerView : UIView {
    var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

final class ShopLivePlayerView: SLView {

    var player: ShopLivePlayer = .init()
    
    var playerLayer : AVPlayerLayer? {
        return self.playerLayerContainer?.playerLayer
    }
    
    private var playerLayerContainer : PlayerLayerContainerView?
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        setLayout()
        self.playerLayer?.backgroundColor = UIColor.clear.cgColor
        self.playerLayer?.player = player
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    
    deinit {
        ShopLiveLogger.debugLog("[HASSAN LOG] ShopLivePlayerView deallocated")
    }
    
    func refreshLayer(videoGravity : AVLayerVideoGravity){
        self.playerLayerContainer?.removeFromSuperview()
        self.playerLayerContainer = nil
        
        setLayout()
        self.playerLayer?.videoGravity = videoGravity
        self.playerLayer?.player = player
        self.playerLayer?.frame = self.frame
    }
    
    
    private func setLayout(){
        self.playerLayerContainer = PlayerLayerContainerView()
        guard let view = playerLayerContainer else { return }
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        view.backgroundColor = .clear
    }
}
