//
//  ShortsCollectionViewModelInterface.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/29/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit



protocol ShortsCollectionBaseViewModelDelegate : NSObject {
    func reloadData(completion : (() -> ())?)
    func reloadData()
    func insertItemsWithOutAnimation(updateIndexPaths : [IndexPath])
    func setScrollEnabled(isEnabled : Bool)
    func onViewAppeared()
    func setCloseBtnVisible(isVisible : Bool)
    func playToPage(index : Int)
    func playWhenNetworkReconnected()
    
    func getLoadedCells(from : Int, to : Int) -> [ShortsCell]?
    func getCellForAt(indexPath : IndexPath) -> UICollectionViewCell?
    func getCurrentIndexPath() -> IndexPath?
    func getIndexPathsForVisibleItems() -> [IndexPath]
    
    func openOsShareSheet(url : String)
    
    func setAudioSessionManager()
    
    func playeCurrentCell()
}

class ShortsCollectionBaseViewModel : NSObject {
    enum ShortsApiType {
        case normal
        case related
    }
    
    /**
     safeArea 어떤걸로 보낼지 결정해야 되서
     */
    enum ViewProvidedType {
        case window // window 자체로 제공 되었을때
        case view //view로 제공되었을때
    }
    
    
    typealias ShortsMode = ShopLiveShortform.ShortsMode
    
    weak var delegate : ShortsCollectionBaseViewModelDelegate?
    
    var networkMonitor = NetworkMonitor()
    var networkAvailable: Bool? = true
    var latestCell: LatestShortsCell = LatestShortsCell()
    var scrollToPage : Int? = nil
    let appStateObserver = ShopliveAppStateObserver()
    var audioLevel : Float = 0.0
    var audioSessionObservationInfo: UnsafeMutableRawPointer?
    
    
    //for relatedShorts
    var relatedRequestData : InternalShortformRelatedDTO?
    var collectionRequestData : InternalShortformCollectionDto?
    var currentApiType : ShortsApiType = .normal
    var isFullNative : Bool = false
    
    //for rotation
    var capturedCurrentIndexPathForRotation : IndexPath?
    var blockScrollViewDidScrollForRotation : Bool = false
    var isOnRotation : Bool = false
    
    //data
    private var previewOptionDto : ShortformPreviewOptionDTO?
    var shortsCollection: SLShortsCollectionModel?
    var lastShortsCount: Int = 0
    var originShortsListData : [SLShortsModel] = [] {
        didSet {
            self.reloadData()
        }
    }
    var shortsListData : [SLShortsModel] {
        return self.shortsMode == .detail ? originShortsListData : originShortsListData.filter{ $0.validate }
    }
    var hasMore: Bool {
        shortsCollection?.hasMore ?? false
    }
    /**
     고객사가 처음 진입하자마자 보여줄려고 하는 shortsId
     */
    var initialTargetShortsId : String?
    var shopliveSessionId : String?
    var previousActiveSrn : String?
    weak var shortformDelegate : ShopLiveShortformReceiveHandlerDelegate?
    
    //currentDatas
    var currentShorts : SLShortsModel? {
        guard let currentIndex = latestCell.indexPath,
              let shorts = shortsListData[safe: currentIndex.row] else { return nil }
        return shorts
    }
    var currentReference: String? {
        guard let reference = shortsCollection?.reference else { return nil }
        return reference
    }
    var currentShortsId: String? {
        guard let currentIndex = latestCell.indexPath,
              let shortsId = shortsListData[safe: currentIndex.row]?.shortsId else { return nil }
        return shortsId
    }
    var currentOverlayUrl: String? {
        guard let currentIndex = latestCell.indexPath,
              let overlayUrl = self.getOverlayUrl(at: currentIndex, shortsModel: shortsListData[safe: currentIndex.row], isYoutube: false)  else { return nil }
        return overlayUrl.absoluteString
    }
    var currentShortsSrn: String? {
        if let latestIndexPath = latestCell.indexPath, let srn = shortsListData[safe: latestIndexPath.row]?.srn  {
            return srn
        }
        else if let srn = shortsListData[safe: 0]?.srn {
            return srn
        }
        return nil
    }
    var currentShortsCollectionModelSrn : String? {
        return self.shortsCollection?.srn
    }
    
    
    //cell state
    var shortsDetailInitialized: Bool = false
    var latestActivePageIndex : Int = -1
    private var videoCurrentTimeWhenPreviewTapped : ShortformCurrentTimeDTO?
    private var videoShortsIdWhenPreviewTapped : String?
    private var canUseShortformCurrentTimeDTO : Bool = false
    var isMuted : Bool {
        get {
            let audioSession = AudioSessionManager.shared.audioSession
            if audioSession.outputVolume == 0 {
                return true
            }
            
            if let collectionRequestData = collectionRequestData, let isMuted = collectionRequestData.isMuted {
                return isMuted
            }
            else if let relatedRequestData = relatedRequestData, let isMuted = relatedRequestData.isMuted {
                return isMuted
            }
            else {
                return true
            }
        }
        set {
            if let collectionRequestData = collectionRequestData {
                collectionRequestData.isMuted = newValue
            }
            else if let relatedRequestData = relatedRequestData {
                relatedRequestData.isMuted = newValue
            }
            self.setCellMuted(isMuted: newValue)
        }
    }
    private var _previewIsMuted : Bool?
    private var previewIsMuted : Bool {
        get {
            if let _previewIsMuted = _previewIsMuted {
                return _previewIsMuted
            }
            else {
                let audioSession = AudioSessionManager.shared.audioSession
                if audioSession.outputVolume == 0 {
                    return true
                }
                if let previewOptionDto = previewOptionDto {
                    return previewOptionDto.previewIsMuted ?? true
                }
                else {
                    return ShortFormConfigurationInfosManager.shared.shortsConfiguration.previewIsMuted
                }
            }
        }
        set {
            _previewIsMuted = newValue
            self.setCellMuted(isMuted: newValue)
        }
    }
    private var preferredForwardBufferDuration : Double = ShortFormConfigurationInfosManager.shared.shortsConfiguration.preferredBufferDuration
    
