//
//  LiveStreamRetryManager.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 10/10/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon

protocol LiveStreamRetryManagerDelegate {
    func updatePlayerItemInRetry(with url : URL)
    func reloadWebViewInRetry(with url : URL)
    func requestHideOrShowLoading(isHidden : Bool)
    func getCurrentWebViewUrl() -> URL?
}

class LiveStreamRetryManager {
    
    private var inBuffering : Bool = false
    private var requireRetryCheck : Bool = false
    private var retryTimer : Timer?
    private var retryCount : Int = 0
    private var isTryingToRecoverFormNetworkDisconnected : Bool = false
    private var isInRetry : Bool = false
    private var blockRetry : Bool = false
    
    
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
    
    func reserveRetry(waitSecond: Int = 5, from : String = #function) {
        ShopLiveLogger.debugLog("[HASSAN LOG] reserveRetry \(from)")
        guard isInRetry == false else { return }
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
        isInRetry = false
    }
    
    func handleRetryPlay() {
        resetRetry()
        if self.blockRetry == true {
            return
        }
        if ShopLiveController.retryPlay {
            isInRetry = true
            retryTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                if self.blockRetry == true {
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
                        }
                    }
                } else {
                    if (self.retryCount < 20 && self.retryCount % 2 == 0) || (self.retryCount >= 20 && self.retryCount % 5 == 0) {
                        if !self.inBuffering {
                            ShopLiveController.shared.seekToLatest()
                            ShopLiveController.playControl = .resume
                            ShopLiveController.retryPlay = false
                        }
                    }
                }
            }
        }
        else {
            isInRetry = false
        }
    }
    
    
    func retryOnNetworkDisconnected(with url : URL) {
        self.isTryingToRecoverFormNetworkDisconnected = true
        resetRetry()
        retryTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.delegate?.requestHideOrShowLoading(isHidden: false)
            guard let player = ShopLiveController.player else { return }
            if player.timeControlStatus != .playing && (self.delegate?.getCurrentWebViewUrl()?.absoluteString ?? "about:blank") == "about:blank" {
                self.delegate?.reloadWebViewInRetry(with: url)
            }
            else if player.timeControlStatus == .playing {
                self.inBuffering = false
                timer.invalidate()
                self.retryTimer = nil
                self.delegate?.requestHideOrShowLoading(isHidden: true)
                self.isInRetry = false
            }
        })
    }
    
    func setIsInRetry(isInRetry : Bool) {
        self.isInRetry = isInRetry
    }
    
    func setBlockRetry(block : Bool) {
        self.blockRetry = block
    }
}
