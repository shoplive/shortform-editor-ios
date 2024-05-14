//
//  ShortsCollectionBaseViewModel + Observers.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 5/7/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon

extension ShortsCollectionBaseViewModel {
    func addObserver() {
        let audioSession = AudioSessionManager.shared.audioSession
        audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
        audioSessionObservationInfo = audioSession.observationInfo
        audioLevel = audioSession.outputVolume
    }
    
    func removeObserver() {
        let audioSession = AudioSessionManager.shared.audioSession
        
        audioSession.safeRemoveObserver_SL(self, forKeyPath: "outputVolume", observeInfo: audioSessionObservationInfo) { success in
            if success {
                self.audioSessionObservationInfo = nil
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let audioSession = AudioSessionManager.shared.audioSession
        switch keyPath {
        case "outputVolume":
            //TODO: - enablePreviewSound
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
            
            if audioLevel <= 0  {
                var currentIndexPath = delegate?.getIndexPathsForVisibleItems().first
                ShortformNativeOnEventsManager.sendNativeOnEvents(command: .video_muted,
                                                                  payload: [ "position" : currentIndexPath?.row ?? -1 ],
                                                                  shortsId: self.currentShortsId,
                                                                  shortsDetail: self.currentShorts?.shortsDetail)
                self.setIsMuted(isMuted: true)
            }
            else if audioLevel > 0 && isDownward == false {
                var currentIndexPath = delegate?.getIndexPathsForVisibleItems().first
                ShortformNativeOnEventsManager.sendNativeOnEvents(command: .video_unmuted,
                                                                  payload: [ "position" : currentIndexPath?.row ?? -1 ],
                                                                  shortsId: self.currentShortsId,
                                                                  shortsDetail: self.currentShorts?.shortsDetail)
                self.setIsMuted(isMuted: false)
            }
        default:
            break
        }
    }
}