    //view state
    var fromPreview: Bool = false
    var shortsMode : ShortsMode = .detail
    var isSwipable : Bool {
        return shortsMode == .detail
    }
    var isViewAppeared : Bool = false {
        didSet {
            if isViewAppeared {
                delegate?.onViewAppeared()
            }
        }
    }
    var viewProvideType : ViewProvidedType = .window
    var didAnimatePreviewToFullScreen : Bool = false
    private var didConfigAudioSessionManager : Bool = false
    
    
    //size
    var superviewSize : CGSize? = nil
    var verticalCollectionBounds: CGSize = UIScreen.main.bounds.size
    var horizontalCollectionBounds : CGSize = UIScreen.main.bounds.size.transpolate_SL
    
    //webviews
    private var webViewLists :  [ ShopliveWebViewListKey : SLWebView] = [:]
    private var loadFinishedWebViewIndexPaths : Set<IndexPath> = []
    private var youtubeWebViewLists : [ShopliveWebViewListKey : SLWebView] = [:]
    private var youtubeWebViewListKeys: Set<ShopliveWebViewListKey> = []
    
    //cell container view list [String:ShortsView]
    //양방향 페이지네이션때 위로 페이지네이션 하는 경우 현재 보여지는 cell이 한번더 initiate되는 경우가 있음, 썸네일이 2번깜박이는 현상을 방지하기 위해서
    //보고 있던 shortsView를 다시 삽입
    //paging의 상황이 생길때 저장
    var shortsViewList : [String : ShortsView] = [:]
    
    init(shopliveSessionId : String?,shortformDelegate : ShopLiveShortformReceiveHandlerDelegate?) {
        super.init()
        self.shortformDelegate = shortformDelegate
        self.shopliveSessionId = shopliveSessionId
        self.webViewLists.removeAll()
        appStateObserver.delegate = self
        bindNetworkMonitorResult()
        addObserver()
    }
    
    init(shorts : [SLShortsModel],shopliveSessionId : String?, shortformDelegate : ShopLiveShortformReceiveHandlerDelegate?) {
        super.init()
        self.shortformDelegate = shortformDelegate
        self.webViewLists.removeAll()
        self.originShortsListData = shorts
        self.shopliveSessionId = shopliveSessionId
        appStateObserver.delegate = self
        bindNetworkMonitorResult()
        addObserver()
    }
    
    deinit {
        ShopLiveLogger.memoryLog("shortscollectionBaseView deinted")
        self.latestCell.setLatest()
        clearWebViewLists()
        appStateObserver.delegate = nil
        removeObserver()
    }
    
    private func clearWebViewLists() {
        self.webViewLists.forEach { (key, view) in
            view.removeFromSuperview()
        }
        self.webViewLists.removeAll()
    }
    
    private func bindNetworkMonitorResult() {
        networkMonitor.resultHandler = { [weak self] (result) in
            switch result {
            case let .statusChanged(status):
                if let networkAvailable = self?.networkAvailable,
                   status.isConnected,
                   status.isConnected != networkAvailable {
                    self?.networkAvailable = true
                    self?.delegate?.playWhenNetworkReconnected()
                }
                self?.networkAvailable = status.isConnected
            }
        }
    }
    
    /**
     v2 override
     returns nil if called in v1
     */
    func getShortsListDataForV2ActivePage() -> [SLShortsModel]? {
        return nil
    }
}
//MARK: - util functions
extension ShortsCollectionBaseViewModel {
    
    func sendCellDetachedEventOnRemoveFromSuperView(indexPaths : [IndexPath]) {
        indexPaths.map({ $0.row })
            .compactMap({ self.shortsListData[safe: $0] })
            .map({ $0.toShopLiveShortformData() })
            .forEach { data in
                shortformDelegate?.onShortsDetached?(data: data)
            }
    }
    
