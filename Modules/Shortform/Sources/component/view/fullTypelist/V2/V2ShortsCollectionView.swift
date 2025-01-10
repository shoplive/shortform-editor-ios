//
//  V2ShortsCollectionView.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/30/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon



public protocol ShortsCollectionViewDataSourcRequestDelegate : AnyObject {
    func onShortformListDownwardPagination(completion : @escaping(((ShopLiveShortformIdsMoreData?,Error?)) -> ()))
    func onShortformListUpwardPagingation(completion : @escaping(((ShopLiveShortformIdsMoreData?,Error?)) -> ()))
}

class V2ShortsCollectionView : ShortsCollectionBaseView {
    
    private var emptyDataView : FullTypeEmptyDataView = {
        let view = FullTypeEmptyDataView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    var viewmodel : V2ShortsCollectionViewModel {
        return viewModel as! V2ShortsCollectionViewModel
    }
    
    weak var requestDelegate : ShortsCollectionViewDataSourcRequestDelegate?
    
    init(shortformIdsData : ShopLiveShortformIdsData, requestDelegate : ShortsCollectionViewDataSourcRequestDelegate, shortformDelegate : ShopLiveShortformReceiveHandlerDelegate?){
        self.requestDelegate = requestDelegate
        let shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        super.init(viewmodel: V2ShortsCollectionViewModel(shopliveSessionId: shopliveSessionId,shortformDelegate: shortformDelegate),
                   shortformDelegate: shortformDelegate)
        viewmodel.v2delegate = self
        viewmodel.setInitialshortFormIdsData(shortformIdsData: shortformIdsData)
        viewmodel.latestActivePageIndex = -1
        viewmodel.shortsMode = .detail
    }
    
    deinit {
        ShopLiveLogger.memoryLog("V2ShortsCollectionView")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layout() {
        super.layout()
        self.addSubview(emptyDataView)
        
        NSLayoutConstraint.activate([
            emptyDataView.topAnchor.constraint(equalTo: self.topAnchor,constant: UIScreen.topSafeArea_SL),
            emptyDataView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            emptyDataView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            emptyDataView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
    }
}
extension V2ShortsCollectionView : V2ShortsCollectioViewModelDelegate {
    func requestDownwardPaginationData() {
        requestDelegate?.onShortformListDownwardPagination { [weak self] moreData,error in
            if let error = error {
                self?.viewmodel.setShortformIdsMoreDataCustomerError(error: error)
            }
            else{
                self?.viewmodel.setDownwardShortformIdsMoreData(moreData: moreData)
            }
        }
    }
    
    func requestUpwardPaginationData() {
        requestDelegate?.onShortformListUpwardPagingation(completion: { [weak self] moreData, error  in
            if let error = error {
                self?.viewmodel.setShortformIdsMoreDataCustomerError(error: error)
            }
            else {
                self?.viewmodel.setUpwardShortformIdsMoreData(moreData: moreData)
            }
        })
    }
    
    func hideEmptyDataView(hide: Bool) {
        if self.viewmodel.shortsMode == .preview {
            emptyDataView.isHidden = true
            return
        }
        if hide == false {
            self.bringSubviewToFront(emptyDataView)
        }
        emptyDataView.isHidden = hide
    }
    
    func insertCells(at indexPaths: [IndexPath]) {
        let currentBottomOffset = self.shortsListView.contentSize.height - self.shortsListView.contentOffset.y
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.shortsListView.performBatchUpdates { [weak self] in
            self?.shortsListView.insertItems(at: indexPaths)
        } completion: { [weak self] _ in
            self?.shortsListView.contentOffset.y = (self?.shortsListView.contentSize.height ?? currentBottomOffset) - currentBottomOffset
            CATransaction.commit()
        }
        
    }
}
extension V2ShortsCollectionView {
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        if indexPath.row >= self.viewmodel.getShortsListDataCount() - 2 &&
            self.viewmodel.getScrollViewDidScrollPaginationIsBlocked() == false {
            viewmodel.requestPaginationDownward()
            viewmodel.startScrollViewDidScrollPaginationBlockTimer()
        }
        else if indexPath.row == 0 &&
                    self.viewmodel.getScrollViewDidScrollPaginationIsBlocked() == false {
            viewmodel.requestPaginationUpward()
            viewmodel.startScrollViewDidScrollPaginationBlockTimer()
        }
    }
    
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        if self.viewmodel.shortsMode == .detail {
            let contentHeight = feedListLayout.collectionViewContentSize.height
            let contentOffset = scrollView.contentOffset.y
            let frameHeight = shortsListView.frame.height
            guard let currentIndexPath = shortsListView.indexPathsForVisibleItems.last else { return }
            
            if contentHeight - (contentOffset + frameHeight) <= 50 &&
                self.viewmodel.getScrollViewDidScrollPaginationIsBlocked() == false {
                viewmodel.requestPaginationDownward()
                viewmodel.startScrollViewDidScrollPaginationBlockTimer()
            }
            else if currentIndexPath.row == 0 &&
                contentOffset <= -50 &&
                self.viewmodel.getScrollViewDidScrollPaginationIsBlocked() == false {
                viewmodel.requestPaginationUpward()
                viewmodel.startScrollViewDidScrollPaginationBlockTimer()
            }
        }
    }
    
    override func playPage(_ page: Int = 0) {
        let pageTo = CGPoint(x: 0, y: CGFloat(page) * self.frame.height)
        if viewModel.isViewAppeared {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.shortsListView.setContentOffset(pageTo, animated: false)
            }
        } else {
            viewModel.scrollToPage = page
            if viewModel.shortsMode == .preview {
                shortsListView.setContentOffset(pageTo, animated: false)
            }
        }
    }
}
//MARK: - ShortsCellDelegate override
extension V2ShortsCollectionView {
    override func requestSetCustomShortformForV2(cell: ShortsCell, shortsId: String) {
        let payload = viewmodel.getCustomShortformPayloadDictFor(shortsId: shortsId)
        cell.sendJSRequestToWeb(sdkToWeb: .SET_CUSTOM_SHORTFORM, payload: payload)
    }
}
