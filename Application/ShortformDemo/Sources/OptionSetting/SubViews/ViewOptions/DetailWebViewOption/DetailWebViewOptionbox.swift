//
//  DetailWebViewOptionbox.swift
//  shortform-examples
//
//  Created by sangmin han on 9/11/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import ShopLiveShortformSDK




class DetailWebViewOptionBox : UIView {
    
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "웹뷰 UI 옵션"
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    
    private let bookMarkBox = OptionSetSwitchBox(title: "북마크 버튼 보이기",type: .detailWebViewBookMark)
    private let shareBtnBox = OptionSetSwitchBox(title: "공유하기 버튼 보이기",type: .detailWebViewShareBtn)
    private let commentBtnBox = OptionSetSwitchBox(title: "댓글 버튼 보이기",type: .detailWebViewCommentBtn)
    private let likeBtnBox = OptionSetSwitchBox(title: "좋아요 버튼 보이기",type: .detailWebViewLikeBtn)
    
    private var detailViewOptionModel = ShopLiveShortformVisibleDetailData()
    
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        setLayout()
        bookMarkBox.setSwitchIsOn(isOn: detailViewOptionModel.isBookMarkVisible )
        shareBtnBox.setSwitchIsOn(isOn: detailViewOptionModel.isShareButtonVisible )
        commentBtnBox.setSwitchIsOn(isOn: detailViewOptionModel.isCommentButtonVisible )
        likeBtnBox.setSwitchIsOn(isOn: detailViewOptionModel.isLikeButtonVisible )
        
        bookMarkBox.delegate = self
        shareBtnBox.delegate = self
        commentBtnBox.delegate = self
        likeBtnBox.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func applyOption() {
        ShopLiveShortform.setVisibileDetailViews(options: detailViewOptionModel)
    }
    
    
}
extension DetailWebViewOptionBox {
    private func setLayout(){
        
        let stack = UIStackView(arrangedSubviews:[titleLabel,
                                                  bookMarkBox,
                                                  shareBtnBox,
                                                  commentBtnBox,
                                                  likeBtnBox])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        self.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.heightAnchor.constraint(lessThanOrEqualToConstant: 5000),
            
            self.bottomAnchor.constraint(equalTo: stack.bottomAnchor)
        ])
        
    }
    
}
extension DetailWebViewOptionBox : OptionSetSwitchBoxDelegate {
    func optionChange(type: OptionSetSwitchBox.OptionType, value: Bool) {
        switch type {
        case .detailWebViewLikeBtn:
            detailViewOptionModel.isLikeButtonVisible = value
        case .detailWebViewBookMark:
            detailViewOptionModel.isBookMarkVisible = value
        case .detailWebViewShareBtn:
            detailViewOptionModel.isShareButtonVisible = value
        case .detailWebViewCommentBtn:
            detailViewOptionModel.isCommentButtonVisible = value
        default:
            break
        }
    }
}
