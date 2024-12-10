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

protocol ShortsCellReactorDelegate : AnyObject {
    func getCurrentOnViewIndexPath() -> IndexPath?
}

class ShortsCellReactor : NSObject, SLReactor {
    typealias WebToSdk = ShopLiveShortform.ShortsWebInterface.WebToSdk
    typealias SdkToWeb = ShopLiveShortform.ShortsWebInterface.SdkToWeb
    typealias JSRequest = (SdkToWeb, [String : Any])
    typealias ViewProvideType = ShortsCollectionBaseViewModel.ViewProvidedType
    typealias ShortsMode = ShopLiveShortform.ShortsMode
    
    enum Action {
        case setShortsModel(SLShortsModel)
        case setWebViewUrl(URL)
        case setSetShortsSingleDetailViewPayload([String : Any]? )
        case webToSdk(name : WebToSdk, payload : [String : Any]? )
        
        case setIsMuted(Bool)
        case setAppState(srn: String?, state : String)
        case setIndexPath(IndexPath)
        case sendActivePageState(forceIsActive : Bool?, srn : String, shortsList : [SLShortsModel]?, previousSrn : String?)
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
        
        case invalidateGetYoutubeCurrentTimer
        
        case setSeekToOnInitial(ShortformCurrentTimeDTO?)
        case requestSeekToOnInital
    }
    
    enum Result {
        case setThumbnailImage(UIImage?)
        case setThumbnailRatio(CGSize?)
        case setYoutubePosterImage(UIImage?)
        case hideYoutubePosterImage(Bool)
        
        case requestEvaluateJS([JSRequest])
        case requestYoutubePlayerEvaluateJS([JSRequest])
        
        case requestEvaluateJSForExternalWebView([JSRequest])
        case requestVideoDuration
        
        case requestCloseShortsDetailForHybrid(String)
        case requestShowShortsDetailForHybrid(String)
        case requestShowNewShortformFullScreen(ShopLiveShortform.ShortsBridgeModel)
        case requestSetCustomShortformForV2(shortsId : String)
        
        case requestCloseShortform
        case requestRemoveShortform(shortsId : String)
        case setWebViewIsScrollable(Bool)
        case setWebViewIsShortformClientInitialized(Bool)
        
        case requestPlayVideo
        case requestPauseVideo
        case requestStopVideo
        case requestReplayVideo
        case requestSeekToTime(CMTime)
        case requestHideVideoPlayer(Bool)
        case requestHideYoutubePlayer(Bool)
        
        case didFinishPlayingVideo
        
        case requestSnapShot
        case requestSnapShotForWindow
        
        case setVideoPlayer(URL)
        case emptyVideoPlayer
        
        case setWebViewIsHidden(Bool)
        case invalidateLayout
        case setVideoLayerGravity(AVLayerVideoGravity)
        case setThumbnailImageContentMode(UIView.ContentMode)
        case scrollToNextCell(SLShortsModel?)
        case showLoadingIndicator(Bool)
    }
    
    //data
    private var shortsModel : SLShortsModel?
    private var currentVideoUrl : String? {
        if let card = shortsModel?.cards?.first,
           let convertStatus = card.convertStatus, convertStatus != .COMPLETE,
           let originVideoUrl = card.originVideoUrl {
            return originVideoUrl
        }
        else if shortsMode == .detail {
            return shortsModel?.cards?.first?.videoUrl
        }
        else {
            return shortsModel?.cards?.first?.previewVideoUrl
        }
    }
    
    private var currentSrn : String? {
        shortsModel?.srn
    }
    
    private var setShortsSingleDetailViewPayload : [String : Any]?
    private var seekToOnInitial : ShortformCurrentTimeDTO?
    
    
    //states
    private var shortsMode : ShortsMode = .detail
    private var viewProvidType : ViewProvideType = .window
    private var currentWebViewUrl : URL?
    private var appState : String = "foreground"
    private var currentIndexPath : IndexPath = IndexPath(row: 0, section: 0)
    private var isActive : Bool = false
    private var shopliveSessionId : String?
    private var isCurrentOrientationLandscape : Bool = UIScreen.isLandscape_SL
    
    //video states
    private var isMuted : Bool = false
    private var isPaused : Bool = false
    private var isPausedByUser : Bool = false
    private var videoDuration : Double = 0.0
    private var isReadyToPlay : Bool = false
    
