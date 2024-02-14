//
//  ShopLiveShortformVerticalTypeViewReactor.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/05/02.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon

/**
 버티컬 타입  뷰 리액터
 -> 카드 타입 리액터와 거의 같음 카드 뷰 리액터 참고할 것
 */
final class ShopLiveShortformVerticalTypeViewReactor : NSObject, SLReactor {
    
    
    enum Action {
        case setCollectionView(UICollectionView)
        case setCardViewType(ShopLiveShortform.CardViewType)
        case setCellSpacing(CGFloat)
        case setSnap(Bool)
        case setEnableAutoPlay(Bool)
        case setIsPlayOnlyOnWifi(Bool)
        case calculateCellSize
        case pullToRefresh
        case setTagsAndBrandsRequestParameterModel(InternalShortformCollectionData?)
        case reloadItem
        case initializeShortsSetting
        case setCellViewHideOptionModel(ShopLiveListCellViewHideOptionModel)
        case setCellRadius(CGFloat)
        case setAvAudioSessionCategoryOptions(AVAudioSession.CategoryOptions?)
        case setCellBackgroundColor(UIColor)
        case notifyViewRotated
    }
    
    enum Result {
        case setSectionInset(UIEdgeInsets)
        case setCellSize(CGSize)
        case onError(Error)
        case endPullToRefresh
        case hideEmptyView(Bool)
        case invalidateCVLayout
    }
    
    var resultHandler: ((Result) -> ())?
    var asyncResultHandler : ((Result) -> ())?
    
    
    //MARK: -Attributes
    private let networkMonitor = NetworkMonitor()
    private var throttle = ShopLiveShortform.Throttle(queue: DispatchQueue.init(label: "pagingThrottle",qos: .background), delay: 1)
    private var currentCardViewType : ShopLiveShortform.CardViewType = .type1
    private var collectionView : UICollectionView?
    private var cellSize : CGSize = .zero
    private var cellSpacing : CGFloat = 8
    private var isSnapEnabled : Bool = false
    private var currentCenteredIndex : CGFloat = 0
    private var playOnIntialLoad : Bool = true
    private var shortsCollectionModel : ShopLiveShortform.ShortsCollectionModel?
    private var shortsListModel : [ShopLiveShortform.ShortsModel] = []
    private var isAutoPlayerEnabled : Bool = true
    private var isPlayOnOnlyWifi : Bool = false
    private var networkConnectionType : NetworkMonitor.ConnectionType = .cellular
    private var isLoadingMoreContents : Bool = false
    private var tagsAndBrandRequestParameterModel : InternalShortformCollectionData?
    private var cellViewHideOptionModel = ShopLiveListCellViewHideOptionModel()
    private var cellRadius : CGFloat = 12
    private var currentAvAudioSessionCategoryOptions : AVAudioSession.CategoryOptions?
    private var currentCellBackgroundColor : UIColor?
    private var currentApiRefrence : String? {
        get {
            guard let model = shortsCollectionModel else { return nil }
            return model.reference
        }
    }
    private var serverHasMoreContent : Bool {
        get {
            guard let model = shortsCollectionModel else { return false }
            return model.hasMore ?? false
        }
    }
    private var shopliveSessionId : String?
    
    
    
    override init(){
        super.init()
        self.handleNetworkMonitorResult()
    }
    
    private func handleNetworkMonitorResult(){
        self.networkMonitor.resultHandler = { [weak self] type in
            switch type {
            case .statusChanged(let result):
                self?.networkConnectionType = result
            }
        }
    }
    
    
    
