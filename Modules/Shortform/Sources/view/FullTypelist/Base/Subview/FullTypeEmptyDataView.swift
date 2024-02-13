//
//  FullTypeEmptyDataView.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/31/23.
//

import Foundation
import UIKit


class FullTypeEmptyDataView : UIView {
    
    lazy private var backBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        let bundle = Bundle(for: type(of: self))
        btn.setImage(UIImage(named: "sl_ic_back_btn",in: bundle, compatibleWith: nil), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    lazy private var emptyIconView : UIImageView = {
        let imageView = UIImageView()
        let bundle = Bundle(for: type(of: self))
        imageView.image =  UIImage(named: "ic_shortform_empty",in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    lazy private var emptyLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.set(size: 14, weight: ._500)
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        let bundle = Bundle(for: type(of: self))
        label.text = "shortform_list_empty_data".localizedString_SL(bundle: bundle)
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setLayout()
        
        backBtn.addTarget(self, action: #selector(backBtnTapped(sender:)), for: .touchUpInside)
    }
    
    required init?(coder : NSCoder){
        fatalError()
    }
    
    @objc func backBtnTapped(sender : UIButton){
        ShopLiveShortform.close()
    }
    
}
extension FullTypeEmptyDataView {
    private func setLayout(){
        self.addSubview(backBtn)
        let stack = UIStackView(arrangedSubviews: [emptyIconView,emptyLabel])
        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stack)
        
        emptyIconView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backBtn.topAnchor.constraint(equalTo: self.topAnchor,constant: 20),
            backBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 20),
            backBtn.widthAnchor.constraint(equalToConstant: 44),
            backBtn.heightAnchor.constraint(equalToConstant: 44),
            
            stack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.heightAnchor.constraint(lessThanOrEqualTo: self.heightAnchor),
            
            emptyIconView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