    func isLast(indexPath: IndexPath) -> Bool {
        guard shortsListData.count > 1 else { return true }
        return indexPath.row == shortsListData.count - 1
    }
    
    func removeShortformByShortsId(shortsIdOrSrn : String,cv : UICollectionView) {
        let numberOfItemsInSection = cv.numberOfItems(inSection: 0)
        if numberOfItemsInSection == 1, let _ = self.shortsListData.firstIndex(where: { $0.shortsId ?? "" == shortsIdOrSrn  || $0.srn  == shortsIdOrSrn }) {
            // 쇼츠 데이터가 1개 뿐일때 삭제하려고 한다면 그냥 닫아버리는 것으로 무신사 측과 협의 됨
            self.shortformDelegate?.onEvent?(messenger: nil, command: "DETAIL_EMPTY", payload: nil)
            self.originShortsListData.removeAll()
            cv.reloadData()
            ShopLiveShortform.close()
        }
        else if let firstIndex = self.shortsListData.firstIndex(where: { $0.shortsId ?? "" == shortsIdOrSrn || $0.srn  == shortsIdOrSrn }) {
            //삭제 되는 것이 마지막 data 라면
            if firstIndex == self.shortsListData.count - 1 {
                self.shortformDelegate?.onEvent?(messenger: nil, command: "DETAIL_EMPTY", payload: nil)
            }
            if numberOfItemsInSection != self.shortsListData.count {
                let newlyAppendDataCount : Int = self.shortsListData.count - numberOfItemsInSection
                let newDatas : [SLShortsModel] = self.originShortsListData.suffix(newlyAppendDataCount)
                self.originShortsListData =  self.originShortsListData.dropLast(newlyAppendDataCount)
                let removedData = originShortsListData[firstIndex]
                cv.performBatchUpdates {
                    originShortsListData.remove(at: firstIndex)
                    cv.deleteItems(at: [IndexPath(row: firstIndex, section: 0)])
                } completion: { [weak self] done in
                    guard done else { return }
                    self?.shortformDelegate?.onShortsDetached?(data: removedData.toShopLiveShortformData())
                    self?.originShortsListData.append(contentsOf: newDatas)
                }
            }
            else {
                self.originShortsListData.removeAll(where: { $0.shortsId ?? "" == shortsIdOrSrn })
                let oldContentOffsetY = cv.contentOffset.y
                cv.deleteItems(at: [IndexPath(row: firstIndex, section: 0)])
                let newContentOffsetY = cv.contentOffset.y
                
                if oldContentOffsetY == newContentOffsetY {
                    guard let currentIndexPath = self.delegate?.getCurrentIndexPath() else { return }
                    guard let currentCell = self.delegate?.getCellForAt(indexPath: currentIndexPath) as? ShortsCell else { return }
                    self.latestCell.setLatest(latestCell: currentCell, indexPath: currentIndexPath)
                    currentCell.setMute(getMuted())
                    currentCell.play(skipIfPaused: false)
                }
            }
        }
    }
    
    func setShortsConfiguration() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.setCloseBtnVisible(isVisible: self.shortsMode == .preview && self.getPreviewUseCloseBtn())
        }
    }
    
    func preDownlaodPosterImage(index : Int) {
        guard let data = self.shortsListData[safe: index],
              let urlString = data.cards?.first?.screenshotUrl,
              let url = URL(string: urlString) else { return }
        ImageDownLoaderManager.shared.preDownloadImage(imageUrl: url)
    }
    
    func preDownloadYoutubePosterImage(index : Int) {
        if let shortsModel = shortsListData[safe : index],
           let cardModel = shortsModel.cards?.first,
           let playerType = cardModel.playerType, playerType == "YOUTUBE",
           let posterUrl = cardModel.externalVideoThumbnail,
           let url = URL(string: posterUrl) {
            ImageDownLoaderManager.shared.preDownloadImage(imageUrl: url)
        }
    }
}
//MARK: - setter functions
extension ShortsCollectionBaseViewModel {
    func setCellMuted(isMuted : Bool) {
        self.latestCell.latestCell?.setMute(isMuted)
        guard let currentIndexPath = self.delegate?.getCurrentIndexPath(),
              let cells = self.delegate?.getLoadedCells(from: currentIndexPath.row - 1, to: currentIndexPath.row + 1) else {
            return
        }
        cells.forEach { cell in
            cell.setMute(self.isMuted)
        }
    }
    
    func setShopLiveSessionId(sessionId : String?) {
        self.shopliveSessionId = sessionId
    }
    
    func setIsMuted(isMuted : Bool, from : String = #function) {
        if self.shortsMode == .preview {
            self.previewIsMuted = isMuted
        }
        else {
            self.isMuted = isMuted
        }
    }
    
    func setPreviewOptionDTO(dto : ShortformPreviewOptionDTO?) {
        self.previewOptionDto = dto
    }
    
