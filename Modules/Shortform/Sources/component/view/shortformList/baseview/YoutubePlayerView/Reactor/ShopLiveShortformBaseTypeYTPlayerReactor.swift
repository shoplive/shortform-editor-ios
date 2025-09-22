//
//  ShopLiveShortformBaseTypeYTPlayerReactor.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 3/4/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import UIKit
import WebKit

class ShopLiveShortformBaseTypeYTPlayerReactor : NSObject, SLReactor {
    typealias SdkToWeb = ShopLiveShortform.ShortsWebInterface.SdkToWeb
    typealias WebToSdk = ShopLiveShortform.ShortsWebInterface.WebToSdk
    typealias YoutubeToSdk = ShopLiveShortform.ShortsWebInterface.YoutubeToSdk
    typealias JSRequest = (SdkToWeb, [String : Any])
    
    enum Action {
        case setisWebViewLoaded(Bool?)
        case queueJSRequest(JSRequest)
        case sendQueuedJSRequest
        case setCurrentSrn(String?)
        case webToSDK(name : WebToSdk, payload : [String : Any]? )
        
        
        case play
        case pause
        
    }
    
    enum Result {
        case requestEvaluateJS([JSRequest])
        case hidePosterImage(Bool)
    }
    
    private var currentSrn : String?
    private var jsRequestsList : [JSRequest] = []
    private var isWebViewLoaded : Bool?
    
    //youtube state
    private var currentYoutubeId : String = ""
    private var isYoutubePlayerReady : Bool = false
    private var isYoutubePlayerOnError : Bool = false
    private var youtubeCurrentPlayState : ShopliveYoutubePlayState = .notReady
    
    var resultHandler: ((Result) -> ())?
    let throttle = SLThrottle(queue: DispatchQueue.main, delay: 0.1)
    
    override init() {
        super.init()
    }
    
    deinit {
        
    }
    
    func action(_ action: Action) {
        switch action {
        case .setisWebViewLoaded(let isLoaded):
            self.onSetIsWebViewLoaded(isLoaded: isLoaded)
        case .queueJSRequest(let jSRequest):
            self.onQueueJSResult(jsRequest: jSRequest)
        case .sendQueuedJSRequest:
            self.onSendQueuedJSRequest()
        case .setCurrentSrn(let currentSrn):
            self.onSetCurrentSrn(currentSrn: currentSrn)
        case .play:
            self.onPlay()
        case .pause:
            self.onPause()
        case .webToSDK(name: let command, payload: let payload):
            self.onWebToSDK(name: command, payload: payload)
        }
    }
    
    private func onSetIsWebViewLoaded(isLoaded : Bool?) {
        self.isWebViewLoaded = isLoaded
    }
    
    private func onQueueJSResult(jsRequest : JSRequest) {
        self.jsRequestsList.append(jsRequest)
    }
    
    private func onSendQueuedJSRequest() {
        resultHandler?( .requestEvaluateJS(jsRequestsList))
        jsRequestsList.removeAll()
    }
    
    private func onSetCurrentSrn(currentSrn : String?) {
        self.currentSrn = currentSrn
    }
    
    private func onPlay() {
        if isYoutubePlayerOnError {
            self.sendYoutubeDestroyAndReload()
        }
        else if isYoutubePlayerReady {
            if youtubeCurrentPlayState != .playing {
                throttle.callAsFunction { [weak self] in
                    self?.sendYoutubeMute()
                    self?.sendYoutubePlayVideo()
                    
                } onCancel: {
                    
                }
            }
        }
    }
    
    private func onPause() {
        if youtubeCurrentPlayState != .paused {
            throttle.callAsFunction { [weak self] in
                self?.sendYoutubePauseVideo()
            } onCancel: {
                
            }
        }
    }
    
    private func onWebToSDK(name : WebToSdk, payload : [String : Any]?) {
        switch name {
        case .SDK_YOUTUBE_PLAYER_SUPPORT:
            self.onSDKYoutubePlayerSupport(payload: payload)
        default:
            break
        }
    }
    
