//
//  File.swift
//  ShortformDemo
//
//  Created by sangmin han on 11/11/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import AVKit


class VideoEditorResultPopUp : UIView {
    
    private var playerContainer : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    
    private var avPlayer : AVPlayer?
    private var playerLayer : AVPlayerLayer?
    private var observer : NSKeyValueObservation?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .init(white: 0, alpha: 0.5)
        setLayout()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = self.playerContainer.bounds
    }
    
    func setVideoPath(videoPath : String) {
        let url = URL(fileURLWithPath: videoPath)
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        avPlayer = AVPlayer()
        avPlayer?.replaceCurrentItem(with: item )
        self.playerLayer = AVPlayerLayer(player: avPlayer)
        self.playerLayer?.frame = self.playerContainer.bounds
        guard let playerLayer = self.playerLayer else { return }
        self.playerContainer.layer.addSublayer(playerLayer)
        self.observer?.invalidate()
        self.observer = nil
        self.observer = item.observe(\.status,options: [.new,.old], changeHandler: { [weak self] item, change in
            if item.status == .readyToPlay {
                print("[VideoEditorResultPopUp] readyToPlay success ")
                return
            }
            else if item.status == .failed {
                if let currentItem = self?.avPlayer?.currentItem, let error = currentItem.error {
                    print("[VideoEditorResultPopUp] readyToPlay error \(error.localizedDescription) ")
                }
            }
        })
        self.avPlayer?.play()
    }
    
    @objc private func backgroundTapped() {
        self.alpha = 0
    }
    
}
extension VideoEditorResultPopUp {
    private func setLayout() {
        self.addSubview(playerContainer)
        NSLayoutConstraint.activate([
            playerContainer.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            playerContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            playerContainer.widthAnchor.constraint(equalToConstant: 300),
            playerContainer.heightAnchor.constraint(equalToConstant: 300),
            
        ])
    }
}