    func setVideoCurrentTimeWhenPreviewTapped(time : ShortformCurrentTimeDTO?) {
        self.videoCurrentTimeWhenPreviewTapped = time
    }
    
    func setVideoShortsIdWhenPreviewTapped() {
        self.videoShortsIdWhenPreviewTapped = self.currentShortsId
    }
    
    func setVideoSHortsIdWhenPreviewTappedToNull() {
        self.videoShortsIdWhenPreviewTapped = nil
    }
    
    func setCanUseShortformCurrentTimeDTO(canUse : Bool) {
        self.canUseShortformCurrentTimeDTO = canUse
    }
    
    func removeShortsView(srn : String) {
        shortsViewList.removeValue(forKey: srn)
    }
}
//MARK: - getter functions
extension ShortsCollectionBaseViewModel {
    
    func getShortsView(srn : String) -> ShortsView? {
        return shortsViewList[srn]
    }
    
    func getMuted() -> Bool {
        if self.shortsMode == .preview {
            return self.previewIsMuted
        }
        else {
            return self.isMuted
        }
    }
    
    func getPreviewUseCloseBtn() -> Bool {
        if let dto = previewOptionDto, let useCloseBtn = dto.useCloseBtn {
            return useCloseBtn
        }
        else {
            return ShortFormConfigurationInfosManager.shared.shortsConfiguration.previewUseCloseButton
        }
    }
    
    func checkIsYoutubePlayer(indexPath : IndexPath) -> Bool {
        guard let data = shortsListData[safe : indexPath.row],
              let playerType = data.cards?.first?.playerType else {
            return false
        }
        return playerType == "YOUTUBE" ? true : false
    }
    
    func getShortsItemIndex(_ item : SLShortsModel?) -> Int? {
        return shortsListData.firstIndex(where:  { $0 == item })
    }
    
    func getNextShortItemIndex(_ item: SLShortsModel?) -> Int? {
        guard let currentItemIndex = getShortsItemIndex(item) else { return nil }
        guard shortsListData.count > 1 else { return nil }
        
        guard shortsListData.count - 1 > currentItemIndex else {
            if currentItemIndex == shortsListData.count - 1 {
                return 0
            }
            return nil
        }
        
        return currentItemIndex + 1
    }
    
    
    func getPreviewEventTraceSrn() -> String? {
        if let collectionSrn = self.currentShortsCollectionModelSrn {
            return collectionSrn
        }
        else if let shortsSrn = self.currentShortsSrn {
            return shortsSrn
        }
        else {
            return nil
        }
    }
    
    func getCurrentShopliveSessionId() -> String? {
        return self.shopliveSessionId
    }
    
    func getPreferredForwardBufferDuration() -> Double {
        return self.preferredForwardBufferDuration
    }
    
    func getOverlayUrl(at indexPath : IndexPath, shortsModel : SLShortsModel?, isYoutube : Bool) -> URL? {
        var payload: String = ""
        
        var payloadDict = self.getOverlayUrlPayload(at: indexPath, shortsModel: shortsModel, isYoutube: isYoutube)
        
        if let shortJson = payloadDict.toJson_SL()  {
            payload = shortJson
        } else {
            return nil
        }
        
        let urlString : String
        
        if isYoutube {
            urlString = ShortFormConfigurationInfosManager.shared.shortsConfiguration.youtubeUrl
        }
        else {
            urlString = ShortFormConfigurationInfosManager.shared.shortsConfiguration.detailUrl
        }
        
        let urlComponents = URLComponents(string: urlString)
        var queryItems = urlComponents?.queryItems ?? [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "payload", value: payload))
       
        guard let params = URLUtil_SL.query(queryItems) else {
            return URL(string: urlString)
        }

        guard let url = URL(string: urlString + "?" + params) else {
            return URL(string: urlString)
        }
        
