//
//  ShortsCell2.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2/1/24.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon


protocol ShortsCellDelegate : NSObject {
    func didFinishPlayingShorts(cell : ShortsCell, data : ShopLiveShortform.ShortsModel?)
    func shortsCommand(name : String, payload : [String : Any]?)
    func didFinishLoadinWebView(indexPath : IndexPath)
    func getShortsListDataForV2ActivePage() -> [ShopLiveShortform.ShortsModel]?
    func requestJSRequestForExternalWebView(request : (ShopLiveShortform.ShortsWebInterface.SdkToWeb, [String : Any]?))
    func requestCloseShortsDetailForHybrid(srn : String)
    func requestShowShortsDetailForHybrid(srn : String)
    func requestShowNewShortformFullScreen(bridgeModel : ShopLiveShortform.ShortsBridgeModel)
    func requestCloseShortform()
    func onExternalEmitEvent(name : String, payload : [String : Any]?)
    func setSnapShotForWindow(image : UIImage?)
    func getCurrentOnViewIndexPath() -> IndexPath?
}


protocol ShortsCellInterface {
    func replay()
    func play(skipIfPaused : Bool)
    func pause()
    func stop()
    func setMute(_ mute : Bool)
    func setShortsMode(_ mode : ShopLiveShortform.ShortsMode)
    func reloadWebView()
    func isWebViewExist() -> Bool
    func reconfigureWebView()
    func handleDeviceRotation(isLandscape : Bool)
    func sendActivePageStateToWeb(forceIsActive : Bool?, srn : String?, index : Int, shortsListModel : [ShopLiveShortform.ShortsModel]?, previousSrn : String?)
    func getCurrentIndexPath() -> IndexPath
    func configureCell(webView : SLWebView,
                       youtubeWebView : SLWebView?,
                       model : ShopLiveShortform.ShortsModel,
                       delegate : ShortsCellDelegate,
                       indexPath : IndexPath,
                       viewProvideype : ShortsCollectionBaseViewModel.ViewProvidedType,
                       shopliveSessionId : String?,
                       shortsMode : ShopLiveShortform.ShortsMode,
                       isLandScape : Bool,
                       isMute : Bool,
                       seekToOnInitial : ShortformCurrentTimeDTO?,
                       setShortsSingleDetailViewPayload : [String : Any]?,
                       preferredForwardBufferDuration : Double)
    func setAppState(srn : String?, state : String)
    func takeSnapShotForWindow(srn : String?)
    
    func cleanUpMemory()
    func getCurrentVidoeTime() -> ShortformCurrentTimeDTO?
}

/**
 뷰 구성 hierarchy
 - ShortsCell
    - ShortsYoutubePlayerView
    - ShortsVideoPlayerView
        - AVPlayerLayer
    - ShortsWebView
        - SLWebView
 */
class ShortsCell : UICollectionViewCell {
    typealias SdkToWeb = ShopLiveShortform.ShortsWebInterface.SdkToWeb
    typealias JSRequest = (SdkToWeb, [String : Any])
    typealias ShortsModel = ShopLiveShortform.ShortsModel
    typealias ViewProvideType = ShortsCollectionBaseViewModel.ViewProvidedType
    typealias ShortsMode = ShopLiveShortform.ShortsMode
    
    
    static let cellId = "shortscell2Id"
    
    
    private var thumbnailImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var playerView : ShortsVideoPlayerView = {
        let view = ShortsVideoPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var youtubePlayerView : ShortsYoutubePlayerView = {
        let view = ShortsYoutubePlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var youtubePosterImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var webView : ShortsWebView = {
        let webView = ShortsWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private let reactor = ShortsCellReactor()
    
    lazy private var thumbnailVerticalWidthAnc : NSLayoutConstraint = {
        return thumbnailImageView.widthAnchor.constraint(equalTo: self.widthAnchor)
    }()
    
    lazy private var thumbnailHorizontalWidthAnc : NSLayoutConstraint = {
        let resolution = ShortFormConfigurationInfosManager.shared.shortsConfiguration.resolution
        let ratio = resolution.width / resolution.height
        return thumbnailImageView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: ratio)
    }()

    lazy private var playerViewVerticalWidthAnc : NSLayoutConstraint = {
        return playerView.widthAnchor.constraint(equalTo: self.widthAnchor)
    }()
    
    lazy private var playerViewHorizontalWidthAnc : NSLayoutConstraint = {
        let resolution = ShortFormConfigurationInfosManager.shared.shortsConfiguration.resolution
        let ratio = resolution.width / resolution.height
        return playerView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: ratio)
    }()
    
    lazy private var playerViewPadWidthAnc : NSLayoutConstraint = {
        return playerView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1)
    }()
    
