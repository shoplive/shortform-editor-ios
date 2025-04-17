//
//  SLCustomAlertBox.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/16/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon


class SLCustomAlertBox : UIView {
    
    private var box : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    

    private var titleLabel : SLLabel = {
        let label = SLLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.setFont(font: .init(size: 17, weight: .bold))
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    
    private var confirmBtn : SLButton = {
        let btn = SLButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle(ShopLiveShortformEditorSDKStrings.Editor.Yes.shoplive, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .init(red: 51, green: 51, blue: 51)
        btn.setFont(font: .init(size: 15, weight: .bold))
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true
        return btn
    }()
    
    private var closeBtn : SLButton = {
        let btn = SLButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle(ShopLiveShortformEditorSDKStrings.Editor.No.shoplive, for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.setFont(font: .init(size: 15, weight: .bold))
        return btn
    }()
    
    
    enum ResultType {
        case no
        case yes
    }
    
    var btnClickCallback : ((ResultType) -> ())?
    
    init(title : String, confirmTitle : String?, closeTitle : String?) {
        super.init(frame: .zero)
        self.backgroundColor = .init(white: 0, alpha: 0.4)
        setLayout()
        if let confirmTitle = confirmTitle {
            self.confirmBtn.setTitle(confirmTitle, for: .normal)
        }
        
        if let closeTitle = closeTitle {
            self.closeBtn.setTitle(closeTitle, for: .normal)
        }
        
        self.titleLabel.text = title
        
        closeBtn.addTarget(self, action: #selector(closeBtnTapped(sender: )), for: .touchUpInside)
        confirmBtn.addTarget(self, action: #selector(confirmBtnTapped(sender: )), for: .touchUpInside)
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    @objc func confirmBtnTapped(sender : UIButton) {
        btnClickCallback?(.yes)
    }
    
    @objc func closeBtnTapped(sender : UIButton) {
        self.isHidden = true
        btnClickCallback?(.no)
    }
    
    func setBoxCornerRadius(cornerRadius : CGFloat){
        self.box.layer.cornerRadius = cornerRadius
    }
    
    func setButtonCornerRadius(cornerRadius : CGFloat) {
        self.confirmBtn.layer.cornerRadius = cornerRadius
        self.closeBtn.layer.cornerRadius = cornerRadius
    }
    
    func setCloseButtonDesign(backgroundColor : UIColor, textColor : UIColor, size: CGFloat, weight: UIFont.Weight, customFont: UIFont?) {
        self.closeBtn.backgroundColor = backgroundColor
        self.closeBtn.setTitleColor(textColor, for: .normal)
        self.closeBtn.setFont(font: .init(customFont: customFont, size: size, weight: weight))
    }
    
    func setConfirmButtonDesign(backgroundColor : UIColor, textColor : UIColor, size: CGFloat, weight: UIFont.Weight, customFont: UIFont?) {
        self.confirmBtn.backgroundColor = backgroundColor
        self.confirmBtn.setTitleColor(textColor, for: .normal)
        self.confirmBtn.setFont(font: .init(customFont: customFont,size: size, weight: weight))
    }
}
extension SLCustomAlertBox {
    private func setLayout() {
        self.addSubview(box)
        
        let btnStack = UIStackView(arrangedSubviews: [closeBtn,confirmBtn])
        btnStack.translatesAutoresizingMaskIntoConstraints = false
        btnStack.axis = .horizontal
        btnStack.distribution = .fillEqually
        btnStack.spacing = 10
        
        let stack = UIStackView(arrangedSubviews: [titleLabel,btnStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 15
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        self.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stack.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -100),
            stack.heightAnchor.constraint(lessThanOrEqualToConstant: 500),
            
            btnStack.heightAnchor.constraint(equalToConstant: 44),
            
            
            box.topAnchor.constraint(equalTo: stack.topAnchor),
            box.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            box.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            box.bottomAnchor.constraint(equalTo: stack.bottomAnchor),
        ])
    }
}