        return url
    }
    
    func getSetShortsSingleDetailViewPayload(at indexPath : IndexPath, shortsModel : SLShortsModel?, isYoutube : Bool) -> [String : Any] {
        var payloadDict = self.getOverlayUrlPayload(at: indexPath, shortsModel: shortsModel, isYoutube: isYoutube)
        payloadDict["ids"] = self.shortsListData.compactMap({ $0.shortsId }).joined(separator: ",")
        let shortsDict = shortsModel?.getRawDataDict()
        payloadDict["shorts"] = shortsDict
        
        return payloadDict
    }
    
    func getVideoCurrentTimeWhenPreviewTapped() -> ShortformCurrentTimeDTO? {
        return self.videoCurrentTimeWhenPreviewTapped
    }
    
    func getVideoShortsIdTimeWhenPreviewTapped() -> String? {
        return self.videoShortsIdWhenPreviewTapped
    }
    
    func getPreviewPlayMaxCount() -> Int? {
        return self.previewOptionDto?.maxCount
    }
    
    func getShortsMode() -> ShortsMode {
        return self.shortsMode
    }
    
    func getCanUseShortformCurrentTimeDTO() -> Bool {
        return canUseShortformCurrentTimeDTO
    }
    
    func getOverlayUrlPayload(at indexPath : IndexPath, shortsModel : SLShortsModel?, isYoutube : Bool) -> [String : Any] {
       
        var payloadDict: [String: Any] = [:]
        
        payloadDict["disableGuide"] = ShopLiveUserDefaults.shortFormGuideOpen
        
        payloadDict["ak"] = ShopLiveCommon.getAccessKey() ?? ""
        
        if let userJWT = ShortFormAuthManager.shared.getuserJWT() {
            payloadDict["userJWT"] = userJWT
        }
        else if let guestUid = ShortFormAuthManager.shared.getGuestUId() {
            payloadDict["guestUid"] = guestUid
        }
        
        if let referrer = ShortFormAuthManager.shared.getReferrer() {
            payloadDict["referrer"] = referrer.prefix(1024)
        }
        
        if let adIdentifier = ShopLiveCommon.getAdIdentifier(), !adIdentifier.isEmpty {
            payloadDict["adIdentifier"] = adIdentifier
            payloadDict["idfa"] = adIdentifier
        }
        
        if let ceId = ShopLiveCommon.getCeId(), !ceId.isEmpty {
            payloadDict["ceId"] = ceId
        }
        
        if let anondId = ShopLiveCommon.getAnonId(), !anondId.isEmpty {
            payloadDict["anonId"] = anondId
        }
        
        if let shopliveSessionId = self.shopliveSessionId, !shopliveSessionId.isEmpty {
            payloadDict["shopliveSessionId"] = shopliveSessionId
        }
        
        if let idfv = UIDevice.idfv_sl, idfv.isEmpty == false {
            payloadDict["idfv"] = idfv
        }
        
        if let utm_source = ShopLiveCommon.getUtmSource() {
            payloadDict["utm_source"] = utm_source
        }
        
        if let utm_content = ShopLiveCommon.getUtmContent() {
            payloadDict["utm_content"] = utm_content
        }
        
        if let utm_campaign = ShopLiveCommon.getUtmCampaign() {
            payloadDict["utm_campaign"] = utm_campaign
        }
        
        if let utm_medium = ShopLiveCommon.getUtmMedium() {
            payloadDict["utm_medium"] = utm_medium
        }
        
        payloadDict["eSlSid"] = self.shopliveSessionId ?? ""
        
        payloadDict["appVersion"] = UIApplication.appVersion_SL()
        payloadDict["sdkVersion"] = ShopLiveShortform.sdkVersion
        
        if self.viewProvideType == .view {
            payloadDict["safeArea"] = [
                "top": 0,
                "right": 0,
                "bottom": 0,
                "left": 0
            ]
        }
        else {
            payloadDict["safeArea"] = [
                "top": UIScreen.topSafeArea_SL,
                "right": UIScreen.leftSafeArea_SL,
                "bottom": UIScreen.bottomSafeArea_SL,
                "left": UIScreen.leftSafeArea_SL
            ]
        }
        
        //튜토리얼 용 쿼리 파라미터
        payloadDict["index"] = indexPath.row
        if let startId = self.initialTargetShortsId {
            payloadDict["startId"] = startId
        }
        else if let startId = self.shortsListData.first?.shortsId {
            payloadDict["startId"] = startId
        }
        
        if let shopliveSessionId = self.shopliveSessionId {
            payloadDict["shopliveSessionId"] = shopliveSessionId
        }
        
        
        if self.viewProvideType == .window {
            payloadDict["ui"] = ShopLiveShortform.detailWebViewViewHideOptionData.toDict()
        }
        else {
            payloadDict["ui"] = ShopLiveShortform.detailWebViewViewHideOptionData.toDict(forceBackBtnVisible: false)
        }
        
        if let youtubeId = shortsModel?.cards?.first?.externalVideoId {
            payloadDict["youtubeId"] = youtubeId
        }
        
        ShortFormAuthManager.shared.getAkAndUserJWTasDict().forEach { payloadDict[$0.key] = $0.value }
        
        return payloadDict
    }
    
    func getShortsListDataCount() -> Int {
        return self.shortsListData.count
    }
    
}
//MARK: - WebViewPool function
extension ShortsCollectionBaseViewModel {
    func updateWebViewPoolForReconnection(currentIndex : IndexPath) {
        guard let data = shortsListData[safe : currentIndex.row],
              let shortsId = data.shortsId,
              let webview = self.webViewLists[ShopliveWebViewListKey(shortsId: shortsId, indexPath: currentIndex)] else { return }
        webview.reconnect()
    }
    
