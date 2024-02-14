//
//  ShortsCollectionViewModelInterface.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/29/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon


protocol ShortsCollectionBaseViewModelDelegate : NSObject {
    func reloadData(completion : (() -> ())?)
    func insertItemsWithOutAnimation(updateIndexPaths : [IndexPath])
    func setScrollEnabled(isEnabled : Bool)
    func onViewAppeared()
    func setCloseBtnVisible(isVisible : Bool)
    func playToPage(index : Int)
    func playWhenNetworkReconnected()
}


class ShortsCollectionBaseViewModel {
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
    
    
    typealias ShortsCollectionModel = ShopLiveShortform.ShortsCollectionModel
    typealias ShortsModel = ShopLiveShortform.ShortsModel
    typealias ShortsMode = ShopLiveShortform.ShortsMode
    
    weak var delegate : ShortsCollectionBaseViewModelDelegate?
    
    var networkMonitor = NetworkMonitor()
    var networkAvailable: Bool? = true
    var latestCell: LatestShortsCell = LatestShortsCell()
    var scrollToPage : Int? = nil
    let appStateObserver = AppStateObserver()
    
    
    //for relatedShorts
    var relatedRequestData : InternalShortformRelatedData?
    var collectionRequestData : InternalShortformCollectionData?
    var currentApiType : ShortsApiType = .normal
    var isFullNative : Bool = false
    
    //for rotation
    var capturedCurrentIndexPathForRotation : IndexPath?
    var blockScrollViewDidScrollForRotation : Bool = false
    var isOnRotation : Bool = false
    
    //data
    var shortsCollection: ShortsCollectionModel?
    var lastShortsCount: Int = 0
    var originShortsListData : [ShortsModel] = [] {
        didSet {
            self.reloadData()
        }
    }
    var shortsListData : [ShortsModel] {
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
    
    //currentDatas
    var currentShorts : ShortsModel? {
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
              let overlayUrl = self.getOverlayUrl(at: currentIndex, shortsModel: shortsListData[safe: currentIndex.row])  else { return nil }
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
    var isMuted : Bool = false {
        didSet {
            self.postMuteShortsNotification()
            self.setLatestCellMuted(isMuted: isMuted)
        }
    }
    
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
    
    
    //size
    var superviewSize : CGSize? = nil
    var verticalCollectionBounds: CGSize = UIScreen.main.bounds.size
    var horizontalCollectionBounds : CGSize = UIScreen.main.bounds.size.transpolate_SL
    
    //webviews
    private var webViewLists :  [ String : ShopLiveShortform.PreloadWebView] = [:]
    
    init(shopliveSessionId : String?) {
        self.shopliveSessionId = shopliveSessionId
        self.webViewLists.removeAll()
        appStateObserver.delegate = self
        bindNetworkMonitorResult()
    }
    
    init(shorts : [ShortsModel],shopliveSessionId : String?) {
        self.webViewLists.removeAll()
        self.originShortsListData = shorts
        self.shopliveSessionId = shopliveSessionId
        appStateObserver.delegate = self
        bindNetworkMonitorResult()
    }
    
    deinit {
        self.latestCell.setLatest()
        self.webViewLists.removeAll()
        appStateObserver.delegate = nil
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
    func getShortsListDataForV2ActivePage() -> [ShortsModel]? {
        return nil
    }
}
extension ShortsCollectionBaseViewModel {
    func isLast(indexPath: IndexPath) -> Bool {
        guard shortsListData.count > 1 else { return true }
        return indexPath.row == shortsListData.count - 1
    }
    
    func setShortsConfiguration() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let configPreviewUseCloseBtn = ShortFormConfigurationInfosManager.shared.shortsConfiguration.previewUseCloseButton
            self.delegate?.setCloseBtnVisible(isVisible: self.shortsMode == .preview && configPreviewUseCloseBtn)
        }
    }
}
//MARK: - setter functions
extension ShortsCollectionBaseViewModel {
    func setLatestCellMuted(isMuted : Bool) {
        self.latestCell.latestCell?.setMute(isMuted)
    }
    
