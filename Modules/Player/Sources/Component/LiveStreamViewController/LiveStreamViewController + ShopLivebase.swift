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
    
    // 오버레이 URL을 다시 설정하여 스트림 화면 갱신
    func reload() {
        ShopLiveController.overlayUrl = viewModel.getOverLayUrlWithInfosAttached()
    }

    /// 쿠폰 다운로드 완료 후 오버레이에 반영/전달
    func didCompleteDownLoadCoupon(couponId: String, couponResult: ShopLiveCouponResult) {
        overlayView?.didCompleteDownloadCoupon(couponId: couponId, couponResult: couponResult)
    }

    /// 커스텀 액션 완료 후 오버레이에 알림
    func didCompleteCustomAction(with id: String) {
        overlayView?.didCompleteCustomAction(with: id)
    }

    /// 커스텀 액션 결과를 오버레이에 전달
    func didCompleteCustomAction(with customActionResult: ShopLiveCustomActionResult) {
        overlayView?.didCompleteCustomAction(with: customActionResult)
    }
    
    /// 세션 종료 시 웹소켓 연결 해제
    func onTerminated() {
        overlayView?.closeWebSocket()
    }

    /// 화면 잠금 시 백그라운드 상태 전환 및 이벤트 전달
    func onLockScreen() {
        guard ShopLiveBase.sessionState != .background else {
            return
        }
        ShopLiveBase.sessionState = .background
        overlayView?.sendEventToWeb(event: .onBackground)
    }
    
    /// 화면 잠금 해제 시 포그라운드 상태 복구 처리
    func onUnlockScreen() {
        guard ShopLiveController.windowStyle == .osPip else {
            return
        }
        
        guard ShopLiveBase.sessionState != .foreground else {
            return
        }
        ShopLiveBase.sessionState = .foreground
        overlayView?.sendEventToWeb(event: .onForeground)
    }
    
    /// 앱이 백그라운드로 전환될 때 스트림 일시정지 처리
    func onBackground() {
        if ShopLiveController.windowStyle == .osPip {
            return
        }
        ShopLiveController.playControl = .pause
        
        guard ShopLiveBase.sessionState != .background else {
            return
        }
        ShopLiveBase.sessionState = .background
        overlayView?.sendEventToWeb(event: .onBackground)
    }

    /// 앱이 포그라운드로 돌아왔을 때 스트림 복원 및 상태 전환 처리
    func onForeground() {
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
            ShopLiveBase.sessionState = .foreground
            self.overlayView?.sendEventToWeb(event: .onForeground)
        }
    }
    
    
}
