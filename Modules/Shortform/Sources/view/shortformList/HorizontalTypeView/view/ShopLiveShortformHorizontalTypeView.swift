//
//  ShopLiveShortformHorizontalTypeView.swift
//  matrix-shortform-ios
//
//  Created by sangmin han on 2023/05/03.
//

import Foundation
import UIKit
import AVKit


final class ShopLiveShortformHorizontalTypeView : ShopLiveShortformBaseTypeView {
    
    
    private let reactor = ShopLiveShortformHorizontalTypeViewReactor()
    private weak var delegate : ShopLiveShortformListViewDelegate?
    
    init(cardViewType : ShopLiveShortform.CardViewType,listViewDelegate : ShopLiveShortformListViewDelegate?,
         tagsAndBrandsRequestParameterModel : InternalShortformCollectionData?,avAudioSessionCategoryOptions : AVAudioSession.CategoryOptions?){
        super.init(frame: .zero)
        self.delegate = listViewDelegate
        collectionViewFlowLayout.scrollDirection = .horizontal
        bindData()
        reactor.action(.setTagsAndBrandsParameterModel(tagsAndBrandsRequestParameterModel))
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
    
    private func bindData(){
        
        reactor.action(.setCollectionView(self.collectionView))
        
       
        reactor.resultHandler = { [weak self] (result) in
            DispatchQueue.main.async {
                self?.handleResultHandlers(result)
            }
        }
    }
    
    private func handleResultHandlers(_ result : ShopLiveShortformHorizontalTypeViewReactor.Result){
        switch result {
        case .setSectionInset(let edgeInset):
            self.collectionViewFlowLayout.sectionInset = edgeInset
        case .setCellSize(let cellSize):
            self.collectionViewFlowLayout.itemSize = cellSize
        case .onError(let error):
            self.handleCellError(error: error)
        case .hideEmptyView(let hide):
            self.collectionView.isHidden = !hide
            self.emptyDataView.isHidden = hide
        }
    }
    
    private func handleCellError(error : Error){
        delegate?.onListViewError(error: error)
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
        case .setScrollContentOffset(let scrollOffset):
            //MARK: -TODO
            self.collectionView.contentOffset.x = scrollOffset
        case .setPlayableType(let type):
            reactor.action(.setPlayableType(type))
        case .setTagsAndBrandsRequestParameterModel(let model):
            reactor.action(.setTagsAndBrandsParameterModel(model))
        case .reloadItems:
            reactor.action(.reloadItem)
        case .initialLizeShortsSetting:
            reactor.action(.initializeShortsSetting)
        case .setCellViewHideOptionModel(let model):
            reactor.action(.setCellViewHideOptionModel(model))
        case .setCellRadius(let cellRadius):
            reactor.action(.setCellRadius(cellRadius))
        case .setCellBackgroundColor(let color):
            reactor.action(.setCellBackgroundColor(color))
        case .notifyViewRotated:
            break //no - op 
        }
    }
    
    
}
extension ShopLiveShortformHorizontalTypeView {
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
