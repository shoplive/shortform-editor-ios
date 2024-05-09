//
//  ShortsCellYoutubeCommandReactor.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 3/5/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import WebKit

protocol ShortsCellYoutubeCommandReactorDelegate : AnyObject {
    func getIsActive() -> Bool
    func getCurrentOnViewIndexPath() -> IndexPath?
}

class ShortsCellYoutubeCommandReactor : NSObject, SLReactor {
    typealias WebToSdk = ShopLiveShortform.ShortsWebInterface.WebToSdk
    typealias SdkToWeb = ShopLiveShortform.ShortsWebInterface.SdkToWeb
    typealias YoutubeToSdk = ShopLiveShortform.ShortsWebInterface.YoutubeToSdk
    typealias JSRequest = (SdkToWeb, [String : Any])
    typealias ShortsModel = ShopLiveShortform.ShortsModel
    typealias ShortsMode = ShopLiveShortform.ShortsMode
    
    
    enum Action {
        case setCurrentSrn(String?)
        case setCurrentYoutubeId(String)
        case setCurrentShortsMode(ShortsMode)
        case setCurrentIndexPath(IndexPath)
        case playVideo
        case pauseVideo
        case sendMuteState(isMute : Bool)
        case sendGetIsMute
        case sendGetPlayerState
        case sendGetCurrentTime
        case sendGetDuration
        case destroyAndReload
        case seekTo(Double)
        
        case invalidateTimer
        
        case onYoutubePlayerSupport(payload : [String : Any]?, isMute : Bool, isActive : Bool,isPausedByUser : Bool, isPaused : Bool)
        case resetYoutubeCurrentState
    }
    
    enum Result {
        case requestEvaluateJS([JSRequest])
        case onVideoTimeUpdate(Double)
        case onVideoDurationChanged(Double)
        case onVideoLoopEvent
        
        case stateChangedToPlay
        case stateChangedToPause
        case sendVideoMuteToWeb(Bool)
        case scrollToNextCell
        case hideThumbnail(Bool)
        
        case requestSeekToOnInitial
    }
    
    
    
    
    private var currentSrn : String?
    private var currentYoutubeId : String = ""
    private var isYoutubePlayerReady : Bool = false
    private var isYoutubePlayerOnError : Bool = false
    private var currentYoutubeDuration : Double?
    private var youtubeCurrentTimeTimer : Timer?
    
    private var youtubeCurrentTimeTimerInterval : TimeInterval = 0.1
    private var youtubeCurrentPlayState : ShopliveYoutubePlayState = .notReady
    //videoLoop이벤트 측정하기 위해서 있는 변수
    private var youtubePlayerReachedEnd : Bool = false
    private var currentTime : Double = 0
    private var currentShortsMode : ShopLiveShortform.ShortsMode = .detail
    //로깅용
    private var currentIndexPath : IndexPath = IndexPath(row: 0, section: 0)
    
    
    //play timer
    private var playTimerCurrentDuration : Double = 0.0
    private var playTimeInterval : TimeInterval = 0.2
    private var playTimer : Timer?
    
    //state timer
    private var stateTimerTimeInterval : TimeInterval = 1
    private var stateTimer : Timer?
    
    
    var resultHandler: ((Result) -> ())?
    private unowned var delegate : ShortsCellYoutubeCommandReactorDelegate!
    
