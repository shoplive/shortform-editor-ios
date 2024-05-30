//
//  LiveStreamViewController + ShopLivebase.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 10/10/23.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon


/**
 ShopLiveBase에서 바로 부르는 함수들 집합 UI관련 x
 */
extension LiveStreamViewController {
    func reload() {
        ShopLiveController.overlayUrl = viewModel.getOverLayUrlWithInfosAttached()
    }

    func didCompleteDownLoadCoupon(with couponId: String) {
        overlayView?.didCompleteDownloadCoupon(with: couponId)
    }

    func didCompleteDownLoadCoupon(with couponResult: ShopLiveCouponResult) {
        overlayView?.didCompleteDownloadCoupon(with: couponResult)
    }
    
    @available(*, deprecated, message: "use didCompleteDownLoadCoupon(with couponResult: ShopLiveCouponResult) instead")
    func didCompleteDownLoadCoupon(with couponResult: CouponResult) {
        overlayView?.didCompleteDownloadCoupon(with: couponResult)
    }

    func didCompleteCustomAction(with id: String) {
        overlayView?.didCompleteCustomAction(with: id)
    }

    func didCompleteCustomAction(with customActionResult: ShopLiveCustomActionResult) {
        overlayView?.didCompleteCustomAction(with: customActionResult)
    }
    
    @available(*, deprecated, message: "use didCompleteCustomAction(with customActionResult: ShopLiveCustomActionResult) instead")
    func didCompleteCustomAction(with customActionResult: CustomActionResult) {
        overlayView?.didCompleteCustomAction(with: customActionResult)
    }
    
    func onTerminated() {
        overlayView?.closeWebSocket()
    }

    func onLockScreen() {
        ShopLiveLogger.debugLog("onLockScreen()")
        
        guard ShopLiveBase.sessionState != .background else {
            return
        }
        
        ShopLiveLogger.debugLog("Function: \(#function), line: \(#line)  onBackground")
        ShopLiveBase.sessionState = .background
        overlayView?.sendEventToWeb(event: .onBackground)
    }
    
    func onUnlockScreen() {
        ShopLiveLogger.debugLog("onUnlockScreen()")
        
        guard ShopLiveController.windowStyle == .osPip else {
            return
        }
        
        guard ShopLiveBase.sessionState != .foreground else {
            return
        }
        
        ShopLiveLogger.debugLog("Function: \(#function), line: \(#line)  onForeground")
        ShopLiveBase.sessionState = .foreground
        overlayView?.sendEventToWeb(event: .onForeground)
    }
    
    func onBackground() {
        ShopLiveLogger.debugLog("onBackground()")
        if ShopLiveController.windowStyle == .osPip {
            return
        }
        ShopLiveController.playControl = .pause
        
        guard ShopLiveBase.sessionState != .background else {
            return
        }
        
        ShopLiveLogger.debugLog("Function: \(#function), line: \(#line)  onBackground")
        ShopLiveBase.sessionState = .background
        overlayView?.sendEventToWeb(event: .onBackground)
    }

    func onForeground() {
        ShopLiveLogger.debugLog("onForeground()")
        if ShopLiveController.windowStyle == .osPip {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.viewModel.getIsOsPipFailedHasOccured() {
                self.refreshAvPlayerLayerWhenOSPipFailedAndOnForeground()
                self.delegate?.resetPictureInPicture()
                self.viewModel.setIsOsPipFailedHasOccured(hasOccured: false)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            if ShopLiveController.timeControlStatus == .paused {
                if !ShopLiveController.isReplayMode {
                    ShopLiveController.webInstance?.sendEventToWeb(event: .reloadBtn, false, false)
                    ShopLiveController.playControl = .resume
                }
            }
            else {
                if !ShopLiveController.isReplayMode {
                    ShopLiveController.shared.needSeek = true
                    ShopLiveController.playControl = .resume
                }
            }
            ShopLiveLogger.debugLog("Function: \(#function), line: \(#line)  onForeground")
            ShopLiveBase.sessionState = .foreground
            self.overlayView?.sendEventToWeb(event: .onForeground)
        }
    }
    
    
}