    func loadWebViewsFor(indexPath : [IndexPath]) {
        indexPath.forEach { indexpath in
            guard let data = shortsListData[safe : indexpath.row] else {
                return
            }
            guard let shortsId = data.shortsId else {
                return
            }
            let webViewListKey = ShopliveWebViewListKey(shortsId: shortsId, indexPath: indexpath)
            guard  webViewLists[webViewListKey] == nil else {
                if loadFinishedWebViewIndexPaths.contains(indexpath) == false {
                    webViewLists[webViewListKey]?.reconnect()
                }
                return
            }
            if let url = getOverlayUrl(at: indexpath, shortsModel: data,isYoutube: false) {
                let webView = SLWebView()
                webView.configure(url: url.absoluteString)
                webViewLists[webViewListKey] = webView
                if let playerType = data.cards?.first?.playerType, playerType == "YOUTUBE" {
                    self.appendYoutubeWebViewList(webViewListKey: webViewListKey,shortsModel: data)
                }
            }
        }
    }
    
    private func appendYoutubeWebViewList(webViewListKey : ShopliveWebViewListKey, shortsModel : SLShortsModel?) {
        if let url = getOverlayUrl(at: webViewListKey.indexPath, shortsModel: shortsModel,isYoutube: true) {
            guard youtubeWebViewLists[webViewListKey] == nil else { return }
            let webView = SLWebView()
            webView.configure(url: url.absoluteString)
            youtubeWebViewLists[webViewListKey] = webView
            youtubeWebViewListKeys.insert(webViewListKey)
        }
    }
    
    func deleteWebViewsWhenCellDidEndDisplaying(indexPath : IndexPath) {
        guard let data = shortsListData[safe : indexPath.row] else { return }
        guard let shortsId = data.shortsId else { return }
        let webViewListKey = ShopliveWebViewListKey(shortsId: shortsId, indexPath: indexPath)
        self.webViewLists.removeValue(forKey: webViewListKey)
        self.loadFinishedWebViewIndexPaths.remove(indexPath)
        
        //youtube의 경우는 좀 느려서 현재 없어지는 index기준으로 위아래로 3 ~ 4개씩은 들고 있는 걸로
        let minYtIndex : Int = max(0,indexPath.row - 4)
        let maxYtIndex : Int = min(indexPath.row + 4, shortsListData.count - 1)
        
        youtubeWebViewListKeys.forEach { key in
            if key.indexPath.row < minYtIndex || key.indexPath.row > maxYtIndex {
                self.youtubeWebViewLists.removeValue(forKey: key)
            }
        }
    }
    
    func getWebview(for shortsId : String, indexPath : IndexPath) -> SLWebView {
        if let webView = self.webViewLists[ShopliveWebViewListKey(shortsId: shortsId, indexPath: indexPath)] {
            return webView
        }
        else {
            return SLWebView()
        }
    }
    
    func getYoutubePlayerView(for shortsId : String, indexPath : IndexPath) -> SLWebView? {
        if let webView = self.youtubeWebViewLists[ShopliveWebViewListKey(shortsId: shortsId, indexPath: indexPath)] {
            return webView
        }
        else {
            return nil
        }
    }
    
    func removeAllWebViewLists(){
        self.webViewLists.removeAll()
        self.youtubeWebViewLists.removeAll()
    }
    
    func webViewLoadedFinished(at indexPath : IndexPath) {
        self.loadFinishedWebViewIndexPaths.insert(indexPath)
    }
    
    func configureAudioSessionManager() {
        if didConfigAudioSessionManager == true { return }
        didConfigAudioSessionManager = true
        self.delegate?.setAudioSessionManager()
    }
}
//MARK: - Notifications
extension ShortsCollectionBaseViewModel {
    
    func onError(_ error: ShopLiveCommonError) {
        shortformDelegate?.onError?(error: error)
//        ShopLiveShortform.Delegate.receiveHandler.delegate?.onError?(error: error)
    }
    
    func postEnableTapNotification() {
        NotificationCenter.default.post(Notification(name: Notification.Name("enableTap"), object: nil, userInfo: ["enable": ShopLiveShortform.ShortsMode.preview == self.shortsMode]))
    }
    
    func postPreviewShowNotification() {
        guard let shorts = self.currentShorts else { return }
        ShopLiveShortform.BridgeInterface.previewShown(shorts: shorts)
    }
    
    func postOnForegroundNotification() {
        guard let srn = currentShortsSrn else { return }
        guard let indexPath = delegate?.getCurrentIndexPath(),
              let cells = delegate?.getLoadedCells(from: indexPath.row - 1, to: indexPath.row + 1) else { return }
        cells.forEach { cell in
            cell.setAppState(srn: srn, state: "foreground")
        }
    }
    
    func postOnBackGroundNotification() {
        guard let srn = currentShortsSrn else { return }
        guard let indexPath = delegate?.getCurrentIndexPath(),
              let cells = delegate?.getLoadedCells(from: indexPath.row - 1, to: indexPath.row + 1) else { return }
        cells.forEach { cell in
            cell.setAppState(srn: srn, state: "background")
        }
    }
    
    func postPreviewCloseNotification() {
        guard let shortsModel = self.currentShorts else { return }
        ShopLiveShortform.BridgeInterface.previewClose(shorts: shortsModel)
    }
    
