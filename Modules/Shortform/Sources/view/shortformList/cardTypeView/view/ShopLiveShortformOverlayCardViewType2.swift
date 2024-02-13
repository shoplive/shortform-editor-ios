//
//  ShopLiveShortformCardViewType2.swift
//  matrix-shortform-ios
//
//  Created by sangmin han on 2023/04/28.
//

import Foundation
import UIKit
import ShopLiveSDKCommon

/**
 세로 1단 템플릿 2 오버레이 뷰
 */
class ShopLiveShortformOverlayCardViewType2 : UIView {
    
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.set(size: 16, weight: ._600)
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
    
    
    private var productImage : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        return imageView
    }()
    
    private var productCountLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.black_700_main
        label.font = UIFont.set(size: 11, weight: ._600)
        label.layer.cornerRadius = 8.5
        label.clipsToBounds = true
        label.textColor = .white
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        return label
    }()
    
    lazy private var wholeStack : UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel,subtitleLabel,userInfoStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .zero
        stack.axis = .vertical
        stack.setCustomSpacing(2, after: titleLabel)
        stack.setCustomSpacing(14, after: subtitleLabel)
        return stack
    }()
    
    lazy private var wholeStackTrailingToProductImageAnc : NSLayoutConstraint = {
        return wholeStack.trailingAnchor.constraint(equalTo: self.productImage.leadingAnchor,constant: -2)
    }()
    
    lazy private var wholeStackTrailingToSuperViewAnc : NSLayoutConstraint = {
        return wholeStack.trailingAnchor.constraint(equalTo: self.trailingAnchor ,constant: -16)
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
        setLayout()
        
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
    
    func setContent(title : String, description : String?, userThumbnail : String, userName : String, productBannerModel : Product?, productCount : Int, viewHideOption : ShopLiveListCellViewHideOptionModel,cellCornerRadius : CGFloat){
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
            }
            else {
                userInfoStack.isHidden = false
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
        
        self.adjustStackCustomSpacing()
        
        guard let productModel = productBannerModel else {
            self.productImage.isHidden = true
            self.productCountLabel.isHidden = true
            wholeStackTrailingToSuperViewAnc.isActive = true
            wholeStackTrailingToProductImageAnc.isActive = false
            return
        }
        wholeStackTrailingToSuperViewAnc.isActive = false
        wholeStackTrailingToProductImageAnc.isActive = true
        
        self.productImage.isHidden = false
        if let productUrlString = productModel.imageUrl,
           let productUrl = URL(string: productUrlString) {
            ImageDownLoaderManager.shared.download(imageUrl: productUrl) { [weak self] result  in
                guard let self = self else { return }
                switch result {
                case .success(let imageData):
                    self.productImage.image = UIImage(data: imageData)
                    self.productImage.isHidden = false
                case .failure(_):
                    self.productImage.image = nil
                    break
                }
            }
        }
        else {
            self.productImage.image = nil
        }
        
        if productModel.stockStatus! != "IN_STOCK"  || viewHideOption.isProductCountVisible == false ||
        productCount <= 1 {
            self.productCountLabel.isHidden = true
        }
        else {
            self.productCountLabel.isHidden = false
        }
        if productCount >= 100 {
            self.productCountLabel.textAlignment = .natural
            self.productCountLabel.text = " 99+ "
        }
        else if productCount >= 10 {
            self.productCountLabel.textAlignment = .natural
            self.productCountLabel.text = " \(productCount) "
        }
        else {
            self.productCountLabel.textAlignment = .center
            self.productCountLabel.text = "\(productCount)"
        }
    }
    

    private func adjustStackCustomSpacing(){
        wholeStack.layoutMargins = .zero
        if userInfoStack.isHidden {
            wholeStack.setCustomSpacing(0, after: subtitleLabel)
            if subtitleLabel.isHidden == false {
                wholeStack.setCustomSpacing(2, after: titleLabel)
            }
            else {
                wholeStack.setCustomSpacing(0, after: titleLabel)
                wholeStack.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
            }
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
    
}
extension ShopLiveShortformOverlayCardViewType2 {
    private func setLayout(){
        self.addSubview(gradationView)
        self.addSubview(wholeStack)
        self.addSubview(productImage)
        self.addSubview(productCountLabel)
        
        NSLayoutConstraint.activate([
            gradationView.topAnchor.constraint(equalTo: wholeStack.topAnchor,constant: -20),
            gradationView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            gradationView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            gradationView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            subtitleLabel.heightAnchor.constraint(lessThanOrEqualToConstant: (subtitleLabel.font.lineHeight * 2 + 3)),
            wholeStack.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -16),
            wholeStack.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 16),
            
            wholeStack.heightAnchor.constraint(lessThanOrEqualToConstant: 300),
            
            userInfoStack.heightAnchor.constraint(equalToConstant: 28),
            userImage.widthAnchor.constraint(equalToConstant: 28),
            
            
            productImage.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -16),
            productImage.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -16),
            productImage.widthAnchor.constraint(equalToConstant: 40),
            productImage.heightAnchor.constraint(equalToConstant: 40),
            
            productCountLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -12),
            productCountLabel.centerYAnchor.constraint(equalTo: productImage.topAnchor,constant: 2),
            productCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),
            productCountLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    
    private func drawGradientLayer() {
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.8).cgColor,UIColor.clear.cgColor]
        gradientLayer.startPoint = .init(x: 0.5, y: 1)
        gradientLayer.endPoint = .init(x: 0.5, y: 0)
        gradationView.layer.addSublayer(gradientLayer)
    }
    
    
}
