//
//  AudioSessionManager.swift
//  ShopLiveSDK
//
//  Created by 김우현 on 2/14/23.
//

import Foundation
import AVFoundation

final class AudioSessionManager {
    
    static var shared: AudioSessionManager = {
        return AudioSessionManager()
    }()
    
    private var audioSession = AVAudioSession.sharedInstance()
    
    var customerAudioCategoryOptions: AVAudioSession.CategoryOptions = .init(rawValue: 0)
    
    var currentCategoryOptions: AVAudioSession.CategoryOptions {
        audioSession.categoryOptions
    }
    
    var originCategoryOptions: AVAudioSession.CategoryOptions = .init(rawValue: 0)
    
    var customerOptions: AVAudioSession.CategoryOptions {
        guard ShopLiveConfiguration.SoundPolicy.useMixWithOthers else {
            return originCategoryOptions
        }
        
        guard customerAudioCategoryOptions != .mixWithOthers else {
            return .mixWithOthers
        }
        
        guard customerAudioCategoryOptions != currentCategoryOptions else {
            return currentCategoryOptions
        }
        
        return customerAudioCategoryOptions
    }
    
    func setCategory(category: AVAudioSession.Category, options: AVAudioSession.CategoryOptions) {
        do {
            try audioSession.setCategory(category, options: options)
        } catch {
            
        }
    }
    
}
