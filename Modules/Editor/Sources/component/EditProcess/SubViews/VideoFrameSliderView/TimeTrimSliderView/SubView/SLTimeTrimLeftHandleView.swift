//
//  SLTimeTrimLeftHandleView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/4/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit


class SLTimeTrimLeftHandleView : UIView {
    private var backgroundView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private var barView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    private var cornerRadius : CGFloat = 4
    
    init(frame: CGRect,cornerRadius : CGFloat, backgroundColor : UIColor, handleBarColor : UIColor) {
        super.init(frame: frame)
        self.cornerRadius = cornerRadius
        backgroundView.backgroundColor = backgroundColor
        barView.backgroundColor = handleBarColor
        self.setLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.roundCorners_SL(corners: [.topLeft,.bottomLeft], radius: cornerRadius)
        barView.layer.cornerRadius = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension SLTimeTrimLeftHandleView {
    private func setLayout() {
        self.addSubview(backgroundView)
        self.addSubview(barView)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            
            barView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            barView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            barView.widthAnchor.constraint(equalToConstant: 4),
            barView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
