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

extension LiveStreamViewController: OverlayWebViewDelegate {
    
    func didUpdatePlaybackSpeed(speed: Float) {
        playerView.player.rate = speed
    }
    
    func log(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any]) {
        delegate?.log(name: name, feature: feature, campaign: campaign, payload: payload)
    }
    
    func updateOrientation(toLandscape: Bool) {
        self.changeOrientation(toLandscape: toLandscape)
    }
    
    func updatePlayerFrame(centerCrop: Bool = false, playerFrame: CGRect = .zero, immediately: Bool = false) {
        guard playerFrame != .zero else {
            updateVideoFit(centerCrop: centerCrop, immediately: immediately)
            return
        }
        
        self.playerView.playerLayer.videoGravity = centerCrop ? .resizeAspectFill : .resizeAspect
        
        playerTopConstraint.constant = playerFrame.origin.y
        playerLeadingConstraint.constant = playerFrame.origin.x
        playerRightConstraint.constant = -playerFrame.size.width
        playerBottomConstraint.constant = -playerFrame.size.height
        
        self.updateImageConstraint(from: playerFrame)
        if immediately {
            self.playerView.setNeedsLayout()
            self.playerView.layoutIfNeeded()
        }
    }
    
    func updateVideoConstraint() {
        self.chatInputView.updateChattingWriteViewConstraint()
        self.playerView.layoutIfNeeded()
    }
    
    func handleReceivedCommand(_ command: String, with payload: Any?) {
        delegate?.handleReceivedCommand(command, with: payload)
    }

    func onSetUserName(_ payload: [String : Any]) {
        delegate?.onSetUserName(payload)
    }

    func didChangeCampaignStatus(status: String) {
        delegate?.didChangeCampaignStatus(status: status)
    }

    func onError(code: String, message: String) {
        delegate?.onError(code: code, message: message)
    }

    func didTouchCustomAction(id: String, type: String, payload: Any?) {
        ShopLiveLogger.debugLog("id \(id) type \(type) payload: \(String(describing: payload))")
        delegate?.didTouchCustomAction(id: id, type: type, payload: payload)
    }

    func shareAction(url: URL?) {
        guard let urlString = url?.absoluteString, !urlString.isEmpty else {
            delegate?.onError(code: "9001", message: "share.url.empty.error".localizedString())
            return
        }
                
        guard let originUrl = urlString as? NSString, let decodeUrl = originUrl.trimmingCharacters(in: .whitespacesAndNewlines).removingPercentEncoding, let shareUrl = URL(string: decodeUrl) else { return }

        let shareAll:[Any] = [shareUrl]
        let activityViewController = SLActivityViewController(activityItems: shareAll , applicationActivities: nil)
        popoverController = activityViewController.popoverPresentationController
        popoverController?.sourceView = self.view
        if UIDevice.isIpad {
            popoverController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController?.permittedArrowDirections = []
        }
       
        self.present(activityViewController, animated: true, completion: nil)
    }

    func didTouchShareButton(with url: URL?) {
        guard let custom = ShopLiveController.shared.customShareAction?.custom else {
            shareAction(url: url)
            return
        }
        custom()
    }

    func didTouchBlockView() {
        shopliveHideKeyboard()
    }

    func replay(with size: CGSize) {
        ShopLiveController.isReplayMode = true
        delegate?.replay(with: size)
    }

    func didTouchCoupon(with couponId: String) {
        delegate?.didTouchCoupon(with: couponId)
    }

    func didTouchMuteButton(with isMuted: Bool) {
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
        ShopLiveController.streamUrl = url
        if ShopLiveController.isReplayMode, let time = ShopLiveController.shared.currentPlayTime {
            ShopLiveController.player?.seek(to: time)
        }
        showBackgroundPoster()
    }

    func didTouchPlayButton() {
        viewModel.play()
    }

    func didTouchPauseButton() {
        viewModel.pause()
    }

    func didTouchPlayButton(with isPlaying: Bool) {
        if isPlaying {
            viewModel.play()
        }
        else {
            viewModel.pause()
        }
    }

    func didTouchNavigation(with url: URL) {
        delegate?.didTouchNavigation(with: url)
    }

    func updatePipStyle(with style: ShopLive.PresentationStyle) {
        overlayView?.updatePipStyle(with: style)
    }

    @objc func didTouchPipButton() {
        delegate?.didTouchPipButton()
    }

    @objc func didTouchCloseButton() {
        overlayView?.closeWebSocket()
        delegate?.didTouchCloseButton()
    }
    
    func handleCommand(_ command: String, with payload: Any?) {
        let interface = WebInterface.WebFunction.init(rawValue: command)
        switch interface  {
        case .setConf:
            let payload = payload as? [String : Any]
            let placeHolder = payload?["chatInputPlaceholderText"] as? String
            let sendText = payload?["chatInputSendText"] as? String
            let chatInputMaxLength = payload?["chatInputMaxLength"] as? Int
            let campaignInfo = payload?["campaignInfo"] as? [String : Any]
            let isMuted = ShopLiveController.shared.isPreview ? true : ShopLiveConfiguration.SoundPolicy.isMuted
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
            ShopLiveController.shared.isStartedCampaign = true
            delegate?.campaignInfo(campaignInfo: campaignInfo ?? [:])
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
