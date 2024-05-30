//
//  LiveStreamViewController + videoGravity.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 5/28/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit

//MARK: - update and set PlayerViewFrame
extension LiveStreamViewController {
    
    /**
     web에서 SET_VIDEO_POSITION으로 조작할 때 부르는 함수
     */
    func updatePlayerViewFrameFromWeb(targetFrame : CGRect) {
        let targetVideoGravity = self.getVideoGravity(windowStyle: .normal)
        playerView?.playerLayer?.videoGravity = targetVideoGravity
        
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear) { [weak self] in
            guard let self = self else { return }
            self.playerTopConstraint.constant = targetFrame.origin.y
            self.playerLeadingConstraint.constant = targetFrame.origin.x
            self.playerRightConstraint.constant = -targetFrame.size.width
            self.playerBottomConstraint.constant = -targetFrame.size.height
            
            self.updateImageConstraint(from: targetFrame,targetWindowStyle: .normal)
            
            self.playerView?.setNeedsLayout()
            self.playerView?.layoutIfNeeded()
        }
        
        animator.startAnimation()
    }
    
    /**
     ShopliveBase에서  play()에서 불림, 나머지 경우는 전부 현재 파일안에서 불림
     */
    func updatePlayerViewFrameFromApp(targetFrame : CGRect,from : String = #function) {
        guard let playerView = self.playerView else { return }
        
        let targetVideoGravity = self.getVideoGravity(windowStyle: .normal)
        playerView.playerLayer?.videoGravity = targetVideoGravity
        
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear) { [weak self] in
            guard let self = self else { return }
            self.playerTopConstraint.constant = targetFrame.origin.y
            self.playerLeadingConstraint.constant = targetFrame.origin.x
            self.playerRightConstraint.constant = -targetFrame.size.width
            self.playerBottomConstraint.constant = -targetFrame.size.height
            self.updateImageConstraint(from: targetFrame,targetWindowStyle: .normal)
            
            playerView.setNeedsLayout()
            playerView.layoutIfNeeded()
        }
        
        animator.startAnimation()
    }
    
    
    
    //startCustomPictureInPicture -> updateVideoFit(centerCrop: true, immediately: false,targetWindowStyle: .inAppPip)
    //startFromCampaignPIP -> updateVideoFit(centerCrop: true,targetWindowStyle: .inAppPip)
    //willChangePreview() ->  updateVideoFit(centerCrop: true, immediately: false, targetWindowStyle: .inAppPip)
    //의 경우들이 이거 하나로 바뀜
    func updatePlayerViewToPipMode(from : String = #function) {
        let targetVideoGravity = self.getVideoGravity(windowStyle: .inAppPip)
        playerView?.playerLayer?.videoGravity = targetVideoGravity
        self.setPlayerViewFrameToFitParent()
    }
    
    func updatePlayerViewFrameFromStartFromCampaignFullScreen(needExecuteFullScreen : Bool) {
        guard !ShopLiveController.shared.isPreview else { return }
        if ShopLiveController.shared.videoOrientation == .landscape {
            if needExecuteFullScreen {
                let targetVideoGravity = self.getVideoGravity(windowStyle: .normal)
                playerView?.playerLayer?.videoGravity = targetVideoGravity
                self.setVideoDefaultFrame()
                return
            }
            else {
                guard let playerFrame = self.getTargetFrameForUpdatePlayerView() else { return }
                self.updatePlayerViewFrameFromApp(targetFrame: playerFrame)
            }
        }
        else {
            let targetVideoGravity = self.getVideoGravity(windowStyle: .normal)
            playerView?.playerLayer?.videoGravity = targetVideoGravity
            self.setPlayerViewFrameToFitParent()
            self.updateImageConstraint(from: .zero,targetWindowStyle: .normal)
        }
    }
    
    
    func updatePlayerViewFrameFromStopCustomPictureInPicture(from : String = #function) {
        guard !ShopLiveController.shared.isPreview else { return }
        if ShopLiveController.shared.videoOrientation == .landscape {
            let targetVideoGravity = self.getVideoGravity(windowStyle: .normal)
            playerView?.playerLayer?.videoGravity = targetVideoGravity
            self.setVideoDefaultFrame()
        }
        else {
            let targetVideoGravity = self.getVideoGravity(windowStyle: .normal)
            playerView?.playerLayer?.videoGravity = targetVideoGravity
            self.setPlayerViewFrameToFitParent()
            self.updateImageConstraint(from: .zero,targetWindowStyle: .normal)
        }
    }
    
    
    func updatePlayerViewFrameFromUpdatePip(targetWindowStyle : ShopLiveWindowStyle,from : String = #function) {
        guard !ShopLiveController.shared.isPreview else { return }
        if ShopLiveController.shared.videoOrientation == .landscape {
            if targetWindowStyle == .inAppPip {
                let targetVideoGravity = self.getVideoGravity(windowStyle: targetWindowStyle)
                playerView?.playerLayer?.videoGravity = targetVideoGravity
                setPlayerViewFrameToFitParent()
            }
            else {
                guard let playerFrame = self.getTargetFrameForUpdatePlayerView() else { return }
                self.updatePlayerViewFrameFromApp(targetFrame: playerFrame)
            }
        }
        else {
            let targetVideoGravity = self.getVideoGravity(windowStyle: targetWindowStyle)
            playerView?.playerLayer?.videoGravity = targetVideoGravity
            self.setPlayerViewFrameToFitParent()
            self.updateImageConstraint(from: .zero,targetWindowStyle: targetWindowStyle)
        }
    }
    
    
    func updatePlayerViewFrameFromChangeOrientation(targetWindowStyle : ShopLiveWindowStyle) {
        guard !ShopLiveController.shared.isPreview else { return }
        
        if ShopLiveController.shared.videoOrientation == .landscape {
            if targetWindowStyle == .inAppPip {
                let targetVideoGravity = self.getVideoGravity(windowStyle: targetWindowStyle)
                playerView?.playerLayer?.videoGravity = targetVideoGravity
                setPlayerViewFrameToFitParent()
            }
            else {
                guard let playerFrame = self.getTargetFrameForUpdatePlayerView() else { return }
                self.updatePlayerViewFrameFromApp(targetFrame: playerFrame)
            }
        }
        else {
            let targetVideoGravity = self.getVideoGravity(windowStyle: targetWindowStyle)
            playerView?.playerLayer?.videoGravity = targetVideoGravity
            self.setPlayerViewFrameToFitParent()
            self.updateImageConstraint(from: .zero,targetWindowStyle: targetWindowStyle)
        }
    }
    
    func updatePlayerViewFrameForViewRotation() {
        let targetVideoGravity = self.getVideoGravity(windowStyle: ShopLiveController.windowStyle)
        playerView?.playerLayer?.videoGravity = targetVideoGravity
        self.setPlayerViewFrameToFitParent()
        self.updateImageConstraint(from: .zero,targetWindowStyle: ShopLiveController.windowStyle)
    }
    
    
    
    
    private func setVideoDefaultFrame() {
        if UIScreen.isLandscape {
            ShopLiveController.shared.videoFrame.landscape.expanded = .zero
        } else {
            let height = UIScreen.main.bounds.height - (UIScreen.main.bounds.width * (ShopLiveController.shared.videoRatio.height / ShopLiveController.shared.videoRatio.width))
            ShopLiveController.shared.videoFrame.portrait = .init(x: 0, y: 0, width: 0, height: height)
        }
    }
    
    private func getTargetFrameForUpdatePlayerView() -> CGRect? {
        var playerFrame : CGRect?
        if UIScreen.isLandscape {
            if ShopLiveController.shared.videoExpanded {
                playerFrame = ShopLiveController.shared.videoFrame.landscape.expanded
            }
            else {
                playerFrame = ShopLiveController.shared.videoFrame.landscape.standard
            }
        }
        else {
            playerFrame = ShopLiveController.shared.videoFrame.portrait
        }
        return playerFrame
    }
    
    
    private func setPlayerViewFrameToFitParent() {
        playerTopConstraint.constant = 0
        playerLeadingConstraint.constant = 0
        playerRightConstraint.constant = 0
        playerBottomConstraint.constant = 0
    }
    
}
//MARK: - videoLayerGravity 관련 로직
extension LiveStreamViewController {
    
    
    private func getVideoGravity(windowStyle : ShopLiveWindowStyle, from : String = #function) -> AVLayerVideoGravity {
        ShopLiveLogger.tempLog("getVideoGravity from : \(from)")
        if windowStyle == .inAppPip {
            return .resizeAspectFill
        }
        else if UIDevice.isIpad {
            return .resizeAspectFill
        }
        else if UIScreen.isLandscape {
            return .resizeAspect
        }
        else if let resizeMode = self.getResizeMode() {
            return resizeMode
        }
        else {
            return .resizeAspectFill
        }
    }
    
