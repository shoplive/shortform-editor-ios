//
//  ShopLiveShortformOverlayCardViewType1.swift
//  matrix-shortform-ios
//
//  Created by sangmin han on 2023/04/28.
//

import Foundation
import UIKit
import ShopliveSDKCommon

/**
 세로 1단 템플릿 1 오버레이 뷰
 */
class ShopLiveShortformOverlayCardViewType1 : UIView {
    
    
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.set(size: 16, weight: ._600)
        label.text = ""
        return label
    }()
    
    private var subtitleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.set(size: 13, weight: ._400)
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        return label
    }()
    
    private var userImage : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 14
        imageView.clipsToBounds = true
        imageView.backgroundColor = .gray
        return imageView
    }()
    
    private var userNameLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.set(size: 12, weight: ._400)
        label.text = ""
        return label
    }()
    
    lazy private var userInfoStack : UIStackView = {
        let stack = UIStackView(arrangedSubviews: [userImage,userNameLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()
    
    lazy private var wholeStack : UIStackView = {
        let wholeStack = UIStackView(arrangedSubviews: [titleLabel,subtitleLabel,userInfoStack,productBannerBox])
        wholeStack.translatesAutoresizingMaskIntoConstraints = false
        wholeStack.axis = .vertical
        wholeStack.setCustomSpacing(4, after: titleLabel)
        wholeStack.setCustomSpacing(4, after: subtitleLabel)
        wholeStack.setCustomSpacing(8, after: userInfoStack)
        return wholeStack
    }()
    
    
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
    
    private var productCompanyLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black_500
        label.font = UIFont.set(size: 10, weight: ._500)
        label.text = ""
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        return label
    }()
    
    private var productNameLabel : UILabel = {
        let label = UILabel()
        label.textColor = .black_700_main
        label.font = UIFont.set(size: 12, weight: ._700)
        label.text = ""
        label.setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
        return label
    }()
    
    private var productpriceLabel : UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
        return label
    }()
    
    lazy private var productInfoStack : UIStackView = {
        let productInfoStack = UIStackView(arrangedSubviews: [productCompanyLabel,productNameLabel,productpriceLabel])
        productInfoStack.translatesAutoresizingMaskIntoConstraints = false
        productInfoStack.isLayoutMarginsRelativeArrangement = true
        productInfoStack.layoutMargins = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        productInfoStack.axis = .vertical
        productInfoStack.setCustomSpacing(3, after: productCompanyLabel)
        productInfoStack.setCustomSpacing(3, after: productNameLabel)
        return productInfoStack
    }()
    
    private var gradationView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    private var gradientLayer = CAGradientLayer()
    
    private var blockGradientDrawing : Bool = false
    
    
    override init(frame : CGRect){
        super.init(frame: frame)
        self.setLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if blockGradientDrawing == false {
            blockGradientDrawing = true
            drawGradientLayer()
        }
        gradientLayer.frame = gradationView.bounds
    }
    
    override func draw(_ rect: CGRect) {
        
    }
    
    func setContent(title : String, description : String?, userThumbnail : String, userName : String, productBannerModel : Product?, viewHideOption : ShopLiveListCellViewHideOptionModel,cellCornerRadius: CGFloat){
        self.gradationView.layer.cornerRadius = cellCornerRadius
        self.gradationView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        self.titleLabel.isHidden = viewHideOption.isTitleVisible ? false : true
        self.titleLabel.text = title
        if viewHideOption.isBrandVisible == false {
            userInfoStack.isHidden = true
        }
        else {
            if userThumbnail == "" && userName == "" {
                userInfoStack.isHidden = true
                wholeStack.setCustomSpacing(8, after: titleLabel)
                wholeStack.setCustomSpacing(0, after: userInfoStack)
            }
            else {
                userInfoStack.isHidden = false
                wholeStack.setCustomSpacing(4, after: titleLabel)
                wholeStack.setCustomSpacing(8, after: userInfoStack)
            }
            
            if let url = URL(string: userThumbnail) {
                userImage.image = UIImage(named: "ic_shoplive_user-fill")
                ImageDownLoaderManager.shared.download(imageUrl: url) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let imageData):
                        self.userImage.image = UIImage(data: imageData)
                        self.userImage.isHidden = false
                    case .failure(_):
                        break
                    }
                }
            }
            else {
                self.userImage.isHidden = true
            }
            
            if userName != "" {
                self.userNameLabel.text = userName
                self.userNameLabel.isHidden = false
            }
            else {
                self.userNameLabel.text = ""
                self.userNameLabel.isHidden = true
            }
        }
        
        if let description = description, description.trimmingCharacters(in: .whitespacesAndNewlines) != "", viewHideOption.isDescriptionVisible {
            self.subtitleLabel.isHidden = false
            self.subtitleLabel.text = description
        }
        else {
            self.subtitleLabel.isHidden = true
        }
        
        adjustStackCustomSpacing()
        
        guard let productModel = productBannerModel else {
            self.productBannerBox.isHidden = true
            return
        }
        self.productBannerBox.isHidden = false
        
        if let brand = productModel.brand, brand.trimWhiteSpacing_SL != "" {
            productCompanyLabel.text = brand
            productCompanyLabel.isHidden = false
        }
        else {
            productCompanyLabel.isHidden = true
        }
        if let name = productModel.name, name.trimWhiteSpacing_SL != "" {
            productNameLabel.text = name
            productNameLabel.isHidden = false
        }
        else {
            productNameLabel.isHidden = true
        }
        
        if let productUrlString = productModel.imageUrl,
           let productUrl = URL(string: productUrlString){
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
        
        self.setProductPrice(originPrice: Double(productModel.originalPrice ?? 0),
                             discountPrice: Double(productModel.discountPrice ?? 0),
                             discount: discount,
                             currency: productModel.currency!,
                             showPrice : productModel.showPrice!)
        
        adjustProductBoxStackSpacingAndDistribution()
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
    
    private func adjustStackCustomSpacing(){
        wholeStack.layoutMargins = .zero
        if userInfoStack.isHidden {
            wholeStack.setCustomSpacing(0, after: userInfoStack)
            if subtitleLabel.isHidden == false {
                wholeStack.setCustomSpacing(6, after: subtitleLabel)
            }
            else {
                wholeStack.setCustomSpacing(0, after: subtitleLabel)
            }
            wholeStack.setCustomSpacing(2, after: titleLabel)
        }
        else {
            if subtitleLabel.isHidden == false && titleLabel.isHidden == false {
                wholeStack.setCustomSpacing(2, after: titleLabel)
                wholeStack.setCustomSpacing(8, after: subtitleLabel)
            }
            else if subtitleLabel.isHidden && titleLabel.isHidden == false {
                wholeStack.setCustomSpacing(8, after: titleLabel)
                wholeStack.setCustomSpacing(0, after: subtitleLabel)
            }
            else if subtitleLabel.isHidden == false {
                wholeStack.setCustomSpacing(8, after: subtitleLabel)
            }
        }
        wholeStack.layoutIfNeeded()
    }
    
    private func adjustProductBoxStackSpacingAndDistribution() {
        if productCompanyLabel.isHidden == true {
            productInfoStack.setCustomSpacing(0, after: productCompanyLabel)
            productInfoStack.distribution = .fillEqually
        }
        else {
            productInfoStack.setCustomSpacing(3, after: productCompanyLabel)
            productInfoStack.distribution = .fill
        }
    }
    
}
extension ShopLiveShortformOverlayCardViewType1 {
    private func setLayout(){
        productBannerBox.addSubview(productImageView)
        productBannerBox.addSubview(productInfoStack)
        
        self.addSubview(gradationView)
        self.addSubview(wholeStack)
        
        NSLayoutConstraint.activate([
            gradationView.topAnchor.constraint(equalTo: wholeStack.topAnchor,constant: -20),
            gradationView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            gradationView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            gradationView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            subtitleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: (subtitleLabel.font.lineHeight * 2 + 3)),
            wholeStack.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -16),
            wholeStack.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 16),
            wholeStack.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -16),
            wholeStack.heightAnchor.constraint(lessThanOrEqualToConstant: 500),
            
            userInfoStack.heightAnchor.constraint(equalToConstant: 28),
            userImage.widthAnchor.constraint(equalToConstant: 28),
            
            productBannerBox.bottomAnchor.constraint(equalTo: productInfoStack.bottomAnchor),
            productBannerBox.topAnchor.constraint(equalTo: productInfoStack.topAnchor),
            
            productImageView.topAnchor.constraint(equalTo: productBannerBox.topAnchor),
            productImageView.leadingAnchor.constraint(equalTo: productBannerBox.leadingAnchor),
            productImageView.bottomAnchor.constraint(equalTo: productBannerBox.bottomAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 50),
            
            productInfoStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 62),
            productInfoStack.heightAnchor.constraint(lessThanOrEqualToConstant: 100),
            productInfoStack.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor),
            productInfoStack.trailingAnchor.constraint(equalTo: productBannerBox.trailingAnchor),
            productInfoStack.bottomAnchor.constraint(equalTo: productBannerBox.bottomAnchor)
            
        ])
    }
    
    
    private func drawGradientLayer() {
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.8).cgColor,UIColor.clear.cgColor]
        gradientLayer.startPoint = .init(x: 0.5, y: 1)
        gradientLayer.endPoint = .init(x: 0.5, y: 0)
        gradationView.layer.addSublayer(gradientLayer)
    }
}
