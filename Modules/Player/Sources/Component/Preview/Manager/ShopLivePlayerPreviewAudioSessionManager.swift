//
//  ShopLivePreviewAudioSessionManager.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/9/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon
import MediaPlayer



class ShopLivePlayerPreviewAudioSessionManager : NSObject, SLReactor {
    static let shared = ShopLivePlayerPreviewAudioSessionManager()
    
    enum Action {
        case setSoundMuteStateOnFirstPlay
        case cleanUpMemory
        case setIsReplayMode(Bool)
        case setAudioSessionCategory
    }
    
    enum Result {
        case log(name : String, feature : ShopLiveLog.Feature , payload : [String : Any])
        case setIsMuted(isMuted : Bool)
        case sendEventToWeb(event : WebInterface, param : Any?, wrapping : Bool )
        case sendCommandToWeb(command : String, payload : [String : Any])
        
        case requestVideoPlay
        case requestVideoPause
        case requestVideoResume
        case requestVideoStop
    }
    
    private let audioSession : AVAudioSession = AVAudioSession.sharedInstance()

    var audioSessionObservationInfo: UnsafeMutableRawPointer?
    var audioLevel : Float = 0.0
    var voiceOverIsOn: Bool = UIAccessibility.isVoiceOverRunning
    private var isReplayMode : Bool = false
    
    var resultHandler: ((Result) -> ())?
    
    override init(){
        super.init()
        addObserver()
    }
    
    
    func action(_ action: Action) {
        switch action {
        case .setIsReplayMode(let isReplayMode):
            self.onSetIsReplayMode(isReplayMode: isReplayMode)
        case .cleanUpMemory:
            self.onCleanUpMemory()
        case .setSoundMuteStateOnFirstPlay:
            self.onSetSoundMuteStateOnFirtPlay()
        case .setAudioSessionCategory:
            self.onSetAudioSessionCategory()
        }
    }
    
    private func onSetIsReplayMode(isReplayMode : Bool) {
        self.isReplayMode = isReplayMode
    }
    
    private func onSetAudioSessionCategory() {
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            do {
                if ShopLiveConfiguration.SoundPolicy.useMixWithOthers {
                    try audioSession.setCategory(.playback, options: [.mixWithOthers])
                }
                else {
                    try audioSession.setCategory(.playback)
                }
                
                try audioSession.setMode(.default)
                try audioSession.setActive(true, options: [.notifyOthersOnDeactivation])
            }
            catch(let error) {
                print("[SHOPLIVE] audioSession category setting failed \(error.localizedDescription)")
            }
        }
    }

    private func onSetSoundMuteStateOnFirtPlay() {
        var isMuted = ShopLiveConfiguration.SoundPolicy.isMutedWhenStart
        if audioSession.outputVolume == 0 {
            isMuted = true
        }
        resultHandler?( .setIsMuted(isMuted: isMuted) )
        resultHandler?( .sendEventToWeb(event: .setVideoMute(isMuted: isMuted), param: isMuted, wrapping: false))
    }
    
    private func onCleanUpMemory() {
        self.removeObserver()
    }
    
    func addObserver() {
        do {
            audioSession.addObserver(self, forKeyPath: "outputVolume",
                               options: NSKeyValueObservingOptions.new, context: nil)
            audioSessionObservationInfo = audioSession.observationInfo
            audioLevel = audioSession.outputVolume
        } catch {
            ShopLiveLogger.tempLog("setup failed - outputVolume observe")
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(voiceOverStatusChanged), name: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(audioRouteChangeListener(notification:)),name: AVAudioSession.routeChangeNotification,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(handleInterruption),name: AVAudioSession.interruptionNotification,object: audioSession)
    }
    
    func removeObserver() {
        audioSession.safeRemoveObserver_SL(self, forKeyPath: "outputVolume", observeInfo: audioSessionObservationInfo) { [weak self] isSuccess in
            guard isSuccess else { return }
            self?.audioSessionObservationInfo = nil
        }
        
        NotificationCenter.default.removeObserver(self, name: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "outputVolume":
            var isDownward : Bool = false
            
            if ShopLiveConfiguration.SoundPolicy.isEnabledVolumeKeyInPreview == false { return }
            
            if audioSession.outputVolume > audioLevel {
                isDownward = false
            }
            if audioSession.outputVolume < audioLevel {
                isDownward = true
            }
            
            audioLevel = audioSession.outputVolume
            
            if audioLevel <= 0 {
                resultHandler?( .log(name: "video_muted", feature: .ACTION, payload: [:]))
                resultHandler?( .setIsMuted(isMuted: true) )
                resultHandler?( .sendEventToWeb(event: .setVideoMute(isMuted: true), param: true, wrapping: false))
            }
            else if audioLevel > 0 && isDownward == false {
                resultHandler?( .log(name: "video_unmuted", feature: .ACTION, payload: [:]))
                resultHandler?( .setIsMuted(isMuted: false) )
                resultHandler?( .sendEventToWeb(event: .setVideoMute(isMuted: false), param: false, wrapping: false))
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    @objc func handleInterruption(notification: Notification) {

        guard let userInfo = notification.userInfo,
                let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                    return
            }

          if type == .began {
              resultHandler?( .log(name: "audio_loss", feature: .ACTION, payload: [:]))
              resultHandler?( .requestVideoPause )
          } else {
              guard userInfo[AVAudioSessionInterruptionOptionKey] != nil else {
                return
            }

            do {
                try audioSession.setActive(true)
            }
            catch let error {
                ShopLiveLogger.debugLog("interruption setActive Failed error: \(error.localizedDescription)")
            }

            guard ShopLiveConfiguration.SoundPolicy.autoResumeVideoOnCallEnded else {
                return
            }
              resultHandler?( .log(name: "audio_gain", feature: .ACTION, payload: [:]))
            if isReplayMode {
                DispatchQueue.main.async { [weak self] in
                    self?.resultHandler?( .requestVideoPlay )
                }
            } else {
                resultHandler?( .sendEventToWeb(event: .reloadBtn, param: false, wrapping: false) )
                resultHandler?( .requestVideoResume )
            }
          }
    }
    
    
    @objc func audioRouteChangeListener(notification: NSNotification) {
        let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt

        var isEarphoneHeadphone: Bool = false
        let currentRoute = audioSession.currentRoute
        if currentRoute.outputs.count != 0 {
            let earphones: [AVAudioSession.Port] = [.headphones, .headsetMic, .bluetoothA2DP, .bluetoothHFP]
            currentRoute.outputs.forEach { description in
                if !earphones.filter({$0 == description.portType}).isEmpty {
                    isEarphoneHeadphone = true
                    return
                }
            }
        }
        
        switch audioRouteChangeReason {
        case AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue:
            if isEarphoneHeadphone {
                resultHandler?( .log(name: "audio_gain", feature: .ACTION, payload: [:]))
            }
        case AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue:
            if !isEarphoneHeadphone {
                resultHandler?( .log(name: "audio_loss", feature: .ACTION, payload: [:]))
            }
        default:
            break
        }
    }
    
    @objc func voiceOverStatusChanged() {
        self.voiceOverIsOn = UIAccessibility.isVoiceOverRunning
        resultHandler?( .sendCommandToWeb(command: "SET_USE_SCREEN_READER", payload: ["useScreenReader" : self.voiceOverIsOn]))
    }
    
}
extension ShopLivePlayerPreviewAudioSessionManager {
    
}
