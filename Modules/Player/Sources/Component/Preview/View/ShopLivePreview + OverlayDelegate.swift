//
//  ShopLivePreview + OverlayDelgate.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/9/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit




extension ShopLivePlayerPreview: OverlayWebViewDelegate {
    func didUpdatePlaybackSpeed(speed: Float) {
        viewModel.action( .setPlaybackSpeed(speed) )
    }
    
    func didUpdateVideo(with url: URL?) {
        viewModel.action( .didUpdateVideoUrl(url) )
    }
    
    func reloadVideo() {
        viewModel.action( .reloadVideo )
    }
    
    func didUpdatePoster(with url: URL) {
        DispatchQueue.main.async { [weak self] in
            self?.backgroundPosterImageWebView?.action( .setBackgroundUrl(url: url) )
        }
    }
    
    func setVideoCurrentTime(to: CMTime) {
        viewModel.action( .seekTo(to) )
    }
    
    func didTouchWebViewCustomAction(id: String, type: String, payload: Any?) {
        //coupont touch action -> shopliveBase -> user
    }
    
    func didReceiveSetIsPlayVideo(isPlaying: Bool) {
        /** do nothing on preview */
    }
    
    func didReceivePlayVideo() {
        // 그냥 PlayerPreview에서는 전적으로 고객사가 컨트롤가능하게 끔 설정
        //        viewModel.action( .playControlAction(.play ) )
    }
    
    func didReceivePauseVideo() {
        // 그냥 PlayerPreview에서는 전적으로 고객사가 컨트롤가능하게 끔 설정
        //        viewModel.action( .playControlAction(.pause) )
    }
    
    func didTouchWebViewMuteButton(with isMuted: Bool) {
        viewModel.action( .setSoundMute(isMuted: isMuted, needToSendToWeb: false) )
    }
    
    func didTouchWebViewPipButton() {
        
    }
    
    func didTouchWebViewCloseButton() {
        self.viewModel.action( .resetPlayer )
        self.viewModel.action( .setRefreshTimer )
    }
    
    func didTouchWebViewNavigation(with url: URL) {
        //delegate?.didTouchNavigation(with: url
    }
    
    func didTouchWebViewCoupon(with couponId: String) {
        //delegate?.didTouchCoupon(with: couponId)
    }
    
    func didChangeCampaignStatus(status: String) {
        guard let status = ShopLiveCampaignStatus(rawValue: status) else { return }
        viewModel.action( .setCampaignStatus(status))
        resultHandler?( .didChangeCampaignStatus(status) )
    }
    
    func didChangeActivityType(activityType: String, campaignKey: String) {
        viewModel.action( .setStreamActivityType(activityType) )
    }
    
    func onError(code: String, message: String) {
        resultHandler?( .onError(code: code, message: message) )
    }
    
    func onSetUserName(_ payload: [String: Any]) {
        resultHandler?( .onSetUserName(payload: payload) )
    }
    
    func handleReceivedCommand(_ command: String, with payload: [String: Any]?) {
        resultHandler?( .handleReceivedCommand(command: command, payload: payload) )
    }
    
    func updatePlayerViewFrameFromWeb(targetFrame: CGRect, isCenterCrop: Bool) {
        //
    }
    
    func updateOrientation(toLandscape: Bool) {
        //
    }
    
    func log(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any]) {
        resultHandler?( .log(name: name, feature: feature, campaignKey: campaign, payload: payload) )
    }
    
    func didFailToLoadWebViewWithNetworkUnreachable() {
        viewModel.action( .retryOnNetworkDisConnect )
    }
    
    func requestReloadWebView() {
        viewModel.action( .reloadOverlayWebView )
    }
    
    func webViewDidFinishedLoading() {
        viewModel.action( .setWebViewLoadingCompleted(true) )
        viewModel.action( .resetRetryFromWebview )
    }
    
    func requestHideOrShowLoadingFromWebView(isHidden: Bool) {
    }
    
    func requestNetworkCapabilityOnSystemInit() {
        overlayView?.sendCommandMessage(command: WebInterface.onNetworkChangeCapability.functionString, payload: ["capability": viewModel.getCurrentNetworkType()])
    }
    
    func requestHandleShare(data: ShopLivePlayerShareData) {
        guard data.url != nil else {
            resultHandler?( .onError(code: "9001", message: "share.url.empty.error".localizedString()))
            return
        }
        resultHandler?( .handleShare(data: data) )
    }
    
    func handleCommand(_ command: String, with payload: Any?) {
        let interface = WebInterface.WebFunction.init(rawValue: command)
        
        switch interface {
        case .setConf:
            handleSetConf(payload: payload)
        default:
            resultHandler?( .handleCommand(command: command, payload: payload) )
        }
    }
    
    private func handleSetConf(payload: Any?) {
        let payload = payload as? [String: Any]
        let campaignInfo = payload?["campaignInfo"] as? [String: Any]
        
        viewModel.action( .setSoundMuteStateOnWebViewSetConf )
        if let videoApsectRatio = payload?["videoAspectRatio"] as? String {
            viewModel.action( .parseRatioStringAndSetData( videoApsectRatio ) )
        }
        
        if let isReplay = payload?["isReplay"] as? Bool {
            viewModel.action( .setIsReplayMode(isReplay) )
        }
        else {
            viewModel.action( .setIsReplayMode(false) )
        }
        
        if let configJson = payload?["configJson"] as? [String: Any] {
            if let streamEdgeType = configJson["streamEdgeType"] as? String {
                if streamEdgeType == "TS_BROADCAST" {
                    viewModel.action(.setStreamEdgeType(type: streamEdgeType) )
                }
                else if streamEdgeType.contains("LLHLS") {
                    viewModel.action(.setStreamEdgeType(type: streamEdgeType) )
                }
                else {
                    viewModel.action(.setStreamEdgeType(type: nil) )
                }
            }
            
            if let campaignId = configJson["campaignId"] as? String {
                viewModel.action( .setCampaignId(campaignId) )
            }
        }
        
        resultHandler?( .didChangeCampaignInfo(campaignInfo ?? [:] ))
        
        let campaignData = ShopLivePlayerCampaign()
        campaignData.parse(payload: payload)
        resultHandler?( .handleShopLivePlayerCampaign(campaignData) )
        
        let brandData = ShopLivePlayerBrand()
        brandData.parse(payload: payload)
        resultHandler?( .handleShopLivePlayerBrand(brandData) )
        
        viewModel.action( .sendPreviewShowEventTrace )
    }
}
