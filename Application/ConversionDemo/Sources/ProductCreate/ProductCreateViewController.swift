//
//  ProductCreateViewController.swift
//  ConversionTrackingDemo
//
//  Created by sangmin han on 4/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon

protocol ProductCreateDelegate : NSObjectProtocol {
    func productCreated(product : ShopLiveEventProduct)
}

class ProductCreateViewController : UIViewController {
    
    private var topNaviBar : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var backBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .clear
        btn.setTitle("back", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.setTitleColor( .systemBlue, for: .normal)
        return btn
    }()
    
    private var pageTitleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.text = "Product Create"
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private var topNavibarUnderBorderLine : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    
    private var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    
    private var stackView : UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        return stack
    }()
    
    let productIdBox = TextInputForms(title: "productId", placeHolder: "productId")
    let customerProductIdBox = TextInputForms(title: "customerProductId", placeHolder: "customerProductId")
    let skuBox = TextInputForms(title: "sku", placeHolder: "sku")
    let urlBox = TextInputForms(title: "url", placeHolder: "url")
    let purchaseQuantityBox = TextInputForms(title: "purchaseQuantity", placeHolder: "purchaseQuantity")
    let purchaseUnitPriceBox = TextInputForms(title: "purchaseUnitPrice", placeHolder: "purchaseUnitPrice")
    
    
    
    private var confirmBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("ADD", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        return btn
    }()
    
    weak var delegate : ProductCreateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        setLayout()
        
        
        purchaseQuantityBox.setKeyBoardType(type: .decimalPad)
        purchaseUnitPriceBox.setKeyBoardType(type: .decimalPad)
        
        
        backBtn.addTarget(self, action: #selector(backBtnTapped(sender: )), for: .touchUpInside)
        confirmBtn.addTarget(self, action: #selector(confirmBtnTapped(sender:)), for: .touchUpInside)
        addObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
    }
    
    
    
    @objc func backBtnTapped(sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func confirmBtnTapped(sender : UIButton) {
        delegate?.productCreated(product: .init(productId: productIdBox.getValue(),
                                                customerProductId: customerProductIdBox.getValue(),
                                                sku: skuBox.getValue(),
                                                url: urlBox.getValue(),
                                                purchaseQuantity: Int(purchaseQuantityBox.getValue() ?? "") ,
                                                purchaseUnitPrice: Double(purchaseUnitPriceBox.getValue() ?? "") ))
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
extension ProductCreateViewController {
    private func setLayout() {
        self.view.addSubview(topNaviBar)
        self.view.addSubview(topNavibarUnderBorderLine)
        self.view.addSubview(pageTitleLabel)
        self.view.addSubview(backBtn)
        
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(productIdBox)
        stackView.addArrangedSubview(customerProductIdBox)
        stackView.addArrangedSubview(skuBox)
        stackView.addArrangedSubview(urlBox)
        stackView.addArrangedSubview(purchaseQuantityBox)
        stackView.addArrangedSubview(purchaseUnitPriceBox)
        
        
        
        self.view.addSubview(confirmBtn)
        
        NSLayoutConstraint.activate([
            topNaviBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            topNaviBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            topNaviBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            topNaviBar.heightAnchor.constraint(equalToConstant: 60),
            
            topNavibarUnderBorderLine.bottomAnchor.constraint(equalTo: topNaviBar.bottomAnchor),
            topNavibarUnderBorderLine.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            topNavibarUnderBorderLine.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            topNavibarUnderBorderLine.heightAnchor.constraint(equalToConstant: 1),
            
            pageTitleLabel.centerYAnchor.constraint(equalTo: topNaviBar.centerYAnchor),
            pageTitleLabel.centerXAnchor.constraint(equalTo: topNaviBar.centerXAnchor),
            pageTitleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            pageTitleLabel.heightAnchor.constraint(equalToConstant: 20),
            
            backBtn.centerYAnchor.constraint(equalTo: topNaviBar.centerYAnchor,constant: 1),
            backBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant : 20),
            backBtn.widthAnchor.constraint(equalToConstant: 40),
            backBtn.heightAnchor.constraint(equalToConstant: 30),
            
            
            scrollView.topAnchor.constraint(equalTo: topNaviBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: confirmBtn.topAnchor),
            //            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            //            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1),
            
            
            productIdBox.heightAnchor.constraint(equalToConstant: 40),
            customerProductIdBox.heightAnchor.constraint(equalToConstant: 40),
            skuBox.heightAnchor.constraint(equalToConstant: 40),
            urlBox.heightAnchor.constraint(equalToConstant: 40),
            purchaseQuantityBox.heightAnchor.constraint(equalToConstant: 40),
            purchaseUnitPriceBox.heightAnchor.constraint(equalToConstant: 40),
            
            
            confirmBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            confirmBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            confirmBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            confirmBtn.heightAnchor.constraint(equalToConstant: 50),
            
        ])
    }
    
}
extension ProductCreateViewController {
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleNotification(_ notification : Notification) {
        
        var keyboardRect : CGRect = .zero
        if let keyboardFrameEndUserInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardRect = keyboardFrameEndUserInfo.cgRectValue
        }
        
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            self.handleKeyboard(keyBoardRect: keyboardRect)
            break
        case UIResponder.keyboardWillHideNotification:
            self.handleKeyboard(keyBoardRect: .zero)
            break
        default:
            break
        }
    }
    
    private func handleKeyboard(keyBoardRect : CGRect){
        if keyBoardRect == .zero {
            scrollView.contentInset = .zero
            scrollView.scrollIndicatorInsets = .zero
            return
        }
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyBoardRect.height, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
        var vcRect = self.view.frame
        vcRect.size.height -= keyBoardRect.height
        let activeFields : UITextView? = findSubViewsRecursively(startView: self.view).first { ($0.isFirstResponder) }
        
        
        if var activeField = activeFields {
            let converted = activeField.convert(activeField.frame.origin, to: self.scrollView)
            if vcRect.contains(converted) == false {
                let scrollPoint = CGPoint(x: 0, y: converted.y - keyBoardRect.height)
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }
    
    private func findSubViewsRecursively(startView : UIView) -> [UITextView] {
        var subViews : [UITextView] = []
        for subView in startView.subviews {
            subViews.append(contentsOf: findSubViewsRecursively(startView: subView))
        }
        
        if startView is UITextView {
            subViews.append(startView as! UITextView)
        }
        
        return subViews
    }
    
}
