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
        case hiddenTextBox(Bool)
        case setTitle(String?)
        case updateStyle(fontSize: CGFloat, fontColor: String, roundedBoxColor: String,  borderRadius: CGFloat, paddingX: CGFloat, paddingY: CGFloat)
    }
    
    enum Result { }
    
    private var paddingConstraints: [NSLayoutConstraint] = []
    
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
        label.text = ""
        label.adjustsFontSizeToFitWidth = true
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
        case let .hiddenTextBox(isHidden):
            self.isHidden = isHidden
        case let .setTitle(title):
            if !(title?.isEmpty ?? false) {
                boxTitle.text = title
            } else {
                self.isHidden = true
            }
        case let .updateStyle(fontSize, fontColor, roundedBoxColor, borderRadius, paddingX, paddingY):
            // title set
            boxTitle.font = UIFont.boldSystemFont(ofSize: fontSize)
            boxTitle.textColor = UIColor(sl_hex: fontColor)
            
            // roundedBox set
            roundedTextBox.backgroundColor = UIColor(sl_hex: roundedBoxColor)
            roundedTextBox.layer.cornerRadius = borderRadius
            
            updatePaddingConstraints(x: paddingX, y: paddingY)
        }
    }
    
    private func setLayout() {
        self.isHidden = true
        self.addSubview(roundedTextBox)
        roundedTextBox.addSubview(boxTitle)
        
        paddingConstraints = [
            boxTitle.topAnchor.constraint(equalTo: roundedTextBox.topAnchor, constant: 6),
            boxTitle.leadingAnchor.constraint(equalTo: roundedTextBox.leadingAnchor, constant: 8),
            boxTitle.trailingAnchor.constraint(equalTo: roundedTextBox.trailingAnchor, constant: -8),
            boxTitle.bottomAnchor.constraint(equalTo: roundedTextBox.bottomAnchor, constant: -6)
        ]
        
        NSLayoutConstraint.activate(paddingConstraints)
        
        NSLayoutConstraint.activate([
            roundedTextBox.topAnchor.constraint(equalTo: self.topAnchor),
            roundedTextBox.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
            roundedTextBox.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            roundedTextBox.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            roundedTextBox.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            roundedTextBox.widthAnchor.constraint(equalTo: boxTitle.widthAnchor, constant: 16),
            roundedTextBox.heightAnchor.constraint(equalTo: boxTitle.heightAnchor, constant: 12)
        ])
    }
    
    private func updatePaddingConstraints(x: CGFloat, y: CGFloat) {
        NSLayoutConstraint.deactivate(paddingConstraints)
        paddingConstraints.removeAll()
        
        paddingConstraints = [
            boxTitle.topAnchor.constraint(equalTo: roundedTextBox.topAnchor, constant: y),
            boxTitle.leadingAnchor.constraint(equalTo: roundedTextBox.leadingAnchor, constant: x),
            boxTitle.trailingAnchor.constraint(equalTo: roundedTextBox.trailingAnchor, constant: -x),
            boxTitle.bottomAnchor.constraint(equalTo: roundedTextBox.bottomAnchor, constant: -y)
        ]
        
        NSLayoutConstraint.activate(paddingConstraints)
        
        updateRoundedTextBoxSizeConstraints(paddingX: x, paddingY: y)
    }
    
    private func updateRoundedTextBoxSizeConstraints(paddingX: CGFloat, paddingY: CGFloat) {
        for constraint in roundedTextBox.constraints {
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        
        NSLayoutConstraint.activate([
            roundedTextBox.widthAnchor.constraint(equalTo: boxTitle.widthAnchor, constant: paddingX * 2),
            roundedTextBox.heightAnchor.constraint(equalTo: boxTitle.heightAnchor, constant: paddingY * 2)
        ])
    }
}
