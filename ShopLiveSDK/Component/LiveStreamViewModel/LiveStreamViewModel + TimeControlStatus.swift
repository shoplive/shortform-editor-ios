//
//  LiveStreamViewModel + TimeControlStatus.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 10/10/23.
//

import Foundation
import AVKit




extension LiveStreamViewModel {
    func handleTimeControlStatusPlaying() {
        self.isAlreadyPlayedOnce = true
        ShopLiveLogger.debugLog("timeControlStatus.playing")
        
        if let retryManager = retryManager {
            retryManager.setRequiredRetryCheck(isRequired: false)
            retryManager.setIsBuffering(isBuffering: false)
        }
        
        ShopLiveController.shared.lastPipPlaying = true
        
        if ShopLiveController.isReplayMode {
            ShopLiveController.webInstance?.sendEventToWeb(event: .setIsPlayingVideo(isPlaying: true),true)
        }
        else {
            ShopLiveController.webInstance?.sendEventToWeb(event: .reloadBtn,false,false)
        }
        
        self.delegate?.requestHideOrShowLoading(hide: true)
        ShopLiveController.isPlaying = true
    }
    
    func handleTimeControlStatusPaused() {
        ShopLiveLogger.debugLog("timeControlStatu.paused")
        if ShopLiveController.isReplayMode {
            ShopLiveController.isPlaying = false
        }
        else {
            if ShopLiveController.playControl != .pause {
                if ShopLiveController.windowStyle != .osPip {
                    ShopLiveController.playControl = .resume
                }
                else if ShopLiveController.shared.screenLock {
                    ShopLiveController.shared.lastPipPlaying = false
                }
            }
            else {
                if ShopLiveController.windowStyle == .osPip, !ShopLiveController.shared.screenLock  {
                    ShopLiveController.shared.lastPipPlaying = false
                }
            }
            ShopLiveController.shared.needSeek = true
        }
    }
    
    func handleTimeControlStatusWaitingToPlay() {
        ShopLiveLogger.debugLog("waitingToPlayAtSpecificRate")
        guard let reason = ShopLiveController.player?.reasonForWaitingToPlay else { return }
        switch reason {
        case .toMinimizeStalls:
            self.handleToMinimizeStall()
        case .evaluatingBufferingRate:
            ShopLiveLogger.debugLog("evaluatingBufferingRate")
        case .noItemToPlay:
            ShopLiveLogger.debugLog("k")
        default:
            break
        }
        
        if #available(iOS 15.0,*) {
            if reason == .interstitialEvent {
                ShopLiveLogger.debugLog("interstitialEvent")
            }
            else if reason == .waitingForCoordinatedPlayback {
                ShopLiveLogger.debugLog("waitingForCoordinatedPlayback")
            }
        }
        
        guard let retryManager = retryManager else { return }
        retryManager.setIsBuffering(isBuffering: true)
    }
    
    private func handleToMinimizeStall() {
        ShopLiveLogger.debugLog("toMinimizeStall")
        guard let retryManager = retryManager else { return }
        guard retryManager.getIsBuffering() == false else { return }
        self.delegate?.requestTakeSnapShotView()
        
        if ShopLiveController.shared.campaignStatus != .close {
            if NetworkReachability().connectionStatus() == .Offline {
                self.retryOnNetworkDisconnected()
            }
            else {
                if ShopLiveController.windowStyle != .osPip {
                    retryManager.reserveRetry(waitSecond: 0)
                }
                else {
                    retryManager.reserveRetry(waitSecond: 8)
                }
            }
        }
    }
    
    
}