    func action(_ action: Action) {
        switch action {
        case .setCardViewType(let cardViewType):
            self.setCardViewType(cardViewType: cardViewType)
        case .setCollectionView(let collectionView):
            self.setCollectionView(cv: collectionView)
        case .setCellSpacing(let spacing):
            self.adjustCellSpacing(spacing: spacing)
        case .setSnap(let isEnabled):
            self.isSnapEnabled = isEnabled
        case .setEnableAutoPlay(let isEnabled):
            self.setEnableAutoPlay(isEnabled: isEnabled)
        case .setIsPlayOnlyOnWifi(let playOnlyOnWifi):
            self.isPlayOnOnlyWifi = playOnlyOnWifi
        case .calculateCellSize:
            self.calculateCellSize()
        case .pullToRefresh, .reloadItem:
            self.callShortCollectionAPI(isRefresh: true)
        case .setTagsAndBrandsRequestParameterModel(let model):
            self.tagsAndBrandRequestParameterModel = model
        case .initializeShortsSetting:
            self.initalizeShortsSettings()
        case .setCellViewHideOptionModel(let model):
            self.setCellViewHideOptionModel(model: model)
        case .setCellRadius(let radius):
            self.cellRadius = radius
        case .setAvAudioSessionCategoryOptions(let option):
            self.currentAvAudioSessionCategoryOptions = option
            self.setAudioSession()
        case .setCellBackgroundColor(let color):
            self.currentCellBackgroundColor = color
        case .notifyViewRotated:
            self.calculateCellSize()
            self.resultHandler?(.invalidateCVLayout)
        }
    }
    
    private func setAudioSession(){
        if let option = currentAvAudioSessionCategoryOptions {
            AudioSessionManager.shared.setCategory(category: .playback, options: option)
        }
        else {
            AudioSessionManager.shared.setCategory(category: .playback, options: .mixWithOthers)
        }
        
    }
    
    private func pauseAllCell(){
        guard let collectionView = collectionView else { return }
        (collectionView.visibleCells as! [ShopLiveShortformBaseListTypeViewCell]).forEach { cell in
            cell.stopVideo()
        }
    }
    
    private func setEnableAutoPlay(isEnabled : Bool){
        self.isAutoPlayerEnabled = isEnabled
        if let cv = self.collectionView {
            if isEnabled == false, let cells = cv.visibleCells as? [ShopLiveShortformCardViewCell] {
                for cell in cells {
                    cell.stopVideo()
                }
            }
            else if isEnabled == true  {
                playVideoOnCenteredCell(cv)
            }
        }
    }
    
    private func setCollectionView(cv : UICollectionView){
        self.collectionView = cv
        cv.dataSource = self
        cv.delegate = self
        cv.register(ShopLiveShortformBaseListTypeViewCell.self, forCellWithReuseIdentifier: ShopLiveShortformBaseListTypeViewCell.cellId)
        cv.reloadData()
    }
    
