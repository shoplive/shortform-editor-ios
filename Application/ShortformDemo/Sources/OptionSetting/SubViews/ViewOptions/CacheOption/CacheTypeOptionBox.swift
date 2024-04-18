//
//  CacheTypeOptionBox.swift
//  ShortformDemo
//
//  Created by sangmin han on 3/25/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon

protocol CacheTypeOptionBoxDelegate {
    func cacheTypeSelected(type : ShopliveCacheType)
}

class CacheTypeOptionBox : UIView {
    
    private var label : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.text = "MP4 Cache 타입 설정"
        return label
    }()
    
    private var type0Btn : UIButton = {
        let btn = UIButton()
        btn.setTitle("memory", for: .normal)
        btn.setTitleColor(.black, for: .selected)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 6
        btn.tag = 0
        btn.titleLabel?.textAlignment = .center
        btn.isSelected = true
        return btn
    }()
    
    private var type1Btn : UIButton = {
        let btn = UIButton()
        btn.setTitle("disk", for: .normal)
        btn.setTitleColor(.black, for: .selected)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 6
        btn.tag = 1
        return btn
    }()
    
    
    var delegate : CacheTypeOptionBoxDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        
        type0Btn.addTarget(self, action: #selector(cacheTypeBtnTapped(sender: )), for: .touchUpInside)
        type1Btn.addTarget(self, action: #selector(cacheTypeBtnTapped(sender: )), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCacheTypeOnInit(type : ShopliveCacheType) {
        type0Btn.isSelected = type == .memory
        type1Btn.isSelected = type == .disk
    }
    
    
    @objc func cacheTypeBtnTapped(sender : UIButton) {
        if sender.tag == 0 && type0Btn.isSelected == false {
            delegate?.cacheTypeSelected(type: .memory)
        }
        else if sender.tag == 1 && type1Btn.isSelected == false {
            delegate?.cacheTypeSelected(type: .disk)
        }
        type0Btn.isSelected = sender.tag == 0
        type1Btn.isSelected = sender.tag == 1
    }
    
    
    
    
}
extension CacheTypeOptionBox {
    private func setLayout() {
        self.addSubview(label)
        let stack = UIStackView(arrangedSubviews: [type0Btn,type1Btn])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        self.addSubview(stack)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            label.heightAnchor.constraint(equalToConstant: 17),
            
            stack.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            stack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: 150 + 10),
            stack.heightAnchor.constraint(equalToConstant: 30),
            
            self.bottomAnchor.constraint(equalTo: stack.bottomAnchor)
        ])
    }
}
