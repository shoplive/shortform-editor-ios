//
//  ProductItemBox.swift
//  ConversionTrackingDemo
//
//  Created by sangmin han on 4/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon


class ProductItemBox : UIView {
    private var stack : UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.axis = .vertical
        stack.distribution = .fill
        return stack
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    func setProduct(product : ShopLiveEventProduct) {
        if let productId = product.productId {
            stack.addArrangedSubview(ProductAttributeView(title: "productId", value: productId))
        }
        
        if let customerProductId = product.customerProductId, customerProductId.isEmpty == false {
            stack.addArrangedSubview(ProductAttributeView(title: "customerProductId", value: customerProductId))
        }
        
        if let sku = product.sku, sku.isEmpty == false {
            stack.addArrangedSubview(ProductAttributeView(title: "sku", value: sku))
        }
        
        if let url = product.url,url.isEmpty == false {
            stack.addArrangedSubview(ProductAttributeView(title: "url", value: url))
        }
        
        if let purchaseQuantity = product.purchaseQuantity {
            stack.addArrangedSubview(ProductAttributeView(title: "purchaseQuantity", value: String(purchaseQuantity)))
        }
        
        if let purchaseUnitPrice = product.purchaseUnitPrice {
            stack.addArrangedSubview(ProductAttributeView(title: "purchaseUnitPrice", value: String(purchaseUnitPrice)))
        }
        
    }
    
    
}
extension ProductItemBox {
    private func setLayout() {
        self.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.heightAnchor.constraint(lessThanOrEqualToConstant: 1000),
            
            
            self.bottomAnchor.constraint(equalTo: stack.bottomAnchor)
        ])
    }
    
    
    
}