    func postStopVideoNotification() {
        guard let indexPath = delegate?.getCurrentIndexPath(),
              let cell = delegate?.getCellForAt(indexPath: indexPath) as? ShortsCell else { return }
        cell.stop()
    }
    
    /**
     cell을 위한 스냅샷이 아니라 컬렉션뷰 자체를 위한 스냅샷
     */
    func postTakeSnapShotForWindowNotification() {
        guard let indexPath = delegate?.getCurrentIndexPath(),
              let cell = delegate?.getCellForAt(indexPath: indexPath) as? ShortsCell else { return }
        cell.takeSnapShotForWindow(srn: self.currentShortsSrn)
    }
    
    func postModeChangeNotification() {
        guard let indexPath = delegate?.getCurrentIndexPath(),
              let cell = delegate?.getCellForAt(indexPath: indexPath) as? ShortsCell else { return }
        cell.setShortsMode(shortsMode)
    }
    
    func postActivePageNotification(forceIsActive : Bool? = nil, srn : String?, index : Int,isFromAppState : Bool = false) {
        guard let cells = delegate?.getLoadedCells(from: index - 1, to: index + 1) else { return }
        var previousSrn : String? = nil
        if isFromAppState == false {
            previousSrn = self.previousActiveSrn
        }
        cells.forEach { cell in
            cell.sendActivePageStateToWeb(forceIsActive : forceIsActive, srn: srn, index: index, shortsListModel: self.getShortsListDataForV2ActivePage(), previousSrn: previousSrn)
        }
        self.previousActiveSrn = srn
    }
    
    func postHandleShareNotification(payload : [String : Any]?) {
        ShopLiveLogger.tempLog("[SHAHRE] payload \(payload)")
        if let url = payload?["url"] as? String {
            self.onShareWithUrl(url: url)
        }
        else if let shorts = payload?["shorts"] as? [String : Any],
                let shortsDetail = shorts["shortsDetail"] as? [String : Any] {
            self.onShareWithShortsModel(shorts: shorts, shortsDetail: shortsDetail)
        }
    }
    
    func postRequestShortsPreview(url : String?, srn : String?){
        ShopLiveShortform.BridgeInterface.requestShortsPreview(url: url, srn: srn)
    }
    
    func postCloseShortsDetail(srn : String?){
        ShopLiveShortform.BridgeInterface.closeShortsDetail(srn: srn)
    }
    
    func postMoveToProductPageNotification(shortsId : String?, srn : String?, productModel : SLProduct) {
        guard let shortsId = shortsId,
              let srn = srn else { return }
        
        shortformDelegate?.handleProductItem?(shortsId: shortsId, shortsSrn: srn, product: productModel.toProductData())
//        ShopLiveShortform.Delegate.receiveHandler.delegate?.handleProductItem?(shortsId: shortsId, shortsSrn: srn, product: productModel.toProductData())
        ShopLiveShortform.BridgeInterface.handleMoveToProductPage(shortsId: shortsId, srn: srn, product: productModel)
        
    }
    
    func postMoveToProductBannerPageNotification(scheme : String?, srn : String?, shortsId : String?, shortsDetailModel : SLShortsDetail) {
        guard let scheme = scheme,
              let srn = srn,
              let shortsId = shortsId else { return }
        shortformDelegate?.handleProductBanner?(shortsId: shortsId, shortsSrn: srn, scheme: scheme)
//        ShopLiveShortform.Delegate.receiveHandler.delegate?.handleProductBanner?(shortsId: shortsId, shortsSrn: srn, scheme: scheme, shortsDetail: shortsDetailModel.toShortsDetailData())
        ShopLiveShortform.BridgeInterface.handleMoveToProductBannerPage(shortsId: shortsId, srn: srn, scheme: scheme, shortsDetail: shortsDetailModel)
        
    }
}
//MARK: -Share관련 handler 함수들
extension ShortsCollectionBaseViewModel {
    private func onShareWithUrl(url : String) {
        if let handleShare = shortformDelegate?.handleShare?(shareUrl: url) {
            handleShare
        }
        else {
            self.delegate?.openOsShareSheet(url: url)
        }
    }
    
    private func onShareWithShortsModel(shorts : [String : Any] ,shortsDetail : [String : Any]) {
        let shareMeteData = ShopLiveShareMetaData()
        shareMeteData.descriptions = shortsDetail["description"] as? String
        let brand = shortsDetail["brand"] as? [String : Any]
        shareMeteData.thumbnail = brand?["imageUrl"] as? String
        shareMeteData.title = shortsDetail["title"] as? String
        shareMeteData.shortsId = shorts["shortsId"] as? String
        shareMeteData.shortsSrn = shorts["srn"] as? String
        
        if let handleShare = shortformDelegate?.handleShare?(shareMetadata: shareMeteData) {
            handleShare
        }
    }
}
//MARK: - reload Functions
extension ShortsCollectionBaseViewModel {
    func appendShortsListData(_ shortsList: [SLShortsModel], reset: Bool = false, scrollToPage : Int? = nil) {
        if reset {
            if let scrollToPage = scrollToPage {
                self.scrollToPage = scrollToPage
            }
            else {
                self.scrollToPage  = 0
            }
            self.lastShortsCount = 0
            self.originShortsListData = shortsList
        } else {
            self.lastShortsCount = self.shortsListData.count
            self.originShortsListData += shortsList
        }
    }
    
    
    //v2 overrided
    @objc func reloadData(){
        guard self.lastShortsCount == 0 else { return }
        delegate?.reloadData(completion: { [weak self] in
            guard let self = self else { return }
            self.lastShortsCount = self.shortsListData.count
            self.delegate?.setScrollEnabled(isEnabled: isSwipable)
            self.postEnableTapNotification()
            if self.shortsMode == .preview {
                self.postPreviewShowNotification()
            }
        })
    }
    
