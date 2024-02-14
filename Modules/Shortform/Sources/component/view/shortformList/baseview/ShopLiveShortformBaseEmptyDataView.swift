//
//  ShopLiveShortformBaseEmptyDataView.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/07/21.
//

import Foundation
import UIKit
import ShopliveSDKCommon


/**
 숏폼 목록뷰 빈 데이터 표시용 셀
 */
class ShopLiveShortformBaseEmptyDataView : UIView {
    
    lazy private var emptyIconView : UIImageView = {
        let imageView = UIImageView()
//        let bundle = Bundle(for: type(of: self))
//        imageView.image =  UIImage(named: "ic_shortform_empty",in: bundle, compatibleWith: nil)
        imageView.image = ShopLiveShortformSDKAsset.slIcShortformEmpty.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    lazy private var emptyLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.set(size: 14, weight: ._500)
        label.textColor = .black_500
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        let bundle = Bundle(for: type(of: self))
        label.text = "shortform_list_empty_data".localizedString_SL(bundle: bundle)
//        label.text = "".localizedString(from: "",bundle: bundle)
        return label
    }()
    
    
    override init(frame : CGRect){
        super.init(frame: frame)
        setLayout()
        
    }
    
    required init?(coder : NSCoder){
        fatalError()
    }
    
    
    
    
}
extension ShopLiveShortformBaseEmptyDataView {
    private func setLayout(){
        let stack = UIStackView(arrangedSubviews: [emptyIconView,emptyLabel])
        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stack)
        
        emptyIconView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor),
            
            emptyIconView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
