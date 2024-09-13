//
//  TimeControlStatusManager.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/5/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon



class TimeControlStatusManager : NSObject, SLReactor {
    
    enum Action {
        case setAVPlayer(AVPlayer?)
        case setAVPlayerItem(AVPlayerItem?)
        case startObserving
        
        case setIsReplayMode(Bool)
        case setCampaignStatus(ShopLiveCampaignStatus)
        case cleanUpMemory
        case setIsAlreadyPlayedOnce(Bool)
        case setCurrentPlayCommand(PlayControlManager.PlayCommand)
        
    }
    
    
    enum Result {
        case requestStopRetry
        case requestRetry(delay : Int)
        case requestRetryOnNetworkDisConnected
        case sendEventToWeb(event : WebInterface, param : Any?, wrapping : Bool = false, dedicatedCompletionType : DedicatedWebViewCommandCompletionType?)
        case requestShowOrHideLoading(needToShow : Bool)
        case requestShowOrHideBackgroundPosterImageView(needToShow : Bool)
        case requestTakeSnapShot
        case requestPlayControl(ShopLivePlayerControlAction)
        case requestSetNeedSeek(Bool)
        case sendVideoError(errorCase : ShopLiveAVPlayerErrorObserver.ErrorCase, reason : String)
        case timeControlStatusDidChange(AVPlayer.TimeControlStatus)
    }
    
    private var playerTimeControlStatusObserver : NSKeyValueObservation?
    private var player : AVPlayer?
    private var playerItem : AVPlayerItem?
    private var isReplayMode : Bool = false
    private var campaignStatus : ShopLiveCampaignStatus = .close
    private var isAlreadyPlayedOnce : Bool = false
    private var currentPlayCommand : PlayControlManager.PlayCommand = .pause
    
    var resultHandler: ((Result) -> ())?
    
    
    deinit {
        ShopLiveLogger.memoryLog("[HLSTIMECONTROLSTATUS] deinit")
    }
    
    
    func action(_ action: Action) {
        ShopLiveLogger.tempLog("[TIMECONTROLSTATUS] action \(action)")
        switch action {
        case .setAVPlayer(let player):
            self.onSetAVPlayer(player: player)
        case .setAVPlayerItem(let playerItem):
            self.onSetAVPlayerItem(playerItem: playerItem)
        case .startObserving:
            self.onStartObserving()
        case .setIsReplayMode(let isReplayMode):
            self.isReplayMode = isReplayMode
        case .setCampaignStatus(let status):
            self.onSetCampaignStatus(status: status)
        case .setIsAlreadyPlayedOnce(let isPlayedOnce):
            self.onSetIsAlreadyPlayedOnce(isAlreadyPlayedOnce: isPlayedOnce)
        case .cleanUpMemory:
            self.onCleanUpMemory()
        case .setCurrentPlayCommand(let command):
            self.onSetCurrentPlayCommand(command : command)
        }
    }
    
    
    private func onSetAVPlayer(player : AVPlayer?) {
        self.player = player
    }
    
    private func onSetAVPlayerItem(playerItem : AVPlayerItem?) {
        self.playerItem = playerItem
    }
    
    private func onStartObserving() {
        playerTimeControlStatusObserver?.invalidate()
        playerTimeControlStatusObserver = nil
        if let player = self.player {
            playerTimeControlStatusObserver = player.observe(\.timeControlStatus, options: [.initial,.new], changeHandler: { [weak self] player, value  in
                guard let self = self else { return }
                self.onTimeControlStatusChanged()
            })
        }
    }
    
    private func onSetIsReplayMode(isReplayMode : Bool) {
        self.isReplayMode = isReplayMode
    }
    
    private func onSetCampaignStatus(status : ShopLiveCampaignStatus) {
        self.campaignStatus = status
    }
    
    private func onSetIsAlreadyPlayedOnce(isAlreadyPlayedOnce : Bool) {
        self.isAlreadyPlayedOnce = isAlreadyPlayedOnce
    }
    
    private func onCleanUpMemory() {
        playerTimeControlStatusObserver?.invalidate()
        playerTimeControlStatusObserver = nil
        self.player = nil
        self.playerItem = nil
    }
    
