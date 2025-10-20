//
//  ShopLiveInAppPipTextBoxView.swift
//  ShopLiveSDK
//
//  Created by Tabber on 10/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopliveSDKCommon

class ShopLiveInAppPipTextBoxView: UIView, SLReactor {
    
    enum Action {
        case setTitle(String?)
    }
    
    enum Result { }
    
    var resultHandler: ((Result) -> ())?
    
    private var roundedTextBox: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = UIColor(sl_hex: "#0C0E13")
        view.layer.cornerRadius = 8
        return view
    }()
    
    private var boxTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.numberOfLines = 1
        label.textColor = .white
        label.textAlignment = .center
        label.text = "한글몇글자까지가능할까요"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func action(_ action: Action) {
        switch action {
        case let .setTitle(title):
            boxTitle.text = title
        }
    }
    
    private func setLayout() {
        self.addSubview(roundedTextBox)
        roundedTextBox.addSubview(boxTitle)
        
        NSLayoutConstraint.activate([
            // roundedTextBox는 텍스트에 맞춰 크기 조절
            roundedTextBox.topAnchor.constraint(equalTo: self.topAnchor),
            roundedTextBox.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
            roundedTextBox.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            roundedTextBox.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            roundedTextBox.centerXAnchor.constraint(equalTo: self.centerXAnchor), // 중앙 정렬
            
            // boxTitle 내부 패딩
            boxTitle.topAnchor.constraint(equalTo: roundedTextBox.topAnchor, constant: 6),
            boxTitle.leadingAnchor.constraint(equalTo: roundedTextBox.leadingAnchor, constant: 8),
            boxTitle.trailingAnchor.constraint(equalTo: roundedTextBox.trailingAnchor, constant: -8),
            boxTitle.bottomAnchor.constraint(equalTo: roundedTextBox.bottomAnchor, constant: -6),
            
            // roundedTextBox 너비는 boxTitle에 맞춤 (패딩 16 = 8*2)
            roundedTextBox.widthAnchor.constraint(equalTo: boxTitle.widthAnchor, constant: 16),
            roundedTextBox.heightAnchor.constraint(equalTo: boxTitle.heightAnchor, constant: 12)
        ])
    }
}