    init(delegate: ShortsCellYoutubeCommandReactorDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    deinit {
        ShopLiveLogger.debugLog("shortscellyoutubecommandReactor deinited")
    }
    
    func action(_ action: Action) {
        switch action {
        case .setCurrentSrn(let srn):
            self.onSetCurrentSrn(srn: srn)
        case .setCurrentYoutubeId(let id):
            self.onSetCurrentYoutubeId(id: id)
        case .setCurrentShortsMode(let shortsMode):
            self.onSetCurrentShortsMode(mode: shortsMode)
        case .setCurrentIndexPath(let indexPath):
            self.setCurrentIndexPath(indexPath: indexPath)
        case .playVideo:
            self.onPlayVideo()
        case .pauseVideo:
            self.onPauseVideo()
        case .sendMuteState(let isMute):
            self.onSendMuteState(isMute: isMute)
        case .sendGetIsMute:
            self.onSendGetIsMute()
        case .sendGetPlayerState:
            self.onSendGetPlayerState()
        case .sendGetCurrentTime:
            self.onSendGetCurrentTime()
        case .sendGetDuration:
            self.onSendGetDuration()
        case .destroyAndReload:
            self.onSendDestroyAndReload()
        case .seekTo(let time):
            self.onSeekTo(time: time)
        case .invalidateTimer:
            self.onInvalidateTimer()
        case .onYoutubePlayerSupport(payload: let payload,isMute : let isMute, isActive : let isActive,isPausedByUser : let isPauseByUser, isPaused : let isPaused):
            self.onYoutubePlayerSupport(payload: payload, isMute: isMute, isActive: isActive, isPausedByUser: isPauseByUser, isPaused: isPaused)
        case .resetYoutubeCurrentState:
            self.onResetYoutubeCurrentState()
        }
    }
    
    private func onSetCurrentSrn(srn : String?) {
        self.currentSrn = srn
    }
    
    private func onSetCurrentYoutubeId(id : String) {
        self.currentYoutubeId = id
    }
    
    private func onSetCurrentShortsMode(mode : ShortsMode) {
        self.currentShortsMode = mode
    }
    
    private func setCurrentIndexPath(indexPath : IndexPath) {
        self.currentIndexPath = indexPath
    }
    
    private func onPlayVideo() {
        self.firePlayTimer()
        self.fireStateTimer()
        sendPlayVideoCommand()
    }
    
    private func sendPlayVideoCommand() {
        guard let payload = self.getYoutubeWebCommandPayload() else { return }
        let request : JSRequest = ( .SDK_YTP_PLAY_VIDEO, payload )
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func onPauseVideo() {
        self.invalidateYoutubeGetCurrentTimeTimer()
        guard let payload = self.getYoutubeWebCommandPayload() else { return }
        let request : JSRequest = ( .SDK_YTP_PAUSE_VIDEO, payload )
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func onSendMuteState(isMute : Bool) {
        guard let payload = self.getYoutubeWebCommandPayload() else { return }
        let request : JSRequest
        if isMute {
            request = ( .SDK_YTP_MUTE, payload )
        }
        else {
            request = ( .SDK_YTP_UNMUTE, payload )
        }
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func onSendGetIsMute() {
        guard let payload = self.getYoutubeWebCommandPayload() else { return }
        let request : JSRequest = ( .SDK_YTP_GET_IS_MUTED, payload )
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func onSendGetPlayerState() {
        guard let payload = self.getYoutubeWebCommandPayload() else { return }
        let request : JSRequest = ( .SDK_YTP_GET_PLAYER_STATE, payload )
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func onSendGetCurrentTime() {
        guard let payload = self.getYoutubeWebCommandPayload() else { return }
        let request : JSRequest = ( .SDK_YTP_GET_CURRENT_TIME, payload )
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func onSendGetDuration() {
        guard let payload = self.getYoutubeWebCommandPayload() else { return }
        let request : JSRequest = ( .SDK_YTP_GET_DURATION, payload )
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func onSendDestroyAndReload() {
        guard let payload = self.getYoutubeWebCommandPayload() else { return }
        let request : JSRequest = ( .SDK_YTP_DESTROY_AND_RELOAD, payload )
        self.youtubeCurrentPlayState = .destroyed
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func onSeekTo(time : Double) {
        guard var payload = self.getYoutubeWebCommandPayload() else { return }
        payload["target"] = time
        let request : JSRequest = (.SDK_YTP_SEEK_TO, payload )
        resultHandler?( .requestEvaluateJS([request]) )
    }
    
    private func onInvalidateTimer() {
        self.invalidateYoutubeGetCurrentTimeTimer()
        self.invalidatePlayTimer()
        self.invalidateStateTimer(from: "onInvalidateTimer")
    }
    
    private func onYoutubePlayerSupport(payload : [String : Any]?, isMute : Bool, isActive : Bool,isPausedByUser : Bool, isPaused : Bool) {
        guard let payload = payload else { return }
        if let youtubeId = payload["youtubeId"] as? String {
            self.currentYoutubeId = youtubeId
        }
        guard let eventName = payload["name"] as? String else { return }
        switch eventName {
        case YoutubeToSdk.SDK_YTP_ON_PLAYER_READY.rawValue :
            self.onYoutubePlayerSupportYTPOnPlayerReady(isMute: isMute, isActive: isActive)
        case YoutubeToSdk.SDK_YTP_GET_PLAYER_STATE.rawValue, YoutubeToSdk.SDK_YTP_ON_PLAYER_STATE_CHANGE.rawValue:
            self.onYoutubePlayerSupportGetPlayerState(payload: payload,isPausedByUser : isPausedByUser, isPaused : isPaused)
        case YoutubeToSdk.SDK_YTP_ON_ERROR.rawValue:
            self.onYoutubePlayerSupportYTPOnError()
        case YoutubeToSdk.SDK_YTP_GET_IS_MUTED.rawValue:
            break
        case YoutubeToSdk.SDK_YTP_GET_CURRENT_TIME.rawValue:
            self.onYoutubePlayerSupportGetCurrentTime(payload: payload)
        case YoutubeToSdk.SDK_YTP_GET_DURATION.rawValue:
            self.onYoutubePlayerSupportGetDuration(payload: payload)
        default:
            break
        }
    }
    
    private func onResetYoutubeCurrentState() {
        self.youtubeCurrentPlayState = .notReady
    }
    
}
extension ShortsCellYoutubeCommandReactor {
    private func getYoutubeWebCommandPayload() -> [String : Any]? {
        guard let currentSrn = currentSrn else {
            return nil
        }
        
        return [
            "srn" : currentSrn,
            "youtubeId" : currentYoutubeId
        ]
    }
    
    //유투브로부터 현재 시간 받아오는 타이머
    private func fireYoutubeGetCurrentTimeTimer() {
        invalidateYoutubeGetCurrentTimeTimer()
        youtubeCurrentTimeTimer = Timer.scheduledTimer(timeInterval: youtubeCurrentTimeTimerInterval, target: self, selector: #selector(updateYoutubeGetCurrentTimeTimer), userInfo: nil, repeats: true)
        youtubeCurrentTimeTimer?.fire()
    }
    
    private func invalidateYoutubeGetCurrentTimeTimer() {
        youtubeCurrentTimeTimer?.invalidate()
        youtubeCurrentTimeTimer = nil
    }
    
    @objc private func updateYoutubeGetCurrentTimeTimer() {
        guard let onViewIndexPath = delegate.getCurrentOnViewIndexPath() else {
            self.onInvalidateTimer()
            return
        }
        if onViewIndexPath != self.currentIndexPath {
            self.onInvalidateTimer()
            return
        }
        self.onSendGetCurrentTime()
    }
    
    //playTimer
    private func firePlayTimer() {
        self.invalidatePlayTimer()
        playTimer = Timer.scheduledTimer(timeInterval: playTimeInterval, target: self, selector: #selector(updatePlayTimer), userInfo: nil, repeats: true)
        playTimer?.fire()
    }
    
    private func invalidatePlayTimer() {
        self.playTimerCurrentDuration = 0
        self.playTimer?.invalidate()
        self.playTimer = nil
    }
    
    @objc private func updatePlayTimer() {
        guard let onViewIndexPath = delegate.getCurrentOnViewIndexPath() else {
            self.onInvalidateTimer()
            return
        }
        if onViewIndexPath != self.currentIndexPath {
            self.onInvalidateTimer()
            return
        }
        self.playTimerCurrentDuration += 0.2
        if self.youtubeCurrentPlayState == .playing || playTimerCurrentDuration >= 5 {
            if playTimerCurrentDuration >= 5 {
                self.invalidateYoutubeGetCurrentTimeTimer()
                self.onSendDestroyAndReload()
            }
            self.invalidatePlayTimer()
            return
        }
        self.sendPlayVideoCommand()
    }
    
    //stateTimer
    private func fireStateTimer() {
        invalidateStateTimer(from: "fire")
        stateTimer = Timer.scheduledTimer(timeInterval: stateTimerTimeInterval, target: self, selector: #selector(updateStateTimer), userInfo: nil, repeats: true)
        stateTimer?.fire()
    }
    
    private func invalidateStateTimer(from : String) {
        stateTimer?.invalidate()
        stateTimer = nil
    }
    
    @objc private func updateStateTimer() {
        guard let onViewIndexPath = delegate.getCurrentOnViewIndexPath() else {
            self.onInvalidateTimer()
            return
        }
        if onViewIndexPath != self.currentIndexPath {
            self.onInvalidateTimer()
            return
        }
        self.onSendGetPlayerState()
    }
    
}
//MARK: - onYoutubePlayerSupport(payload : [String : Any]?, isMute : Bool, isActive : Bool,isPausedByUser : Bool, isPaused : Bool) 휘하 함수들 집합
extension ShortsCellYoutubeCommandReactor {
    private func onYoutubePlayerSupportYTPOnPlayerReady(isMute : Bool, isActive : Bool) {
        self.isYoutubePlayerReady = true
        self.onSendGetDuration()
        self.onSendGetCurrentTime()
        self.onSendMuteState(isMute: isMute)
        resultHandler?( .sendVideoMuteToWeb(isMute) )
        //PlayerSupport가 뒤늦게 도착했을때 자동 재생
        if youtubeCurrentPlayState != .playing && (youtubeCurrentPlayState == .notReady || youtubeCurrentPlayState == .destroyed)  && isActive == true {
            self.onPlayVideo()
        }
    }
    
    private func onYoutubePlayerSupportYTPOnError() {
        isYoutubePlayerOnError = true
        if isYoutubePlayerReady {
            isYoutubePlayerOnError = false
            self.onSendDestroyAndReload()
        }
    }
    
    private func onYoutubePlayerSupportGetCurrentTime(payload : [String : Any]) {
        var currentTime : Double?
        if let values = payload["values"] as? [String : Any] {
            if let time = values["currentTime"] as? Double {
                currentTime = time
            }
            else if let currentTimeString = values["currentTime"] as? String, let time = Double(currentTimeString) {
                currentTime = time
            }
        }
        guard let currentTime = currentTime else { return }
        self.currentTime = currentTime
        resultHandler?( .onVideoTimeUpdate(currentTime) )
        checkYoutubeCurrentTimeAndDurationAndSendVideoLoopedEvent(currentTime: currentTime)
    }
    
    private func checkYoutubeCurrentTimeAndDurationAndSendVideoLoopedEvent(currentTime : Double) {
        if currentTime < 1 {
            self.youtubePlayerReachedEnd = false
        }
        guard let duration = currentYoutubeDuration else { return }
        //currentTime 은 초단위
        if currentTime >= duration - 1 && self.youtubePlayerReachedEnd == false {
            self.youtubePlayerReachedEnd = true
            
            if self.currentShortsMode == .preview {
                resultHandler?( .scrollToNextCell )
            }
            else {
                resultHandler?( .hideThumbnail(false) )
                resultHandler?( .onVideoLoopEvent )
            }
        }
    }
    
    private func onYoutubePlayerSupportGetDuration(payload : [String : Any]) {
        if let values = payload["values"] as? [String : Any] {
            if let duration = values["duration"] as? Double {
                self.currentYoutubeDuration = duration
                resultHandler?( .onVideoDurationChanged(duration) )
            }
            else if let durationString = values["duration"] as? String, let duration = Double(durationString) {
                self.currentYoutubeDuration = duration
                resultHandler?( .onVideoDurationChanged(duration) )
            }
        }
    }
    
    private func onYoutubePlayerSupportGetPlayerState(payload : [String : Any],isPausedByUser : Bool, isPaused : Bool) {
        guard let youtubeId = payload["youtubeId"] as? String,
              youtubeId == currentYoutubeId else { return }
        
        if let values = payload["values"] as? [String : Any] {
            var data : Int = -1
            if let value = values["data"] as? Int {
                data = value
            }
            else if let value = values["playerState"] as? Int {
                data = value
            }
            switch data {
            case -1: //시작되지 않음
                youtubeCurrentPlayState = .notReady
            case 0: //종료
                youtubeCurrentPlayState = .destroyed
            case 1: // 재생중
                self.onYoutubePlayerSuppoertGetPlayerStatePlaying()
            case 2: // 일시중지
                onYoutubePlayerSupportGetPlayerStatePaused(isPausedByUser : isPausedByUser, isPaused : isPaused)
            case 3: // 버퍼링
                youtubeCurrentPlayState = .buffering
            case 5: // 동영상 신호
                break
            default:
                break
            }
        }
    }
    
    private func onYoutubePlayerSuppoertGetPlayerStatePlaying() {
        self.fireYoutubeGetCurrentTimeTimer()
        self.invalidatePlayTimer()
        self.invalidateStateTimer(from: "onPlayerStatePlaying")
        youtubeCurrentPlayState = .playing
        resultHandler?( .stateChangedToPlay )
        resultHandler?( .requestSeekToOnInitial )
    }
    
    private func onYoutubePlayerSupportGetPlayerStatePaused(isPausedByUser : Bool, isPaused : Bool) {
        if isPausedByUser == true || isPaused == true {
            youtubeCurrentPlayState = .paused
        }
        else {
            self.onPlayVideo()
        }
    }
    
}
//MARK: -Getter
extension ShortsCellYoutubeCommandReactor {
    func getYoutubeId() -> String {
        return self.currentYoutubeId
    }
    
    func isPlayerReady() -> Bool {
        return self.isYoutubePlayerReady
    }
    
    func isPlayerOnError() -> Bool {
        return self.isYoutubePlayerOnError
    }
    
    func getYoutubeState() -> ShopliveYoutubePlayState {
        return self.youtubeCurrentPlayState
    }
    
    func getCurrenTime() -> Double? {
        return currentTime == 0 ? nil : currentTime
    }
}
