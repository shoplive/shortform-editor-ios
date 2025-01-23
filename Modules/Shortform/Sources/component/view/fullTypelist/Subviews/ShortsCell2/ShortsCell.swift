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
    func didFinishPlayingShorts(cell : ShortsCell, data : SLShortsModel?)
    func shortsCommand(name : String, payload : [String : Any]?)
    func didFinishLoadinWebView(indexPath : IndexPath)
    func getShortsListDataForV2ActivePage() -> [SLShortsModel]?
    func requestJSRequestForExternalWebView(request : (ShopLiveShortform.ShortsWebInterface.SdkToWeb, [String : Any]?))
    func requestCloseShortsDetailForHybrid(srn : String)
    func requestShowShortsDetailForHybrid(srn : String)
    func requestShowNewShortformFullScreen(bridgeModel : ShopLiveShortform.ShortsBridgeModel)
    func requestCloseShortform()
    func requestRemoveShortform(shortsId : String)
    func onExternalEmitEvent(webView : ShortsWebView?, name : String, payload : [String : Any]?)
    func setSnapShotForWindow(image : UIImage?)
    func getCurrentOnViewIndexPath() -> IndexPath?
    func requestSetCustomShortformForV2(cell : ShortsCell, shortsId : String)
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
    func sendActivePageStateToWeb(forceIsActive : Bool?, srn : String?, index : Int, shortsListModel : [SLShortsModel]?, previousSrn : String?)
    func getCurrentIndexPath() -> IndexPath
    func configureCell(webView : SLWebView,
                       youtubeWebView : SLWebView?,
                       model : SLShortsModel,
                       delegate : ShortsCellDelegate,
                       shortformDelegate : ShopLiveShortformReceiveHandlerDelegate?,
                       indexPath : IndexPath,
                       viewProvideype : ShortsCollectionBaseViewModel.ViewProvidedType,
                       shopliveSessionId : String?,
                       shortsMode : ShopLiveShortform.ShortsMode,
                       isLandScape : Bool,
                       isMute : Bool,
                       seekToOnInitial : ShortformCurrentTimeDTO?,
                       setShortsSingleDetailViewPayload : [String : Any]?,
                       preferredForwardBufferDuration : Double)
    func replaceShortsView(shortsView : ShortsView,indexPath : IndexPath)
    func setAppState(srn : String?, state : String)
    func takeSnapShotForWindow(srn : String?)
    
    func cleanUpMemory()
    func getCurrentVidoeTime() -> ShortformCurrentTimeDTO?
    func getCurrentShortsView() -> ShortsView
    func checkAttachedAndDetached(scrollView : UIView, coordinateView : UIView)
    /**
     preview -> detail 로 이동할때 cell이 로딩되기 전에 videoLayerGravity 셋하기위해서
     */
    func setVideoLayerGravityFromParentView()
    func sendJSRequestToWeb(sdkToWeb : ShopLiveShortform.ShortsWebInterface.SdkToWeb, payload : [String : Any]?)
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
    typealias ViewProvideType = ShortsCollectionBaseViewModel.ViewProvidedType
    typealias ShortsMode = ShopLiveShortform.ShortsMode
    
    
    static let cellId = "shortscell2Id"
   
    lazy private var shortsView : ShortsView = {
        let shortsView = ShortsView()
        shortsView.translatesAutoresizingMaskIntoConstraints = false
        return shortsView
    }()
    
    
    private var attachState : ShortFormCellAttachState?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        setLayout()
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    deinit {
        ShopLiveLogger.memoryLog("shortscell deinited")
    }
    
    func configureCell(webView : SLWebView,
                       youtubeWebView : SLWebView?,
                       model : SLShortsModel,
                       delegate : ShortsCellDelegate,
                       shortformDelegate : ShopLiveShortformReceiveHandlerDelegate?,
                       indexPath : IndexPath,
                       viewProvideype : ViewProvideType,
                       shopliveSessionId : String?,
                       shortsMode : ShortsMode,
                       isLandScape : Bool,
                       isMute : Bool,
                       seekToOnInitial : ShortformCurrentTimeDTO?,
                       setShortsSingleDetailViewPayload : [String : Any]?,
                       preferredForwardBufferDuration : Double) {
        self.attachState = nil
        shortsView.configureShortsView(webView: webView,
                                       youtubeWebView: youtubeWebView,
                                       model: model,
                                       delegate: delegate,
                                       shortformDelegate: shortformDelegate,
                                       indexPath: indexPath,
                                       viewProvideype: viewProvideype,
                                       shopliveSessionId: shopliveSessionId,
                                       shortsMode: shortsMode,
                                       isLandScape: isLandScape,
                                       isMute: isMute,
                                       seekToOnInitial: seekToOnInitial,
                                       setShortsSingleDetailViewPayload: setShortsSingleDetailViewPayload,
                                       preferredForwardBufferDuration: preferredForwardBufferDuration)
    }
    
    func replaceShortsView(shortsView: ShortsView,indexPath : IndexPath) {
        self.shortsView = shortsView
        bindShortsView()
        shortsView.action( .setIndexPath(indexPath) )
    }
    
}
//MARK: - bind shortsView
extension ShortsCell {
    func bindShortsView() {
        shortsView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .setShortformCellAttachedState(let attachState):
                self.onShortsViewSetShortformCellAttachState(state: attachState)
            }
        }
    }
    
    private func onShortsViewSetShortformCellAttachState(state : ShortFormCellAttachState) {
        self.attachState = state
    }
}
extension ShortsCell {
    private func setLayout() {
        self.addSubview(shortsView)
        
        NSLayoutConstraint.activate([
            shortsView.topAnchor.constraint(equalTo: self.topAnchor),
            shortsView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            shortsView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            shortsView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
//MARK: - interface functions
extension ShortsCell : ShortsCellInterface {
    func replay() {
        shortsView.playerViewAction(.replay)
    }
    
    func play(skipIfPaused: Bool) {
        shortsView.reactorAction( .play(skipIfPause: skipIfPaused) )
    }
    
    func pause() {
        shortsView.reactorAction( .pause )
    }
    
    func stop() {
        shortsView.reactorAction( .stop )
    }
    
    func setMute(_ mute: Bool) {
        shortsView.reactorAction( .setMute(mute) )
    }
    
    func setShortsMode(_ mode: ShopLiveShortform.ShortsMode) {
        shortsView.reactorAction( .setShortsMode(mode) )
    }
    
    func reloadWebView() {
        shortsView.webViewAction( .reload)
    }
    
    func isWebViewExist() -> Bool {
        return shortsView.isWebViewExist()
    }
    
    func reconfigureWebView() {
        shortsView.webViewAction( .reconnectWebView )
    }
    
    func handleDeviceRotation(isLandscape: Bool) {
        shortsView.reactorAction( .handleDeviceRotation(isLandscape: isLandscape) )
    }
    
    func sendActivePageStateToWeb(forceIsActive : Bool?, srn: String?, index: Int, shortsListModel: [SLShortsModel]?, previousSrn : String?) {
        shortsView.reactorAction( .sendActivePageState(forceIsActive: forceIsActive, srn: srn, index: index, shortsListModel: shortsListModel, previousSrn: previousSrn))
    }
    
    func getCurrentIndexPath() -> IndexPath {
        return shortsView.getCurrentIndexPath()
    }
    
    func setAppState(srn: String?, state: String) {
        shortsView.reactorAction( .setAppState(srn: srn, state: state) )
    }
    
    func takeSnapShotForWindow(srn: String?) {
        shortsView.reactorAction( .requestSnapShotForWindow(srn: srn) )
    }
    
    func cleanUpMemory() {
        shortsView.reactorAction( .invalidateGetYoutubeCurrentTimer )
    }
    
    func getCurrentVidoeTime() -> ShortformCurrentTimeDTO? {
        return shortsView.getShortformCurrentTimeDTO()
    }
    
    func getCurrentShortsView() -> ShortsView {
        return shortsView
    }
    
    func checkAttachedAndDetached(scrollView : UIView, coordinateView : UIView) {
        let convertedCellFrame = scrollView.convert(self.frame, to: coordinateView)
        let isIntersected = coordinateView.frame.intersects(convertedCellFrame)
        shortsView.action( .checkAttachedAndDetached(isIntersected: isIntersected, currentAttachState: attachState) )
    }
    
    func setVideoLayerGravityFromParentView() {
        shortsView.playerViewAction( .setVideoGravity )
    }
    
    func sendJSRequestToWeb(sdkToWeb: ShopLiveShortform.ShortsWebInterface.SdkToWeb, payload: [String : Any]?) {
        shortsView.webViewAction( .evaluateJavaScript(sdkToWeb: sdkToWeb, arguments: payload) )
    }
    
}
