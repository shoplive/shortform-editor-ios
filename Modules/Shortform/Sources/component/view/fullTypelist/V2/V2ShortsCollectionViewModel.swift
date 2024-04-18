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
    func requestForMoreData()
    func hideEmptyDataView(hide : Bool)
    func insertCells(at indexPaths : [IndexPath])
}

class V2ShortsCollectionViewModel : ShortsCollectionBaseViewModel {
    
    var shortFormIdsList : [String] = []
    private var requestedShortFormIdsList : [String] = []
    weak var shortFormIdsMoreData : ShopLiveShortformIdsMoreData?
    var isLoadingMoreData : Bool = false
    
    
    weak var v2delegate : V2ShortsCollectioViewModelDelegate?
    var customerHasMore : Bool = true
    override var hasMore: Bool {
        return customerHasMore
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
    private var numberOfInsertedCellAtFirstIndex : Int?
    
    
    deinit {
        ShopLiveLogger.debugLog("v2shortscollectionviewmodel deinited")
    }
    
    func setshortFormIdsData(shortformIdsData : ShopLiveShortformIdsData){
        if let ids = shortformIdsData.ids {
            self.shortFormIdsList = ids
        }
        else {
            self.requestedShortFormIdsList.removeAll()
            self.shortFormIdsList.removeAll()
        }
        
        if let currentShortsId = shortformIdsData.currentId,let index = self.shortFormIdsList.firstIndex(of: currentShortsId) {
            self.scrollToPage = index
            self.initialTargetShortsId = currentShortsId
        }
        else {
            self.scrollToPage = nil
        }
        
        if shortFormIdsList.count == 0 {
            self.v2delegate?.hideEmptyDataView(hide: false)
        }
        else {
            self.v2delegate?.hideEmptyDataView(hide: true)
            
            if let startIndex = self.scrollToPage {
                if startIndex < 5 {
                    self.requestedShortFormIdsList.append(contentsOf: self.shortFormIdsList.prefix(5))
                }
                else if startIndex > (self.shortFormIdsList.count - 6) {
                    self.requestedShortFormIdsList.append(contentsOf: self.shortFormIdsList.suffix(5))
                }
                else {
                    ((startIndex - 2)...(startIndex + 2)).forEach({ index  in
                        if let shortsId = self.shortFormIdsList[safe : index] {
                            self.requestedShortFormIdsList.append(shortsId)
                        }
                    })
                }
                //배열이 변경되었으므로 scrollToPage도 변경된 배열에 맞춰서 수정
                if let scrollToPageShortsId = shortformIdsData.currentId, let newScrollToPageIndex = self.requestedShortFormIdsList.firstIndex(of: scrollToPageShortsId) {
                    self.scrollToPage = newScrollToPageIndex
                }
            }
            else {
                self.requestedShortFormIdsList.append(contentsOf: self.shortFormIdsList.prefix(5))
            }
            
            self.loadShortFormIds(ids: self.requestedShortFormIdsList, reset: true) { [weak self] _ in
                self?.isLoadingMoreData = false
            }
        }
    }
    
    
    func setShortformIdsMoreData(moreData : ShopLiveShortformIdsMoreData?){
        guard let moreData = moreData else {
            self.customerHasMore = true
            self.isLoadingMoreData = false
            return
        }
        self.shortFormIdsMoreData = moreData
        if let ids = moreData.ids {
            self.shortFormIdsList.append(contentsOf: ids)
            self.requestedShortFormIdsList.append(contentsOf: ids.prefix(5))
        }
        self.customerHasMore = moreData.hasMore ?? false
        self.loadShortFormIds(ids: Array(moreData.ids?.prefix(5) ?? []), reset: false) { [weak self] _ in
            self?.appendCells()
            self?.isLoadingMoreData = false
        }
    }
    
    func setShortformIdsMoreDataCustomerError(error : Error?) {
        self.customApiError = error
        self.isLoadingMoreData = false
        self.customerHasMore = true
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
    
    
    func requestForPagination() {
        if self.shortFormIdsList.count != self.requestedShortFormIdsList.count {
            if self.shortFormIdsList.count - self.requestedShortFormIdsList.count >= 5 {
                useRemainingShortsIdsOnly()
            }
            else if self.shortFormIdsList.count - self.requestedShortFormIdsList.count < 5 {
                useRemainingShortsIdsAndRequestForMoreData()
            }
            else {
                requestForMoreData()
            }
        }
        else {
            requestForMoreData()
        }
    }
    
    private func useRemainingShortsIdsOnly() {
        var nextShortsIdsToRequest : [String] = []
        if let lastShortsId = self.requestedShortFormIdsList.last,
           let index = self.shortFormIdsList.firstIndex(of: lastShortsId) {
            nextShortsIdsToRequest = (index...(index + 4)).compactMap({ index -> String? in
                return self.shortFormIdsList[safe: index]
            })
            self.requestedShortFormIdsList.append(contentsOf: nextShortsIdsToRequest)
        }
        self.loadShortFormIds(ids: nextShortsIdsToRequest, reset: false) { [weak self] _ in
            self?.appendCells()
            self?.isLoadingMoreData = false
        }
    }
    
    private func useRemainingShortsIdsAndRequestForMoreData() {
        let nextShortsIdsToRequest = ((self.requestedShortFormIdsList.count - 1)...((self.shortFormIdsList.count - 1))).compactMap({ index -> String? in
            return self.shortFormIdsList[safe: index]
        })
        self.requestedShortFormIdsList = self.shortFormIdsList
        self.loadShortFormIds(ids: nextShortsIdsToRequest, reset: false) { [weak self] isSuccess in
            self?.isLoadingMoreData = false
            if isSuccess {
                self?.appendCells()
                self?.requestForMoreData()
            }
        }
    }
    
    private func requestForMoreData() {
        guard self.hasMore == true &&
                self.isLoadingMoreData == false &&
                self.blockScrollViewDidScrollPagination == false else { return }
        v2delegate?.requestForMoreData()
    }
    
    override func getShortsListDataForV2ActivePage() -> [ShortsCollectionBaseViewModel.ShortsModel]? {
        return shortsListData
    }
}
extension V2ShortsCollectionViewModel {
    func getShortsListDataCount() -> Int {
        return self.shortsListData.count
    }
    
    func getScrollViewDidScrollPaginationIsBlocked() -> Bool {
        return self.blockScrollViewDidScrollPagination
    }
    
    
}
extension V2ShortsCollectionViewModel {
    
    
    private func loadShortFormIds(ids : [String]?, reset : Bool,completion : @escaping ((Bool) -> ())) {
        currentPaginationDirection = .down
        self.callShortsConfigurationAPI { [weak self] isSucess in
            guard let self = self else { return }
            if isSucess == false { return }
            self.isLoadingMoreData = true
            ShortsIdsListAPI(ids: ids).request { result in
                switch result {
                case .success(let response):
                    guard let shortsList = response.shortsList else {
                        completion(false)
                        return
                    }
                    self.shortsCollection = response
                    self.appendShortsListData(shortsList,reset: reset,scrollToPage: self.scrollToPage)
                    self.v2delegate?.hideEmptyDataView(hide: (shortsList.count == 0 && reset == true) ? false : true)
                    completion(true)
                case .failure(let error):
                    ShopLiveShortform.Delegate.receiveHandler.delegate?.onError?(error: error)
                    completion(false)
                    break
                }
            }
        }
    }
    
    
    
}
//MARK: -Upward pagination functions
extension V2ShortsCollectionViewModel {
    func requestPaginationUpward() {
        if let firstShortsId = self.requestedShortFormIdsList.first, let indexInOriginList = self.shortFormIdsList.firstIndex(of: firstShortsId)  {
            guard indexInOriginList != 0 else { return }
           
            let min = max(0,indexInOriginList - 6)
            let shortsIdToRequest = ((min)...(indexInOriginList - 1)).compactMap { index in
                if let shortsId = self.shortFormIdsList[safe : index] {
                    return shortsId
                }
                return nil
            }
            self.requestedShortFormIdsList.insert(contentsOf: shortsIdToRequest, at: 0)
            self.numberOfInsertedCellAtFirstIndex = shortsIdToRequest.count
            self.loadShortFormIdsForUpwardPagination(ids: shortsIdToRequest) { [weak self] _ in
                self?.isLoadingMoreData = false
            }
        }
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
                    ShopLiveShortform.Delegate.receiveHandler.delegate?.onError?(error: error)
                    completion(false)
                }
            }
    }
    
    
    
    private func appendShortsListDataForUpwardPagination(shortsList : [ShortsModel]) {
        
        self.originShortsListData.insert(contentsOf: shortsList, at: 0) //이게 didSet에서 reload 호출, -> override해서 reloadDataForUpward~가 실행
        self.lastShortsCount = self.originShortsListData.count
    }
    
    
    
    private func reloadDataForUpwardPagination() {
        guard let numberOfInsertedCellAtFirstIndex = self.numberOfInsertedCellAtFirstIndex else { return }
        let indexPaths = (0...(numberOfInsertedCellAtFirstIndex - 1)).map { index in
            return IndexPath(row: index, section: 0)
        }
        self.v2delegate?.insertCells(at: indexPaths)
    }
    
}


