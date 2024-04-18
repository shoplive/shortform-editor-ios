//
//  TextBtnForm.swift
//  ConversionTrackingDemo
//
//  Created by sangmin han on 4/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit



class TextBtnForm : UIView {
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private var btn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Add", for: .normal)
        btn.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    
    private var stack : UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private var underBorderLine : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    
    var btnTapped : (() -> ())?
    
    
    
    init(title : String, btnTitle : String) {
         super.init(frame: .zero)
        setLayout()
        self.setbtnTitle(btnTitle : btnTitle)
        self.setTitle(title: title)
        
        btn.addTarget(self, action: #selector(btnTapped(sender: )), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setbtnTitle(btnTitle : String) {
        self.btn.setTitle(btnTitle, for: .normal)
    }
    
    func setTitle(title : String) {
        self.titleLabel.text = title
    }
    
    
    @objc func btnTapped(sender : UIButton) {
        self.btnTapped?()
    }
    
    
}
extension TextBtnForm {
    private func setLayout() {
        self.addSubview(stack)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        stack.addArrangedSubview(titleLabel)
        
        let btnPadding = UIStackView(arrangedSubviews: [btn])
        btnPadding.isLayoutMarginsRelativeArrangement = true
        btnPadding.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        stack.addArrangedSubview(btnPadding)
        
        
        self.addSubview(underBorderLine)
        
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            btnPadding.widthAnchor.constraint(equalToConstant: 40),
            
            
            
            underBorderLine.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            underBorderLine.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            underBorderLine.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            underBorderLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

