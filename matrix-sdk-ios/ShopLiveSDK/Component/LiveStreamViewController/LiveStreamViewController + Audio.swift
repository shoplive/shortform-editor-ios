//
//  LiveStreamViewController + Audio.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 10/10/23.
//

import Foundation
import UIKit
import AVKit
import MediaPlayer
import ShopliveSDKCommon

extension LiveStreamViewController {
    func setupAudioConfig() {
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(audioRouteChangeListener(notification:)),
                name: AVAudioSession.routeChangeNotification,
                object: nil)
        NotificationCenter.default.addObserver(self,
                           selector: #selector(handleInterruption),
                           name: AVAudioSession.interruptionNotification,
                           object: audioSession)

    }
    
     func teardownAudioConfig() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc func handleInterruption(notification: Notification) {
        ShopLiveLogger.debugLog("handleInterruption")

        guard let userInfo = notification.userInfo,
                let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                    return
            }

          if type == .began {
              delegate?.log(name: "audio_loss", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: [:])
              ShopLiveController.playControl = .pause
          } else {
              guard userInfo[AVAudioSessionInterruptionOptionKey] != nil else {
                return
            }

            do {
                try audioSession.setActive(true)
                ShopLiveLogger.debugLog("interruption setActive")
            }
            catch let error {
                ShopLiveLogger.debugLog("interruption setActive Failed error: \(error.localizedDescription)")
            }

            guard ShopLiveConfiguration.SoundPolicy.autoResumeVideoOnCallEnded else {
                return
            }
              delegate?.log(name: "audio_gain", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: [:])
            if ShopLiveController.isReplayMode {
                DispatchQueue.main.async {
                    ShopLiveController.player?.play()
                }
            } else {
                ShopLiveController.webInstance?.sendEventToWeb(event: .reloadBtn, false, false)
                
                ShopLiveController.playControl = .resume
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
                delegate?.log(name: "audio_gain", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: [:])
                updateHeadPhoneStatus(plugged: true)
            }
        case AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue:
            if !isEarphoneHeadphone {
                delegate?.log(name: "audio_loss", feature: .ACTION, campaign: ShopLiveController.shared.campaignKey, payload: [:])
                updateHeadPhoneStatus(plugged: false)
            }
        default:
            break
        }
    }
    
    private func updateHeadPhoneStatus(plugged: Bool) {
        DispatchQueue.main.async {
            if !ShopLiveConfiguration.SoundPolicy.keepPlayVideoOnHeadphoneUnplugged {
                if plugged {
                    ShopLiveController.isReplayMode ? ShopLiveController.webInstance?.sendEventToWeb(event: .setIsPlayingVideo(isPlaying: true), true) : ShopLiveController.webInstance?.sendEventToWeb(event: .reloadBtn, false, false)
                    ShopLiveController.playControl = .resume
                } else {
                    ShopLiveController.playControl = .pause
                }
            } else {
                if ShopLiveConfiguration.SoundPolicy.onHeadphoneUnpluggedIsMute && !plugged {
                    MPVolumeView.setVolume(0.0)
                }
                if !plugged {
                    ShopLiveController.isReplayMode ? ShopLiveController.webInstance?.sendEventToWeb(event: .setIsPlayingVideo(isPlaying: true), true) : ShopLiveController.webInstance?.sendEventToWeb(event: .reloadBtn, false, false)
                    ShopLiveController.playControl = .resume
                }
            }
        }
    }
}
