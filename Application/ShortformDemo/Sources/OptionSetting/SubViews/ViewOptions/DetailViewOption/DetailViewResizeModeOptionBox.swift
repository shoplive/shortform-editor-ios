//
//  DetailViewResizeModeOptionBox.swift
//  ShortformDemo
//
//  Created by sangmin han on 5/21/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import ShopLiveShortformSDK

protocol DetailViewResizeModeOptionBoxDelegate {
    func resizeModeSelected(type : ShopLiveResizeMode)
}


class DetailViewResizeModeOptionBox : UIView {
    
    private var label : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.text = "숏폼 동영상 렌더링 방법 설정"
        return label
    }()
    
    private var type0Btn : UIButton = {
        let btn = UIButton()
        btn.setTitle("AUTO", for: .normal)
        btn.setTitleColor(.black, for: .selected)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 6
        btn.tag = 0
        return btn
    }()
    
    private var type1Btn : UIButton = {
        let btn = UIButton()
        btn.setTitle("CENTER_CROP", for: .normal)
        btn.setTitleColor(.black, for: .selected)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 6
        btn.isSelected = true
        btn.tag = 1
        return btn
    }()
    
    private var type2Btn : UIButton = {
        let btn = UIButton()
        btn.setTitle("FIT", for: .normal)
        btn.setTitleColor(.black, for: .selected)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 6
        btn.tag = 2
        return btn
    }()
    
    
    var delegate : DetailViewResizeModeOptionBoxDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        
        type1Btn.addTarget(self, action: #selector(cardTypeBtnTapped(sender: )), for: .touchUpInside)
        type2Btn.addTarget(self, action: #selector(cardTypeBtnTapped(sender: )), for: .touchUpInside)
        
        type1Btn.isSelected = OptionSettingModel.resizeMode == .CENTER_CROP
        type2Btn.isSelected = OptionSettingModel.resizeMode == .FIT
        
    }
    
    
    required init?(coder : NSCoder){
        fatalError()
    }
    
    @objc func cardTypeBtnTapped(sender : UIButton) {
       
        if sender.tag == 1 && type1Btn.isSelected == false {
            delegate?.resizeModeSelected(type: .CENTER_CROP)
        }
        else if sender.tag == 2 && type2Btn.isSelected == false {
            delegate?.resizeModeSelected(type: .FIT)
        }
        type1Btn.isSelected = sender.tag == 1
        type2Btn.isSelected = sender.tag == 2
    }
    
    
}
extension DetailViewResizeModeOptionBox {
    private func setLayout() {
        self.addSubview(label)
        let stack = UIStackView(arrangedSubviews: [type1Btn,type2Btn])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillProportionally
        self.addSubview(stack)
        
        type0Btn.isHidden = true
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 0),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            label.heightAnchor.constraint(equalToConstant: 17),
            
            stack.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            stack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: 150 + 10 + 50),
            stack.heightAnchor.constraint(equalToConstant: 30),
            
            self.bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: 0),
        ])
    }
    
    
   
}
