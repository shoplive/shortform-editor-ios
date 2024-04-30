//
//  ShopLiveShortformCardView.swift
//  matrix-shortform-ios
//
//  Created by sangmin han on 2023/04/28.
//

import Foundation
import UIKit
import AVFoundation
import ShopliveSDKCommon

/**
 세로 1단 템플릿 기본 셀
 뷰 구성 hierarchy
 - ShopLiveShortformBaseTypeCardView
    - posterImage (z index 0)
    - videoPlayerView (z index 1)
    - overlayType0
    - overlayType1
    - overlayType2
 */
class ShopLiveShortformCardViewCell : UICollectionViewCell {
    
    lazy private var basicCardView : ShopLiveShortformBaseTypeCardView = {
        let view = ShopLiveShortformBaseTypeCardView(frame: .zero, delegate: self,playIconLeftTopPadding: 16)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    static let cellId = "shortcardviewCellId"
    private var currentCardViewType : ShopLiveShortform.CardViewType = .type1
    private var cardViewType0 : ShopLiveShortformOverlayCardViewType0?
    private var cardViewType1 : ShopLiveShortformOverlayCardViewType1?
    private var cardViewType2 : ShopLiveShortformOverlayCardViewType2?
    private var currentMediaType : String = "VIDEO"
    var currentReference : String = ""
    weak var delegate : ShopliveShortformListViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder : NSCoder){
        fatalError()
        
    }
    
    
    func configureCell(title : String, description : String?, userThumbnail : String, userName : String, productModel : Product?, productCount : Int, viewCount : String, posterImageUrl : String?, videoURL : String?, youtubeWebView : SLWebView?, currentMediaType : String, viewHideOption : ShopLiveListCellViewHideOptionModel, cellCornerRadius : CGFloat, backgroundColor : UIColor?,currentSrn : String?,indexPath : IndexPath){
        self.currentMediaType = currentMediaType
        basicCardView.setContents(viewCount: viewCount, posterImageUrl: posterImageUrl, videoUrl: videoURL, youtubeWebView: youtubeWebView, currentMediaType: currentMediaType,viewHideOption: viewHideOption,cornerRadius: cellCornerRadius,backgroundColor: backgroundColor,currentSrn: currentSrn, indexPath: indexPath)
        
        if let cardView0 = cardViewType0 {
            cardView0.setContent(title: title, description: description, userThumbnail: userThumbnail, userName: userName ,viewHideOption: viewHideOption,cellCornerRadius: cellCornerRadius)
        }
        if let cardView1 = cardViewType1 {
            cardView1.setContent(title: title, description: description, userThumbnail: userThumbnail, userName: userName, productBannerModel: productModel,viewHideOption: viewHideOption,cellCornerRadius: cellCornerRadius)
        }
        if let cardView2 = cardViewType2 {
            cardView2.setContent(title: title, description: description, userThumbnail: userThumbnail, userName: userName, productBannerModel: productModel, productCount: productCount,viewHideOption: viewHideOption, cellCornerRadius: cellCornerRadius)
        }
        
        
    }
    
    
    func setCardViewType(cardViewType : ShopLiveShortform.CardViewType){
        if cardViewType == .type0 && cardViewType0 == nil {
            cardViewType0 = ShopLiveShortformOverlayCardViewType0(frame: .zero)
            self.setOverLayerCardViewLayout(view: cardViewType0!)
            cardViewType1?.removeFromSuperview()
            cardViewType1 = nil
            cardViewType2?.removeFromSuperview()
            cardViewType2 = nil
        }
        else if cardViewType == .type1 && cardViewType1 == nil {
            cardViewType1 = ShopLiveShortformOverlayCardViewType1(frame: .zero)
            self.setOverLayerCardViewLayout(view: cardViewType1!)
            cardViewType2?.removeFromSuperview()
            cardViewType2 = nil
            cardViewType0?.removeFromSuperview()
            cardViewType0 = nil
        }
        else if cardViewType == .type2 && cardViewType2 == nil {
            cardViewType2 = ShopLiveShortformOverlayCardViewType2(frame: .zero)
            self.setOverLayerCardViewLayout(view: cardViewType2!)
            cardViewType1?.removeFromSuperview()
            cardViewType1 = nil
            cardViewType0?.removeFromSuperview()
            cardViewType0 = nil
        }
        
    }
    
    func stopVideo(){
        guard currentMediaType == "VIDEO" else { return }
        basicCardView.stopVideo()
    }
    
    func playVideo(){
        guard currentMediaType == "VIDEO" else { return }
        basicCardView.playVideo()
    }
    
    func refreshPlayer(){
        self.basicCardView.refreshPlayer()
    }
}
extension ShopLiveShortformCardViewCell {
    private func setLayout(){
        self.addSubview(basicCardView)
      
        NSLayoutConstraint.activate([
            basicCardView.topAnchor.constraint(equalTo: self.topAnchor,constant: 0 ),
            basicCardView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 0),
            basicCardView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: 0),
            basicCardView.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: 0)
        ])
    }
    
    private func setOverLayerCardViewLayout(view : UIView){
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: basicCardView.topAnchor),
            view.leadingAnchor.constraint(equalTo: basicCardView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: basicCardView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: basicCardView.bottomAnchor)
        ])
    }
    
    
}
extension ShopLiveShortformCardViewCell : ShopLiveShortformBaseTypeCardViewDelegate {
    func onCardViewError(error: Error) {
        delegate?.onCellError(error: error)
    }
}


