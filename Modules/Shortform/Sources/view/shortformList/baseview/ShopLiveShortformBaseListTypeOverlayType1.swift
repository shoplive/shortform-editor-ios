//
//  ShopLiveShortformVerticalOverlayType1.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/05/02.
//

import Foundation
import UIKit
import ShopLiveSDKCommon
/**
 세론 2단, 가로 템플릿 1 오버레이 뷰
 */
class ShopLiveShortformBaseListTypeOverlayType1 : UIView {
    
    private var productBannerBox : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()
    
    private var productImageView : UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.backgroundColor = .white
        return imgView
    }()
    
    
    private var productNameLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black_700_main
        label.font = UIFont.set(size: 11, weight: ._700)
        label.text = "shoplive Big Logo Black Hoodies"
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        return label
    }()
    
    private var productpriceLabel : UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        return label
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        self.backgroundColor = .clear
        
    }
    
    
    required init?(coder : NSCoder){
        fatalError()
    }
    
    func setContent(productBannerModel : Product?,viewHideOption : ShopLiveListCellViewHideOptionModel){
        
        guard let productModel = productBannerModel else {
            self.productBannerBox.isHidden = true
            return
        }
        self.productBannerBox.isHidden = false
        if let name = productModel.name {
            productNameLabel.text = name
            productNameLabel.isHidden = false
        }
        else {
            productNameLabel.isHidden = true
        }
        if let productUrlString = productModel.imageUrl,
           let productUrl = URL(string: productUrlString) {
            ImageDownLoaderManager.shared.download(imageUrl: productUrl) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let imageData):
                    self.productImageView.image = UIImage(data: imageData)
                    self.productImageView.isHidden = false

                case .failure(_):
                    self.productImageView.image = nil
                    break
                }
            }
        }
        else {
            self.productImageView.image = nil
        }
        
        let discount : Double = Double(productModel.discountRate!)
        
        self.setProductPrice(originPrice: Double(productModel.originalPrice!),
                             discountPrice: Double(productModel.discountPrice!),
                             discount: discount,
                             currency: productModel.currency!,
                             showPrice : productModel.showPrice!)
        
    }
    
    
    private func setProductPrice(originPrice : Double, discountPrice : Double, discount : Double, currency : String, showPrice : Bool) {
        if showPrice == false {
            self.productpriceLabel.attributedText = nil
            self.productpriceLabel.text = "dummy space"
            self.productpriceLabel.textColor = .clear
            return
        }
        var string : String = ""
        let originPriceString = originPrice.currency(currencyCode: currency)
        let discountPriceString = discountPrice.currency(currencyCode: currency)
        let discountPercentString = discount.dropFractionIfPossible()
        if discount != 0.0 {
            string = "\(discountPercentString)% \(discountPriceString)"
        }
        else {
            string = "\(originPriceString)"
        }
        let attr = NSMutableAttributedString(string: string,attributes: [.font : UIFont.set(size: 12, weight: ._600),
                                                                                            .foregroundColor : UIColor.black_700_main])
        if discount != 0.0 {
            let range = NSString(string: string).range(of: "\(discountPercentString)%")
            attr.addAttributes([.foregroundColor : UIColor.brand_red], range: range)
        }
        self.productpriceLabel.attributedText = attr
    }
    
    
    
}
extension ShopLiveShortformBaseListTypeOverlayType1 {
    private func setLayout(){
        let productInfoStack = UIStackView(arrangedSubviews: [productNameLabel,productpriceLabel])
        productInfoStack.translatesAutoresizingMaskIntoConstraints = false
        productInfoStack.isLayoutMarginsRelativeArrangement = true
        productInfoStack.layoutMargins = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        productInfoStack.axis = .vertical
        productInfoStack.setCustomSpacing(3, after: productNameLabel)
        
        productBannerBox.addSubview(productImageView)
        productBannerBox.addSubview(productInfoStack)
        
        self.addSubview(productBannerBox)
        
        NSLayoutConstraint.activate([
            productBannerBox.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -6),
            productBannerBox.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 6),
            productBannerBox.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -6),
            productBannerBox.topAnchor.constraint(equalTo: productInfoStack.topAnchor),
            
            productImageView.topAnchor.constraint(equalTo: productBannerBox.topAnchor),
            productImageView.leadingAnchor.constraint(equalTo: productBannerBox.leadingAnchor),
            productImageView.bottomAnchor.constraint(equalTo: productBannerBox.bottomAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 45),
            
            productInfoStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 45),
            productInfoStack.heightAnchor.constraint(lessThanOrEqualToConstant: 100),
            productInfoStack.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor),
            productInfoStack.trailingAnchor.constraint(equalTo: productBannerBox.trailingAnchor),
            productInfoStack.bottomAnchor.constraint(equalTo: productBannerBox.bottomAnchor)
            
            
        ])
        
        
        
    }
}
