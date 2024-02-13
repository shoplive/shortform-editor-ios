//
//  ShortsView.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/26/23.
//

import Foundation
import ShopLiveSDKCommon
import UIKit
import WebKit
import AVKit

protocol ShortsViewDelegate: AnyObject {
    func shortsCommand(name: String, payload: [String: Any]?)
    func didFinishedPlayingShorts(item: ShopLiveShortform.ShortsModel)
    func didFinishLoadingWebView()
    func getShortsListDataForV2ActivePage() -> [ShopLiveShortform.ShortsModel]?
}

extension ShopLiveShortform {
    
    class ShortsView: ShopLiveWindowItemView, SLShortsWindowItemViewable {
        var itemView: ShopLiveWindowItemView {
            return self
        }
        
        class ViewModel {
            var cvIndexPathRow: Int = 0
            
            var currentIndex: Int = 0
            
            var isLoop: Bool = false
            
            var listIndex: Int?
            
            var isPaused: Bool = false
            var pausedByUser: Bool = false
            
            var isLast: Bool {
                guard validateCards.count > 1 else {
                    return true
                }
                
                return (validateCards.count - 1) == currentIndex
            }
            
            private var shortsId: String? {
                guard let sId = shorts.shortsId else { return nil }
                return "\(sId)"
            }
            
            var isOverlayHidden: Bool {
                return shortsMode == .preview
            }
            
            var currentVideoUrl: String? {
                return self.shorts.cards?[safe: currentIndex]?.videoUrl
            }
            
            var currentOverlayUrl : URL?
            var currentViewProvideType : ShortsCollectionBaseViewModel.ViewProvidedType = .window
            
            
            var isMuted: Bool = false
            var isActive: Bool = false
            var reservedIsActiveForEnteringBackground : Bool?
            
            private(set) var shorts: ShortsModel
            private(set) var cards: [Card] = []
            var validateCards: [Card] {
                cards.filter { $0.validate() }
            }
            var shortsMode: ShortsMode
            
            var webViewCommands : [(ShortsWebInterface.SdkToWeb,[String : Any])] = []
            var isWebViewLoaded : Bool?
            var isReadyToPlay : Bool = false
            var shopliveSessionId : String?
            
            func getCardIndex(_ card: Card) -> Int? {
                validateCards.firstIndex(where: { $0 == card })
            }
            
            init(shorts: ShortsModel, shortsMode: ShortsMode, contentIndex: Int,currentOverlayUrl : URL?,currentViewProvideType : ShortsCollectionBaseViewModel.ViewProvidedType,shopliveSessionId : String?) {
                webViewCommands = []
                isWebViewLoaded = nil
                isReadyToPlay = false
                self.shopliveSessionId = shopliveSessionId
                self.currentOverlayUrl = currentOverlayUrl
                self.currentViewProvideType = currentViewProvideType
                self.shorts = shorts
                self.shortsMode = shortsMode
                self.cvIndexPathRow = contentIndex
                self.appendCards(cards: shorts.cards)
                
            }
            
            private func appendCards(cards: [CardModel]?) {
                guard let cardModels = cards else { return }
                
                cardModels.forEach { cm in
                    if let card = cm.getCard(shortsMode: shortsMode) {
                        self.cards.append(card)
                    }
                }
            }
        }
        
        private let appstateObserver = AppStateObserver()
        
        private var cardViews: [CardView]? = []
        
        weak var delegate: ShortsViewDelegate?
        
        private lazy var cardContrainer: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private weak var overlayView: SLWebView?
        
        var viewModel: ViewModel
        
        init(webView : SLWebView, shorts: ShortsModel, shortsMode: ShopLiveShortform.ShortsMode, contentIndex: Int,currentOverlayUrl : URL?,currentViewProvideType : ShortsCollectionBaseViewModel.ViewProvidedType,shopliveSessionId : String?) {
            viewModel = ViewModel(shorts: shorts, shortsMode: shortsMode, contentIndex: contentIndex,currentOverlayUrl: currentOverlayUrl,currentViewProvideType: currentViewProvideType,shopliveSessionId: shopliveSessionId)
            super.init(frame: .zero)
            layout()
            attributes()
            bindView()
            bindData()
            setUpOverlayWebView(webView : webView)
            self.clipsToBounds = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
            teardownObserver()
            overlayView?.slWebResponseDelegate = nil
            overlayView?.webViewNavigationDelegate = nil
            overlayView = nil
            cardViews?.removeAll()
            cardViews = nil
            
        }
        
