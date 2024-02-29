//
//  ShortsCellReactor.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2/1/24.
//

import Foundation
import UIKit
import AVKit
import VideoToolbox
import ShopliveSDKCommon

class ShortsCellReactor : NSObject, SLReactor {
    typealias WebToSdk = ShopLiveShortform.ShortsWebInterface.WebToSdk
    typealias SdkToWeb = ShopLiveShortform.ShortsWebInterface.SdkToWeb
    typealias JSRequest = (SdkToWeb, [String : Any])
    typealias ShortsModel = ShopLiveShortform.ShortsModel
    typealias ViewProvideType = ShortsCollectionBaseViewModel.ViewProvidedType
    typealias ShortsMode = ShopLiveShortform.ShortsMode
    
    enum Action {
        case setShortsModel(ShortsModel)
        case setWebViewUrl(URL)
        case webToSdk(name : WebToSdk, payload : [String : Any]? )
        
        case setIsMuted(Bool)
        case setAppState(srn: String?, state : String)
        case setIndexPath(IndexPath)
        case sendActivePageState(forceIsActive : Bool?, srn : String, shortsList : [ShortsModel]?, previousSrn : String?)
        case onChangedShortsItemTimeControlStatus(AVPlayer.TimeControlStatus)
        case onChangedShortsItemPlayerItemStatus(AVPlayerItem.Status)
        
        case setVideoDuration(Double)
        case setShopliveSessionId(String?)
        case videoTimeUpdated(CMTime)
        
        case didEndPlayingVideo
        
        case initializeCell
        case setViewProvideType(ViewProvideType)
        case setShortsMode(ShortsMode)
        
        case play(skipIfPaused : Bool)
        case pause
        case stop
        case replay
        
        case handleDeviceRotation(isLandscape : Bool)
        case requestSnapShot(String?)
        case requestSnapShotForWindow(String?)
    }
    
    enum Result {
        case setPosterImage(UIImage?)
        case requestEvaluateJS([JSRequest])
        case requestEvaluateJSForExternalWebView([JSRequest])
        case requestVideoDuration
        
        case requestCloseShortsDetailForHybrid(String)
        case requestShowShortsDetailForHybrid(String)
        case requestShowNewShortformFullScreen(ShopLiveShortform.ShortsBridgeModel)
        
        case requestCloseShortform
        case setWebViewIsScrollable(Bool)
        
        case requestPlayVideo
        case requestPauseVideo
        case requestStopVideo
        case requestReplayVideo
        case requestSeekToTime(CMTime)
        
        case didFinishPlayingVideo
        
        case requestSnapShot
        case requestSnapShotForWindow
        
        case setVideoPlayer(URL)
        
        case setWebViewIsHidden(Bool)
        case invalidateLayout
        case setVideoLayerGravity(AVLayerVideoGravity)
    }
    
    //data
    private var shortsModel : ShortsModel?
    private var currentVideoUrl : String? {
        shortsModel?.cards?.first?.videoUrl
    }
    private var currentSrn : String? {
        shortsModel?.srn
    }
    
    
    
    
    //states
    private var shortsMode : ShortsMode = .detail
    private var viewProvidType : ViewProvideType = .window
    private var currentWebViewUrl : URL?
    private var appState : String = "foreground"
    private var currentIndexPath : IndexPath = IndexPath(row: 0, section: 0)
    private var isActive : Bool = false
    private var shopLiveSessionId : String?
    private var isCurrentOrientationLandscape : Bool = UIScreen.isLandscape_SL
    
