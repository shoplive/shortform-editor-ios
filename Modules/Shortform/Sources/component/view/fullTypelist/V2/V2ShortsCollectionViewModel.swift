//
//  V2ShortsCollectionViewModel.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/30/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon

protocol V2ShortsCollectioViewModelDelegate : ShortsCollectionBaseViewModelDelegate {
    func requestDownwardPaginationData()
    func requestUpwardPaginationData()
    func hideEmptyDataView(hide : Bool)
    func insertCells(at indexPaths : [IndexPath])
}

class V2ShortsCollectionViewModel : ShortsCollectionBaseViewModel {
    
    var shortFormIdsList : [String] = []
    var shortFormIdPayloadDict : [String : [String : Any]?] = [:]
    private var requestedShortFormIdsList : [String] = []
    var isLoadingMoreData : Bool = false
    private var v2initalTargetShortsId: String?
    
    private var _isMuted : Bool = false
    override var isMuted: Bool {
        get {
            let audioSession = AudioSessionManager.shared.audioSession
            if audioSession.outputVolume == 0 {
                return true
            }
            return _isMuted
        }
        set {
            _isMuted = newValue
            self.setCellMuted(isMuted: newValue)
        }
    }
    
    weak var v2delegate : V2ShortsCollectioViewModelDelegate?
    var customerDownwardHasMore : Bool = true
    var customerUpwardHasMore : Bool = true
    override var hasMore: Bool {
        /**
         BaseViewModel에서 DETAIL_SHORTFORM_MORE_ENDED외 사용하는 경우 없음
         */
        return customerDownwardHasMore
    }
    var customApiError : Error?
    
    var scrollViewDidScrollPaginationBlockTimer : Timer?
    var scrollViewDidScrollPaginationBlockDuration : Double = 0.8
    var blockScrollViewDidScrollPagination : Bool = false
    
    enum PaginationDirection {
        case up
        case down
    }
    private var currentPaginationDirection : PaginationDirection = .down
    private var numberOfInsertedCellsAtFirstIndex : Int?
    
    
    deinit {
        ShopLiveLogger.memoryLog("v2shortscollectionviewmodel deinited")
    }
    
