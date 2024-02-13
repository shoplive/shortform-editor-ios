//
//  AudioRouteObserver.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/23/23.
//

import Foundation
import AVKit

enum SLShortsAudioInterruptionType {
    case begin
    case ended
}

protocol SLShortsAudioRouteObserverDelegate: AnyObject {
    func handleInterruption(type: SLShortsAudioInterruptionType)
    func handleHeadPhoneStatus(plugged: Bool)
}

final class AudioRouteObserver: NSObject {
    
    weak var delegate: SLShortsAudioRouteObserverDelegate?
    
    override init() {
        super.init()
        self.setupObserver()
    }
    
    deinit {
        // print("AudioRouteObserver deinit")
        teardownAudioRouteObserver()
    }
    
    private func teardownAudioRouteObserver() {
        teardownObserver()
        delegate = nil
    }
    
    private func setupObserver() {
        NotificationCenter.default.addObserver(self,
                selector: #selector(handleNotification(_:)),
                name: AVAudioSession.routeChangeNotification,
                object: nil)
        NotificationCenter.default.addObserver(self,
                           selector: #selector(handleNotification(_:)),
                           name: AVAudioSession.interruptionNotification,
                           object: nil)
    }
    
    private func teardownObserver() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc private func handleNotification(_ notification: Notification) {
        switch notification.name {
        case AVAudioSession.interruptionNotification:
            guard let userInfo = notification.userInfo,
                let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                    return
            }
            
            if type == .began {
                delegate?.handleInterruption(type: .begin)
            } else {
                guard userInfo[AVAudioSessionInterruptionOptionKey] != nil else {
                    return
                }
                
                delegate?.handleInterruption(type: .ended)
            }
            break
        case AVAudioSession.routeChangeNotification:
            let audioRouteChangeReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt

            let audioSession = AVAudioSession.sharedInstance()
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
                    delegate?.handleHeadPhoneStatus(plugged: true)
                }
                break
            case AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue:
                if !isEarphoneHeadphone {
                    delegate?.handleHeadPhoneStatus(plugged: false)
                }
                break
            default:
                break
            }
            break
        default:
            break
        }
    }
}