    //v2 override
    @objc func appendCells() {
        guard let latestIndex = latestCell.indexPath?.row else { return }
        if latestIndex != self.lastShortsCount - 1 { return }
        delegate?.insertItemsWithOutAnimation(updateIndexPaths: self.getUpdatingIndexPaths())
        lastShortsCount = shortsListData.count
        delegate?.setScrollEnabled(isEnabled: self.isSwipable)
        self.postEnableTapNotification()
    }
    
    func getUpdatingIndexPaths() -> [IndexPath] {
        if lastShortsCount > 0 {
            return (lastShortsCount..<shortsListData.count).map{ IndexPath(row: $0, section: 0) }
        }
        else {
            return (0..<3).map{ IndexPath(row: $0, section: 0) }
        }
    }
    
    func removeData(where shortsIdOrSrn : String,collectionView : UICollectionView) {
        self.removeShortformByShortsId(shortsIdOrSrn: shortsIdOrSrn, cv: collectionView)
    }
    
}
//MARK: - Network functions
extension ShortsCollectionBaseViewModel {
    func callShortsConfigurationAPI( completion : @escaping(_ isSucess : Bool) -> ()) {
        ShortFormConfigurationInfosManager.shared.callShortsConfigurationAPI { [weak self] result in
            guard let self = self else { return }
            self.setShortsConfiguration()
            switch result {
            case .success(let isRenewed):
                if isRenewed {
                    self.configureAudioSessionManager()
                }
                completion(true)
            case .failure(let error):
                ShopLiveShortform.close()
                self.onError(error)
                completion(false)
            }
        }
    }
}
//MARK: -AppStateObserver
extension ShortsCollectionBaseViewModel : ShopliveAppStateObserverDelegate {
    func handleAppStateNotification(appState: SLAppState) {
        // print("appState \(appState)")
        switch appState {
        case .didEnterForeground:
            self.handleAppDidEnterForeground()
            break
        case .orientationDidChange:
            break
        case .enterLockScreen:
            break
        case .leaveLockScreen:
            break
        case .willEnterForeground:
            self.handleAppWillEnterForeground()
            break
        case .willEnterBackground:
            self.handleAppWillEnterBackground()
        case .didEnterBackground:
            self.handleAppDidEnterBackground()
        case .none:
            break
        }
    }
    
    private func handleAppWillEnterForeground() {
        postOnForegroundNotification()
    }
    
    private func handleAppDidEnterForeground() {
        delegate?.setScrollEnabled(isEnabled: isSwipable)
        guard let currentIndexPath = delegate?.getCurrentIndexPath() else { return }
        guard let data = shortsListData[safe: currentIndexPath.row] else { return }
        self.postActivePageNotification(srn: data.srn, index: currentIndexPath.row,isFromAppState: true)
        guard let cell = delegate?.getCellForAt(indexPath: currentIndexPath),
              let currentCell = cell as? ShortsCell else { return }
        currentCell.play(skipIfPaused: false)
    }
    
    private func handleAppWillEnterBackground() {
        postOnBackGroundNotification()
        guard let currentIndexPath = delegate?.getCurrentIndexPath() else { return }
        guard let data = shortsListData[safe: currentIndexPath.row] else { return }
        self.postActivePageNotification(forceIsActive: false, srn: data.srn, index: currentIndexPath.row,isFromAppState: true)
        guard ShopLiveShortform.enableResumeOnForeGround else { return }
        guard let cells = delegate?.getLoadedCells(from: currentIndexPath.row - 1, to: currentIndexPath.row + 1) else { return }
        cells.forEach { cell in
            cell.pause()
        }
    }
    
    private func handleAppDidEnterBackground() {
        postOnBackGroundNotification()
        guard let currentIndexPath = delegate?.getCurrentIndexPath() else { return }
        self.postActivePageNotification(forceIsActive: false, srn: shortsListData[currentIndexPath.row].srn, index: currentIndexPath.row,isFromAppState: true)
        guard let cells = delegate?.getLoadedCells(from: currentIndexPath.row - 1, to: currentIndexPath.row + 1) else { return }
        cells.forEach { cell in
            cell.pause()
        }
    }
}