    func setInitialshortFormIdsData(shortformIdsData : ShopLiveShortformIdsData, completion: @escaping (() -> ())){
        ShopLiveLogger.publicLog("[ShopLiveShortformV2] 1. received shortformIdsData : \(shortformIdsData.ids?.map({ $0.shortsId }) )")
        
        if let ids = shortformIdsData.ids {
            ids
                .filter{ $0.shortsId != "" }
                .forEach { idData in
                    shortFormIdsList.append(idData.shortsId)
                    shortFormIdPayloadDict[idData.shortsId] = idData.payload
                }
        }
        else {
            self.requestedShortFormIdsList.removeAll()
            self.shortFormIdsList.removeAll()
        }
        
        ShopLiveLogger.publicLog("[ShopLiveShortformV2] 2. received currentID : \(shortformIdsData.currentId ?? "nil value")")
        
        if let currentShortsId = shortformIdsData.currentId,let index = self.shortFormIdsList.firstIndex(of: currentShortsId) {
            ShopLiveLogger.publicLog("[ShopLiveShortformV2] 2-1. landing Index -> \(index), currentShortsId \(currentShortsId) ")
            self.scrollToPage = index
            self.initialTargetShortsId = currentShortsId
            self.v2initalTargetShortsId = currentShortsId
            
        }
        else {
            ShopLiveLogger.publicLog("[ShopLiveShortformV2] 2-2. scrollToPage set to nil ")
            self.scrollToPage = nil
        }
        
        if shortFormIdsList.count == 0 {
            ShopLiveLogger.publicLog("[ShopLiveShortformV2] 3. shortFormIdsList count is zero ")
            self.shortformDelegate?.onEvent?(messenger: nil, command: "DETAIL_EMPTY", payload: nil)
            self.v2delegate?.hideEmptyDataView(hide: false)
        }
        else {
            self.v2delegate?.hideEmptyDataView(hide: true)
            if let startIndex = self.scrollToPage {
                ShopLiveLogger.publicLog("[ShopLiveShortformV2] 3-1. scrollToPage is NOT nil")
                
                ShopLiveLogger.publicLog("[ShopLiveShortformV2] 4-1. startIndex : \(startIndex)")
                
                if startIndex < 3 {
                    
                    ShopLiveLogger.publicLog("[ShopLiveShortformV2] 5. startIndex in to [startIndex < 3] : \(startIndex)")
                    
                    self.requestedShortFormIdsList.append(contentsOf: self.shortFormIdsList.prefix(5))
                }
                else if startIndex > ((self.shortFormIdsList.count - 1) - 3) {
                    
                    ShopLiveLogger.publicLog("[ShopLiveShortformV2] 5-1. startIndex in to [startIndex > ((self.shortFormIdsList.count - 1) - 3)] : \(startIndex)")
                    
                    self.requestedShortFormIdsList.append(contentsOf: self.shortFormIdsList.suffix(5))
                }
                else {
                    
                    ShopLiveLogger.publicLog("[ShopLiveShortformV2] 5-2. startIndex in to else : \(startIndex)")
                    
                    ((startIndex - 2)...(startIndex + 2))
                        .compactMap{ self.shortFormIdsList[safe:$0] }
                        .forEach { shortsId in
                            requestedShortFormIdsList.append(shortsId)
                        }
                }
                
                //배열이 변경되었으므로 scrollToPage도 변경된 배열에 맞춰서 수정
                if let scrollToPageShortsId = shortformIdsData.currentId, let newScrollToPageIndex = self.requestedShortFormIdsList.firstIndex(of: scrollToPageShortsId) {
                    ShopLiveLogger.publicLog("[ShopLiveShortformV2] 6. landing Index rearranged -> \(newScrollToPageIndex), currentShortsId \(scrollToPageShortsId) ")
                    self.scrollToPage = newScrollToPageIndex
                }
                
                ShopLiveLogger.publicLog("[ShopLiveShortformV2] 7. requestedShortFormIdsList : \(startIndex)")
            }
            else {
                
                ShopLiveLogger.publicLog("[ShopLiveShortformV2] 3-2. scrollToPage is nil")
                
                self.requestedShortFormIdsList.append(contentsOf: self.shortFormIdsList.prefix(5))
            }
            ShopLiveLogger.publicLog("[ShopLiveShortformV2] 8. totalRequestedShortsIds -> \(self.requestedShortFormIdsList)")
            
            ShopLiveLogger.publicLog("[ShopLiveShortformV2] 9. loadShortFormIds called from [setInitialshortFormIdsData]")
            
            self.loadShortFormIds(ids: self.requestedShortFormIdsList, reset: true) { [weak self] _ in
                self?.isLoadingMoreData = false
                ShopLiveLogger.tempLog("[ShopLiveShortformV2] 11. [loadShortFormIds] Completion Called")
                completion()
            }
        }
    }
   
    func setShortformIdsMoreDataCustomerError(error : Error?) {
        self.customApiError = error
        self.isLoadingMoreData = false
        self.customerDownwardHasMore = true
    }
    
    func startScrollViewDidScrollPaginationBlockTimer() {
        blockScrollViewDidScrollPagination = true
        if scrollViewDidScrollPaginationBlockTimer != nil {
            scrollViewDidScrollPaginationBlockTimer?.invalidate()
            scrollViewDidScrollPaginationBlockTimer = nil
            scrollViewDidScrollPaginationBlockDuration = 0.8
        }
        scrollViewDidScrollPaginationBlockTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(paginationBlockTimerUpdated), userInfo: nil, repeats: true)
        scrollViewDidScrollPaginationBlockTimer?.fire()
    }
    
    @objc func paginationBlockTimerUpdated() {
        self.scrollViewDidScrollPaginationBlockDuration -= 0.2
        if self.scrollViewDidScrollPaginationBlockDuration <= 0 {
            self.scrollViewDidScrollPaginationBlockDuration = 0.8
            self.blockScrollViewDidScrollPagination = false
            self.scrollViewDidScrollPaginationBlockTimer?.invalidate()
            self.scrollViewDidScrollPaginationBlockTimer = nil
        }
    }
    
    override func appendCells() {
        delegate?.insertItemsWithOutAnimation(updateIndexPaths: self.getUpdatingIndexPaths())
        lastShortsCount = shortsListData.count
        delegate?.setScrollEnabled(isEnabled: self.isSwipable)
        self.postEnableTapNotification()
    }
    
    override func reloadData() {
        if self.currentPaginationDirection == .down {
            super.reloadData()
        }
        else {
            self.reloadDataForUpwardPagination()
        }
    }
    
    
    
    override func getShortsListDataForV2ActivePage() -> [SLShortsModel]? {
        return shortsListData
    }
}
extension V2ShortsCollectionViewModel {
    func getScrollViewDidScrollPaginationIsBlocked() -> Bool {
        return self.blockScrollViewDidScrollPagination
    }
    
