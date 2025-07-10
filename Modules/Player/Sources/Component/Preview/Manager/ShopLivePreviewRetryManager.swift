//
//  ShopLivePreviewRetryManager.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/9/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit

protocol ShopLivePreviewRetryManagerDelegate : NSObjectProtocol {
    func getCurrentWebViewUrl() -> URL?
    func getTimeControlStatus() -> AVPlayer.TimeControlStatus
    func getCurrentPreviewUrl() -> URL?
}

class ShopLivePreviewRetryManager : NSObject, SLReactor {
    
    enum Action {
        case startRetry(delayed : Int)
        case retryWebViewOnNetworkDisconnected
        case stopRetry
    }
    
    enum Result {
        case playerItemCancelPendingSeek
        case requestSeekToLatest
        case requestResume
        case reloadWebView
        case updatePlayerItem
        case requestHideOrShowLoading(needToShow : Bool)
    }
    
    var resultHandler: ((Result) -> ())?
    
    private var isRetrying : Bool = false
    private var retryTimer : DispatchSourceTimer?
    private var retryCount : Int = 0
    
    weak var delegate : ShopLivePreviewRetryManagerDelegate?
    
    
    init(delegate : ShopLivePreviewRetryManagerDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    func action(_ action: Action) {
        switch action {
        case .startRetry(delayed: let delayed):
            self.startRetry(delaySecond: delayed)
        case .retryWebViewOnNetworkDisconnected:
            self.retryWebViewOnNetworkDisconnected()
        case .stopRetry:
            self.stopRetry()
        }
    }
    
    private func stopRetry() {
        retryTimer?.cancel()
        retryTimer = nil
        isRetrying = false
        retryCount = 0
    }
    
    private func startRetry(delaySecond : Int) {
        if isRetrying {
            return
        }
        self.isRetrying = true
        self.retryTimer = DispatchSource.makeTimerSource(flags: .strict, queue: .global(qos: .background))
        self.retryTimer?.schedule(deadline: .now(),repeating: .seconds(3))
        self.retryTimer?.setEventHandler(qos: .background, handler: { [weak self] in
            self?.updateRetry()
        })
        self.retryTimer?.resume()
    }
    
    private func updateRetry() {
        self.retryCount += 1
        if delegate?.getCurrentPreviewUrl() == nil {
            self.stopRetry()
        }
        else if (self.retryCount < 20 && self.retryCount % 2 == 0) || (self.retryCount >= 20 && self.retryCount % 5 == 0) {
            DispatchQueue.main.async { [weak self] in
                self?.resultHandler?( .updatePlayerItem )
            }
        }
    }
    
    private func retryWebViewOnNetworkDisconnected() {
        if isRetrying {
            return
        }
        isRetrying = true
        self.retryTimer = DispatchSource.makeTimerSource(flags: .strict, queue: .global(qos: .background))
        self.retryTimer?.schedule(deadline: .now(),repeating: .seconds(3))
        self.retryTimer?.setEventHandler(qos: .background, handler: { [weak self] in
            self?.updateNetWorkDisconnectedTimer()
        })
        self.retryTimer?.resume()
        
    }
    
    private func updateNetWorkDisconnectedTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.resultHandler?( .requestHideOrShowLoading(needToShow: true) )
            if (self.delegate?.getTimeControlStatus() != .playing) && (self.delegate?.getCurrentWebViewUrl()?.absoluteString ?? "about:blank") == "about:blank" {
                self.resultHandler?( .reloadWebView )
            }
            else if self.delegate?.getTimeControlStatus() == .playing {
                self.stopRetry()
                self.resultHandler?( .requestHideOrShowLoading(needToShow: false) )
            }
        }
    }
}