    private func onSetCurrentPlayCommand(command : PlayControlManager.PlayCommand) {
        self.currentPlayCommand = command
    }
    
    private func onTimeControlStatusChanged() {
        guard let player = player else { return }
        ShopLiveLogger.tempLog("[timeControlStatus] \(player.timeControlStatus.name_SL)")
        switch player.timeControlStatus {
        case .playing:
            self.onTimeControlStatusPlaying()
        case .paused:
            self.onTimeControlStatusPaused()
        case .waitingToPlayAtSpecifiedRate:
            self.onTimeControlStatusWaitingToPlay()
        default:
            break
        }
        resultHandler?( .timeControlStatusDidChange(player.timeControlStatus) )
    }
    
    private func onTimeControlStatusPlaying() {
        
        self.isAlreadyPlayedOnce = true
        
        resultHandler?( .requestStopRetry )
        
        if self.isReplayMode == false {
            resultHandler?( .sendEventToWeb(event: .reloadBtn, param: false, wrapping: false, dedicatedCompletionType: nil))
        }
         
        resultHandler?(. requestShowOrHideBackgroundPosterImageView(needToShow: false) )
        
        resultHandler?( .sendEventToWeb(event: .setIsPlayingVideo(isPlaying: true), param: true, wrapping: false, dedicatedCompletionType: nil))
    }
    
    private func onTimeControlStatusPaused() {
        if self.isReplayMode {
            resultHandler?( .sendEventToWeb(event: .setIsPlayingVideo(isPlaying: false), param: false, wrapping: false, dedicatedCompletionType: nil))
        }
        else {
            if currentPlayCommand != .pause {
                resultHandler?( .requestTakeSnapShot )
                if UIApplication.shared.applicationState != .active {
                    return
                }
                if playerItem?.status == .readyToPlay {
                    ShopLiveLogger.tempLog("[timeControlStatus] called pause and called resume")
                    resultHandler?( .requestPlayControl(.resume) )
                }
            }
            resultHandler?( .requestSetNeedSeek(true) )
        }
    }
    
    private func onTimeControlStatusWaitingToPlay() {
        guard let reason = player?.reasonForWaitingToPlay else { return }
        
        resultHandler?( .requestTakeSnapShot )
        
        switch reason {
        case .toMinimizeStalls:
            ShopLiveLogger.tempLog("[timeControlStatus] [toMinimizeStalls]")
            self.onReasonForWaitingToMinimizeStalls()
        case .evaluatingBufferingRate:
            ShopLiveLogger.tempLog("[timeControlStatus] [evaluatingBufferingRate]")
            break
        case .noItemToPlay:
            ShopLiveLogger.tempLog("[timeControlStatus] [noItemToPlay]")
            self.onReasonForWaitingNoItemToPlay()
        default:
            ShopLiveLogger.tempLog("[timeControlStatus] [reasonForWaitingToPlay] reason \(reason.rawValue)")
            break
        }
    }
    
    private func onReasonForWaitingToMinimizeStalls() {
        if campaignStatus != .close {
            if NetworkReachability().connectionStatus() == .Offline {
                resultHandler?( .requestRetryOnNetworkDisConnected )
            }
            else {
                ShopLiveLogger.tempLog("[toMinimizeStalls] retry in 0 sec")
                resultHandler?( .requestRetry(delay: 0) )
            }
        }
    }
    
    private func onReasonForWaitingNoItemToPlay() {
        guard let currentPlayTime = self.player?.currentTime().seconds else { return }
        if currentPlayTime < 5 || currentPlayTime == .nan  {
            return
        }
        resultHandler?( .sendVideoError(errorCase: .noItemToPlay, reason: "noItemToPlay") )
    }
    
}
extension TimeControlStatusManager {
    func getIsAlreadyPlayedOnce() -> Bool {
        return self.isAlreadyPlayedOnce
    }
    
    func getTimeControlStatus() -> AVPlayer.TimeControlStatus? {
        return self.player?.timeControlStatus
    }
}