    func getCustomShortformPayloadDictFor(shortsId : String) -> [String : Any]? {
        if let payloadDict = shortFormIdPayloadDict[shortsId] {
            return payloadDict
        }
        else {
            return nil
        }
    }
}
extension V2ShortsCollectionViewModel {
    private func loadShortFormIds(ids : [String]?, reset : Bool,completion : @escaping ((Bool) -> ())) {
        currentPaginationDirection = .down
        self.callShortsConfigurationAPI { [weak self] isSucess in
            guard let self = self else { return }
            if isSucess == false { return }
            self.isLoadingMoreData = true
            ShortsIdsListAPI(ids: ids).request { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    guard let shortsList = response.shortsList else {
                        completion(false)
                        return
                    }
                    self.shortsCollection = response
                    self.appendShortsListData(shortsList,reset: reset,scrollToPage: self.scrollToPage)
                    
                    // Functions that are only called during list data init
                    if let scrollToPage = self.scrollToPage {
                        self.delegate?.scrollToAfterLoadShortsID(index: scrollToPage)
                        self.scrollToPage = nil
                    }
                    
                    ShopLiveLogger.publicLog("[ShopLiveShortformV2] 10. [loadShortFormIds] Data is Init")
                    let hideEmptyDataView = (shortsList.count == 0 && reset == true) ? false : true
                    if hideEmptyDataView == false {
                        self.shortformDelegate?.onEvent?(messenger: nil, command: "DETAIL_EMPTY", payload: nil)
                    }
                    self.v2delegate?.hideEmptyDataView(hide: hideEmptyDataView )
                    completion(true)
                case .failure(let error):
                    shortformDelegate?.onError?(error: error)
                    completion(false)
                    break
                }
            }
        }
    }
    
    func getv2initalTargetShortsId() -> String? {
        return v2initalTargetShortsId
    }
    
    func removev2initalTargetShortId() {
        v2initalTargetShortsId = nil
    }
}
//MARK: -Downward pagingation functions
extension V2ShortsCollectionViewModel {
    func setDownwardShortformIdsMoreData(moreData : ShopLiveShortformIdsMoreData?){
        guard let moreData = moreData else {
            self.customerDownwardHasMore = true
            self.isLoadingMoreData = false
            return
        }
        var currentRequestingShortsIds : [String] = []
        moreData.ids?
            .filter({ $0.shortsId != "" })
            .enumerated()
            .forEach({ index,idData in
                if index < 5 {
                    currentRequestingShortsIds.append(idData.shortsId)
                    requestedShortFormIdsList.append(idData.shortsId)
                }
                shortFormIdsList.append(idData.shortsId)
                shortFormIdPayloadDict[idData.shortsId] = idData.payload
            })
        
        self.customerDownwardHasMore = moreData.hasMore ?? false
        
        ShopLiveLogger.publicLog("[ShopLiveShortformV2] 9. loadShortFormIds called from [setDownwardShortformIdsMoreData]")
        
        self.loadShortFormIds(ids: currentRequestingShortsIds, reset: false) { [weak self] _ in
            self?.appendCells()
            self?.isLoadingMoreData = false
        }
    }
    
