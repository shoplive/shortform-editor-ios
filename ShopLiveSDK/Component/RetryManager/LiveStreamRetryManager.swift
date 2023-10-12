//
//  LiveStreamRetryManager.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 10/10/23.
//

import Foundation
import UIKit

protocol LiveStreamRetryManagerDelegate {
    func updatePlayerItemInRetry(with url : URL)
    func reloadWebViewInRetry(with url : URL)
    func requestHideOrShowSnapShot(hide : Bool)
}

class LiveStreamRetryManager {
    
    private var inBuffering : Bool = false
    private var requireRetryCheck : Bool = false
    private var retryTimer : Timer?
    private var retryCount : Int = 0
    private var isTryingToRecoverFormNetworkDisconnected : Bool = false
    private var isTryingToRecoverFromLoadedTimeRangeStalled : Bool = false
    
    
    var delegate : LiveStreamRetryManagerDelegate?

    
    func getIsBuffering() -> Bool {
        return inBuffering
    }
    
    func setIsBuffering(isBuffering : Bool){
        self.inBuffering = isBuffering
    }
    
    func setRequiredRetryCheck(isRequired : Bool){
        self.requireRetryCheck = isRequired
    }
    
    func setIsTryingToRecoverFromLoadedTimeRangeStalled(isRetrying : Bool) {
        self.isTryingToRecoverFromLoadedTimeRangeStalled = isRetrying
    }
    
    func getIsTringtoRecoverFromLoadedTimeRangeStalled() -> Bool {
        return isTryingToRecoverFromLoadedTimeRangeStalled
    }
    
    
    func reserveRetry(waitSecond: Int = 5) {
        self.requireRetryCheck = true
        ShopLiveController.playerItem?.cancelPendingSeeks()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(waitSecond)) {
            if self.inBuffering, self.requireRetryCheck {
                ShopLiveController.retryPlay = true
            }
            self.requireRetryCheck = false
        }
    }
    
    func resetRetry(triggerFromWebView : Bool = false) {
        if triggerFromWebView == true && self.isTryingToRecoverFormNetworkDisconnected == false {
            return
        }
        retryTimer?.invalidate()
        retryTimer = nil
        retryCount = 0
    }
    
    func handleRetryPlay() {
        resetRetry()
        if ShopLiveController.retryPlay {
            retryTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                self.retryCount += 1
                
                if ShopLiveController.windowStyle != .osPip {
                    if ShopLiveController.shared.streamUrl == nil {
                        self.resetRetry()
                        return
                    }
                    
                    if (self.retryCount < 20 && self.retryCount % 2 == 0) || (self.retryCount >= 20 && self.retryCount % 5 == 0) {
                        if let videoUrl = ShopLiveController.streamUrl {
                            self.delegate?.updatePlayerItemInRetry(with: videoUrl)
                        } else {
                            ShopLiveController.retryPlay = false
                            self.delegate?.requestHideOrShowSnapShot(hide: true)
                        }
                    }
                } else {
                    if (self.retryCount < 20 && self.retryCount % 2 == 0) || (self.retryCount >= 20 && self.retryCount % 5 == 0) {
                        if !self.inBuffering {
                            ShopLiveController.shared.seekToLatest()
                            ShopLiveController.playControl = .resume
                            ShopLiveController.retryPlay = false
                            self.delegate?.requestHideOrShowSnapShot(hide: true)
                        }
                    }
                }
            }
        }
    }
    
    
    func retryOnNetworkDisconnected(with url : URL) {
        self.isTryingToRecoverFormNetworkDisconnected = true
        resetRetry()
        retryTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [weak self] timer in
            ShopLiveController.loading = true
            guard let self = self else {
                timer.invalidate()
                return
            }
            guard let player = ShopLiveController.player else { return }
            if player.timeControlStatus != .playing {
                self.delegate?.reloadWebViewInRetry(with: url)
            }
            else if player.timeControlStatus == .playing {
                self.inBuffering = false
                timer.invalidate()
                self.retryTimer = nil
                ShopLiveController.loading = false
            }
        })
    }
}