    private var loadingIndicatorWorkItem : DispatchWorkItem?
    

    //ON_SHORTFORM_DETAIL_ACTIVE가 webView에서 리스터 마운트 되기전에 호출되면 detail_active가 안들어옴
    //따라서 Detail_INITIALIZED 이벤트 받은후에 보내도록 보장해야함
    private var isShortformDetailInitialized : Bool = false
    private var onShortformDetailActiveCommandReserveCallback : (() -> ())?
    
    lazy private var ytCommandReactor = ShortsCellYoutubeCommandReactor(delegate: self)
    
    var resultHandler: ((Result) -> ())?
    
    weak var delegate : ShortsCellReactorDelegate?
    
    override init(){
        super.init()
        bindYoutubeCommandReactor()
    }
    
    deinit {
        ytCommandReactor.action( .invalidateTimer )
        ShopLiveLogger.memoryLog("shortscellreactor deinited")
    }
    
    
    func action(_ action: Action) {
        switch action {
        case .initializeCell:
            self.onInitializeCell()
        case .setWebViewUrl(let url):
            self.onSetWebViewUrl(url: url)
        case .setSetShortsSingleDetailViewPayload(let payload):
            self.onSetShortsSingleDetailViewPayload(payload: payload)
        case .setShopliveSessionId(let shopliveSessionId):
            self.onSetShopliveSessionId(id: shopliveSessionId)
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
        case .invalidateGetYoutubeCurrentTimer:
            self.onInvalidateYoutubeTimer()
        case .setSeekToOnInitial(let time):
            self.onSetSeekToOnInitial(time: time)
        case .requestSeekToOnInital:
            self.onRequestSeekToOnInitial()
        }
    }
    