    private func getResizeMode() -> AVLayerVideoGravity? {
        if let resizeMode = self.viewModel.getResizeMode(), UIDevice.isIpad == false, UIScreen.isLandscape == false, ShopLiveController.shared.isPreview == false {
            return resizeMode == .CENTER_CROP ? .resizeAspectFill : .resizeAspect
        }
        else {
            return nil
        }
    }
    
    /**
        OsPip에서 올라올때 사용
        keepWindowStyleOnReturnFromOsPip 의 여부는 무시해도 됨. 결국은 전체 화면 -> preview, pip로 가는 것이기 때문
     */
    func setVideoLayerGravityOnOsPipRestoration(){
        guard let playerView = playerView else { return }
        playerView.playerLayer?.videoGravity = self.getVideoGravity(windowStyle: .normal)
    }
    
    
    /**
     showShopLiveView(with 에서 처음이자 마지막으로 불림
     */
    func setInitialAVPlayerLayerVideoGravity(isPreview : Bool) {
        playerView?.playerLayer?.videoGravity = self.getVideoGravity(windowStyle: isPreview ? .inAppPip : .normal)
    }
    
    
    func refreshAvPlayerLayerWhenOSPipFailedAndOnForeground() {
       if let previousVideoGravity = self.playerLayer?.videoGravity {
            playerView?.refreshLayer(videoGravity: previousVideoGravity)
        }
        else {
            playerView?.refreshLayer(videoGravity: getVideoGravity(windowStyle: ShopLiveController.windowStyle))
        }
    }
}
