//
//  LiveStreamViewController + observer.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 10/10/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon

extension LiveStreamViewController {
    func addObserver() {
        ShopLiveController.shared.addPlayerDelegate(delegate: self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(voiceOverStatusChanged), name: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil)
        UIScreen.main.addObserver(self, forKeyPath: "captured", options: .new, context: nil)
        
        do {
            try audioSession.setActive(true, options: [])
            audioSession.addObserver(self, forKeyPath: "outputVolume",
                               options: NSKeyValueObservingOptions.new, context: nil)
            audioSessionObservationInfo = audioSession.observationInfo
            audioLevel = audioSession.outputVolume
        } catch {
            ShopLiveLogger.debugLog("setup failed - outputVolume observe")
        }
        

    }
    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil)
        UIScreen.main.safeRemoveObserver(self, forKeyPath: "captured")
        audioSession.safeRemoveObserver(self, forKeyPath: "outputVolume", observeInfo: audioSessionObservationInfo) { [weak self] success in
            if success {
                self?.audioSessionObservationInfo = nil
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "outputVolume":
            var isDownward : Bool = false
            
            if audioSession.outputVolume > audioLevel {
                ShopLiveLogger.debugLog("volume up")
                isDownward = false
            }
            if audioSession.outputVolume < audioLevel {
                ShopLiveLogger.debugLog("volume down")
                isDownward = true
            }
            
            audioLevel = audioSession.outputVolume
            let isMuted = ShopLiveController.player?.isMuted ?? false
            
            if audioLevel <= 0 {
                delegate?.log(name: "video_muted", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: [ : ])
                ShopLiveController.shared.isMuted = true
                ShopLiveController.shared.setSoundMute(isMuted: true)
            }
            else if audioLevel > 0 && isDownward == false {
                guard isMuted else { return }
                delegate?.log(name: "video_unmuted", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: [ : ])
                ShopLiveController.shared.isMuted = false
                ShopLiveController.shared.setSoundMute(isMuted: false)
            }
            break
        case "captured":
            guard !ShopLiveController.shared.isPreview else { return }
            let audioSessionManager = AudioSessionManager.shared
            if UIScreen.main.isCaptured {
                guard ShopLiveController.windowStyle != .osPip else {
                    return
                }
                
                audioSessionManager.setCategory(category: .soloAmbient, options: audioSessionManager.currentCategoryOptions)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(200)) {
                    audioSessionManager.setCategory(category: .playback, options: audioSessionManager.currentCategoryOptions)
                }
            } else {
                audioSessionManager.setCategory(category: .playback, options: audioSessionManager.currentCategoryOptions)
            }
            break
        default:
            break
        }
    }
    
    @objc func voiceOverStatusChanged() {
        self.voiceOverIsOn = UIAccessibility.isVoiceOverRunning
        self.updateVoiceOverStatus()
    }

    @objc func handleNotification(_ notification: Notification) {
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            guard chatInputView.isFocused() else { return }
            self.chatInputView.isHidden = false
            self.chatInputBG.isHidden = false
            self.setKeyboard(notification: notification)
            break
        case UIResponder.keyboardWillHideNotification:
            self.setKeyboard(notification: notification)
            break
        default:
            break
        }
    }
    
    func setKeyboard(notification: Notification) {
        guard let keyboardFrameEndUserInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber,
              let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom else { return }

        let keyboardScreenEndFrame = keyboardFrameEndUserInfo.cgRectValue
        let keyboard = self.view.convert(keyboardScreenEndFrame, from: self.view.window)
        let height = self.view.frame.size.height
        var isHiddenView = true
        
        switch notification.name.rawValue {
        case "UIKeyboardWillHideNotification":
            lastKeyboardHeight = 0
            if chatInputView.isFocused() && (ShopLiveController.windowStyle == ShopLiveWindowStyle.normal) {
                self.hasKeyboard = false
                isHiddenView = false
                self.chatInputView.isHidden = false
                self.chatInputBG.isHidden = false
            }
            
            if (ShopLiveController.shared.lastOrientaion.orientation == UIScreen.currentOrientation.deviceOrientation) || (ShopLiveController.shared.lastOrientaion.direction != (UIScreen.isLandscape ? .landscape : .portrait)) {
                let param: Dictionary = Dictionary<String, Any>.init(dictionaryLiteral: ("value", hasKeyboard ? "\(self.chatInputView.frame.height)px" : "0px"), ("keyboard", hasKeyboard))
                ShopLiveController.webInstance?.sendEventToWeb(event: .setChatListMarginBottom, param.toJson())
                ShopLiveController.webInstance?.sendEventToWeb(event: .hiddenChatInput)
                chatConstraint.constant = 0
            }
            
            break
        case "UIKeyboardWillShowNotification":
            hasKeyboard = (keyboard.origin.y + keyboard.size.height) > height
            lastKeyboardHeight = keyboardScreenEndFrame.height
            chatConstraint.constant = -(keyboardScreenEndFrame.height - bottomPadding)
            let param: Dictionary = Dictionary<String, Any>.init(dictionaryLiteral: ("value", "\(Int((hasKeyboard ? 0 : lastKeyboardHeight) + self.chatInputView.frame.height))px"), ("keyboard", hasKeyboard))
            ShopLiveController.webInstance?.sendEventToWeb(event: .setChatListMarginBottom, param.toJson())
            isHiddenView = false
        default:
            break
        }
        let animateCurve = UIView.AnimationCurve(rawValue: curve.intValue)!
        let animator = UIViewPropertyAnimator(duration: duration, curve: animateCurve)
        animator.addAnimations { [weak self] in
            guard let self = self else { return }
            if isHiddenView {
                self.chatInputView.isHidden = isHiddenView
                self.chatInputBG.isHidden = isHiddenView
            }
            self.view.layoutIfNeeded()
        }
        
        animator.addCompletion { [weak self] position in
            guard let self = self, position == .end else { return }
            self.chatInputView.focusOut()
        }

        animator.startAnimation()
    }
}