    //무조건 아래방향만 고려하면 됨
    func requestPaginationDownward() {
        guard self.shortFormIdsList.count != self.requestedShortFormIdsList.count else {
            requestDownwardPaginationData()
            return
        }
        
        guard let lastRequestId = requestedShortFormIdsList.last,
              let lastShortformId = shortFormIdsList.last else { return }
        let isContainedInLastFiveShorts = self.shortFormIdsList.suffix(5).contains(where: { $0 == lastRequestId })
        
        if lastRequestId == lastShortformId {
            requestDownwardPaginationData()
        }
        else if lastRequestId != lastShortformId && isContainedInLastFiveShorts {
            useRemainingShortsIdsAndRequestForMoreDataDownward()
        }
        else {
            useRemainingShortsIdsOnlyDownward()
        }
    }
    
    private func useRemainingShortsIdsAndRequestForMoreDataDownward() {
        guard let lastRequestId = requestedShortFormIdsList.last else { return }
        guard let startIndex = shortFormIdsList.firstIndex(where: { $0 == lastRequestId }) else { return }
        let nextShortsIdsToRequest = ((startIndex + 1)...((self.shortFormIdsList.count - 1))).compactMap({ shortFormIdsList[safe : $0] })
        self.requestedShortFormIdsList.append(contentsOf: nextShortsIdsToRequest)
        
        ShopLiveLogger.publicLog("[ShopLiveShortformV2] 9. loadShortFormIds called from [useRemainingShortsIdsAndRequestForMoreDataDownward]")
        
        self.loadShortFormIds(ids: nextShortsIdsToRequest, reset: false) { [weak self] isSuccess in
            self?.isLoadingMoreData = false
            if isSuccess {
                self?.appendCells()
                self?.requestDownwardPaginationData()
            }
        }
    }
    
    private func useRemainingShortsIdsOnlyDownward() {
        var nextShortsIdsToRequest : [String] = []
        guard let lastShortsId = self.requestedShortFormIdsList.last else { return }
        guard let index = self.shortFormIdsList.firstIndex(of: lastShortsId) else { return }
        nextShortsIdsToRequest = ((index + 1)...(index + 5)).compactMap({ shortFormIdsList[safe : $0] })
        requestedShortFormIdsList.append(contentsOf: nextShortsIdsToRequest)
        
        ShopLiveLogger.publicLog("[ShopLiveShortformV2] 9. loadShortFormIds called from [useRemainingShortsIdsOnlyDownward]")
        
        loadShortFormIds(ids: nextShortsIdsToRequest, reset: false) { [weak self] _ in
            self?.appendCells()
            self?.isLoadingMoreData = false
        }
    }
    
    private func requestDownwardPaginationData() {
        guard self.hasMore == true &&
                self.isLoadingMoreData == false &&
                self.blockScrollViewDidScrollPagination == false else { return }
        v2delegate?.requestDownwardPaginationData()
    }
}
//MARK: -Upward pagination functions
extension V2ShortsCollectionViewModel {
    func setUpwardShortformIdsMoreData(moreData : ShopLiveShortformIdsMoreData?) {
        guard let moreData = moreData else {
            self.customerUpwardHasMore = true
            self.isLoadingMoreData = false
            return
        }
        var currentRequestingShortsIds : [String] = []
        moreData.ids?
            .filter({ $0.shortsId != "" })
            .reversed()
            .enumerated()
            .forEach({ (index,idData) in
                if index < 5 {
                    currentRequestingShortsIds.insert(idData.shortsId, at: 0)
                    requestedShortFormIdsList.insert(idData.shortsId, at: 0)
                }
                shortFormIdsList.insert(idData.shortsId, at: 0)
                shortFormIdPayloadDict[idData.shortsId] = idData.payload
            })
        
        self.customerUpwardHasMore = moreData.hasMore ?? false
        self.numberOfInsertedCellsAtFirstIndex = currentRequestingShortsIds.count
        self.loadShortFormIdsForUpwardPagination(ids: currentRequestingShortsIds) { [weak self] _ in
            self?.isLoadingMoreData = false
        }
    }
    