    //video states
    private var isMuted : Bool = false
    private var isPaused : Bool = false
    private var isPausedByUser : Bool = false
    private var videoDuration : Double = 0.0
    private var isReadyToPlay : Bool = false
    
    
    var resultHandler: ((Result) -> ())?
    
    
    deinit {
        ShopLiveLogger.debugLog("shortscellreactor deinited")
    }
    
    
    func action(_ action: Action) {
        switch action {
        case .initializeCell:
            self.onInitializeCell()
        case .setWebViewUrl(let url):
            self.onSetWebViewUrl(url: url)
        case .setShopliveSessionId(let shopLiveSessionId):
            self.onSetShopliveSessionId(id: shopLiveSessionId)
        case .setShortsModel(let model):
            self.onSetShortsModel(model: model)
        case .webToSdk(name: let name, payload: let payload):
            self.onWebToSdk(eventName: name, payload: payload)
        case .setIsMuted(let isMuted):
            self.onSetIsMuted(isMuted: isMuted)
        case .setAppState(let srn, let appState):
            self.onSetAppState(srn: srn, state: appState)
        case .setIndexPath(let indexPath):
            self.onSetIndexPath(indexPath: indexPath)
        case .sendActivePageState(forceIsActive: let forceIsActive, srn: let srn, shortsList: let shortsList, let previousSrn):
            self.onSendActivePageState(forceIsActive : forceIsActive, srn: srn, shortsList: shortsList, previousSrn : previousSrn)
        case .onChangedShortsItemTimeControlStatus(let timeControlStatus):
            self.onChangedShortsItemTimeControlStatus(status: timeControlStatus)
        case .onChangedShortsItemPlayerItemStatus(let playerItemStatus):
            self.onChangedShortsPlayerItemStatusChanged(status: playerItemStatus)
        case .setVideoDuration(let duration):
            self.onSetVideoDuration(duration: duration)
        case .videoTimeUpdated(let time):
            self.onVideoTimeUpdate(time: time)
        case .didEndPlayingVideo:
            self.onDidEndPlayingVideo()
        case .setViewProvideType(let viewProvideType):
            self.onSetViewProvideType(viewProvideType: viewProvideType)
        case .setShortsMode(let shortsMode):
            self.onSetShortsMode(shortsMode: shortsMode)
        case .play(skipIfPaused: let skipIfPaused):
            self.onPlay(skipIfPaused: skipIfPaused)
        case .pause:
            self.onPause()
        case .stop:
            self.onStop()
        case .replay:
            self.onReplay()
        case .handleDeviceRotation(isLandscape: let isLandScape):
            self.onHandleDeviceRotation(isLandscape: isLandScape)
        case .requestSnapShot(let srn):
            self.onRequestSnapShot(srn: srn)
        case .requestSnapShotForWindow(let srn):
            self.onRequestSnapShotFormWindow(srn: srn)
        }
    }
    
