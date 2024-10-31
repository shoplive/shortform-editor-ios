//
//  ShopLiveShortformVerticalViewCell.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/05/02.
//

import Foundation
import UIKit
import ShopliveSDKCommon


/**
 숏폼 2단 카드 템플릿, 가로 카드 템플릿 셀
 뷰 구성 hierarchy
 - ShopLiveShortformBaseTypeCardView
    - videoPlayerView (z index 0)
    - posterImage (z index 1)
 - overlayType0
 - overlayType1
 - overlayType2
 */
final class ShopLiveShortformBaseListTypeViewCell : UICollectionViewCell {
    
    
    lazy private var basicCardView : ShopLiveShortformBaseTypeCardView = {
        let view = ShopLiveShortformBaseTypeCardView(frame: .zero, delegate: self,playIconLeftTopPadding: 8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var titleLabel : UITextView = {
        let label = UITextView()
        label.font = UIFont.set(size: 13, weight: ._500)
        label.textColor = UIColor.black_700_main
        label.textContainer.lineFragmentPadding = .zero
        label.textContainerInset = .zero
        label.textContainer.maximumNumberOfLines = 2
        label.textContainer.lineBreakMode = .byTruncatingTail
        label.backgroundColor = .clear
        label.isScrollEnabled = false
        label.isEditable = false
        return label
    }()
    
    private var userImage : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 11
        imageView.clipsToBounds = true
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    private var userNameLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black_600
        label.font = UIFont.set(size: 12, weight: ._400)
        label.text = "testusername"
        return label
    }()
    
    lazy private var userInfoStack : UIStackView =  {
        let stack = UIStackView(arrangedSubviews: [userImage,userNameLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()
    
    lazy private var wholeStack : UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel,userInfoStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        stack.axis = .vertical
        stack.setCustomSpacing(4, after: titleLabel)
        return stack
    }()
    
    
    
    
    static let cellId = "shortsverticalCellId"
    private var currentCardViewType : ShopLiveShortform.CardViewType = .type1
    private var cardViewType1 : ShopLiveShortformBaseListTypeOverlayType1?
    private var cardViewType2 : ShopLiveShortformBaseListTypeOverlayType2?
    private var currentMediaType : String = "VIDEO"
    weak var delegate : ShopliveShortformListViewCellDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder : NSCoder){
        fatalError()
    }
    
    
    
    func configureCell(title : String,
                       userThumbnail : String,
                       userName : String,
                       productModel : Product?,
                       productCount : Int,
                       viewCount : String,
                       posterImageUrl : String?,
                       videoURL : String?,
                       youtubeWebView : SLWebView?,
                       currentMediaType : String,
                       viewHideOption : ShopLiveListCellViewHideOptionModel,
                       cellCornerRadius : CGFloat,
                       backgroundColor : UIColor?,
                       currentSrn : String?,
                       indexPath : IndexPath){
        self.currentMediaType = currentMediaType
        basicCardView.setContents(viewCount: viewCount,
                                  posterImageUrl: posterImageUrl,
                                  videoUrl: videoURL,
                                  youtubeWebView: youtubeWebView,
                                  currentMediaType: currentMediaType,
                                  viewHideOption : viewHideOption,
                                  cornerRadius: cellCornerRadius,
                                  backgroundColor: backgroundColor,
                                  currentSrn: currentSrn,
                                  indexPath: indexPath)
        
        if let cardView1 = cardViewType1 {
            cardView1.setContent(productBannerModel: productModel,viewHideOption: viewHideOption)
        }
        if let cardView2 = cardViewType2 {
            cardView2.setContent(productBannerModel: productModel, productCount: productCount,viewHideOption: viewHideOption)
        }
        
        
        titleLabel.isHidden = viewHideOption.isTitleVisible ? false : true
        titleLabel.text = title
        
        
        if viewHideOption.isBrandVisible == false {
            userInfoStack.isHidden = true
        }
        else {
            if userName == "" && userThumbnail ==  "" || viewHideOption.isBrandVisible == false {
                userInfoStack.isHidden = true
            }
            else {
                userInfoStack.isHidden = false
            }
            
            if userName == "" {
                userNameLabel.isHidden = true
            }
            else {
                userNameLabel.isHidden = false
                userNameLabel.text = userName
            }
            if let url = URL(string: userThumbnail) {
                userImage.image = ShopLiveShortformSDKAsset.slIcShopliveUserFill.image
                ImageDownLoaderManager.shared.download(imageUrl: url) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let imageData):
                        self.userImage.image = UIImage(data: imageData)
                        userImage.isHidden = false
                    case .failure(let error):
                        self.delegate?.onCellError(error: error)
                    }
                }
            }
            else {
                userImage.isHidden = true
            }
        }
        