    private func onSDKYoutubePlayerSupport(payload : [String : Any]?) {
        guard let payload = payload else { return }
        if let youtubeId = payload["youtubeId"] as? String {
            self.currentYoutubeId = youtubeId
        }
        
        guard let eventName = payload["name"] as? String else { return }
        switch eventName {
        case YoutubeToSdk.SDK_YTP_ON_PLAYER_READY.rawValue:
            onYoutubePlayerSupportYTPOnPlayerReady()
            break
        case YoutubeToSdk.SDK_YTP_GET_PLAYER_STATE.rawValue, YoutubeToSdk.SDK_YTP_ON_PLAYER_STATE_CHANGE.rawValue:
            onYoutubePlayerSupportGetPlayerState(payload: payload)
            break
        case YoutubeToSdk.SDK_YTP_ON_ERROR.rawValue:
            sendYoutubeDestroyAndReload()
            break
        case YoutubeToSdk.SDK_YTP_GET_CURRENT_TIME.rawValue, YoutubeToSdk.SDK_YTP_GET_DURATION.rawValue, YoutubeToSdk.SDK_YTP_GET_IS_MUTED.rawValue:
            break
        default:
            break
        }
    }
    
    private func onYoutubePlayerSupportYTPOnPlayerReady() {
        self.isYoutubePlayerReady = true
        self.sendYoutubeMute()
        //PlayerSupport가 뒤늦게 도착했을때 자동 재생
        if youtubeCurrentPlayState != .playing && youtubeCurrentPlayState == .notReady {
            sendYoutubePlayVideo()
        }
    }
    
    private func onYoutubePlayerSupportGetPlayerState(payload : [String : Any]) {
        guard let youtubeId = payload["youtubeId"] as? String,
              youtubeId == currentYoutubeId else { return }
        if let values = payload["values"] as? [String : Any] , let data = values["data"] as? Int {
            switch data {
            case -1: //시작되지 않음
                self.onYoutubePlayerSupportGetPlayerStateOnNotReady()
            case 0: //종료
                youtubeCurrentPlayState = .destroyed
            case 1: // 재생중
                self.onYoutubePlayerSupportGetPlayerStateOnPlayingState()
            case 2: // 일시중지
                youtubeCurrentPlayState = .paused
            case 3: // 버퍼링
                youtubeCurrentPlayState = .buffering
            case 5: // 동영상 신호
                break
            default:
                break
            }
        }
    }
    
    private func onYoutubePlayerSupportGetPlayerStateOnNotReady() {
        youtubeCurrentPlayState = .notReady
        resultHandler?( .hidePosterImage(false) )
    }
    
    private func onYoutubePlayerSupportGetPlayerStateOnPlayingState() {
        youtubeCurrentPlayState = .playing
        resultHandler?( .hidePosterImage(true) )
        
    }
}
//MARK: - YoutubePlayer 전용 웹 커맨드
extension ShopLiveShortformBaseTypeYTPlayerReactor {
    private func sendYoutubeGetPlayerState() {
        guard let payload = self.getYoutubeWebCommandPayload() else { return }
        let request : JSRequest = ( .SDK_YTP_GET_PLAYER_STATE, payload )
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func sendYoutubePlayVideo() {
        guard let payload = self.getYoutubeWebCommandPayload() else { return }
        let request : JSRequest = ( .SDK_YTP_PLAY_VIDEO, payload )
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func sendYoutubePauseVideo() {
        guard let payload = self.getYoutubeWebCommandPayload() else { return }
        let request : JSRequest = ( .SDK_YTP_PAUSE_VIDEO, payload )
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func sendYoutubeDestroyAndReload() {
        guard let payload = self.getYoutubeWebCommandPayload() else { return }
        let request : JSRequest = ( .SDK_YTP_DESTROY_AND_RELOAD, payload )
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func sendYoutubeMute() {
        guard let payload = self.getYoutubeWebCommandPayload() else { return }
        let request : JSRequest = ( .SDK_YTP_MUTE, payload )
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func getYoutubeWebCommandPayload() -> [String : Any]? {
        guard let currentSrn = currentSrn else {
            return nil
        }
        
        return [
            "srn" : currentSrn,
            "youtubeId" : currentYoutubeId
        ]
    }
}
//MARK: -Getter
extension ShopLiveShortformBaseTypeYTPlayerReactor {
    func getIsWebViewLoaded() -> Bool? {
        return isWebViewLoaded
    }
    
    func getYoutubeId() -> String {
        return currentYoutubeId
    }
}
