//
//  LiveStreamViewModel + PlayControl.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 10/10/23.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon

extension LiveStreamViewModel {
    func play() {
        guard !ShopLiveController.shared.screenLock else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let url = ShopLiveController.streamUrl, !url.absoluteString.isEmpty, (ShopLiveController.playerItemStatus == .failed || ShopLiveController.player?.reasonForWaitingToPlay == AVPlayer.WaitingReason.evaluatingBufferingRate) {
                if ShopLiveController.windowStyle != .osPip {
                    self.updatePlayerItem(with: url)
                } else {
                    if let player = ShopLiveController.player {
                        player.play()
                    }
                }
            }
            else {
                if ShopLiveController.isReplayMode && ShopLiveController.isReplayFinished {
                    self.seek(to: .init(value: 0, timescale: 1))
                }
                if let player = ShopLiveController.player {
                    if ShopLiveController.windowStyle == .osPip {
                        ShopLiveController.shared.lastPipPlaying = true
                    }
                    player.play()
                }
            }
        }
    }
    
    func pause() {
        if !ShopLiveController.isReplayMode, ShopLiveController.windowStyle == .osPip {
            ShopLiveController.shared.needReload = true
        }
        DispatchQueue.main.async {
            ShopLiveController.player?.pause()
        }
    }
    
    func stop() {
        resetPlayer()
    }

    func resume() {
        guard !ShopLiveController.shared.screenLock else { return }
        if ShopLiveController.windowStyle == .osPip, !ShopLiveController.shared.lastPipPlaying { return }
        
        if ShopLiveController.isReplayMode {
            ShopLiveController.webInstance?.sendEventToWeb(event: .setIsPlayingVideo(isPlaying: true), true)
        }
        else {
            ShopLiveController.webInstance?.sendEventToWeb(event: .reloadBtn, false, false)
        }
        
        guard ShopLiveController.player?.timeControlStatus != .playing else { return }
        DispatchQueue.main.async {
            if ShopLiveController.isReplayMode {
                ShopLiveController.player?.play()
            }
            else if let url = ShopLiveController.streamUrl, !url.absoluteString.isEmpty {
                if ShopLiveController.shared.needSeek {
                    ShopLiveController.shared.needSeek = false
                    ShopLiveController.shared.seekToLatest()
                }
                ShopLiveController.player?.play()
            }
        }
    }
    
    func resumeFromNotification() {
        if ShopLiveController.isReplayMode {
            ShopLiveController.webInstance?.sendEventToWeb(event: .setIsPlayingVideo(isPlaying: true), true)
        }
        else {
            ShopLiveController.webInstance?.sendEventToWeb(event: .reloadBtn, false, false)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.resume()
        }
    }
}