        adjustStackCustomSpacing()
    }
    
    private func adjustStackCustomSpacing() {
        wholeStack.layoutMargins = .zero
        
        if userInfoStack.isHidden  {
            if titleLabel.isHidden {
                wholeStack.setCustomSpacing(0, after: titleLabel)
                wholeStack.layoutMargins = .zero
            }
            else {
                wholeStack.setCustomSpacing(0, after: titleLabel)
                wholeStack.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
            }
        }
        else {
            if titleLabel.isHidden {
                wholeStack.setCustomSpacing(0, after: titleLabel)
                wholeStack.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
            }
            else {
                wholeStack.setCustomSpacing(4, after: titleLabel)
                wholeStack.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
            }
        }
        wholeStack.layoutIfNeeded()
        
    }
    
    func setCardViewType(cardViewType : ShopLiveShortform.CardViewType){
        if cardViewType == .type0 {
            currentCardViewType = .type0
            cardViewType2?.removeFromSuperview()
            cardViewType2 = nil
            cardViewType1?.removeFromSuperview()
            cardViewType1 = nil
        }
        else if cardViewType == .type1 && cardViewType1 == nil {
            currentCardViewType = .type1
            cardViewType1 = ShopLiveShortformBaseListTypeOverlayType1(frame: .zero)
            self.setOverLayerViewLayout(view: cardViewType1!)
            cardViewType2?.removeFromSuperview()
            cardViewType2 = nil
        }
        else if cardViewType == .type2 && cardViewType2 == nil {
            currentCardViewType = .type2
            cardViewType2 = ShopLiveShortformBaseListTypeOverlayType2(frame: .zero)
            self.setOverLayerViewLayout(view: cardViewType2!)
            cardViewType1?.removeFromSuperview()
            cardViewType1 = nil
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
    
    func playVideoOnInitialLoad() {
        guard currentMediaType == "VIDEO" else { return }
        basicCardView.playVideoOnInitialLoad()
    }
    
    func refreshPlayer(){
        self.basicCardView.refreshPlayer()
    }
    
    func setVideoCache(originUrl : String, cacheUrl : URL) {
        self.basicCardView.setVideoCache(originUrl : originUrl, cacheUrl : cacheUrl)
    }
}
extension ShopLiveShortformBaseListTypeViewCell {
    private func setLayout(){
        self.addSubview(basicCardView)
        self.addSubview(wholeStack)
        
        NSLayoutConstraint.activate([
            basicCardView.topAnchor.constraint(equalTo: self.topAnchor,constant: 0 ),
            basicCardView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 0),
            basicCardView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: 0),
            basicCardView.heightAnchor.constraint(equalTo: basicCardView.widthAnchor, multiplier: 1.5),
            
            wholeStack.topAnchor.constraint(equalTo: basicCardView.bottomAnchor),
            wholeStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            wholeStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            wholeStack.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor),
            
            userInfoStack.heightAnchor.constraint(equalToConstant: 22),
            userImage.widthAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    private func setOverLayerViewLayout(view : UIView){
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
extension ShopLiveShortformBaseListTypeViewCell : ShopLiveShortformBaseTypeCardViewDelegate {
    func onCardViewError(error: Error) {
        delegate?.onCellError(error: error)
    }
}