    func setShopLiveSessionId(sessionId : String?) {
        self.shopliveSessionId = sessionId
    }
}
//MARK: - getter functions
extension ShortsCollectionBaseViewModel {
    func getShortsItemIndex(_ item : ShortsModel?) -> Int? {
        return shortsListData.firstIndex(where:  { $0 == item })
    }
    
    func getNextShortItemIndex(_ item: ShortsModel?) -> Int? {
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
    
    func getOverlayUrl(at indexPath : IndexPath, shortsModel : ShortsModel?) -> URL? {
        var payload: String = ""
        do {
            let shortsDict = try shortsModel.toDictionary_SL()
            var payloadDict: [String: Any] = ["shorts": shortsDict]
            
            if let userJWT = ShortFormAuthManager.shared.getuserJWT() {
                payloadDict["userJWT"] = userJWT
            }
            else if let guestUid = ShortFormAuthManager.shared.getGuestUId() {
                payloadDict["guestUid"] = guestUid
            }
            
            if let referrer = ShortFormAuthManager.shared.getReferrer() {
                payloadDict["referrer"] = referrer
            }
            
            if let adIdentifier = ShopLiveCommon.getAdIdentifier(), !adIdentifier.isEmpty {
                payloadDict["adIdentifier"] = adIdentifier
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
            payloadDict["ids"] = self.shortsListData.compactMap({ $0.shortsId }).joined(separator: ",")
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
            
            
            ShortFormAuthManager.shared.getAkAndUserJWTasDict().forEach { payloadDict[$0.key] = $0.value }
            
            if let shortJson = payloadDict.toJson_SL()  {
                payload = shortJson
            } else {
                return nil
            }
        } catch {
            return nil
        }
        
        
        let urlString: String = ShortFormConfigurationInfosManager.shared.shortsConfiguration.detailUrl
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
    
}
//MARK: - WebViewPool function
extension ShortsCollectionBaseViewModel {
    func updateWebViewPoolForReconnection(currentIndex : IndexPath) {
        guard let data = shortsListData[safe : currentIndex.row],
              let shortsId = data.shortsId,
              let webview = self.webViewLists[shortsId] else { return }
        webview.loadWebView()
    }
    
    func loadWebViewsFor(indexPath : [IndexPath]) {
        indexPath.forEach { indexpath in
            guard let data = shortsListData[safe : indexpath.row] else { return }
            guard let shortsId = data.shortsId else { return }
            if self.webViewLists[shortsId] == nil {
                if let url = self.getOverlayUrl(at: indexpath, shortsModel: data) {
                    let webView = ShopLiveShortform.PreloadWebView()
                    webView.url = url.absoluteString
                    webView.loadWebView()
                    self.webViewLists[shortsId] = webView
                }
            }
        }
    }
    
    func deleteWebViewsWhenCellDidEndDisplaying(indexPath : IndexPath) {
        guard let data = shortsListData[safe : indexPath.row] else { return }
        guard let shortsId = data.shortsId else { return }
        self.webViewLists.removeValue(forKey: shortsId)
    }
    
    func getWebview(for shortsId : String) -> SLWebView {
        if let webView = self.webViewLists[shortsId] {
            return webView.webview
        }
        else {
            return SLWebView()
        }
    }
    
    func removeAllWebViewLists(){
        self.webViewLists.removeAll()
    }
}
//MARK: - Notifications
extension ShortsCollectionBaseViewModel {
    
    func onError(_ error: ShopLiveCommonError) {
        NotificationCenter.default.post(Notification(name: Notification.Name("onError"), object: nil, userInfo: ["error": error]))
    }
    
    func postEnableTapNotification() {
        NotificationCenter.default.post(Notification(name: Notification.Name("enableTap"), object: nil, userInfo: ["enable": ShopLiveShortform.ShortsMode.preview == self.shortsMode]))
    }
    
    func postPreviewShowNotification() {
        NotificationCenter.default.post(Notification(name: Notification.Name("previewShown"), object: nil, userInfo: ["shorts": self.currentShorts as Any]))
    }
    
    func postMuteShortsNotification() {
        NotificationCenter.default.post(Notification(name: Notification.Name("muteShorts"), object: nil, userInfo: ["mute": self.isMuted]))
    }
    
    func postOnForegroundNotification() {
        guard let srn = currentShortsSrn else { return }
        NotificationCenter.default.post(Notification(name: Notification.Name("onChangedAppState"), object: nil, userInfo: ["srn": srn, "state": "foreground"]))
    }
    
    func postOnBackGroundNotification() {
        guard let srn = currentShortsSrn else { return }
        NotificationCenter.default.post(Notification(name: Notification.Name("onChangedAppState"), object: nil, userInfo: ["srn": srn, "state": "background"]))
    }
    
    func postPreviewCloseNotification() {
        NotificationCenter.default.post(Notification(name: Notification.Name("previewClose"), object: nil, userInfo: ["shorts": self.currentShorts as Any]))
    }
    
    func postStopVideoNotification() {
        NotificationCenter.default.post(Notification(name: Notification.Name("stopVideo")))
    }
    
    func postTakeSnapShotNotification() {
        NotificationCenter.default.post(Notification(name: Notification.Name("takeSnapshot"), object: nil, userInfo: ["srn": (self.currentShortsSrn ?? nil) as Any ]))
    }
    
    func postModeChangeNotification() {
        NotificationCenter.default.post(Notification(name: Notification.Name("modeChange"), object: nil, userInfo: ["mode": shortsMode]))
    }
    
    /**
     v2 overrided
     */
    @objc func postActivePageNotification(srn : String?, index : Int) {
        NotificationCenter.default.post(Notification(name: Notification.Name("activePage"), object: nil, userInfo: ["srn": srn, "index": index]))
    }
    
    func postHandleShareNotification(payload : [String : Any]?) {
        NotificationCenter.default.post(Notification(name: Notification.Name("handleShare"), userInfo: payload))
    }
    
    func postRequestShortsPreview(url : String?, srn : String?){
        NotificationCenter.default.post(Notification(name: Notification.Name("requestShortsPreview"), userInfo: ["url": url, "srn" : srn]))
    }
    
    func postCloseShortsDetail(srn : String?){
        NotificationCenter.default.post(Notification(name: Notification.Name("closeShortsDetail"), userInfo: ["srn" :srn]))
    }
    
    func postMoveToProductPageNotification(shortsId : String?, srn : String?, productModel : Product) {
        let postNotiName = Notification.Name(rawValue: "moveToProductPage")
        NotificationCenter.default.post(name: postNotiName, object: nil,userInfo: ["shortsId" : shortsId, "srn" : srn, "productModel" : productModel])
    }
    
    func postMoveToProductBannerPageNotification(scheme : String?, srn : String?, shortsId : String?, shortsDetailModel : ShortsDetail) {
        let postNotiName = Notification.Name("moveToProductBannerPage")
        NotificationCenter.default.post(Notification(name: postNotiName , userInfo: ["scheme": scheme , "srn" : srn, "shortsId" : shortsId, "shortsDetail" : shortsDetailModel ]))
    }
    
    
}
//MARK: - reload Functions
extension ShortsCollectionBaseViewModel {
    func appendShortsListData(_ shortsList: [ShortsModel], reset: Bool = false, scrollToPage : Int? = nil) {
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
    
    func reloadData(){
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
    
}
//MARK: - Network functions
extension ShortsCollectionBaseViewModel {
    func callShortsConfigurationAPI( completion : @escaping(_ isSucess : Bool) -> ()) {
        ShortFormConfigurationInfosManager.shared.callShortsConfigurationAPI { [weak self] result in
            guard let self = self else { return }
            self.setShortsConfiguration()
            switch result {
            case .success():
                completion(true)
            case .failure(let error):
                self.onError(error)
                completion(false)
            }
        }
    }
    
}
//MARK: -AppStateObserver
extension ShortsCollectionBaseViewModel : AppStateObserverDelegate {
    func handleAppStateNotification(appState: SLAppState) {
        // print("appState \(appState)")
        switch appState {
        case .didEnterForeground:
            delegate?.setScrollEnabled(isEnabled: isSwipable)
            break
        case .orientationDidChange:
            break
        case .enterLockScreen:
            break
        case .leaveLockScreen:
            break
        case .willEnterForeground:
            postOnForegroundNotification()
            break
        case .willEnterBackground:
            postOnBackGroundNotification()
        case .didEnterBackground:
            postOnBackGroundNotification()
        case .none:
            break
        }
    }
}