    lazy private var youtubePlayerViewVerticalWidthAnc : NSLayoutConstraint = {
        return youtubePlayerView.widthAnchor.constraint(equalTo: self.widthAnchor)
    }()
    
    lazy private var youtubePlayerViewHorizontalWidthAnc : NSLayoutConstraint = {
        let resolution = ShortFormConfigurationInfosManager.shared.shortsConfiguration.resolution
        let ratio = resolution.width / resolution.height
        return youtubePlayerView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: ratio)
    }()
    
    lazy private var youtubePlayerViewPadWidhAnc : NSLayoutConstraint = {
        return youtubePlayerView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1)
    }()
    
    lazy private var youtubePosterVerticalWidthAnc : NSLayoutConstraint = {
        return youtubePosterImageView.widthAnchor.constraint(equalTo: self.widthAnchor)
    }()
    
    lazy private var youtubePosterHorizontalWidthAnc : NSLayoutConstraint = {
        let resolution = ShortFormConfigurationInfosManager.shared.shortsConfiguration.resolution
        let ratio = resolution.width / resolution.height
        return youtubePosterImageView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: ratio)
    }()
    
    weak var delegate : ShortsCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        reactor.delegate = self
        bindReactor()
        bindPlayerView()
        bindShortsYoutubePlayerView()
        bindShortsWebView()
        setLayout()
        
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    deinit {
        ShopLiveLogger.debugLog("shortscell deinited")
    }
    
    func configureCell(webView : SLWebView,
                       youtubeWebView : SLWebView?,
                       model : ShortsModel,
                       delegate : ShortsCellDelegate,
                       indexPath : IndexPath,
                       viewProvideype : ViewProvideType,
                       shopliveSessionId : String?,
                       shortsMode : ShortsMode,
                       isLandScape : Bool,
                       isMute : Bool,
                       seekToOnInitial : ShortformCurrentTimeDTO?,
                       setShortsSingleDetailViewPayload : [String : Any]?,
                       preferredForwardBufferDuration : Double) {
        
        playerView.action( .removePlayerStatusObserver )
        self.webView.indexPath = indexPath
        self.thumbnailImageView.image = nil
        playerView.action( .setPreferredForwardBufferDuration(preferredForwardBufferDuration) )
        playerView.action( .setShortsMode(shortsMode) )
        self.youtubePosterImageView.image = nil
        self.youtubePosterImageView.alpha = 1
        reactor.action( .setSetShortsSingleDetailViewPayload(setShortsSingleDetailViewPayload) )
        reactor.action( .setSeekToOnInitial(seekToOnInitial) )
        self.webView.action( .setWebView(webView) )
        self.youtubePlayerView.action( .setWebView(youtubeWebView) )
        self.youtubePlayerView.action( .setCurrentIndexPath(indexPath) )
        reactor.action( .setShortsModel(model) )
        reactor.action( .setIndexPath(indexPath) )
        reactor.action( .setViewProvideType(viewProvideype) )
        reactor.action( .setShopliveSessionId(shopliveSessionId) )
        reactor.action( .setShortsMode(shortsMode) )
        reactor.action( .handleDeviceRotation(isLandscape: isLandScape) )
        reactor.action( .setIsMuted(isMute) )
        self.delegate = delegate
        reactor.action( .initializeCell )
        
    }
    
}
//MARK: - bind ShortsCellReactor
extension ShortsCell {
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .setThumbnailImage(let image):
                self.onReactorSetThumbnail(image: image)
            case .setThumbnailRatio(let ratio):
                self.onReactorSetThumbnailRatio(ratio: ratio)
            case .setYoutubePosterImage(let image):
                self.onReactorSetYoutubePosterImage(image: image)
            case .hideYoutubePosterImage(let hide):
                self.onReactorHideYoutubePosterImage(hide: hide)
            case .requestEvaluateJS(let request):
                self.onReactorRequestEvaluateJS(request: request)
            case .requestYoutubePlayerEvaluateJS(let request):
                self.onReactorRequestYoutubePlayerEvaluateJS(request: request)
            case .requestEvaluateJSForExternalWebView(let request): // for hybrid
                self.onReactorRequestEvaluateJSforExternalWebView(request: request)
            case .requestVideoDuration:
                self.onReactorRequestVideoDuration()
            case .requestCloseShortsDetailForHybrid(let srn):
                self.onReactorRequestCloseShortsDetailForHybrid(srn: srn)
            case .requestShowShortsDetailForHybrid(let srn):
                self.onReactorRequestShowShortsDetailForHybrid(srn: srn)
            case .requestShowNewShortformFullScreen(let bridgeModel):
                self.onReactorRequestShowNewShortformFullScreen(bridgeModel: bridgeModel)
            case .requestCloseShortform:
                self.onReactorRequestCloseShortform()
            case .setWebViewIsScrollable(let isScrollable):
                self.onReactorSetWebViewIsScrollable(isScrollable: isScrollable)
            case .requestPlayVideo:
                self.onReactorRequestPlayVideo()
            case .requestPauseVideo:
                self.onReactorRequestPauseVideo()
            case .requestStopVideo:
                self.onReactorRequestStopVideo()
            case .requestReplayVideo:
                self.onReactorRequestReplayVideo()
            case .requestSeekToTime(let time):
                self.onReactorRequestSeekToTime(time: time)
            case .requestHideVideoPlayer(let hide):
                self.onReactorRequestHideVideoPlayer(hide : hide)
            case .requestHideYoutubePlayer(let hide):
                self.onReactorRequestHideYoutubePlayer(hide: hide)
            case .didFinishPlayingVideo:
                self.onReactorDidFinishPlayerVideo()
            case .requestSnapShot:
                self.onReactorRequestSnapShot()
            case .requestSnapShotForWindow:
                self.onReactorRequestSnapShortForWindow()
            case .setVideoPlayer(let videoUrl):
                self.onReactorSetVideoPlayer(videoURl: videoUrl)
            case .setWebViewIsHidden(let isHidden):
                self.onReactorSetWebViewIsHidden(isHidden: isHidden)
            case .invalidateLayout:
                self.onReactorInvalidateLayout()
            case .setVideoLayerGravity(let gravity):
                self.onReactorSetVideoGravity(gravity: gravity)
            case .setThumbnailImageContentMode(let contentMode):
                self.onReactorSetThumbnailContentMode(contentMode: contentMode)
            case .scrollToNextCell(let data):
                self.onReactorScrollToNextCell(data : data )
            }
        }
    }
    
    
    private func onReactorSetThumbnail(image : UIImage?) {
        self.thumbnailImageView.image = image
    }
    
    private func onReactorSetThumbnailRatio(ratio : CGSize?) {
        if let ratio = ratio , ratio.width != 0 , ratio.height != 0 {
            thumbnailHorizontalWidthAnc.isActive = false
            thumbnailImageView.removeConstraint(thumbnailHorizontalWidthAnc)
            thumbnailHorizontalWidthAnc = thumbnailImageView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: (ratio.width / ratio.height ))
            thumbnailVerticalWidthAnc.isActive = false
            thumbnailHorizontalWidthAnc.isActive = true
        }
        else {
            let resolution = ShortFormConfigurationInfosManager.shared.shortsConfiguration.resolution
            let ratio = resolution.width / resolution.height
            thumbnailHorizontalWidthAnc.isActive = false
            thumbnailImageView.removeConstraint(thumbnailHorizontalWidthAnc)
            thumbnailHorizontalWidthAnc = thumbnailImageView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: ratio)
            thumbnailHorizontalWidthAnc.isActive = UIDevice.current.userInterfaceIdiom == .pad || UIApplication.isLandscape_SL
            thumbnailVerticalWidthAnc.isActive = (UIDevice.current.userInterfaceIdiom == .pad || UIApplication.isLandscape_SL) ? false : true
        }
    }
    
    private func onReactorSetYoutubePosterImage(image : UIImage?) {
        self.youtubePosterImageView.image = image
    }
    
    private func onReactorHideYoutubePosterImage(hide : Bool) {
        if hide {
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.youtubePosterImageView.alpha = 0
            }
        }
        else {
            youtubePosterImageView.alpha = 1
        }
    }
    
    private func onReactorRequestEvaluateJS(request : [JSRequest] ) {
        request.forEach { request in
            webView.action( .evaluateJavaScript(request) )
        }
    }
    
    private func onReactorRequestYoutubePlayerEvaluateJS(request : [JSRequest]) {
        request.forEach { request in
            youtubePlayerView.action( .evaluateJavaScript(request) )
        }
    }
    
    private func onReactorRequestEvaluateJSforExternalWebView(request : [JSRequest]) {
        request.forEach { request in
            delegate?.requestJSRequestForExternalWebView(request: request)
        }
    }
    
    private func onReactorRequestVideoDuration() {
        let videoDuration = playerView.getVideoDuration()
        reactor.action(.setVideoDuration(videoDuration) )
    }
    
    private func onReactorRequestCloseShortsDetailForHybrid(srn : String) {
        delegate?.requestCloseShortsDetailForHybrid(srn: srn)
    }
    
    private func onReactorRequestShowShortsDetailForHybrid(srn : String) {
        delegate?.requestShowShortsDetailForHybrid(srn: srn)
    }
    
    private func onReactorRequestShowNewShortformFullScreen(bridgeModel : ShopLiveShortform.ShortsBridgeModel) {
        delegate?.requestShowNewShortformFullScreen(bridgeModel: bridgeModel)
    }
    
    private func onReactorRequestCloseShortform() {
        delegate?.requestCloseShortform()
    }
    
    private func onReactorSetWebViewIsScrollable(isScrollable : Bool) {
        webView.action( .setWebViewIsScrollable(isScrollable) )
    }
    
    private func onReactorRequestPlayVideo() {
        playerView.action( .play )
    }
    
    private func onReactorRequestPauseVideo() {
        playerView.action( .pause )
    }
    
    private func onReactorRequestStopVideo() {
        playerView.action( .stop )
    }
    
    private func onReactorRequestReplayVideo() {
        playerView.action( .replay )
    }
    
    private func onReactorRequestSeekToTime(time : CMTime) {
        playerView.action( .seekTo(time) )
    }
    
    private func onReactorRequestHideVideoPlayer(hide : Bool) {
        playerView.isHidden = hide
    }
    
    private func onReactorRequestHideYoutubePlayer(hide : Bool) {
        youtubePlayerView.isHidden = hide
    }
    
    private func onReactorDidFinishPlayerVideo() {
        delegate?.didFinishPlayingShorts(cell: self, data: reactor.getShortsModel())
    }
    
    private func onReactorRequestSnapShot() {
        playerView.action( .requestSnapShot )
    }
    
    private func onReactorRequestSnapShortForWindow() {
        playerView.action( .requestSnapShotForWindow )
    }
    
    private func onReactorSetVideoPlayer(videoURl : URL) {
        playerView.action( .initPlayerView(videoURl) )
    }
    
    private func onReactorSetWebViewIsHidden(isHidden : Bool) {
        self.webView.isHidden = isHidden
    }
    
    private func onReactorInvalidateLayout() {
        self.invalidateLayout()
    }
    
    private func onReactorSetVideoGravity(gravity : AVLayerVideoGravity) {
        playerView.action( .setVideoGravity(gravity) )
    }
    
    private func onReactorSetThumbnailContentMode(contentMode : UIView.ContentMode) {
        self.thumbnailImageView.contentMode = contentMode
    }
    
    private func onReactorScrollToNextCell(data : ShopLiveShortform.ShortsModel?) {
        delegate?.didFinishPlayingShorts(cell: self, data: data)
    }
    
}
//MARK: - bind playerView
extension ShortsCell {
    private func bindPlayerView() {
        playerView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .snapShotComplete(let image):
                self.onPlayerViewSnapShotComplete(image: image)
            case .snapShotCompleteForWindow(let image):
                self.onPlayerViewSnapShotCompleteForWindow(image: image)
            case .videoTimeUpdated(let time):
                self.onPlayerViewVideoTimeUpdated(time: time)
            case .videoDidPlayToEnd:
                self.onPlayerViewVideoDidPlayToEnd()
            case .playerItemStatusChanged(let status):
                self.onPlayerViewPlayerItemStatusChanged(status: status)
            case .timeControlStatusChanged(let status):
                self.onPlayerViewTimeControlStatusChanged(status: status)
            case .playerItemSetComplete:
                self.onPlayerViewPlayerItemSetComplete()
            case .requestHideSnapShotFormWindow:
                self.onPlayerRequestHideSnapshotForWindow()
            }
        }
    }
    
    private func onPlayerViewSnapShotComplete(image : UIImage?) {
        self.thumbnailImageView.image = image
    }
    
    private func onPlayerViewSnapShotCompleteForWindow(image : UIImage?) {
        self.delegate?.setSnapShotForWindow(image: image)
    }
    
    private func onPlayerViewVideoTimeUpdated(time : CMTime) {
        reactor.action( .videoTimeUpdated(time) )
    }
    
    private func onPlayerViewVideoDidPlayToEnd() {
        reactor.action( .didEndPlayingVideo )
    }
    
    private func onPlayerViewPlayerItemStatusChanged(status : AVPlayerItem.Status) {
        reactor.action( .onChangedShortsItemPlayerItemStatus(status) )
    }
    
    private func onPlayerViewTimeControlStatusChanged(status : AVPlayer.TimeControlStatus) {
        reactor.action( .onChangedShortsItemTimeControlStatus(status) )
    }
    
    private func onPlayerViewPlayerItemSetComplete() {
        reactor.action( .requestSeekToOnInital )
    }
    
    private func onPlayerRequestHideSnapshotForWindow() {
        self.delegate?.setSnapShotForWindow(image: nil)
    }
    
    
}
//MARK: - bind ShortsWebView
extension ShortsCell {
    private func bindShortsWebView() {
        webView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .didFinishLoadingWebView:
                self.onWebViewDidFinishLoadingWebView()
            case .handleWebInterface(let webReceivedCommand):
                self.onWebViewHandleWebInterface(name: webReceivedCommand.name, payload: webReceivedCommand.payload)
            case .onExternEmitEvent(let webReceivedCommand):
                self.onWebViewOnExternalEmitEvent(name: webReceivedCommand.0, payload: webReceivedCommand.1)
            case .shortsCommand(let shortsCommand):
                self.onWebviewOnShortsCommand(name: shortsCommand.0, payload: shortsCommand.1)
                break
            }
        }
    }
    
    private func onWebViewDidFinishLoadingWebView() {
        delegate?.didFinishLoadinWebView(indexPath: reactor.getCurrentIndexPath())
    }
    
    private func onWebViewHandleWebInterface(name : ShopLiveShortform.ShortsWebInterface.WebToSdk, payload : [String : Any]?) {
        reactor.action( .webToSdk(name: name, payload: payload) )
        
    }
    
    private func onWebViewOnExternalEmitEvent(name : String, payload : [String : Any]?) {
        // 고객사에게 넘겨주는 이벤트 ShortsReceiveInterface로 넘겨줘야 함 원래는 그냥 안쪽에서 바로 noti이용해서 전달 하고 있었음
        delegate?.onExternalEmitEvent(name: name, payload: payload)
    }
    
    private func onWebviewOnShortsCommand(name : String, payload : [String : Any]? ) {
        delegate?.shortsCommand(name: name, payload: payload)
    }
}
//MARK: - bind ShortsYoutubePlayerView
extension ShortsCell {
    private func bindShortsYoutubePlayerView() {
        youtubePlayerView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .handleWebInterface(let webReceivedCommand):
                self.onWebViewHandleWebInterface(name: webReceivedCommand.name, payload: webReceivedCommand.payload)
            }
        }
    }
}
//MARK: - layout
extension ShortsCell {
    private func setLayout() {
        self.addSubview(thumbnailImageView)
        self.addSubview(playerView)
        self.addSubview(youtubePlayerView)
        self.addSubview(youtubePosterImageView)
        self.addSubview(webView)
        
        if UIDevice.current.userInterfaceIdiom == .pad || UIScreen.isLandscape_SL {
            thumbnailHorizontalWidthAnc.isActive = true
            thumbnailVerticalWidthAnc.isActive = false
            
            playerViewHorizontalWidthAnc.isActive = false
            playerViewVerticalWidthAnc.isActive = false
            playerViewPadWidthAnc.isActive = true
            
            youtubePlayerViewHorizontalWidthAnc.isActive = false
            youtubePlayerViewVerticalWidthAnc.isActive = false
            youtubePlayerViewPadWidhAnc.isActive = true
            
//
//            if UIDevice.current.userInterfaceIdiom == .pad {
//                playerViewHorizontalWidthAnc.isActive = false
//                playerViewVerticalWidthAnc.isActive = false
//                playerViewPadWidthAnc.isActive = true
//                
//                youtubePlayerViewHorizontalWidthAnc.isActive = false
//                youtubePlayerViewVerticalWidthAnc.isActive = false
//                youtubePlayerViewPadWidhAnc.isActive = true
//            }
//            else {
//                playerViewHorizontalWidthAnc.isActive = true
//                playerViewVerticalWidthAnc.isActive = false
//                playerViewPadWidthAnc.isActive = false
//                
//                youtubePlayerViewHorizontalWidthAnc.isActive = true
//                youtubePlayerViewVerticalWidthAnc.isActive = false
//                yo`utubePlayerViewPadWidhAnc.isActive = false
//            }
            
            
            youtubePosterVerticalWidthAnc.isActive = true
            youtubePosterHorizontalWidthAnc.isActive = false
            
        }
        else {
            thumbnailHorizontalWidthAnc.isActive = false
            thumbnailVerticalWidthAnc.isActive = true

            playerViewHorizontalWidthAnc.isActive = false
            playerViewVerticalWidthAnc.isActive = true
            
            youtubePlayerViewHorizontalWidthAnc.isActive = false
            youtubePlayerViewVerticalWidthAnc.isActive = true
            
            youtubePosterVerticalWidthAnc.isActive = false
            youtubePosterHorizontalWidthAnc.isActive = true
        }
        
        NSLayoutConstraint.activate([
            thumbnailImageView.heightAnchor.constraint(equalTo: self.heightAnchor),
            thumbnailImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            thumbnailImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            playerView.heightAnchor.constraint(equalTo: self.heightAnchor),
            playerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            playerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            youtubePlayerView.heightAnchor.constraint(equalTo: self.heightAnchor),
            youtubePlayerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            youtubePlayerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            youtubePosterImageView.heightAnchor.constraint(equalTo: self.heightAnchor),
            youtubePosterImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            youtubePosterImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            webView.topAnchor.constraint(equalTo: self.topAnchor),
            webView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
    }
    
    private func invalidateLayout() {
        if UIDevice.current.userInterfaceIdiom == .pad || UIScreen.isLandscape_SL {
            thumbnailHorizontalWidthAnc.isActive = true
            thumbnailVerticalWidthAnc.isActive = false
            playerViewHorizontalWidthAnc.isActive = true
            playerViewVerticalWidthAnc.isActive = false
            youtubePlayerViewHorizontalWidthAnc.isActive = true
            youtubePlayerViewVerticalWidthAnc.isActive = false
            youtubePosterVerticalWidthAnc.isActive = true
            youtubePosterHorizontalWidthAnc.isActive = false
        }
        else {
            thumbnailHorizontalWidthAnc.isActive = false
            thumbnailVerticalWidthAnc.isActive = true
            playerViewHorizontalWidthAnc.isActive = false
            playerViewVerticalWidthAnc.isActive = true
            youtubePlayerViewHorizontalWidthAnc.isActive = false
            youtubePlayerViewVerticalWidthAnc.isActive = true
            youtubePosterVerticalWidthAnc.isActive = false
            youtubePosterHorizontalWidthAnc.isActive = true
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.layoutIfNeeded()
        }
    }
    
}
extension ShortsCell : ShortsCellReactorDelegate {
    /**
     디버그용도로써 실사용처가 없음
     */
    func  getCurrentOnViewIndexPath() -> IndexPath? {
        return delegate?.getCurrentOnViewIndexPath()
    }
}
//MARK: - interface functions
extension ShortsCell : ShortsCellInterface {
    func replay() {
        playerView.action( .replay )
    }
    
    func play(skipIfPaused: Bool) {
        reactor.action( .play(skipIfPaused: skipIfPaused))
    }
    
    func pause() {
        reactor.action( .pause )
    }
    
    func stop() {
        reactor.action( .stop )
    }
    
    func setMute(_ mute: Bool) {
        reactor.action( .setIsMuted(mute) )
        playerView.action( .setMute(mute) )
    }
    
    func setShortsMode(_ mode: ShopLiveShortform.ShortsMode) {
        reactor.action( .setShortsMode(mode) )
    }
    
    func reloadWebView() {
        webView.action( .reloadWebView(reactor.getWebViewUrl()) )
    }
    
    func isWebViewExist() -> Bool {
        return webView.getIsWebViewExist()
    }
    
    func reconfigureWebView() {
        webView.action( .reconnectWebView )
    }
    
    func handleDeviceRotation(isLandscape: Bool) {
        reactor.action( .handleDeviceRotation(isLandscape: isLandscape) )
    }
    
    func sendActivePageStateToWeb(forceIsActive : Bool?, srn: String?, index: Int, shortsListModel: [ShopLiveShortform.ShortsModel]?, previousSrn : String?) {
        guard let srn = srn else { return }
        reactor.action( .sendActivePageState(forceIsActive: forceIsActive, srn: srn, shortsList: shortsListModel,previousSrn: previousSrn) )
    }
    
    func getCurrentIndexPath() -> IndexPath {
        return reactor.getCurrentIndexPath()
    }
    
    func setAppState(srn: String?, state: String) {
        reactor.action( .setAppState(srn: srn, state: state) )
    }
    
    func takeSnapShotForWindow(srn: String?) {
        reactor.action( .requestSnapShotForWindow(srn) )
    }
    
    func cleanUpMemory() {
        reactor.action( .invalidateGetYoutubeCurrentTimer )
    }
    
    func getCurrentVidoeTime() -> ShortformCurrentTimeDTO? {
        if reactor.getIsYoutubePlayer() {
            return .youtube(reactor.getYoutubeCurrentTime())
        }
        else {
            return .shoplive(playerView.getCurrentCMTime())
        }
    }
}
