//
//  ShopLiveShortformBaseTypeView.swift
//  matrix-shortform-ios
//
//  Created by sangmin han on 2023/04/30.
//

import Foundation
import UIKit
import ShopLiveSDKCommon

/**
 숏폼 목록 기본 뷰 
 */
class ShopLiveShortformBaseTypeView : UIView, SLReactor {
    
    var currentListViewType : ShopLiveShortform.ListViewType = .vertical
    
    //Not In Use : SlReactor 파생 변수
    var resultHandler: ((Result) -> ())?
    
    var refreshControl = UIRefreshControl()
    
    var collectionViewFlowLayout = UICollectionViewFlowLayout()
    lazy var collectionView : UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.isPagingEnabled = false
        cv.contentInsetAdjustmentBehavior = .never
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        
        return cv
    }()
    
    var emptyDataView : ShopLiveShortformBaseEmptyDataView = {
        let view = ShopLiveShortformBaseEmptyDataView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    enum Result {
        
    }
    
    enum Action {
        case setCardViewType(ShopLiveShortform.CardViewType)
        case enableSnap
        case disableSnap
        case enablePlayVideos
        case disablePlayVideos
        case scrollToTop
        case setPlayOnlyWifi(Bool)
        case setCellSpacing(CGFloat)
        case setScrollContentOffset(CGFloat)
        case setPlayableType(ShopLiveShortform.PlayableType)
        case setTagsAndBrandsRequestParameterModel(InternalShortformCollectionData?)
        case reloadItems
        case initialLizeShortsSetting
        case setCellViewHideOptionModel(ShopLiveListCellViewHideOptionModel)
        case setCellRadius(CGFloat)
        case setCellBackgroundColor(UIColor)
        case notifyViewRotated
    }
    
    
    override init(frame : CGRect){
        super.init(frame: frame)
        self.setLayout()
        
        collectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func action(_ action: Action) {}
    
    func getScrollContentOffset() -> CGPoint {
        return self.collectionView.contentOffset
    }
    
    
    @objc func pullToRefresh(){
        
    }
    
}
extension ShopLiveShortformBaseTypeView  {
    private func setLayout(){
        self.addSubview(collectionView)
        self.addSubview(emptyDataView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            emptyDataView.topAnchor.constraint(equalTo: self.topAnchor),
            emptyDataView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            emptyDataView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            emptyDataView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
    }
}

