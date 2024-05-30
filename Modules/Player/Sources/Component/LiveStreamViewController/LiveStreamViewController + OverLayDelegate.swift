//
//  LiveStreamViewController + OverLayDelegate.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 10/10/23.
//

import Foundation
import UIKit
import AVKit
import WebKit
import ShopliveSDKCommon


extension LiveStreamViewController: OverlayWebViewDelegate {
    
    func didChangeActivityType(activityType: String, campaignKey: String) {
        viewModel.setStreamActivityType(type: activityType)
    }
    
    func requestHandleShare(data: ShopLivePlayerShareData) {
        delegate?.requestHandleShare(data: data)
    }
    
    func didUpdatePlaybackSpeed(speed: Float) {
        guard let playerView = playerView else { return }
        playerView.player.rate = speed
    }
    
    func log(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any]) {
        delegate?.log(name: name, feature: feature, campaign: campaign, payload: payload)
    }
    
    func updateOrientation(toLandscape: Bool) {
        self.changeOrientation(toLandscape: toLandscape)
    }

    func updateVideoConstraint() {
        self.chatInputView.updateChattingWriteViewConstraint()
        guard let playerView = playerView else { return }
        playerView.layoutIfNeeded()
    }
    
    func handleReceivedCommand(_ command: String, with payload: [String : Any]?) {
        delegate?.handleReceivedCommand(command, with: payload)
    }

    func onSetUserName(_ payload: [String : Any]) {
        delegate?.onSetUserName(payload)
    }

    func didChangeCampaignStatus(status: String) {
        if status == "CLOSED" {
            self.hideSnapShotView()
        }
        delegate?.didChangeCampaignStatus(status: status)
    }

    func onError(code: String, message: String) {
        delegate?.onError(code: code, message: message)
    }

    func didTouchWebViewCustomAction(id: String, type: String, payload: Any?) {
        delegate?.didTouchCustomAction(id: id, type: type, payload: payload)
    }
    
    func didTouchBlockView() {
        shopliveHideKeyboard_SL()
    }

    func replay(with size: CGSize) {
        ShopLiveController.isReplayMode = true
        delegate?.replay(with: size)
    }

    func didTouchWebViewCoupon(with couponId: String) {
        delegate?.didTouchCoupon(with: couponId)
    }

    func didTouchWebViewMuteButton(with isMuted: Bool) {
        if !ShopLiveController.shared.isPreview {
            ShopLiveController.shared.isMuted = isMuted
        }
        
        ShopLiveController.shared.setSoundMute(isMuted: ShopLiveController.shared.isPreview ? true : isMuted)
    }

    func reloadVideo() {
        viewModel.resume()
    }

    func setVideoCurrentTime(to: CMTime) {
        viewModel.seek(to: to)
    }

    func didUpdatePoster(with url: URL) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.backgroundPosterImageWebView?.load(.init(url: url))
        }
    }

    func didUpdateVideo(with url: URL) {
        if let streamUrl = ShopLiveController.streamUrl, streamUrl.absoluteString == url.absoluteString {
            return
        }
        self.takeSnapShot()
        self.viewModel.setBlockRetry(block: true)
        ShopLiveController.streamUrl = url
        if ShopLiveController.isReplayMode, let time = ShopLiveController.shared.currentPlayTime {
            ShopLiveController.player?.seek(to: time)
        }
    }

    func didTouchWebViewPlayButton() {
        viewModel.play()
    }

    func didTouchWebViewPauseButton() {
        viewModel.pause()
    }

    func didTouchPlayButton(with isPlaying: Bool) {
        if isPlaying {
            viewModel.play()
        }
        else {
            ShopLiveLogger.debugLog("didTouchPlayButton isPlaying \(isPlaying)")
            viewModel.pause()
        }
    }

    func didTouchWebViewNavigation(with url: URL) {
        delegate?.didTouchNavigation(with: url)
    }

    func updatePipStyle(with style: ShopLive.PresentationStyle) {
        overlayView?.updatePipStyle(with: style)
    }

    func didTouchWebViewPipButton() {
        delegate?.didTouchPipButton()
    }

    func didTouchWebViewCloseButton() {
        overlayView?.closeWebSocket()
        delegate?.didTouchCloseButton()
    }
    
    func handleCommand(_ command: String, with payload: Any?) {
        let interface = WebInterface.WebFunction.init(rawValue: command)
        switch interface  {
        case .setConf:
            self.handleSetConf(payload: payload)
            break
        case .showChatInput:
            chatInputView.focus()
            break
        case .written:
            if (payload as? Int ?? 1) == 0 { chatInputView.clearChatText() }
            break
        default:
            delegate?.handleCommand(command, with: payload)
            break
        }
    }
    
    private func handleSetConf(payload : Any?) {
        let payload = payload as? [String : Any]
        let placeHolder = payload?["chatInputPlaceholderText"] as? String
        let sendText = payload?["chatInputSendText"] as? String
        let chatInputMaxLength = payload?["chatInputMaxLength"] as? Int
        let campaignInfo = payload?["campaignInfo"] as? [String : Any]
        var isMuted = ShopLiveController.shared.isPreview ? !ShopLiveConfiguration.SoundPolicy.previewSoundEnabled : ShopLiveConfiguration.SoundPolicy.isMutedWhenStart
        if audioSession.outputVolume == 0 {
            isMuted = true
        }
        ShopLiveController.shared.setSoundMute(isMuted: isMuted)
        
        self.viewModel.parseRatioStringAndSetData(ratio: payload?["videoAspectRatio"] as? String)
        
        ShopLiveController.shared._playerMode = ShopLiveController.shared.isPreview ? .preview : .play
        
        if viewModel.getIsUpdatePictureInPictureNeedInSetConfInitialized() {
            viewModel.setIsUpdatePictureInPictureNeedInSetConfInitialized(isNeeded: false)
            delegate?.updatePictureInPicture()
        }
        else if ShopLiveController.shared.isPreview == false  {
            delegate?.updatePictureInPicture()
        }
        
        ShopLiveController.shared.swipeEnabled = true
        if let isReplay = payload?["isReplay"] as? Bool {
            ShopLiveController.isReplayMode = isReplay
        }
        ShopLiveConfiguration.UI.chatInputPlaceholderString = placeHolder ?? "chat.placeholder".localizedString()
        ShopLiveConfiguration.UI.chatInputSendString = sendText ?? "chat.send.title".localizedString()
        ShopLiveConfiguration.UI.chatInputMaxLength = chatInputMaxLength ?? 200
        updateChattingWriteView()
        
        
        if let configJson = payload?["configJson"] as? [String : Any] {
            if let streamEdgeType = configJson["streamEdgeType"] as? String {
                if streamEdgeType == "TS_BROADCAST" {
                    viewModel.setStreamEdgeType(type: streamEdgeType)
                    viewModel.setIsLLHls(isLLHLs: false)
                }
                else if streamEdgeType.contains("LLHLS") {
                    viewModel.setStreamEdgeType(type: streamEdgeType)
                    viewModel.setIsLLHls(isLLHLs: true)
                }
                else {
                    viewModel.setStreamEdgeType(type: nil)
                    viewModel.setIsLLHls(isLLHLs: false)
                }
            }
            
            if let campaignId = configJson["campaignId"] as? Int {
                viewModel.setCampaignId(campaignId: campaignId)
            }
            
        }
        else {
            viewModel.setIsLLHls(isLLHLs: false)
        }
        
        if let sdkClientSetting = payload?["sdkClientSettings"] as? [String : Any] {
            if let liveKeepUpBufferEndurance = sdkClientSetting["liveKeepUpBufferEndurance"] as? Double {
                viewModel.setLiveKeepUpBufferEndurance(value: liveKeepUpBufferEndurance)
            }
            
            if let liveKeepUpTimerFrequency = sdkClientSetting["liveKeepUpTimerFrequency"] as? Double {
                viewModel.setLiveKeepUpTimerFrequency(frequency: liveKeepUpTimerFrequency)
            }
            
            if let useLiveKeepUpTimerInApp = sdkClientSetting["useLiveKeepUpTimerOnInApp"] as? Bool {
                viewModel.setUseLiveKeepUpTimerOnInApp(isUsed: useLiveKeepUpTimerInApp)
            }
            
            if let useLiveKeepUpTimerOnOsPip = sdkClientSetting["useLiveKeepUpTimerOnOsPip"] as? Bool {
                viewModel.setUseLiveKeepUpTimerOnOsPip(isUsed: useLiveKeepUpTimerOnOsPip)
            }
            
            if let liveKeepUpBufferSize  = sdkClientSetting["liveKeepUpBufferSize"] as? Int, liveKeepUpBufferSize != 0 {
                viewModel.setUseLiveKeepUpTimerBufferSize(size: liveKeepUpBufferSize)
            }
            
            viewModel.startLiveStreamKeepUpTimer()
        }
        
        
        delegate?.campaignInfo(campaignInfo: campaignInfo ?? [:])
        let campaignData = ShopLivePlayerCampaign()
        campaignData.parse(payload: payload)
        delegate?.handleShopLivePlayerCampaign(campaign: campaignData)
        let brandData = ShopLivePlayerBrand()
        brandData.parse(payload: payload)
        delegate?.handleShopLivePlayerBrand(brand: brandData)
    }
    
    func updateVoiceOverStatus() {
        self.sendCommandMessage(command: "SET_USE_SCREEN_READER", payload: ["useScreenReader" : self.voiceOverIsOn])
    }
    
    func awakePlayer() {
        let vc = SLViewController()
        vc.view.backgroundColor = .clear
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false, completion: {
            vc.dismiss(animated: false)
        })
    }
    
    func sendCommandMessage(command: String, payload: [String : Any]?) {
        guard let payload = payload else {
            return
        }

        var message: [String : Any] = [:]

        message["command"] = command
        message["payload"] = payload

        ShopLiveController.webInstance?.sendEventToWeb(event: .sendCommandMessage, message.toJson() ?? "", false)
    }
    
    func didFailToLoadWebViewWithNetworkUnreachable() {
        viewModel.retryOnNetworkDisconnected()
    }
    
    func webViewDidFinishedLoading() {
        viewModel.setWebViewLoadingCompleted(isCompleted: true)
        viewModel.resetRetry(triggerFromWebView: true)
    }
    
    func requestHideOrShowLoadingFromWebView(isHidden : Bool) {
        viewModel.checkIsLoadingAvailable(isHidden: isHidden)
    }
    
    func requestNetworkCapabilityOnSystemInit() {
        self.sendNetworkCapabilityChangedToWeb(capability: viewModel.getCurrentNetworkType())
    }
    
    func requestReloadWebView() {
        guard let overlayUrl = viewModel.getOverLayUrlWithInfosAttached() else { return }
        self.overlayView?.reload(with: overlayUrl)
    }
    
}
extension LiveStreamViewController {
    func sendNetworkCapabilityChangedToWeb(capability : String){
        self.sendCommandMessage(command: WebInterface.onNetworkChangeCapability.functionString, payload: ["capability" : capability])
    }
}
extension LiveStreamViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = SLAlertController(myTitle: nil, myMessage: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))

        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                present(alertController, animated: true, completion: nil)
            }
        }
        else {
            present(alertController, animated: true, completion: nil)
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = SLAlertController(myTitle: nil, myMessage: message, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))

        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                present(alertController, animated: true, completion: nil)
            }
        }
        else {
            present(alertController, animated: true, completion: nil)
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = SLAlertController(myTitle: nil, myMessage: prompt, preferredStyle: .actionSheet)

        alertController.addTextField { (textField) in
            textField.text = defaultText
        }

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                present(alertController, animated: true, completion: nil)
            }
        }
        else {
            present(alertController, animated: true, completion: nil)
        }
    }
}