    private func onInitializeCell() {
        if getIsYoutubePlayer() {
            if let cardModel = shortsModel?.cards?.first,
               let playerType = cardModel.playerType, playerType == "YOUTUBE",
               let youtubeId = shortsModel?.cards?.first?.externalVideoId,
               let externalVideoThumbnail = cardModel.externalVideoThumbnail,
               let posterUrl = URL(string: externalVideoThumbnail) {
                ImageDownLoaderManager.shared.download(imageUrl: posterUrl) { [weak self] result  in
                    switch result {
                    case .success(let data):
                        self?.resultHandler?( .setYoutubePosterImage(UIImage(data: data)) )
                    case .failure(_):
                        break
                    }
                }
            }
            if let youtubeId = shortsModel?.cards?.first?.externalVideoId {
                ytCommandReactor.action( .setCurrentYoutubeId(youtubeId) )
            }
            resultHandler?( .hideYoutubePosterImage(false) )
            resultHandler?( .requestHideVideoPlayer(true) )
            resultHandler?( .requestStopVideo )
            resultHandler?( .requestHideYoutubePlayer(false) )
            ytCommandReactor.action( .resetYoutubeCurrentState )
            ytCommandReactor.action( .setCurrentSrn(currentSrn) )
            ytCommandReactor.action( .setCurrentIndexPath(currentIndexPath) )
        }
        else {
            self.isReadyToPlay = false
            resultHandler?( .hideYoutubePosterImage(true) )
            resultHandler?( .requestHideVideoPlayer(false) )
            resultHandler?( .requestHideYoutubePlayer(true) )
            
            if let currentVideoUrl = currentVideoUrl, let videoUrl = URL(string: currentVideoUrl) {
                resultHandler?( .setVideoPlayer(videoUrl) )
            }
            else {
                resultHandler?( .emptyVideoPlayer )
            }
            
            let videoGravity : AVLayerVideoGravity = self.getVideoGravity()
            
            if videoGravity == .resizeAspect {
                resultHandler?( .setThumbnailImageContentMode(.scaleAspectFit) )
            }
            else {
                resultHandler?( .setThumbnailImageContentMode(.scaleAspectFill) )
            }
            
            resultHandler?( .setVideoLayerGravity(videoGravity) )
            let urlString = shortsModel?.cards?.first?.screenshotUrl ?? (shortsModel?.cards?.first?.specifiedScreenShotUrl ?? "")
            if let url = URL(string: urlString) {
                ImageDownLoaderManager.shared.download(imageUrl: url) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let data):
                        self.resultHandler?( .setThumbnailImage(UIImage(data: data)) )
                    case .failure(_):
                        break
                    }
                }
            }
            if let card = shortsModel?.cards?.first, let w = card.width, let h = card.height, UIDevice.current.userInterfaceIdiom == .pad || UIScreen.isLandscape_SL {
                resultHandler?( .setThumbnailRatio(CGSize(width: w, height: h)) )
            }
            else {
                resultHandler?( .setThumbnailRatio(nil) )
            }
        }
        ytCommandReactor.action( .setCurrentShortsMode(self.shortsMode) )
        
        cancelLoadingIndicatorWorkItem()
        loadingIndicatorWorkItem = DispatchWorkItem(block: { [weak self] in
            self?.resultHandler?( .showLoadingIndicator(true) )
        })
        if let workItem = loadingIndicatorWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: workItem)
        }
    }
    
    private func onSetWebViewUrl(url : URL) {
        self.currentWebViewUrl = url
    }
    
    private func onSetShortsSingleDetailViewPayload(payload : [String : Any]?) {
        self.setShortsSingleDetailViewPayload = payload
    }
    
    private func onSetShopliveSessionId(id : String?) {
        self.shopliveSessionId = id
    }
    
    private func onSetShortsModel(model : SLShortsModel) {
        self.shortsModel = model
    }
    
    private func onSetIsMuted(isMuted : Bool) {
        self.isMuted = isMuted
        
        sendMuteStateToWebOrYoutube()
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
    
    private func onSendActivePageState(forceIsActive : Bool?, srn : String, shortsList : [SLShortsModel]?, previousSrn : String?) {
        guard let currentSrn = currentSrn else { return }
        if let forceIsActive = forceIsActive {
            self.isActive = forceIsActive
        }
        else {
            self.isActive = srn == currentSrn
        }
        
        self.sendOnChangedSessionInfoToWeb(shopliveSessionId: shopliveSessionId)
        
        if let shortsList = shortsList {
            self.sendV2ActivePageToWeb(srn: srn, shortsList: shortsList, previousSrn : previousSrn)
        }
        else {
            self.sendActivePageToWeb(srn: srn, previousSrn : previousSrn)
        }
        
        if isReadyToPlay == true && isActive == true && (isPausedByUser == false || shortsMode == .preview ) && getIsYoutubePlayer() == false {
            resultHandler?( .requestPlayVideo )
        }
        else if getIsYoutubePlayer() == true {
            resultHandler?( .requestStopVideo )
        }
    }
    
    private func onChangedShortsItemTimeControlStatus(status : AVPlayer.TimeControlStatus) {
        isPaused = status == .paused
        
        if status == .playing {
            cancelLoadingIndicatorWorkItem()
            self.resultHandler?( .showLoadingIndicator(false) )
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
            cancelLoadingIndicatorWorkItem()
            self.resultHandler?( .showLoadingIndicator(false) )
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.sendVideoLoopedToWeb()
                self?.resultHandler?( .requestReplayVideo )
            }
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
        if getIsYoutubePlayer() {
            if ytCommandReactor.isPlayerOnError() {
                ytCommandReactor.action( .destroyAndReload )
            }
            else if ytCommandReactor.isPlayerReady() {
                sendMuteStateToWebOrYoutube()
                ytCommandReactor.action( .playVideo )
            }
        }
        else {
            sendMuteStateToWebOrYoutube()
            resultHandler?( .requestPlayVideo )
        }
    }
    
    private func onPause() {
        isPausedByUser = true
        if getIsYoutubePlayer() {
            ytCommandReactor.action( .pauseVideo )
        }
        else {
            resultHandler?( .requestPauseVideo )
        }
        
    }
    
    private func onStop() {
        isPausedByUser = true
        if getIsYoutubePlayer() {
            resultHandler?( .hideYoutubePosterImage(false))
            ytCommandReactor.action( .seekTo(0) )
            ytCommandReactor.action( .pauseVideo )
            ytCommandReactor.action( .invalidateTimer )
        }
        else {
            resultHandler?( .requestStopVideo )
        }
    }
    
    private func onReplay() {
        isPausedByUser = false
        if getIsYoutubePlayer() {
            ytCommandReactor.action( .seekTo(0) )
        }
        else {
            resultHandler?( .requestReplayVideo )
        }
    }
    
    private func onHandleDeviceRotation(isLandscape : Bool) {
        if isCurrentOrientationLandscape != isLandscape {
            isCurrentOrientationLandscape = isLandscape
            
            let videoGravity : AVLayerVideoGravity = getVideoGravity()
            
            
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
    
    private func onInvalidateYoutubeTimer() {
        ytCommandReactor.action( .invalidateTimer )
    }
    
    private func onSetSeekToOnInitial(time : ShortformCurrentTimeDTO?) {
        seekToOnInitial = time
    }
    
    private func onRequestSeekToOnInitial() {
        guard let seekTo = self.seekToOnInitial else { return }
        switch seekTo {
        case .shoplive(let time):
            guard let time = time else { return }
            resultHandler?( .requestSeekToTime(time) )
            self.seekToOnInitial = nil
        default:
            break
        }
    }
}
extension ShortsCellReactor {
    func getVideoGravity() -> AVLayerVideoGravity {
        var videoGravity : AVLayerVideoGravity = .resizeAspect
        if UIDevice.current.userInterfaceIdiom == .pad {
            videoGravity = .resizeAspect
        }
        else if self.shortsMode == .preview {
            videoGravity = .resizeAspectFill
        }
        else {
            if let resizeMode = ShopLiveShortform.detailPlayerResizeMode {
                if resizeMode == .CENTER_CROP {
                    videoGravity = .resizeAspectFill
                }
                else {
                    videoGravity = .resizeAspect
                }
            }
            else {
                videoGravity = .resizeAspectFill
            }
        }
        return videoGravity
    }
}
//MARK: - YoutubeCommandReactor
extension ShortsCellReactor {
    private func bindYoutubeCommandReactor() {
        ytCommandReactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .onVideoDurationChanged(let duration):
                self.onYTCommandReactorOnVideoDurationChanged(duration: duration)
            case .onVideoLoopEvent:
                self.onYTCommandReactorOnVideoLoopEvent()
            case .onVideoTimeUpdate(let currentTime):
                self.onYTCommandReactorOnVideoTimeUpdate(currentTime: currentTime)
            case .requestEvaluateJS(let jsRequestList):
                self.onYTCommandReactorRequestEvaluateJS(requestList: jsRequestList)
            case .stateChangedToPlay:
                self.onYTCommandReactorStateChangedToPlay()
            case .stateChangedToPause:
                break
            case .sendVideoMuteToWeb(let isMute):
                onYTCommandReactorSendVideoMuteToWeb(isMute: isMute)
            case .scrollToNextCell:
                self.onYTCommandReactorScrollToNextCell()
            case .hideThumbnail(let hide):
                self.onYTCommandReactorHideThumbnail(hide: hide)
            case .requestSeekToOnInitial:
                self.onYTCommandReactorRequestSeekToOnInitial()
                break
            }
        }
    }
    
    private func onYTCommandReactorOnVideoDurationChanged(duration : Double) {
        self.sendVideoDurationChanged(duration: duration)
    }
    
    private func onYTCommandReactorOnVideoLoopEvent() {
        self.sendVideoLoopedToWeb()
    }
    
    private func onYTCommandReactorOnVideoTimeUpdate(currentTime : Double) {
        self.sendVideoTimeUpdated(time: currentTime)
    }
    
    private func onYTCommandReactorRequestEvaluateJS(requestList : [JSRequest]) {
        resultHandler?( .requestYoutubePlayerEvaluateJS(requestList) )
    }
    
    private func onYTCommandReactorStateChangedToPlay() {
        resultHandler?( .hideYoutubePosterImage(true) )
        sendMuteStateToWebOrYoutube()
    }
    
    private func onYTCommandReactorSendVideoMuteToWeb(isMute : Bool) {
        self.isMuted = isMute
        sendMuteStateToWebOrYoutube()
    }
    
    private func onYTCommandReactorScrollToNextCell() {
        resultHandler?( .scrollToNextCell(self.shortsModel) )
    }
    
    private func onYTCommandReactorHideThumbnail(hide : Bool) {
        resultHandler?( .hideYoutubePosterImage(hide) )
    }
    
    private func onYTCommandReactorRequestSeekToOnInitial() {
        guard let seekTo = self.seekToOnInitial else { return }
        switch seekTo {
        case .youtube(let time):
            guard let time = time else { return }
            ytCommandReactor.action( .seekTo(time) )
            self.seekToOnInitial = nil
        default:
            break
        }
    }
}
//MARK: - not classified functions 잡부 느낌의 함수는 여기에 넣어주세요
extension ShortsCellReactor {
    private func sendMuteStateToWebOrYoutube() {
        if getIsYoutubePlayer() {
            ytCommandReactor.action( .sendMuteState(isMute: isMuted) )
        }
        self.sendMuteStateToWeb()
    }
}
//MARK: - webView Event handler
extension ShortsCellReactor {
    private func onWebToSdk(eventName : WebToSdk, payload : [String : Any]?) {
        switch eventName {
        case .ON_SHORTFORM_DETAIL_REMOVED:
            self.onShortformRemoved(payload : payload)
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
        
            //youtube
        case .SDK_YOUTUBE_PLAYER_SUPPORT:
            self.onYoutubePlayerSupport(payload: payload, isMute: isMuted, isActive: isActive, isPausedByUser: isPausedByUser, isPaused: isPaused)
        case .SET_VIDEO_MUTE:
            self.onSetVideoMute(payload: payload)
        default:
            break
        }
    }
    