    private func onInitializeCell() {
        self.isReadyToPlay = false
        if let currentVideoUrl = currentVideoUrl, let videoUrl = URL(string: currentVideoUrl) {
            resultHandler?( .setVideoPlayer(videoUrl) )
        }
        let videoGravity : AVLayerVideoGravity = UIDevice.current.userInterfaceIdiom == .pad ? .resizeAspect : .resizeAspectFill
        resultHandler?( .setVideoLayerGravity(videoGravity) )
        
        if let urlString = shortsModel?.cards?.first?.screenshotUrl, let url = URL(string: urlString) {
            ImageDownLoaderManager.shared.download(imageUrl: url) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    self.resultHandler?( .setPosterImage(UIImage(data: data)) )
                case .failure(_):
                    break
                }
            }
        }
    }
    
    private func onSetWebViewUrl(url : URL) {
        self.currentWebViewUrl = url
    }
    
    private func onSetShopliveSessionId(id : String?) {
        self.shopLiveSessionId = id
    }
    
    private func onSetShortsModel(model : ShortsModel) {
        self.shortsModel = model
    }
    
    private func onSetIsMuted(isMuted : Bool) {
        self.isMuted = isMuted
        self.sendMuteStateToWeb()
    }
    
    private func onSetAppState(srn : String?, state : String) {
        guard let currentSrn = self.currentSrn,
              let srn = srn, srn == currentSrn else { return }
        
        self.appState = state
        self.setAppStateToWeb()
    }
    
    private func onSetIndexPath(indexPath : IndexPath) {
        self.currentIndexPath = indexPath
    }
    
    private func onSendActivePageState(forceIsActive : Bool?, srn : String, shortsList : [ShortsModel]?, previousSrn : String?) {
        guard let currentSrn = currentSrn else { return }
        if let forceIsActive = forceIsActive {
            self.isActive = forceIsActive
        }
        else {
            self.isActive = srn == currentSrn
        }
        
        self.sendOnChangedSessionInfoToWeb(shopliveSessionId: shopLiveSessionId, sessionId: "nil")
        
        if let shortsList = shortsList {
            self.sendV2ActivePageToWeb(srn: srn, shortsList: shortsList, previousSrn : previousSrn)
        }
        else {
            self.sendActivePageToWeb(srn: srn, previousSrn : previousSrn)
        }
        
        if isReadyToPlay == true && isActive == true && (isPausedByUser == false || shortsMode == .preview ) {
            resultHandler?( .requestPlayVideo )
        }
    }
    
    private func onChangedShortsItemTimeControlStatus(status : AVPlayer.TimeControlStatus) {
        isPaused = status == .paused
        
        if status == .playing {
            resultHandler?( .requestVideoDuration )
            self.sendVideoDurationChanged(duration: videoDuration)
        }
        
        self.sendOnVideoPausedToWeb()
    }
    
    private func onChangedShortsPlayerItemStatusChanged(status : AVPlayerItem.Status) {
        switch status {
        case .unknown, .failed:
            break
        case .readyToPlay:
            self.isReadyToPlay = true
            resultHandler?( .requestVideoDuration )
            self.sendVideoDurationChanged(duration: videoDuration)
            resultHandler?( .requestSnapShot )
            if isReadyToPlay == true && isActive == true && (isPausedByUser == false || shortsMode == .preview) {
                resultHandler?( .requestPlayVideo )
            }
        default:
            break
        }
    }
    
    private func onSetVideoDuration(duration : Double) {
        self.videoDuration = duration
    }
    
    private func onVideoTimeUpdate(time : CMTime) {
        self.sendVideoTimeUpdated(time: time.seconds)
    }
    
    private func onDidEndPlayingVideo() {
        if self.shortsMode == .preview {
            resultHandler?( .didFinishPlayingVideo )
        }
        else {
            self.sendVideoLoopedToWeb()
            resultHandler?( .requestReplayVideo )
        }
    }
    
    private func onSetViewProvideType(viewProvideType : ViewProvideType) {
        self.viewProvidType = viewProvideType
    }
    
    private func onSetShortsMode(shortsMode : ShortsMode) {
        self.shortsMode = shortsMode
        resultHandler?( .setWebViewIsHidden(shortsMode == .preview ))
    }
    
    private func onPlay(skipIfPaused : Bool) {
        if skipIfPaused && isPaused && isPausedByUser {
            return
        }
        isPausedByUser = false
        self.sendMuteStateToWeb()
        resultHandler?( .requestPlayVideo )
    }
    
    private func onPause() {
        isPausedByUser = true
        resultHandler?( .requestPauseVideo )
    }
    
    private func onStop() {
        isPausedByUser = true
        resultHandler?( .requestStopVideo )
    }
    
    private func onReplay() {
        isPausedByUser = false
        resultHandler?( .requestReplayVideo )
    }
    
    private func onHandleDeviceRotation(isLandscape : Bool) {
        if isCurrentOrientationLandscape != isLandscape {
            isCurrentOrientationLandscape = isLandscape
            
            let videoGravity : AVLayerVideoGravity
            if UIDevice.current.userInterfaceIdiom == .pad || UIScreen.isLandscape_SL {
                videoGravity = .resizeAspect
            }
            else {
                videoGravity = .resizeAspectFill
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return } 
                self.resultHandler?( .invalidateLayout )
                self.resultHandler?( .setVideoLayerGravity(videoGravity) )
            }
            sendSafeAreaInfoToWeb()
        }
    }
    
    private func onRequestSnapShot(srn : String?) {
        guard let currentSrn = self.currentSrn,
              let srn = srn, srn == currentSrn else { return }
        resultHandler?( .requestSnapShot )
    }
    
    private func onRequestSnapShotFormWindow(srn : String?) {
        guard let currentSrn = self.currentSrn,
              let srn = srn , srn == currentSrn else { return }
        resultHandler?( .requestSnapShotForWindow )
    }
}
//MARK: - webView Event handler
extension ShortsCellReactor {
    private func onWebToSdk(eventName : WebToSdk, payload : [String : Any]?) {
        switch eventName {
        case .ON_SHORTFORM_CLIENT_INITIALIZED:
            self.onShortformClientInitialized(payload: payload)
        case .ON_SHORTFORM_DETAIL_INITIALIZED:
            self.onShortformDetailInitialized()
        case .PLAY_SHORTFORM_DETAIL:
            self.onPlayShortformDetail(payload: payload)
        case .ON_CHANGED_USER_AUTH:
            self.onOnChangeduserAuth(payload: payload)
        case .HIDE_SHORTFORM_PREVIEW:
            self.onHideShortformPreview()
        case .ENABLE_SWIPE_DOWN:
            self.onEnableSwipdeDown()
        case .DISABLE_SWIPE_DOWN:
            self.onDisableSwipeDown()
        case .PLAY_VIDEO:
            self.onPlayVideo()
        case .SET_VIDEO_PAUSE:
            self.onSetVideoPause(payload: payload)
        case .SET_VIDEO_CURRENT_TIME:
            /** no - op not in use */
            break
        case .SET_VIDEO_SEEK_TIME:
            self.onSetVideoSeekTime(payload: payload)
        case .ON_USER_AUTHORIZATION_UPDATED:
            self.onuserAuthorizationUpdated(payload: payload)
        case .REQUEST_CLIENT_VERSION:
            self.onRequestClientVersion()
        case .CLOSE_SHORTFORM_DETAIL:
            self.onCloseShortformDetail()
        default:
            break
        }
    }
    
