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
    
    func setCategory(category: AVAudioSession.Category, options: AVAudioSession.CategoryOptions) {
        do {
            try audioSession.setCategory(category, options: options)
        } catch {
            
        }
    }
    
    func setActive(_ isActive : Bool,options : AVAudioSession.SetActiveOptions ) {
        do {
            try audioSession.setActive(isActive,options: options)
        }
        catch(let error) {
            ShopLiveLogger.tempLog("[SHOPLIVEAUDIOSESSIONMANAGER] \(error.localizedDescription)")
        }
    }
    
    func setMode(_ mode : AVAudioSession.Mode) {
        do {
            try audioSession.setMode(mode)
        }
        catch(let error) {
            ShopLiveLogger.tempLog("[SHOPLIVEAUDIOSESSIONMANAGER] \(error.localizedDescription)")
        }
    }
}
