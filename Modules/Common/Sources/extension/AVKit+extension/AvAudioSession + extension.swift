//
//  AvAudioSession + extension.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2023/05/24.
//

import Foundation
import AVFoundation

public extension AVAudioSession {
    
    func safeRemoveObserver_SL(_ observer: Any, forKeyPath keyPath: String, observeInfo: UnsafeMutableRawPointer?, completion: @escaping (Bool)->Void) {
        guard let obverb: NSObject = observer as? NSObject else { return }
        ShopLiveLogger.debugLog("\(keyPath) self.observationInfo is nil ? \(observeInfo == nil). \(observeInfo)")
        if observeInfo != nil {
            do {
                try self.removeObserver(obverb, forKeyPath: keyPath)
            } catch {
                completion(false)
            }
            
            completion(true)
        } else {
            completion(false)
        }
    }
}