    private func onShortformClientInitialized(payload : [String : Any]?) {
        guard let payload = payload else { return }
        if ShortFormAuthManager.shared.getuserJWT() == nil && ShortFormAuthManager.shared.getGuestUId() == nil {
            ShortFormAuthManager.shared.setAuthInfo(payload)
        }
        else {
            var payload: [String: Any] = [:]
            if let userJWT = ShortFormAuthManager.shared.getuserJWT() {
                payload["userJWT"] = userJWT
            }
            
            if let guestUid = ShortFormAuthManager.shared.getGuestUId() {
                payload["guestUid"] = guestUid
            }
            
            let jsRequest : [JSRequest] = [(.ON_CHANGED_USER_AUTH_SDK, payload)]
            if ShopLiveShortform.BridgeInterface.isBridgeConnected() {
                resultHandler?( .requestEvaluateJSForExternalWebView(jsRequest))
            }
            else {
                resultHandler?( .requestEvaluateJS(jsRequest))
            }
        }
    }
    
    
    private func onShortformDetailInitialized() {
        sendSafeAreaInfoToWeb()
        sendMuteStateToWeb()
    }
    
    private func onPlayShortformDetail(payload : [String : Any]?) {
        guard let currentSrn = self.currentSrn else { return }
        if ShopLiveShortform.BridgeInterface.isBridgeConnected() {
            resultHandler?( .requestCloseShortsDetailForHybrid(currentSrn) )
        }
        guard let payload = payload,
              let jsonString = payload.toJson_SL(),
              let shortsBridgeModel = jsonString.convert_SL(to: ShopLiveShortform.ShortsBridgeModel.self) else { return }
        ShortFormAuthManager.shared.setAuthInfo(payload)
        
        resultHandler?( .requestShowNewShortformFullScreen(shortsBridgeModel) )
        
        if ShopLiveShortform.BridgeInterface.isBridgeConnected() {
            resultHandler?( .requestShowShortsDetailForHybrid(currentSrn) )
        }
    }
    
