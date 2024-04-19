//
//  ShopLiveShortformVerticalTypeView.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/05/02.
//

import Foundation
import UIKit
import AVKit


final class ShopLiveShortformVerticalTypeView : ShopLiveShortformBaseTypeView {
    
    private let reactor = ShopLiveShortformVerticalTypeViewReactor()
    private weak var delegate : ShopLiveShortformListViewDelegate?
    
    init(cardViewType : ShopLiveShortform.CardViewType,listViewDelegate : ShopLiveShortformListViewDelegate?,
         tagsAndBrandsRequestParameterModel : InternalShortformCollectionDto?,avAudioSessionCategoryOptions : AVAudioSession.CategoryOptions?){
        super.init(frame: .zero)
        self.delegate = listViewDelegate
        collectionViewFlowLayout.scrollDirection = .vertical
        bindData()
        reactor.action(.setTagsAndBrandsRequestParameterModel(tagsAndBrandsRequestParameterModel))
        reactor.action(.setCardViewType(cardViewType))
        reactor.action(.setAvAudioSessionCategoryOptions(avAudioSessionCategoryOptions))
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reactor.action(.calculateCellSize)
    }
    
    @objc override func pullToRefresh() {
        reactor.action(.pullToRefresh)
    }
    
    private func bindData(){
        
        reactor.action(.setCollectionView(self.collectionView))
        
       
        reactor.resultHandler = { [weak self] (result) in
            DispatchQueue.main.async {
                self?.handleResultHandlers(result)
            }
        }
    }
    
    private func handleResultHandlers(_ result : ShopLiveShortformVerticalTypeViewReactor.Result){
        switch result {
        case .setSectionInset(let edgeInset):
            self.collectionViewFlowLayout.sectionInset = edgeInset
        case .setCellSize(let cellSize):
            self.collectionViewFlowLayout.itemSize = cellSize
        case .onError(let error):
            self.handleCellError(error: error)
        case .endPullToRefresh:
            self.endPullToRefresh()
        case .hideEmptyView(let hide):
            self.collectionView.isHidden = !hide
            self.emptyDataView.isHidden = hide
        case .invalidateCVLayout:
            self.invalidateCvlayout()
        }
    }
    
    private func endPullToRefresh(){
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
    }
    
    private func handleCellError(error : Error){
        delegate?.onListViewError(error: error)
    }
    
    private func invalidateCvlayout(){
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
        }
    }
    
    override func action(_ action: Action) {
        switch action {
        case .setCardViewType(let cardViewType):
            reactor.action(.setCardViewType(cardViewType))
        case .enableSnap:
            self.configureCvForSnap(isEnabled: true)
        case .disableSnap:
            self.configureCvForSnap(isEnabled: false)
        case .enablePlayVideos:
            reactor.action(.setEnableAutoPlay(true))
        case .disablePlayVideos:
            reactor.action(.setEnableAutoPlay(false))
        case .scrollToTop:
            self.scrollToTop()
        case .setPlayOnlyWifi(let isOnlyOnWifi):
            reactor.action(.setIsPlayOnlyOnWifi(isOnlyOnWifi))
        case .setCellSpacing(let cellSpacing):
            self.setCellSpacing(cellSpacing: cellSpacing)
        case .setTagsAndBrandsRequestParameterModel(let model):
            reactor.action(.setTagsAndBrandsRequestParameterModel(model))
        case .reloadItems:
            reactor.action(.reloadItem)
        case .setScrollContentOffset(_):
            break
        case .setPlayableType(_):
            break
        case .setCellViewHideOptionModel(let model):
            reactor.action(.setCellViewHideOptionModel(model))
            break
        case .initialLizeShortsSetting:
            reactor.action(.initializeShortsSetting)
        case .setCellRadius(let cellRadius):
            reactor.action(.setCellRadius(cellRadius))
        case .setCellBackgroundColor(let color):
            reactor.action(.setCellBackgroundColor(color))
        case .notifyViewRotated:
            reactor.action(.notifyViewRotated)
        }
    }
}
extension ShopLiveShortformVerticalTypeView {
    private func setCellSpacing(cellSpacing : CGFloat){
        collectionViewFlowLayout.minimumLineSpacing = cellSpacing
        collectionViewFlowLayout.minimumInteritemSpacing = cellSpacing
        reactor.action(.setCellSpacing(cellSpacing))
    }
    
    private func configureCvForSnap(isEnabled : Bool){
        if isEnabled {
            collectionView.decelerationRate = .fast
        }
        else {
            collectionView.decelerationRate = .normal
        }
        reactor.action(.setSnap(isEnabled))
    }
    
    private func scrollToTop(){
        if collectionView.numberOfItems(inSection: 0) >= 1 {
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
        }
    }
    
}
