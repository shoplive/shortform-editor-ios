//
//  ListViewCardTypeOptionBox.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/08/24.
//

import Foundation
import UIKit
import ShopLiveShortformSDK

protocol ListViewCardTypeOptionBoxDelegate {
    func listCardViewTypeSelected(type : ShopLiveShortform.CardViewType)
}

class ListViewCardTypeOptionBox : UIView {
    
    private var label : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.text = "카드 타입 설정"
        return label
    }()
    
    private var type0Btn : UIButton = {
        let btn = UIButton()
        btn.setTitle("type0", for: .normal)
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
        btn.setTitle("type1", for: .normal)
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
        btn.setTitle("type2", for: .normal)
        btn.setTitleColor(.black, for: .selected)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 6
        btn.tag = 2
        return btn
    }()
    
    var delegate : ListViewCardTypeOptionBoxDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        
        type0Btn.addTarget(self, action: #selector(cardTypeBtnTapped(sender: )), for: .touchUpInside)
        type1Btn.addTarget(self, action: #selector(cardTypeBtnTapped(sender: )), for: .touchUpInside)
        type2Btn.addTarget(self, action: #selector(cardTypeBtnTapped(sender: )), for: .touchUpInside)
    }
    
    
    required init?(coder : NSCoder){
        fatalError()
    }
    
    func setCardTypeOnInit(type : ShopLiveShortform.CardViewType) {
        type0Btn.isSelected = type == .type0
        type1Btn.isSelected = type == .type1
        type2Btn.isSelected = type == .type2
    }
    
    @objc func cardTypeBtnTapped(sender : UIButton) {
        if sender.tag == 0 && type0Btn.isSelected == false {
            delegate?.listCardViewTypeSelected(type: .type0)
        }
        if sender.tag == 1 && type1Btn.isSelected == false {
            delegate?.listCardViewTypeSelected(type: .type1)
        }
        else if sender.tag == 2 && type2Btn.isSelected == false {
            delegate?.listCardViewTypeSelected(type: .type2)
        }
        
        type0Btn.isSelected = sender.tag == 0
        type1Btn.isSelected = sender.tag == 1
        type2Btn.isSelected = sender.tag == 2
    }
}
extension ListViewCardTypeOptionBox {
    private func setLayout() {
        self.addSubview(label)
        let stack = UIStackView(arrangedSubviews: [type0Btn,type1Btn,type2Btn])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        self.addSubview(stack)
        
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 0),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            label.heightAnchor.constraint(equalToConstant: 17),
            
            stack.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            stack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: 110 + 10 + 50),
            stack.heightAnchor.constraint(equalToConstant: 30),
            
            self.bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: 0),
        ])
    }
    
    
    
}