    private func onOnChangeduserAuth(payload : [String : Any]?) {
        guard let payload = payload else { return }
        ShortFormAuthManager.shared.setAuthInfo(payload)
    }
    
    private func onHideShortformPreview() {
        resultHandler?( .requestCloseShortform )
    }
    
    private func onEnableSwipdeDown() {
        resultHandler?( .setWebViewIsScrollable(true) )
    }
    
    private func onDisableSwipeDown() {
        resultHandler?( .setWebViewIsScrollable(false) )
    }
    
    private func onPlayVideo() {
        resultHandler?( .requestPlayVideo )
    }
    
    private func onSetVideoPause(payload : [String : Any]?) {
        guard let payload = payload else { return }
        guard let isPaused = payload["pause"] as? Bool else { return }
        self.isPaused = isPaused
        if isPaused {
            resultHandler?( .requestPauseVideo )
        }
        else {
            resultHandler?( .requestPlayVideo )
        }
    }
    
    private func onSetVideoSeekTime(payload : [String : Any]? ) {
        guard let payload = payload else { return }
        guard let seekTime = payload["seekTime"] as? CGFloat else { return }
        let seekCmTime = CMTimeMakeWithSeconds(seekTime, preferredTimescale: 1000000)
        guard seekCmTime != .zero else { return }
        resultHandler?( .requestSeekToTime(seekCmTime) )
    }
    
    private func onuserAuthorizationUpdated(payload : [String : Any]?) {
        guard let payload = payload else { return }
        ShortFormAuthManager.shared.setAuthInfo(payload)
    }
    
    private func onRequestClientVersion() {
        self.sendVersionInfoToWeb()
    }
    