    private func adjustCellSpacing(spacing : CGFloat){
        self.cellSpacing = spacing
        resultHandler?(.setSectionInset(UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)))
        self.calculateCellSize()
        self.collectionView?.reloadData()
    }
    
    private func calculateCellSize(){
        guard let collectionView = self.collectionView else { return }
        let boundWidth = collectionView.frame.width
        var bottomStackHeight : CGFloat = 0
        if cellViewHideOptionModel.isTitleVisible {
            bottomStackHeight += 8 + 36
        }
        if cellViewHideOptionModel.isBrandVisible {
            bottomStackHeight += 28 + 4 + 8
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad || UIScreen.isLandscape_SL {
            let cellWidth = floor((boundWidth - (4 * cellSpacing)) / 3)
            let cellHeight = cellWidth * 1.5
            cellSize = CGSize(width: cellWidth, height: cellHeight + bottomStackHeight)
        }
        else {
            let cellWidth = floor((boundWidth - (3 * cellSpacing)) / 2)
            let cellHeight = cellWidth * 1.5
            cellSize = CGSize(width: cellWidth, height: cellHeight + bottomStackHeight)
        }
        resultHandler?(.setCellSize(cellSize))
    }
    
    private func setCardViewType(cardViewType : ShopLiveShortform.CardViewType){
        self.currentCardViewType = cardViewType
        self.collectionView?.reloadData()
        
    }
    
    
    private func checkIfPlayOnWifiViaAvailable() -> Bool {
        if self.isPlayOnOnlyWifi == true && self.networkConnectionType != .wifi {
            return false
        }
        return true
    }
    
    private func setCellViewHideOptionModel(model : ShopLiveListCellViewHideOptionModel){
        self.cellViewHideOptionModel = model
        self.calculateCellSize()
    }
    
    
}
extension ShopLiveShortformVerticalTypeViewReactor : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ShopliveShortformListViewCellDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shortsListModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopLiveShortformBaseListTypeViewCell.cellId, for: indexPath) as! ShopLiveShortformBaseListTypeViewCell
        let model = shortsListModel[indexPath.row]
        let acitviyModel = model.activity!
        let shortsDetailModel = model.shortsDetail!
        let cardModel = model.cards!.first!
        let viewCount  = "\((acitviyModel.viewCount ?? 0).addCommas_SL())"
        var productCountString : String = ""
        let productCount = shortsDetailModel.productCount ?? 0
        
        cell.refreshPlayer()
        
        cell.setCardViewType(cardViewType: self.currentCardViewType)
        
        let videoUrl : String? = cardModel.previewVideoUrl
        var title = shortsDetailModel.title ?? ""
        title = title.replacingOccurrences(of: " ", with: "\u{00A0}")
        var brand = shortsDetailModel.brand?.name ?? ""
        brand = brand.replacingOccurrences(of: " ", with: "\u{00A0}")
        
        
        cell.configureCell(title: title,
                           userThumbnail: shortsDetailModel.brand?.imageUrl ?? "",
                           userName: brand,
                           productModel: shortsDetailModel.products?.first,
                           productCount: productCount,
                           viewCount: viewCount,
                           posterImageUrl: cardModel.screenshotUrl,
                           videoURL: videoUrl,
                           currentMediaType: cardModel.cardType ?? "VIDEO",
                           viewHideOption: cellViewHideOptionModel,
                           cellCornerRadius: cellRadius,
                           backgroundColor: currentCellBackgroundColor)
        
        cell.delegate = self
        
        if playOnIntialLoad && isAutoPlayerEnabled && checkIfPlayOnWifiViaAvailable() {
            if UIDevice.current.userInterfaceIdiom == .pad {
                if indexPath.row <= 2 {
                    cell.playVideo()
                }
                else {
                    playOnIntialLoad = false
                }
            }
            else {
                if indexPath.row <= 1 {
                    cell.playVideo()
                }
                else {
                    playOnIntialLoad = false
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ShopLiveShortformCardViewCell {
            cell.stopVideo()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == (self.shortsListModel.count - 1) && serverHasMoreContent && isLoadingMoreContents == false {
            isLoadingMoreContents = true
            throttle.callAsFunction { [weak self] in
                self?.callShortCollectionAPI()
            } onCancel: {
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = shortsListModel[indexPath.row]
        let shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        ShortformNativeOnEventsManager.sendNativeOnEvents(command: .collection_click_item, payload: ["position" : indexPath.row], shortsId: model.shortsId, shortsDetail: model.shortsDetail)
        ShortformEventTraceManager.processCollectionClickItemEventTrace(shortCollectionSrn: shortsCollectionModel?.srn, shortsSrn: model.srn, shopliveSessionId: shopliveSessionId)
        ShopLiveShortform.playNormalFullScreen(shortsId: model.shortsId, shortsSrn: model.srn, requestModel: self.tagsAndBrandRequestParameterModel,shopliveSessionId: shopliveSessionId)
        self.pauseAllCell()
    }
    
    func onCellError(error: Error) {
        resultHandler?(.onError(error))
    }
}
extension ShopLiveShortformVerticalTypeViewReactor {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard isSnapEnabled == true else { return }
        guard let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        let cellHeight = layout.itemSize.height + cellSpacing
        
        let topPadding : CGFloat = (scrollView.bounds.height - (cellHeight + cellSpacing)) / 2
        
        var nextIndex : CGFloat = 0
        if velocity.y > 0 { //아래로 내릴때
            nextIndex = min(currentCenteredIndex + 1, CGFloat(self.shortsListModel.count - 1))
        }
        else if velocity.y < 0 { //위로 올릴때
            nextIndex = max(0,currentCenteredIndex - 1)
        }
        else {
            nextIndex = round(targetContentOffset.pointee.y / cellHeight)
        }
        let targetOffsetY = nextIndex * cellHeight - topPadding
        
        
        targetContentOffset.pointee = CGPoint(x: layout.sectionInset.left, y: targetOffsetY )
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        let cellHeight = layout.itemSize.height + cellSpacing
        currentCenteredIndex = round((scrollView.contentOffset.y + cellSpacing) / cellHeight)
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cv = scrollView as? UICollectionView {
            playVideoOnCenteredCell(cv)
        }
    }
    
    private func playVideoOnCenteredCell(_ collectionView : UICollectionView){
        
        guard self.isAutoPlayerEnabled && checkIfPlayOnWifiViaAvailable() else { return }
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.checkCenteredCellByIpad(collectionView)
        }
        else {
            self.checkCenteredCellByIphone(collectionView)
        }
    }
    
    private func checkCenteredCellByIpad(_ collectionView : UICollectionView){
        var leftCenteredIndexPath = IndexPath(row: 0, section: 0)
        var middleCenteredIndexPath = IndexPath(row: 1, section: 0)
        var rightCenteredIndexPath = IndexPath(row: 2, section: 0)
        if collectionView.contentOffset.y != 0 {
            let centerIndex = Int((collectionView.contentOffset.y + (collectionView.frame.height / 2)) / (cellSize.height + cellSpacing))
            //패드의 경우 한 줄에 3개씩 보이기 때문에 centerIndex에 3를 곱해줌
            leftCenteredIndexPath = IndexPath(row: centerIndex * 3, section: 0)
            middleCenteredIndexPath = IndexPath(row: (centerIndex * 3) + 1, section: 0)
            rightCenteredIndexPath = IndexPath(row: (centerIndex * 3) + 2, section: 0)
        }
        
        let visibleIndexPath = collectionView.indexPathsForVisibleItems
        for indexPath in visibleIndexPath {
            if let cell = collectionView.cellForItem(at: indexPath) as? ShopLiveShortformBaseListTypeViewCell {
                if indexPath == leftCenteredIndexPath ||
                    indexPath == rightCenteredIndexPath ||
                    indexPath == middleCenteredIndexPath {
                    cell.playVideo()
                }
                else {
                    cell.stopVideo()
                }
            }
        }
    }
    
    private func checkCenteredCellByIphone(_ collectionView : UICollectionView){
        let centerIndex = Int((collectionView.contentOffset.y + (collectionView.frame.height / 2)) / (cellSize.height + cellSpacing))
        let leftCenteredIndexPath = IndexPath(row: centerIndex * 2, section: 0)
        let rightCenteredIndexPath = IndexPath(row: (centerIndex * 2) + 1, section: 0)
        
        let visibleIndexPath = collectionView.indexPathsForVisibleItems
        for indexPath in visibleIndexPath {
            if let cell = collectionView.cellForItem(at: indexPath) as? ShopLiveShortformBaseListTypeViewCell {
                if indexPath == leftCenteredIndexPath ||
                    indexPath == rightCenteredIndexPath  {
                    cell.playVideo()
                }
                else {
                    cell.stopVideo()
                }
            }
        }
        
    }
    
}
extension ShopLiveShortformVerticalTypeViewReactor {
    private func initalizeShortsSettings(){
        ShortFormConfigurationInfosManager.shared.callShortsConfigurationAPI { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success():
                self.callShortCollectionAPI(isRefresh: true)
                break
            case .failure(let error):
                print("code: \(error.code) message : \(error.message) error : \(error.localizedDescription)")
                break
            }
        }
    }
    
    private func callShortCollectionAPI(isRefresh : Bool = false){
        
        if isRefresh == false && self.currentApiRefrence == nil {
            return
        }
        
        var reference : String = ""
        
        if isRefresh == false {
            reference = self.currentApiRefrence ?? ""
        }
        
        var count : Int = ShortFormConfigurationInfosManager.shared.shortsConfiguration.listApiInitializeCount
        if self.shortsListModel.count >= count {
            count = ShortFormConfigurationInfosManager.shared.shortsConfiguration.listApiPaginationCount
        }
        
        let tags = tagsAndBrandRequestParameterModel?.tags
        let tagSearchOperator = tagsAndBrandRequestParameterModel?.tagSearchOperator
        let brands = tagsAndBrandRequestParameterModel?.brands
        let shuffle = tagsAndBrandRequestParameterModel?.shuffle
        ShortsCollectionAPI(reference: reference,
                            count: count,
                            tags: tags,
                            tagSearchOperator: tagSearchOperator,
                            brands: brands,
                            shuffle: shuffle,
                            finite: true).request { [weak self] result in
            switch result {
            case .success(let response):
                self?.shortsCollectionModel = response
                guard let shortsListModel = response.shortsList else { return }
                self?.addShortListModel(dataList: shortsListModel, isRefresh: isRefresh)
                self?.callCollectionShowEventTrace(shortsListModel: shortsListModel, shortsCollection: response, isRefresh: isRefresh, paginationCount: count)
            case .failure(let error):
                self?.resultHandler?(.onError(error))
            }
        }
    }
    
    private func addShortListModel(dataList : [ShopLiveShortform.ShortsModel], isRefresh : Bool){
        if isRefresh {
            self.shortsListModel.removeAll()
            self.playOnIntialLoad = true
            ShortformNativeOnEventsManager.sendNativeOnEvents(command: .collection_show, payload: ["template" : "VERTICAL"], shortsId: nil, shortsDetail: nil)
        }
        else {
            self.playOnIntialLoad = false
            ShortformNativeOnEventsManager.sendNativeOnEvents(command: .collection_show, payload: ["template" : "VERTICAL"], shortsId: nil, shortsDetail: nil)
        }
        let startIndex = self.shortsListModel.count - 1
        self.shortsListModel.append(contentsOf: dataList)
        let endIndex = self.shortsListModel.count - 1
        
        self.resultHandler?(.hideEmptyView(self.shortsListModel.count == 0 ? false : true))
        DispatchQueue.main.async(flags: .barrier) { [weak self] in
            if isRefresh {
                self?.collectionView?.reloadData()
            }
            else {
                if startIndex >= endIndex || startIndex + 1 >= endIndex {
                    self?.collectionView?.reloadData()
                }
                else {
                    if self?.collectionView?.numberOfItems(inSection: 0) ?? 0 == self?.shortsListModel.count {
                        return
                    }
                    self?.collectionView?.performBatchUpdates({ [weak self] in
                        let addingIndexPath = ((startIndex + 1)...endIndex).map { row in
                            return IndexPath(row: row, section: 0)
                        }
                        self?.collectionView?.insertItems(at: addingIndexPath)
                    })
                }
            }
            self?.isLoadingMoreContents = false
            self?.resultHandler?(.endPullToRefresh)
        }
        
    }
    
    private func callCollectionShowEventTrace(shortsListModel : [ShopLiveShortform.ShortsModel], shortsCollection : ShopLiveShortform.ShortsCollectionModel?,isRefresh : Bool, paginationCount : Int ){
        var overlayType : ShortformEventTraceManager.OverlayType = .TYPE0
        switch self.currentCardViewType {
        case .type0:
            overlayType = .TYPE0
        case .type1:
            overlayType = .TYPE1
        case .type2:
            overlayType = .TYPE2
        }
        
        var sdkOptionData = ShopLiveShortformSDKOptionsData()
        sdkOptionData.isSnapEnabled = self.isSnapEnabled
        sdkOptionData.playableType = "FIRST"
        sdkOptionData.isViewCountVisible = cellViewHideOptionModel.isViewCountVisible
        sdkOptionData.isBrandVisible = cellViewHideOptionModel.isBrandVisible
        sdkOptionData.isTitleVisible = cellViewHideOptionModel.isTitleVisible
        sdkOptionData.isProductCountVisible = cellViewHideOptionModel.isProductCountVisible
        sdkOptionData.isDescriptionVisible = cellViewHideOptionModel.isDescriptionVisible
        
        
        if self.shopliveSessionId == nil {
            self.shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        }
        
        ShortformEventTraceManager.processCollectionShowEventTrace(shortsList: shortsListModel,
                                                                   shortsCollection: shortsCollection,
                                                                   listType: .VERTICAL,
                                                                   overlayType: overlayType,
                                                                   isReset: isRefresh,
                                                                   paginationCount: paginationCount,
                                                                   tagsAndBrandRequestParameterModel: self.tagsAndBrandRequestParameterModel,
                                                                   sdkOptionsData: sdkOptionData,
                                                                   shopliveSessionId: self.shopliveSessionId)
    }
    
}
extension ShopLiveShortformVerticalTypeViewReactor {
    
}