    private func onShortformRemoved(payload : [String : Any]?) {
         ShopLiveLogger.tempLog("[HASSAN LOG] payload \(payload)")
     }
    
    private func onShortformClientInitialized(payload : [String : Any]?) {
        guard let payload = payload else { return }
        
        //SET_SHORTS_SINGLE_DETAIL_VIEW
        if let setShortsSingleDetailViewPayload = setShortsSingleDetailViewPayload {
            let jsRequest : [JSRequest] = [(.SET_SHORTS_SINGLE_DETAIL_VIEW, setShortsSingleDetailViewPayload)]
            resultHandler?( .requestEvaluateJS(jsRequest))
        }
        
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
        resultHandler?( .setWebViewIsShortformClientInitialized(true) )
    }
    
    private func onShortformDetailInitialized() {
        sendSafeAreaInfoToWeb()
        sendMuteStateToWebOrYoutube()
        if let shortsId = self.shortsModel?.shortsId {
            resultHandler?( .requestSetCustomShortformForV2(shortsId: shortsId) )
        }
        isShortformDetailInitialized = true
        onShortformDetailActiveCommandReserveCallback?()
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
        if getIsYoutubePlayer() {
            ytCommandReactor.action( .playVideo )
        }
        else {
            resultHandler?( .requestPlayVideo )
        }
    }
    