    private func onCloseShortformDetail() {
        guard let currentSrn = self.currentSrn else { return }
        self.onSendActivePageState(forceIsActive: false, srn: currentSrn, shortsList: nil, previousSrn: nil)
        if ShopLiveShortform.BridgeInterface.isBridgeConnected() == false {
            resultHandler?( .requestCloseShortform )
        }
    }
    
}
//MARK: - SDK TO WEB COMMAND FUNCTIONS
extension ShortsCellReactor {
    private func sendMuteStateToWeb() {
        guard let videoUrl = self.currentVideoUrl else { return }
        let payload : [String : Any] = [
            "srn" : currentSrn ?? "",
            "videoUrl" : videoUrl,
            "muted" : isMuted
        ]
        
        let request : JSRequest = ( .ON_VIDEO_MUTED, payload )
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func sendSafeAreaInfoToWeb() {
        var payload : [String : Any] = [:]
        if self.viewProvidType == .view {
            payload = [ "top": 0, "right": 0, "bottom": 0, "left": 0 ]
        }
        else {
            payload = [
                "top": UIScreen.topSafeArea_SL,
                "right": UIScreen.rightSafeArea_SL,
                "bottom": UIScreen.bottomSafeArea_SL,
                "left": UIScreen.leftSafeArea_SL
            ]
        }
        let request : JSRequest = (.ON_CHANGED_SAFE_AREA, payload)
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func setAppStateToWeb() {
        let payload : [String : Any] = ["state" : appState]
        let request : JSRequest = (.ON_CHANGED_APPSTATE, payload)
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func sendActivePageToWeb(srn : String,previousSrn : String?) {
        guard shortsMode == .detail,
            let currentSrn = currentSrn else { return }
        
        let payload : [String : Any] = [
            "srn" : currentSrn,
            "index" : currentIndexPath.row,
            "previousSrn" : previousSrn
        ]
        
        let request : JSRequest
        if isActive {
            request = (.ON_SHORTFORM_DETAIL_PAGE_ACTIVE, payload)
        }
        else {
            request = (.ON_SHORTFORM_DETAIL_PAGE_INACTIVE, payload)
            resultHandler?( .requestStopVideo )
        }
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func sendV2ActivePageToWeb(srn : String, shortsList : [ShortsModel],previousSrn : String?) {
        guard shortsMode == .detail,
            let currentSrn = self.currentSrn else { return }
        let shortsListJson = SLJSONUtil.toJsonString(shortsList) ?? "[]"
        
        let payload : [String : Any] = [
            "srn" : currentSrn,
            "index" : currentIndexPath.row,
            "shortsList" : shortsListJson,
            "previousSrn" : previousSrn
        ]
        
        let request : JSRequest
        if isActive {
            request = (.ON_SHORTFORM_DETAIL_PAGE_ACTIVE, payload)
        }
        else {
            request = (.ON_SHORTFORM_DETAIL_PAGE_INACTIVE, payload)
            resultHandler?( .requestStopVideo )
        }
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func sendVersionInfoToWeb() {
        let payload : [String : Any] = [
            "appVersion" : UIApplication.appVersion_SL(),
            "sdkVersion" : ShopLiveShortform.sdkVersion
        ]
        
        let request : JSRequest = ( .SEND_CLIENT_VERSION, payload )
        resultHandler?( .requestEvaluateJS([request]) )
    }
    
    private func sendOnChangedSessionInfoToWeb(shopliveSessionId : String?, sessionId : String?) {
        let payload : [String : Any] = [
            "shopliveSessionId" : shopliveSessionId,
            "sessionId" : sessionId
        ]
        
        let request : JSRequest = (.ON_CHANGED_SESSION_INFO, payload)
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func sendVideoLoopedToWeb() {
        let payload : [String : Any] = [
            "videoUrl" : currentVideoUrl ?? "",
            "srn" : currentSrn ?? "",
        ]
        
        let request : JSRequest = (.ON_VIDEO_LOOPED, payload)
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func sendOnVideoPausedToWeb() {
        guard let currentSrn = currentSrn,
              let videoUrl = currentVideoUrl else { return }
        var payload : [String : Any] = [
            "srn" : currentSrn,
            "videoUrl" : videoUrl,
            "paused" : isPaused
        ]
        
        ShortFormAuthManager.shared.getAkAndUserJWTasDict().forEach { payload[$0.key] = $0.value }
        
        let request : JSRequest = ( .ON_VIDEO_PAUSED , payload )
        
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func sendVideoDurationChanged(duration : Double) {
        guard let currentSrn = currentSrn,
              let currentVideoUrl = currentVideoUrl else { return }
        let durationValue : Float64 = (round(1000 * duration) / 1000)
        
        var payload : [String : Any] = [
            "srn" : currentSrn,
            "videoUrl" : currentVideoUrl,
            "duration" : durationValue
        ]
        
        ShortFormAuthManager.shared.getAkAndUserJWTasDict().forEach{ payload[$0.key] = $0.value }
        
        let request : JSRequest = ( .ON_VIDEO_DURATION_CHANGED, payload )
        
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    
    private func sendVideoTimeUpdated(time : Double) {
        guard let currentSrn = currentSrn,
              let currentVideoUrl = currentVideoUrl else { return }
        let timeValue : Float64 = (round(1000 * time) / 1000)
        var payload : [String : Any] = [
            "srn" : currentSrn,
            "videoUrl" : currentVideoUrl,
            "currentTime" : timeValue
        ]
        
        ShortFormAuthManager.shared.getAkAndUserJWTasDict().forEach{ payload[$0.key] = $0.value }
        
        let request : JSRequest = ( .ON_VIDEO_TIME_UPDATED, payload )
        
        resultHandler?( .requestEvaluateJS([request]))
    }
}
//MARK: Getter
extension ShortsCellReactor {
    func getShortsModel() -> ShortsModel? {
        return self.shortsModel
    }
    
    func getWebViewUrl() -> URL? {
        return self.currentWebViewUrl
    }
    
    func getCurrentIndexPath() -> IndexPath {
        return self.currentIndexPath
    }
}
