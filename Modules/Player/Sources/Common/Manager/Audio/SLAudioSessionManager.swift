//
//  AudioSessionManager.swift
//  ShopLiveSDK
//
//  Created by 김우현 on 2/14/23.
//

import Foundation
import AVFoundation
import ShopliveSDKCommon

final class SLAudioSessionManager {
    
    static var shared: SLAudioSessionManager = {
        return SLAudioSessionManager()
    }()
    
    var audioSession = AVAudioSession.sharedInstance()
    
    var customerAudioCategoryOptions: AVAudioSession.CategoryOptions = .init(rawValue: 0)
    
    var currentCategoryOptions: AVAudioSession.CategoryOptions {
        audioSession.categoryOptions
    }
    
    func setCategory(category: AVAudioSession.Category, options: AVAudioSession.CategoryOptions, from: String = #function) {
        let optionName = getAudioSessionCategoryName(options: options)
        do {
            try audioSession.setCategory(category, options: options)
        } catch {
            
        }
    }
    
    private func getAudioSessionCategoryName(options: AVAudioSession.CategoryOptions) -> String {
        switch options {
        case .allowAirPlay:
            return "allowAirPlay"
        case .allowBluetooth:
            return "allowBlueTooth"
        case .allowBluetoothA2DP:
            return "allowBluetoothA2DP"
        case .defaultToSpeaker:
            return "defaultToSpeaker"
        case .duckOthers:
            return "duckOthers"
        case .interruptSpokenAudioAndMixWithOthers:
            return "interruptSpokenAudioAndMixWithOthers"
        case .mixWithOthers:
            return "mixWithOthers"
        default:
            return "\(options.rawValue)"
        }
    }
    
    func setActive(_ isActive: Bool,options: AVAudioSession.SetActiveOptions , from: String = #function) {
        do {
            try audioSession.setActive(isActive,options: options)
        }
        catch { }
    }
    
    func setMode(_ mode: AVAudioSession.Mode, from: String = #function) {
        let modeName = self.getModeName(mode: mode)
        do {
            try audioSession.setMode(mode)
        }
        catch { }
    }
    
    private func getModeName(mode: AVAudioSession.Mode) -> String {
        switch mode {
        case .default:
            return "default"
        case .gameChat:
            return "gameChat"
        case .measurement:
            return "measurement"
        case .moviePlayback:
            return "moviePlayback"
        case .spokenAudio:
            return "spokenAudio"
        case .videoChat:
            return "videoChat"
        case .videoRecording:
            return "videoRecording"
        case .voiceChat:
            return "voiceChat"
        default:
            return "\(mode.rawValue)"
        }
    }
}
