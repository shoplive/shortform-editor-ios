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
    func onV2ListAPIError(error : Error)
    func hideEmptyDataView(hide : Bool)
}

class V2ShortsCollectionViewModel : ShortsCollectionBaseViewModel {
    
    var shortFormIdsList : [String] = []
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
    
    
    deinit {
        ShopLiveLogger.debugLog("v2shortscollectionviewmodel deinited")
    }
    
    func setshortFormIdsData(shortformIdsData : ShopLiveShortformIdsData){
        if let ids = shortformIdsData.ids {
            self.shortFormIdsList = ids
        }
        else {
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
            self.loadShortFormIds(ids: shortFormIdsList, reset: true) { [weak self] in
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
        }
        self.customerHasMore = moreData.hasMore ?? false
        
        self.loadShortFormIds(ids: moreData.ids, reset: false) { [weak self] in
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
    
    func requestForPagination() {
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
    
    
    private func loadShortFormIds(ids : [String]?, reset : Bool,completion : @escaping (() -> ())) {
        self.callShortsConfigurationAPI { [weak self] isSucess in
            guard let self = self else { return }
            if isSucess == false { return }
            self.isLoadingMoreData = true
            ShortsIdsListAPI(ids: ids).request { result in
                switch result {
                case .success(let response):
                    guard let shortsList = response.shortsList else {
                        return
                    }
                    self.shortsCollection = response
                    self.appendShortsListData(shortsList,reset: reset,scrollToPage: self.scrollToPage)
                    self.v2delegate?.hideEmptyDataView(hide: (shortsList.count == 0 && reset == true) ? false : true)
                    completion()
                case .failure(let error):
                    self.v2delegate?.onV2ListAPIError(error: error)
                    completion()
                    break
                }
            }
        }
    }
    
}
