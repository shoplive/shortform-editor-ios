//
//  ShopLiveShortformVerticalOverlayCardViewType2.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/05/02.
//

import Foundation
import UIKit
import ShopliveSDKCommon


/**
 세론 2단, 가로 템플릿 2 오버레이 뷰
 */
final class ShopLiveShortformBaseListTypeOverlayType2 : UIView {
    
    private var productImage : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 18
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
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        self.backgroundColor = .clear
        
    }
    
    required init?(coder : NSCoder){
        fatalError()
    }
    
    
    func setContent( productBannerModel : SLProduct?, productCount : Int, viewHideOption : ShopLiveListCellViewHideOptionModel){
        guard let productModel = productBannerModel else {
            self.productImage.isHidden = true
            self.productCountLabel.isHidden = true
            return
        }
        
        self.productImage.isHidden = false
        self.productCountLabel.isHidden = false
        if let productUrlString = productModel.imageUrl,
           let productUrl = URL(string: productUrlString) {
            ImageDownLoaderManager.shared.download(imageUrl: productUrl) { [weak self] result in
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
        
        if productModel.stockStatus! != "IN_STOCK" || viewHideOption.isProductCountVisible == false ||
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
    
    
    
}
extension ShopLiveShortformBaseListTypeOverlayType2 {
    private func setLayout(){
        self.addSubview(productImage)
        self.addSubview(productCountLabel)
        
        NSLayoutConstraint.activate([
            productImage.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -8),
            productImage.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -8),
            productImage.widthAnchor.constraint(equalToConstant: 36),
            productImage.heightAnchor.constraint(equalToConstant: 36),
            
            productCountLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -7),
            productCountLabel.centerYAnchor.constraint(equalTo: productImage.topAnchor,constant: 2),
            productCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),
            productCountLabel.heightAnchor.constraint(equalToConstant: 16)
            
        ])
        
    }
    
}