        func invalidateLayout(){
            cardViews?.forEach({ cardview in
                cardview.invalidateLayout()
            })
        }
        
        func layout() {
            self.backgroundColor = .black
            self.addSubview(cardContrainer)
            cardContrainer.fit_SL()
        }
        
        func attributes() {
            appstateObserver.delegate = self
        }
        
        func bindView() {
            validateAndSetUpCards()
        }
        
        private func validateAndSetUpCards(){
            cardViews?.removeAll()
            viewModel.validateCards.forEach { card in
                switch card.type {
                case .image:
                    break
                case .video:
                    if case let Card.VideoCard(video: videoData) = card  {
                        let vCard = VideoCardView(cardData: videoData, shortsMode: viewModel.shortsMode)
                        vCard.delegate = self
                        cardViews?.append(vCard)
                    }
                    break
                }
            }
            
            self.cardViews?.forEach {
                self.cardContrainer.addSubview($0)
                $0.fitToParent_SL()
            }
            setCurrentCard(index: 0)
        }
        
        func bindData() {
            setupObserver()
            sendWebToSafeareaInfo()
        }
        
        private func setupObserver() {
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: Notification.Name("takeSnapshot"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("modeChange"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("onChangedUserAuthSdk"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("activePage"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("onChangedAppState"), object: nil)
        }
        
        private func teardownObserver() {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("takeSnapshot"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("modeChange"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("onChangedUserAuthSdk"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("activePage"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("onChangedAppState"), object: nil)
            NotificationCenter.default.removeObserver(self)
        }
        
        @objc func handleNotification(_ notification: Notification) {
            switch notification.name {
            case Notification.Name("onChangedAppState"):
                guard let currentSrn = notification.userInfo?["srn"] as? String,
                      let srn = self.viewModel.shorts.srn,
                      currentSrn == srn,
                      let state = notification.userInfo?["state"] as? String else { return }
                self.sendWebToAppState(state: state)
                break
            case Notification.Name("modeChange"):
                if let mode = notification.userInfo?["mode"] as? ShopLiveShortform.ShortsMode {
                    self.setShortsMode(mode)
                }
                break
            case Notification.Name("onChangedUserAuthSdk"):
                let userJWT = notification.userInfo?["userJWT"] as? String
                let guestUid = notification.userInfo?["guestUid"] as? String
                self.sendChangedUserAuthSdk(userJWT: userJWT, guestUid: guestUid)
                break
            case Notification.Name("activePage"):
                self.handleSendActivePag(data: notification.userInfo as? [String : Any])
                break
            case Notification.Name("takeSnapshot"):
                guard let currentSrn = notification.userInfo?["srn"] as? String,
                      let shortsSrn = self.viewModel.shorts.srn,
                      currentSrn == shortsSrn,
                      let currentCardView: ShopLiveShortform.CardView = cardViews?[safe: viewModel.currentIndex] else { return }
                
                currentCardView.getSnapshot(completion: { image in
                    NotificationCenter.default.post(Notification(name: Notification.Name("setWindowSnapshot"), object: nil, userInfo: ["snapshot": image]))
                })
                break
            default:
                break
            }
        }
        
        private func handleSendActivePag(data : [String : Any]?) {
            guard let srn = data?["srn"] as? String,
                  let index = data?["index"] as? Int else { return }
            
            self.sendToWebOnChangedSessionInfo(shopliveSessionId: viewModel.shopliveSessionId, sessionId: "")
            
            if let shortsList = data?["shortsList"] as? [ShortsModel] {
                if let currentSrn = self.viewModel.shorts.srn, currentSrn == srn {
                    self.sendV2ActiveSatePage(isActive: true, srn: srn, index: index,shortsList: shortsList)
                }
                else {
                    self.viewModel.isActive = false
                    self.sendV2ActiveSatePage(isActive: false, srn: self.viewModel.shorts.srn ,
                                              index: self.viewModel.cvIndexPathRow, shortsList: shortsList)
                    seekToZeroOnPageInActive()
                }
            }
            else {
                if let currentSrn = self.viewModel.shorts.srn, currentSrn == srn {
                    self.sendActiveStatePage(isActive: true, srn: srn, index: index)
                }
                else {
                    self.viewModel.isActive = false
                    self.sendActiveStatePage(isActive: false, srn: self.viewModel.shorts.srn ,
                                             index: self.viewModel.cvIndexPathRow)
                    seekToZeroOnPageInActive()
                }
            }
        }
        
        private func seekToZeroOnPageInActive() {
            if let videoCard = self.cardViews?[safe : viewModel.currentIndex] as? VideoCardView,
               let currentTime = videoCard.getCurrentTime(), currentTime >= 1 && viewModel.isActive == false {
                videoCard.seekTo(time: .zero)
            }
        }
        
        func play(_ skipIfPaused: Bool = false) {
            updateOverlayDelegate()
            
            if skipIfPaused {
                if viewModel.isPaused && viewModel.pausedByUser {
                    return
                }
            }
            
            guard viewModel.validateCards.count > 0 else {
                return
            }
            viewModel.pausedByUser = false
            sendWebToMuteState()
            cardViews?[safe: viewModel.currentIndex]?.play()
        }
        
        func pause() {
            viewModel.pausedByUser = true
            cardViews?[safe: viewModel.currentIndex]?.pause()
        }
        
        func stop() {
            viewModel.pausedByUser = true
            cardViews?[safe: viewModel.currentIndex]?.stop()
        }
        
        func replay() {
            guard viewModel.validateCards.count > 0 else {
                return
                
            }
            
            viewModel.pausedByUser = false
            sendWebToMuteState()
            cardViews?[safe: viewModel.currentIndex]?.replay()
        }
        
        func setMute(_ mute: Bool) {
            cardViews?.forEach { $0.setMute(mute) }

            guard let videoUrl = viewModel.currentVideoUrl else {
                return
            }

            viewModel.isMuted = mute

            let payload: [String: Any] = [
                "srn": viewModel.shorts.srn ?? "",
                "videoUrl": videoUrl,
                "muted": mute
            ]
            
            if viewModel.isWebViewLoaded ?? true == false {
                viewModel.webViewCommands.append((.ON_VIDEO_MUTED, payload))
                return
            }

            overlayView?.sendShortsEvent(event: ShortsWebInterface.SdkToWeb.ON_VIDEO_MUTED.rawValue, parameter: payload, completion: {})
            sendWebToSafeareaInfo()
        }
        
        func reloadWebview() {
            if let overlayView = self.overlayView {
                self.overlayView?.slWebResponseDelegate = self
                self.overlayView?.isHidden = viewModel.isOverlayHidden
                if self.subviews.filter({$0.isKind(of: SLWebView.self)}).count == 0 {
                    self.addSubview(overlayView)
                    overlayView.fit_SL()
                }
                overlayView.slWebResponseDelegate = self
                overlayView.webViewNavigationDelegate = self
                overlayView.reload()
                sendWebToSafeareaInfo()
            }
            else if let overlayUrl = viewModel.currentOverlayUrl {
                let webView = SLWebView()
                webView.load(URLRequest(url: overlayUrl))
                self.setUpOverlayWebView(webView: webView)
            }
        }
        
        func isWebViewExist() -> Bool {
            if let overlayWebView = self.overlayView {
                if let superview = overlayWebView.superview, superview === self {
                    return true
                }
                else {
                    return false
                }
            }
            else {
                return false
            }
        }

        
        func setShortsMode(_ mode: ShortsMode) {
            viewModel.shortsMode = mode
            overlayView?.isHidden = viewModel.isOverlayHidden
            cardViews?.forEach {
                $0.setShortsMode(mode: mode)
            }
        }
        
        private func sendChangedUserAuthSdk(userJWT: String?, guestUid: String?) {

            if let userJWT = userJWT {
                ShortFormAuthManager.shared.setUserJWT(userJWT: userJWT)
            }
            
            if let guestUid = guestUid {
                ShortFormAuthManager.shared.setGuestUid(guestUid: guestUid)
            }
            
            let payLoad : [String : Any] = ShortFormAuthManager.shared.getAkAndUserJWTasDict()
            
            overlayView?.sendShortsEvent(event: ShortsWebInterface.SdkToWeb.ON_CHANGED_USER_AUTH_SDK.rawValue, parameter: payLoad) {}
            
        }
        
        private func updateOverlayDelegate() {
            overlayView?.slWebResponseDelegate = self
        }
        
        private func setUpOverlayWebView(webView : SLWebView) {
            self.overlayView = webView
            webView.slWebResponseDelegate = self
            webView.webViewNavigationDelegate = self
            self.addSubview(webView)
            webView.fit_SL()
            self.bringSubviewToFront(webView)
            webView.isHidden = viewModel.isOverlayHidden
            sendWebToSafeareaInfo()
        }
        
        private func setCurrentCard(index: Int) {
            if let cardView = cardViews?[safe: index] {
                self.cardContrainer.bringSubviewToFront(cardView)
            }
        }
        
        private func sendWebToMuteState() {
            guard let videoUrl = viewModel.currentVideoUrl else {
                return
            }
                    
            let payload: [String: Any] = [
                "srn": viewModel.shorts.srn ?? "",
                "videoUrl": videoUrl,
                "muted": viewModel.isMuted
            ]
            
            if let isWebViewLoaded = viewModel.isWebViewLoaded, isWebViewLoaded == false {
                viewModel.webViewCommands.append((.ON_VIDEO_MUTED, payload))
            }
            
            overlayView?.sendShortsEvent(event: ShopLiveShortform.ShortsWebInterface.SdkToWeb.ON_VIDEO_MUTED.rawValue, parameter: payload) {}
        }
        
        private func sendWebToAppState(state: String) {
            let payload: [String: Any] = [
                "state": state
            ]
            
            overlayView?.sendShortsEvent(event: ShopLiveShortform.ShortsWebInterface.SdkToWeb.ON_CHANGED_APPSTATE.rawValue, parameter: payload) {}
        }
        
        func sendWebToSafeareaInfo() {
            var payload : [String : Any] = [: ]
            if viewModel.currentViewProvideType == .view {
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
            
            if let isWebViewLoaded = viewModel.isWebViewLoaded, isWebViewLoaded == false {
                viewModel.webViewCommands.append((.ON_CHANGED_SAFE_AREA, payload))
            }
            
            overlayView?.sendShortsEvent(event: ShortsWebInterface.SdkToWeb.ON_CHANGED_SAFE_AREA.rawValue, parameter: payload) {}
        }
        
        private func sendActiveStatePage(isActive: Bool, srn: String?, index: Int) {
            guard self.viewModel.shortsMode == .detail else { return }
            guard let srn = srn else { return }
            let payload: [String: Any] = [
                "srn": srn,
                "index": index
            ]
            self.viewModel.isActive = isActive
            overlayView?.sendShortsEvent(event: isActive ? ShortsWebInterface.SdkToWeb.ON_SHORTFORM_DETAIL_PAGE_ACTIVE.rawValue : ShortsWebInterface.SdkToWeb.ON_SHORTFORM_DETAIL_PAGE_INACTIVE.rawValue, parameter: payload) {}
        }
        
        private func sendV2ActiveSatePage(isActive : Bool, srn : String?, index : Int, shortsList : [ShortsModel]) {
            guard self.viewModel.shortsMode == .detail else { return }
            guard let srn = srn else { return }
            
            do {
                let shortsListJson = try shortsList.toDictionary_SL().toJSONString_SL()
                let payload: [String: Any] = [
                    "srn": srn,
                    "index": index,
                    "shortsList" : shortsListJson ?? "[]"
                ]
                self.viewModel.isActive = isActive
                overlayView?.sendShortsEvent(event: isActive ? ShortsWebInterface.SdkToWeb.ON_SHORTFORM_DETAIL_PAGE_ACTIVE.rawValue : ShortsWebInterface.SdkToWeb.ON_SHORTFORM_DETAIL_PAGE_INACTIVE.rawValue, parameter: payload) {}
            }
            catch(_) {
                self.sendActiveStatePage(isActive: isActive, srn: srn, index: index)
            }
            
        }
        
        private func sendWebToVersionInfo() {
            
            let payload: [String: Any] = [
                "appVersion": UIApplication.appVersion_SL(),
                "sdkVersion": ShopLiveShortform.sdkVersion
            ]
            
            if let isWebViewLoaded = viewModel.isWebViewLoaded, isWebViewLoaded == false {
                viewModel.webViewCommands.append((.SEND_CLIENT_VERSION, payload))
            }
            
            overlayView?.sendShortsEvent(event: ShortsWebInterface.SdkToWeb.SEND_CLIENT_VERSION.rawValue, parameter: payload) {}
        }
        
        func sendToWebOnChangedSessionInfo(shopliveSessionId : String?, sessionId : String) {
            
            let payload : [String : Any] = [
                "shopLiveSessionId" : shopliveSessionId,
                "sessionId" : sessionId
            ]
            
            if let isWebViewLoaded = viewModel.isWebViewLoaded, isWebViewLoaded == false {
                viewModel.webViewCommands.append( (.ON_CHANGED_SESSION_INFO, payload) )
            }
            
            overlayView?.sendShortsEvent(event: ShortsWebInterface.SdkToWeb.ON_CHANGED_SESSION_INFO.rawValue, parameter: payload) { }
        }
        
        private func sendWebToOnVideoLooped() {
            let payload : [String : Any] = [
                "videoUrl" : viewModel.currentVideoUrl,
                "srn" : viewModel.shorts.srn
            ]
            
            if let isWebViewLoaded = viewModel.isWebViewLoaded, isWebViewLoaded == false {
                viewModel.webViewCommands.append(( .ON_VIDEO_LOOPED, payload ))
            }
            
            overlayView?.sendShortsEvent(event: ShortsWebInterface.SdkToWeb.ON_VIDEO_LOOPED.rawValue, parameter: payload) { }
        }
    }
}
extension ShopLiveShortform.ShortsView : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        viewModel.isWebViewLoaded = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewModel.isWebViewLoaded = true
        delegate?.didFinishLoadingWebView()
        for commands in viewModel.webViewCommands {
            overlayView?.sendShortsEvent(event: commands.0.rawValue, parameter: commands.1) { }
        }
        if let card = cardViews?.first as? ShopLiveShortform.VideoCardView, let duration = card.getVideoDuration(),let videoUrl = viewModel.currentVideoUrl {
            self.onVideoDurationChanged(duration: duration, videoUrl: videoUrl)
        }
        
        if viewModel.isReadyToPlay == false && viewModel.isActive == true {
            validateAndSetUpCards()
        }
        viewModel.webViewCommands.removeAll()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        viewModel.isWebViewLoaded = false
    }
}

extension ShopLiveShortform.ShortsView: SLShortsCardViewDelegate {
    func onChangedShortsItemPlayStatus(status: ShopLiveShortform.ItemPlayStatus, videoUrl: String) {
        
        var isPaused = status == .paused
        var payload: [String: Any] = [
            "srn": viewModel.shorts.srn ?? "",
            "videoUrl": videoUrl,
            "paused": isPaused
        ]
        
        viewModel.isPaused = isPaused
        
        if status == .playing {
            if  let card = cardViews?.first as? ShopLiveShortform.VideoCardView, let duration = card.getVideoDuration() {
                self.onVideoDurationChanged(duration: duration, videoUrl: videoUrl)
            }
        }
        
        ShortFormAuthManager.shared.getAkAndUserJWTasDict().forEach { payload[$0.key] = $0.value }
        
        if let isWebViewLoaded = viewModel.isWebViewLoaded, isWebViewLoaded == false {
            viewModel.webViewCommands.append((.ON_VIDEO_PAUSED, payload))
        }
        
        
        overlayView?.sendShortsEvent(event: ShopLiveShortform.ShortsWebInterface.SdkToWeb.ON_VIDEO_PAUSED.rawValue, parameter: payload) {}
    }
    
    func onVideoDurationChanged(duration: Float64, videoUrl: String) {
        // 웹으로 현재 아이템 duration time send
        let durationValue: Float64 = (round(1000 * duration) / 1000)
        
        var payload: [String: Any] = [
            "srn": viewModel.shorts.srn ?? "",
            "videoUrl": videoUrl,
            "duration": durationValue
        ]
        ShortFormAuthManager.shared.getAkAndUserJWTasDict().forEach { payload[$0.key] = $0.value }
        
        if let isWebViewLoaded = viewModel.isWebViewLoaded, isWebViewLoaded == false {
            viewModel.webViewCommands.append((.ON_VIDEO_DURATION_CHANGED, payload))
        }
        
        overlayView?.sendShortsEvent(event: ShopLiveShortform.ShortsWebInterface.SdkToWeb.ON_VIDEO_DURATION_CHANGED.rawValue, parameter: payload) {}
    }
    
    func onVideoTimeUpdated(time: Float64, videoUrl: String) {
        // 웹으로 현재 아이템 play time send
        let timeValue: Float64 = (round(1000 * time) / 1000)
        var payload: [String: Any] = [
            "srn": viewModel.shorts.srn ?? "",
            "videoUrl": videoUrl,
            "currentTime": timeValue
        ]
        
        ShortFormAuthManager.shared.getAkAndUserJWTasDict().forEach { payload[$0.key] = $0.value }
        
        if let isWebViewLoaded = viewModel.isWebViewLoaded, isWebViewLoaded == false {
            viewModel.webViewCommands.append((.ON_VIDEO_TIME_UPDATED, payload))
        }
        
        overlayView?.sendShortsEvent(event: ShopLiveShortform.ShortsWebInterface.SdkToWeb.ON_VIDEO_TIME_UPDATED.rawValue, parameter: payload) {}
        
    }
    
    func readyToPlay(card: ShopLiveShortform.Card) {
        switch card {
        case .VideoCard(_):
            break
        case .ImageCard(_):
            break
        }
        
        guard let index = viewModel.getCardIndex(card) else {
            return
        }
        
        guard index == viewModel.currentIndex,
              let _ = cardViews?[safe: index]
        else { return }
        
        viewModel.isReadyToPlay = true
    }
    
    func didFinishPlaying(card: ShopLiveShortform.Card) {
        
        guard let index = viewModel.getCardIndex(card) else {
            return
        }
        
        if viewModel.isLast {
            if viewModel.shortsMode == .preview {
                delegate?.didFinishedPlayingShorts(item: viewModel.shorts)
            }
            else {
                viewModel.currentIndex = 0
                guard let cardView = cardViews?[safe: viewModel.currentIndex] else { return }
                setCurrentCard(index: 0)
                cardView.replay()
                self.sendWebToOnVideoLooped()
            }
            return
        }
        
        guard index == viewModel.currentIndex else { return }
        viewModel.currentIndex = index + 1
        guard let cardView = cardViews?[safe: viewModel.currentIndex] else { return }
        setCurrentCard(index: index + 1)
        cardView.play()
        
    }
}

extension ShopLiveShortform.ShortsView: SLWebviewResponseDelegate {
    func handleShopliveEvent(_ command: String, with payload: [String: Any]?, userImplements: Bool) {
    }
    
    func handleEventMessage(message: WKScriptMessage) {
        guard let body = message.body as? [String: Any],
              let event = body["shopliveShortsEvent"] as? [String : Any],
              let eventName = event["name"] as? String,
              let metadata = event["metadata"] as? [String: String],
              let type = metadata["type"] else {
            return
        }
        
        if type != "INTERNAL_MESSAGE" {
            var payload: [String: Any] = [:]
            
            payload["command"] = eventName
            payload["payload"] = body["payload"] as? [String:Any]
            NotificationCenter.default.post(Notification(name: Notification.Name("onEvent"), object: nil, userInfo: payload))
        }
        
        
        let parameters = body["payload"] as? [String: Any]
        
        delegate?.shortsCommand(name: eventName, payload: parameters)
        
        guard let webInterfece = ShopLiveShortform.ShortsWebInterface.WebToSdk(rawValue: eventName) else { return }
        
        switch webInterfece {
        case .ON_SHORTFORM_CLIENT_INITIALIZED:
            guard let parameters = parameters else { return }
            if ShortFormAuthManager.shared.getuserJWT() == nil && ShortFormAuthManager.shared.getGuestUId() == nil {
                ShortFormAuthManager.shared.setAuthInfo(parameters)
            }
            else {
                var payload: [String: Any] = [:]
                if let userJWT = ShortFormAuthManager.shared.getuserJWT() {
                    payload["userJWT"] = userJWT
                }
                
                if let guestUid = ShortFormAuthManager.shared.getGuestUId() {
                    payload["guestUid"] = guestUid
                }
                
                NotificationCenter.default.post(Notification(name: Notification.Name("onChangedUserAuthSdk"), object: nil, userInfo: payload))
            }
            break
        case .ON_SHORTFORM_DETAIL_INITIALIZED:
            sendWebToSafeareaInfo()
            sendWebToMuteState()
            break
        case .PLAY_SHORTFORM_DETAIL:
            NotificationCenter.default.post(Notification(name: Notification.Name("closeShortsDetail"), userInfo: ["srn" : viewModel.shorts.srn]))
            guard let parameters = parameters, let param = parameters.toJson_SL(), let shortsList = param.convert_SL(to: ShopLiveShortform.ShortsBridgeModel.self) else { return }
            ShortFormAuthManager.shared.setAuthInfo(parameters)
            self.showShortFormFullScreen(model: shortsList)
            NotificationCenter.default.post(Notification(name: Notification.Name("showShortsDetail"), userInfo: ["srn" : viewModel.shorts.srn]))
            break
        case .ON_CHANGED_USER_AUTH:
            guard let parameters = parameters else { return }
            ShortFormAuthManager.shared.setAuthInfo(parameters)
            break
        case .HIDE_SHORTFORM_PREVIEW:
            ShopLiveShortform.close()
            break
        case .ENABLE_SWIPE_DOWN:
            overlayView?.setScrollable(true)
            break
        case .DISABLE_SWIPE_DOWN:
            overlayView?.setScrollable(false)
            break
        case .PLAY_VIDEO:
            play()
            break
        case .SET_VIDEO_PAUSE:
            guard let parameters = parameters,
            let _ = parameters["videoUrl"] as? String,
            let isPaused = parameters["pause"] as? Bool else { return }
            isPaused ? pause() : play()
            break
        case .SET_VIDEO_CURRENT_TIME:
            break
        case .SET_VIDEO_SEEK_TIME:
            guard let parameters = parameters,
            let _ = parameters["videoUrl"] as? String,
            let seekTime = parameters["seekTime"] as? CGFloat else { return }
            let seekCMTime = CMTimeMakeWithSeconds(seekTime, preferredTimescale: 1000000)

            if seekTime != .zero {
                NotificationCenter.default.post(Notification(name: Notification.Name("seekStart"), object: nil))
            }
            cardViews?[safe: viewModel.currentIndex]?.seekTo(time: seekCMTime)
            break
        case .ON_USER_AUTHORIZATION_UPDATED:
            guard let parameters = parameters else { return }
            ShortFormAuthManager.shared.setAuthInfo(parameters)
            break
        case .REQUEST_CLIENT_VERSION:
            sendWebToVersionInfo()
        case .CLOSE_SHORTFORM_DETAIL:
            guard let currentSrn = self.viewModel.shorts.srn else { return }
            self.sendActiveStatePage(isActive: false, srn: currentSrn, index: self.viewModel.cvIndexPathRow)
            if ShopLiveShortform.BridgeInterface.isBridgeConnected() == false {
                ShopLiveShortform.close()
            }
            break
        default:
            break
        }
    }
    
    private func showShortFormFullScreen(model : ShopLiveShortform.ShortsBridgeModel){
        let shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        if ShortFormConfigurationInfosManager.shared.shortsConfiguration.detailCollectionListAll {
            let requestModel = InternalShortformCollectionData()
            if let collectionQuery = model.collectionQuery {
                requestModel.tags = collectionQuery.tags
                requestModel.tagSearchOperator = collectionQuery.tagSearchOperator
                requestModel.brands = collectionQuery.brands
                requestModel.shuffle = collectionQuery.shuffle
            }
            else {
                requestModel.tags = model.relatedQuery?.tags
                requestModel.tagSearchOperator = model.relatedQuery?.tagSearchOperator
                requestModel.brands = model.relatedQuery?.brands
                requestModel.shuffle = model.relatedQuery?.shuffle
            }
            ShopLiveShortform.playNormalFullScreen(shortsId: model.shorts?.shortsId, shortsSrn: model.shorts?.srn, requestModel: requestModel,shopliveSessionId: shopliveSessionId)
        }
        else {
            let requestModel = InternalShortformRelatedData()
            requestModel.tags = model.relatedQuery?.tags
            requestModel.tagSearchOperator = model.relatedQuery?.tagSearchOperator
            requestModel.brands = model.relatedQuery?.brands
            requestModel.productId = model.relatedQuery?.productId
            requestModel.name = model.relatedQuery?.name
            requestModel.sku = model.relatedQuery?.sku
            requestModel.url = model.relatedQuery?.url
            requestModel.shuffle = model.relatedQuery?.shuffle
            
            
            ShopLiveShortform.playRelatedFullScreen(shortsId: model.shorts?.shortsId, shortsSrn: model.shorts?.srn, requestModel: requestModel,shopliveSessionId: shopliveSessionId)
        }
    }
    
}

extension ShopLiveShortform.ShortsView: AppStateObserverDelegate {
    
    func handleAppStateNotification(appState: SLAppState) {
        switch appState {
        case .didEnterForeground:
            updateOverlayDelegate()
            overlayView?.setScrollable(true)
            guard let currentSrn = self.viewModel.shorts.srn else { return }
            let reserved = self.viewModel.reservedIsActiveForEnteringBackground ?? false
            self.viewModel.reservedIsActiveForEnteringBackground = nil
            if reserved  {
                self.play()
            }
            else {
                seekToZeroOnPageInActive()
            }
            self.sendActivePageOnAppStateChanged(isActive: reserved, srn: currentSrn, index: self.viewModel.cvIndexPathRow)
            break
        case .willEnterBackground:
            guard let currentSrn = self.viewModel.shorts.srn,
                  viewModel.isActive == true else { return}
            self.pause()
            self.viewModel.reservedIsActiveForEnteringBackground = viewModel.isActive
            self.sendActivePageOnAppStateChanged(isActive: false, srn: currentSrn, index: self.viewModel.cvIndexPathRow)
        case .didEnterBackground:
            guard let currentSrn = self.viewModel.shorts.srn,
                  viewModel.isActive == true else { return}
            self.pause()
            self.sendActivePageOnAppStateChanged(isActive: false, srn: currentSrn, index: self.viewModel.cvIndexPathRow)
        default:
            break
        }
    }
    
    private func sendActivePageOnAppStateChanged(isActive : Bool, srn : String?, index : Int) {
        let data : [String : Any] = [
            "srn" : srn,
            "isActive" : isActive,
            "shortsList" : delegate?.getShortsListDataForV2ActivePage()
        ]
        self.handleSendActivePag(data: data)
    }
}

