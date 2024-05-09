//
//  AudioSessionManager.swift
//  ShopliveSDKCommon
//
//  Created by 김우현 on 3/20/23.
//

import AVKit

public final class AudioSessionManager {
    
    public static var shared: AudioSessionManager = {
        return AudioSessionManager()
    }()
    
    public var audioSession = AVAudioSession.sharedInstance()
    
    public var customerAudioCategoryOptions: AVAudioSession.CategoryOptions = .init(rawValue: 0)
    
    public var currentCategoryOptions: AVAudioSession.CategoryOptions {
        audioSession.categoryOptions
    }
    
    public func setCategory(category: AVAudioSession.Category, options: AVAudioSession.CategoryOptions) {
        do {
            try audioSession.setCategory(category, options: options)
        } catch {
            
        }
    }
    
}