    func requestPaginationUpward() {
        guard self.shortFormIdsList.count != self.requestedShortFormIdsList.count else {
            self.requestUpwardPaginationData()
            return
        }
        guard let firstRequestedId = self.requestedShortFormIdsList.first,
              let firstOriginShortformId = self.shortFormIdsList.first else {
            return
        }
        
        let isContainedInFirstFiveShorts = self.shortFormIdsList.prefix(5).contains(where: { $0 == firstRequestedId })
        
        if firstRequestedId == firstOriginShortformId {
            self.requestUpwardPaginationData()
        }
        else if firstRequestedId != firstOriginShortformId && isContainedInFirstFiveShorts {
            self.useRemainingShortsIdsAndRequestForMoreDataUpward()
        }
        else {
            self.useRemainingShortsIdsOnlyUpward()
        }
    }
    
    private func useRemainingShortsIdsAndRequestForMoreDataUpward() {
        guard let firstRequestId = requestedShortFormIdsList.first else { return }
        guard let startIndex = shortFormIdsList.firstIndex(of: firstRequestId) else { return }
        let nextShortsIdsToRequest = (0...(startIndex - 1)).compactMap({ shortFormIdsList[safe:$0] })
        self.requestedShortFormIdsList.insert(contentsOf: nextShortsIdsToRequest, at: 0)
        self.numberOfInsertedCellsAtFirstIndex = nextShortsIdsToRequest.count
        self.loadShortFormIdsForUpwardPagination(ids: nextShortsIdsToRequest) { [weak self] isSuccess in
            self?.isLoadingMoreData = false
            self?.requestUpwardPaginationData()
        }
    }
    
    private func useRemainingShortsIdsOnlyUpward() {
        guard let firstRequestId = requestedShortFormIdsList.first else { return }
        guard let startIndex = shortFormIdsList.firstIndex(of: firstRequestId) else { return }
        let nextShortsIdsToRequest = ((startIndex - 6)...(startIndex - 1)).compactMap({ shortFormIdsList[safe:$0] })
        self.requestedShortFormIdsList.insert(contentsOf: nextShortsIdsToRequest, at: 0)
        self.numberOfInsertedCellsAtFirstIndex = nextShortsIdsToRequest.count
        self.loadShortFormIdsForUpwardPagination(ids: nextShortsIdsToRequest) { [weak self] isSuccess in
            self?.isLoadingMoreData = false
        }
    }
   
    private func requestUpwardPaginationData() {
        guard self.customerUpwardHasMore == true &&
                self.isLoadingMoreData == false &&
                self.blockScrollViewDidScrollPagination == false else { return }
        v2delegate?.requestUpwardPaginationData()
    }
    
    private func loadShortFormIdsForUpwardPagination(ids : [String]?, completion : @escaping( (Bool) -> () ) ) {
        currentPaginationDirection = .up
        self.isLoadingMoreData = true
        ShortsIdsListAPI(ids: ids)
            .request { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    guard let shortsList = response.shortsList else {
                        completion(false)
                        return
                    }
                    self.shortsCollection = response
                    self.appendShortsListDataForUpwardPagination(shortsList: shortsList)
                    
                    completion(true)
                    break
                case .failure(let error):
                    shortformDelegate?.onError?(error: error)
                    completion(false)
                }
            }
    }
   
    private func appendShortsListDataForUpwardPagination(shortsList : [SLShortsModel]) {
        if let currentIndexPath = delegate?.getCurrentIndexPath(),
           let currentCell = delegate?.getCellForAt(indexPath: currentIndexPath) as? ShortsCell,
           let srn = self.shortsListData[currentIndexPath.row].srn {
            self.shortsViewList[srn] = currentCell.getCurrentShortsView()
        }
        self.originShortsListData.insert(contentsOf: shortsList, at: 0) //이게 didSet에서 reload 호출, -> override해서 reloadDataForUpward~가 실행
        self.lastShortsCount = self.originShortsListData.count
    }
   
    private func reloadDataForUpwardPagination() {
        guard let numberOfInsertedCellAtFirstIndex = self.numberOfInsertedCellsAtFirstIndex else { return }
        self.numberOfInsertedCellsAtFirstIndex = nil
        let indexPaths = (0...(numberOfInsertedCellAtFirstIndex - 1)).map { index in
            return IndexPath(row: index, section: 0)
        }
        self.v2delegate?.insertCells(at: indexPaths)
    }
    
}


