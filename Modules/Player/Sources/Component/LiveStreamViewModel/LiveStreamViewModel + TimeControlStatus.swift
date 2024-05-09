//
//  LiveStreamViewModel + TimeControlStatus.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 10/10/23.
//

import Foundation
import AVKit
import ShopliveSDKCommon




extension LiveStreamViewModel {
    func handleTimeControlStatusPlaying() {
        self.isAlreadyPlayedOnce = true
        ShopLiveLogger.debugLog("timeControlStatus.playing")
        
        if let retryManager = retryManager {
            retryManager.setRequiredRetryCheck(isRequired: false)
            retryManager.setIsBuffering(isBuffering: false)
            retryManager.setIsInRetry(isInRetry: false)
            retryManager.setBlockRetry(block: false)
        }
        
        ShopLiveController.shared.lastPipPlaying = true
        
        if ShopLiveController.isReplayMode {
            ShopLiveController.webInstance?.sendEventToWeb(event: .setIsPlayingVideo(isPlaying: true),true)
        }
        else {
            ShopLiveController.webInstance?.sendEventToWeb(event: .reloadBtn,false,false)
        }
        self.delegate?.requestHideOrShowLoading(isHidden: true)
        ShopLiveController.isPlaying = true
    }
    
    func handleTimeControlStatusPaused() {
        ShopLiveLogger.debugLog("timeControlStatu.paused")
        self.delegate?.requestTakeSnapShotView()
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
        ShopLiveLogger.debugLog("waitingToPlayAtSpecificRate ")
        guard let reason = ShopLiveController.player?.reasonForWaitingToPlay else { return }
        guard let retryManager = retryManager else { return }
        self.delegate?.requestTakeSnapShotView()
        switch reason {
        case .toMinimizeStalls:
            self.handleToMinimizeStall()
            retryManager.setIsBuffering(isBuffering: true)
        case .evaluatingBufferingRate:
            ShopLiveLogger.debugLog("evaluatingBufferingRate")
        case .noItemToPlay:
            ShopLiveLogger.debugLog("noItemToPlay")
            self.sendOnVideoErrorToWebForNoItemToPlay()
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
    }
    
    private func sendOnVideoErrorToWebForNoItemToPlay() {
        let currentPlayTime = ShopLiveController.player?.currentTime().seconds ?? 0
        if currentPlayTime < 5 || currentPlayTime == .nan  {
            return
        }
        self.sendOnVideoErrorToWeb(errorCase: .noItemToPlay , reason: "noItemToPlay")
    }
    
    private func handleToMinimizeStall() {
        ShopLiveLogger.debugLog("toMinimizeStall")
        guard let retryManager = retryManager else { return }
        guard retryManager.getIsBuffering() == false else { return }
        
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