    private func onSetVideoPause(payload : [String : Any]?) {
        guard let payload = payload else { return }
        guard let isPaused = payload["pause"] as? Bool else { return }
        if getIsYoutubePlayer() {
            if ytCommandReactor.getYoutubeState() == .playing {
                ytCommandReactor.action( .pauseVideo )
            }
            else {
                ytCommandReactor.action( .playVideo )
            }
        }
        else {
            self.isPaused = isPaused
            if isPaused {
                resultHandler?( .requestPauseVideo )
            }
            else {
                resultHandler?( .requestPlayVideo )
            }
        }
    }
    
    //TODO: -여기에서 youtube seek 이벤트도 같이 해야 하나?
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
    
    private func onYoutubePlayerSupport(payload : [String : Any]?, isMute : Bool, isActive : Bool,isPausedByUser : Bool, isPaused : Bool) {
        ytCommandReactor.action( .onYoutubePlayerSupport(payload: payload, isMute: isMute, isActive: isActive, isPausedByUser: isPausedByUser, isPaused: isPaused))
    }
    
    private func onSetVideoMute(payload : [String : Any]?) {
        guard let isMute = payload?["mute"] as? Bool else { return }
        guard getIsYoutubePlayer() else { return }
        self.isMuted = isMute
        ytCommandReactor.action( .sendMuteState(isMute: isMute) )
    }
    
}
//MARK: - SDK TO WEB COMMAND FUNCTIONS
extension ShortsCellReactor {
    /**
        바로 가져다가 쓰지 말고 sendMuteStateToWebOrYoutube 써야합니다.
     */
    private func sendMuteStateToWeb() {
        guard let currentVideoUrl = getCurrentVideoUrlByType() else { return }
        
        var payload : [String : Any] = [
            "srn" : currentSrn ?? "",
            "muted" : isMuted,
            "videoUrl" : currentVideoUrl
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
        
        if isShortformDetailInitialized == false {
            onShortformDetailActiveCommandReserveCallback = { [weak self] in
                self?.resultHandler?( .requestEvaluateJS([request]))
            }
        }
        else {
            resultHandler?( .requestEvaluateJS([request]))
        }
    }
    
    private func sendV2ActivePageToWeb(srn : String, shortsList : [SLShortsModel],previousSrn : String?) {
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
        if isShortformDetailInitialized == false {
            onShortformDetailActiveCommandReserveCallback = { [weak self] in
                self?.resultHandler?( .requestEvaluateJS([request]))
            }
        }
        else {
            resultHandler?( .requestEvaluateJS([request]))
        }
    }
    
    private func sendVersionInfoToWeb() {
        let payload : [String : Any] = [
            "appVersion" : UIApplication.appVersion_SL(),
            "sdkVersion" : ShopLiveShortform.sdkVersion
        ]
        
        let request : JSRequest = ( .SEND_CLIENT_VERSION, payload )
        resultHandler?( .requestEvaluateJS([request]) )
    }
    
    private func sendOnChangedSessionInfoToWeb(shopliveSessionId : String?) {
        let payload : [String : Any] = [
            "shopliveSessionId" : shopliveSessionId
        ]
        
        let request : JSRequest = (.ON_CHANGED_SESSION_INFO, payload)
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func sendVideoLoopedToWeb() {
        guard let videoUrl = self.getCurrentVideoUrlByType() else { return }
        
        let payload : [String : Any] = [
            "videoUrl" : videoUrl,
            "srn" : currentSrn ?? "",
        ]
        
        let request : JSRequest = (.ON_VIDEO_LOOPED, payload)
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func sendOnVideoPausedToWeb() {
        guard let currentSrn = currentSrn,
              let currentVideoUrl = getCurrentVideoUrlByType() else { return }
        
        var payload : [String : Any] = [
            "srn" : currentSrn,
            "videoUrl" : currentVideoUrl,
            "paused" : isPaused
        ]
        
        ShortFormAuthManager.shared.getAkAndUserJWTasDict().forEach { payload[$0.key] = $0.value }
        
        let request : JSRequest = ( .ON_VIDEO_PAUSED , payload )
        
        resultHandler?( .requestEvaluateJS([request]))
    }
    
    private func sendVideoDurationChanged(duration : Double) {
        
        guard let currentSrn = currentSrn,
              let currentVideoUrl = getCurrentVideoUrlByType() else { return }
        
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
              let currentVideoUrl = getCurrentVideoUrlByType() else { return }
        
        
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
    
    
    /**
     현재 동영상 타입에 따라 알아서 videoUrl가져오는 함수 
     */
    private func getCurrentVideoUrlByType() -> String? {
        if self.getIsYoutubePlayer() {
            return shortsModel?.cards?.first?.externalVideoUrl
        }
        else {
            return currentVideoUrl
        }
    }
    
    private func cancelLoadingIndicatorWorkItem() {
        if loadingIndicatorWorkItem != nil {
            loadingIndicatorWorkItem?.cancel()
            loadingIndicatorWorkItem = nil
            resultHandler?( .showLoadingIndicator(false) )
        }
    }
}
//MARK: Getter
extension ShortsCellReactor {
    func getShortsModel() -> SLShortsModel? {
        return self.shortsModel
    }
    
    func getWebViewUrl() -> URL? {
        return self.currentWebViewUrl
    }
    
    func getCurrentIndexPath() -> IndexPath {
        return self.currentIndexPath
    }
    
    func getIsYoutubePlayer() -> Bool {
        if let playerType = shortsModel?.cards?.first?.playerType, playerType == "YOUTUBE" {
            return true
        }
        else {
            return false
        }
    }
    
    func getYoutubeCurrentTime() -> Double? {
        return ytCommandReactor.getCurrenTime()
    }
}

extension ShortsCellReactor : ShortsCellYoutubeCommandReactorDelegate {
    func getIsActive() -> Bool {
        return self.isActive
    }
    
    func getCurrentOnViewIndexPath() -> IndexPath? {
        return delegate?.getCurrentOnViewIndexPath()
    }
}
