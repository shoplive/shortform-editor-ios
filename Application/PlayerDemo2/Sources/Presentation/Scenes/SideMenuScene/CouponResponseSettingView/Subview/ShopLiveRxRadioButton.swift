//
//  ShopLiveRxRadioButton.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/12/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ShopLiveRxRadioButton : UIButton {
    
    lazy var radioButtonImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = PlayerDemo2Asset.radioNotSelected.image

        return imageView
    }()

    lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        view.font = .systemFont(ofSize: 12, weight: .medium)
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            radioButtonImage.image = isSelected ? PlayerDemo2Asset.radioSelected.image : PlayerDemo2Asset.radioNotSelected.image
        }
    }
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchrect = self.bounds
        if touchrect.contains(point) {
            return self
        }
        else {
            return nil
        }
    }
}
extension ShopLiveRxRadioButton {
    private func setLayout() {
        self.addSubview(radioButtonImage)
        self.addSubview(descriptionLabel)
        
        radioButtonImage.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.leading.equalTo(radioButtonImage.snp.trailing).offset(5)
        }
    }
}
