//
//  DetailViewOption.swift
//  ShortformDemo
//
//  Created by sangmin han on 5/21/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopLiveShortformSDK
import ShopliveSDKCommon


class DetailViewOptionBox : UIView {
    
    
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "전체 화면 옵션"
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    
    
    private let resizeModeBox = DetailViewResizeModeOptionBox()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setLayout()
        resizeModeBox.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
extension DetailViewOptionBox : DetailViewResizeModeOptionBoxDelegate {
    func resizeModeSelected(type: ShopLiveResizeMode) {
        OptionSettingModel.resizeMode = type
        ShopLiveShortform.setResizeMode(mode: type)
    }
}
extension DetailViewOptionBox {
    private func setLayout(){
        
        let stack = UIStackView(arrangedSubviews:[titleLabel,
                                                  resizeModeBox])
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
