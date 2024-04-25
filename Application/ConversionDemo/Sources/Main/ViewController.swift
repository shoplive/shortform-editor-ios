//
//  ViewController.swift
//  ConversionTrackingDemo
//
//  Created by sangmin han on 4/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon


class ViewController : UIViewController {
    
    private var topNaviBar : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var topNavibarUnderBorderLine : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    private var pageTitleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.text = "Conversion Tracking Demo"
        label.textAlignment = .center
        label.textColor = .black
        return label
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
    
    let accessKeySelectBox = AccessKeySelectBox()
    let accessKey = TextInputForms(title: "AccessKey", placeHolder: "accessKey")
    let anonIdBox = TextInputForms(title: "anonId", placeHolder: "anonId")
    let ceIdBox = TextInputForms(title: "ceId", placeHolder: "ceId")
    let referrerBox = TextInputForms(title: "referrer", placeHolder: "referrer")
    let typeBox = TextInputForms(title: "type", placeHolder: "type")
    let userId = TextInputForms(title: "userId", placeHolder: "userId")
    let orderId = TextInputForms(title: "orderId", placeHolder: "orderId")
    let products = TextBtnForm(title: "Products", btnTitle: "Add")
    
    private var productsData : [ShopLiveEventProduct] = []
    
    private var confirmBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Call API", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setLayout()
        accessKeySelectBox.delegate = self
        accessKey.setValue(value: "a1AW6QRCXeoZ9MEWRdDQ")
        
        
        ShopLiveCommon.setUtmMedium(utmMedium: "utm_medium_test")
        ShopLiveCommon.setUtmSource(utmSource: "utm_source_test")
        ShopLiveCommon.setUtmContent(utmContent: "utm_content_test")
        ShopLiveCommon.setUtmCampaign(utmCampaign: "utm_campaign_test")
        
        
        products.btnTapped = { [weak self] in
            guard let self = self else { return }
            let vc = ProductCreateViewController()
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        addObserver()
        
        
        confirmBtn.addTarget(self, action: #selector(confirmBtnTapped(sender: )), for: .touchUpInside)
    }
    
    
    @objc func confirmBtnTapped(sender : UIButton) {
        ShopLiveCommon.setAccessKey(accessKey: accessKey.getValue())
        
        
        ShopLiveCommon.setAnonId(anonId: anonIdBox.getValue())
        ShopLiveCommon.setUser(user: ShopLiveCommonUser(userId: userId.getValue() ?? "test_ios_user"), accessKey: accessKey.getValue())
        
        
        
        let products = productsData.map({ item -> ShopLiveConversionProductData in
            return .init(productId: item.productId,
                         customerProductId: item.customerProductId,
                         sku: item.sku,
                         url: item.url,
                         purchaseQuantity: item.purchaseQuantity,
                         purchaseUnitPrice: item.purchaseUnitPrice)
            
        })
        
        //필수
        //ceId
        //idfa
        //idfv
        ShopLiveEvent.sendConversionEvent(data: .init(type: "purchase",
                                                      products: products,
                                                      orderId: orderId.getValue(),
                                                      referrer: referrerBox.getValue(),
                                                      custom: nil))
    }
    
}
extension ViewController : ProductCreateDelegate {
    func productCreated(product: ShopLiveEventProduct) {
        productsData.append(product)
        let productBox = ProductItemBox()
        productBox.setProduct(product: product)
        stackView.addArrangedSubview(productBox)
        
//        productBox.translatesAutoresizingMaskIntoConstraints = false
        
    }
}
extension ViewController : AccessKeySelectBoxDelegate {
    func segmentSelected(index: Int) {
        switch index {
        case 0:
            accessKey.setValue(value: "a1AW6QRCXeoZ9MEWRdDQ")
        case 1:
            accessKey.setValue(value: "e4cscSXMMHtEQnMiZI5E")
        case 2:
            accessKey.setValue(value: Defaults.customAccessKey)
        default:
            break
        }
    }
}
extension ViewController {
    private func setLayout() {
        self.view.addSubview(topNaviBar)
        self.view.addSubview(topNavibarUnderBorderLine)
        self.view.addSubview(pageTitleLabel)
        

        self.view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        stackView.addArrangedSubview(accessKeySelectBox)
        stackView.addArrangedSubview(accessKey)
        stackView.addArrangedSubview(anonIdBox)
        stackView.addArrangedSubview(ceIdBox)
        stackView.addArrangedSubview(referrerBox)
        stackView.addArrangedSubview(typeBox)
        stackView.addArrangedSubview(userId)
        stackView.addArrangedSubview(orderId)
        stackView.addArrangedSubview(products)
        
        self.view.addSubview(confirmBtn)
        
        NSLayoutConstraint.activate([
            topNaviBar.topAnchor.constraint(equalTo: self.view.topAnchor),
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
            
            accessKeySelectBox.heightAnchor.constraint(equalToConstant: 60),
            accessKey.heightAnchor.constraint(equalToConstant: 40),
            anonIdBox.heightAnchor.constraint(equalToConstant: 40),
            ceIdBox.heightAnchor.constraint(equalToConstant: 40),
            referrerBox.heightAnchor.constraint(equalToConstant: 40),
            typeBox.heightAnchor.constraint(equalToConstant: 40),
            userId.heightAnchor.constraint(equalToConstant: 40),
            orderId.heightAnchor.constraint(equalToConstant: 40),
            products.heightAnchor.constraint(equalToConstant: 40),
            
            confirmBtn.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            confirmBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            confirmBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            confirmBtn.heightAnchor.constraint(equalToConstant: 50),
            
        ])
    }
    
    
    
    
}
extension ViewController {
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
