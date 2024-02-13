//
//  ShopLiveShortformOverlayCardViewType0.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/08/02.
//

import Foundation
import UIKit
import ShopLiveSDKCommon



class ShopLiveShortformOverlayCardViewType0 : UIView {
    
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.set(size: 16, weight: ._600)
        label.text = "032c Readytowear"
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
        let stack = UIStackView(arrangedSubviews: [titleLabel,subtitleLabel,userInfoStack])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .zero
        stack.axis = .vertical
        stack.setCustomSpacing(2, after: titleLabel)
        stack.setCustomSpacing(8, after: subtitleLabel)
        return stack
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if blockGradientDrawing == false {
            blockGradientDrawing = true
            drawGradientLayer()
        }
        gradientLayer.frame = gradationView.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setContent(title : String, description : String?, userThumbnail : String, userName : String, viewHideOption : ShopLiveListCellViewHideOptionModel,cellCornerRadius : CGFloat){
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
        
        
        if let description = description, description.trimmingCharacters(in: .whitespacesAndNewlines) != "", viewHideOption.isDescriptionVisible  {
            self.subtitleLabel.isHidden = false
            self.subtitleLabel.text = description
        }
        else {
            self.subtitleLabel.isHidden = true
        }
        
        self.adjustStackCustomSpacing()
    }
    
    private func adjustStackCustomSpacing(){
        if userInfoStack.isHidden {
            wholeStack.setCustomSpacing(0, after: subtitleLabel)
            if subtitleLabel.isHidden == false {
                wholeStack.setCustomSpacing(2, after: titleLabel)
            }
            else {
                wholeStack.setCustomSpacing(0, after: titleLabel)
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
extension ShopLiveShortformOverlayCardViewType0 {
    private func setLayout(){
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
            wholeStack.heightAnchor.constraint(lessThanOrEqualToConstant: 300),
            
            userInfoStack.heightAnchor.constraint(equalToConstant: 28),
            userImage.widthAnchor.constraint(equalToConstant: 28),
        ])
    }
    
    private func drawGradientLayer() {
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.8).cgColor,UIColor.clear.cgColor]
        gradientLayer.startPoint = .init(x: 0.5, y: 1)
        gradientLayer.endPoint = .init(x: 0.5, y: 0)
        gradationView.layer.addSublayer(gradientLayer)
    }
}
