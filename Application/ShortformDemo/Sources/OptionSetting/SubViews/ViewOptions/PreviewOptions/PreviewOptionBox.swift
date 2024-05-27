//
//  PreviewOptionBox.swift
//  ShortformDemo
//
//  Created by sangmin han on 4/24/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit


class PreviewOptionBox : UIView {
    
    
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Preview 옵션"
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    
    private let previewPlayMaxCount = OptionTextViewInputBox(title: "Preview 동영상 갯수")
    private let previewIsMutedBox = OptionSetSwitchBox(title: "Preview 음소거", type: .previewIsMuted)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        previewPlayMaxCount.setKeyboardType(type: .decimalPad)
        previewIsMutedBox.delegate = self
        bindTextViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setOptions() {
        previewPlayMaxCount.setValue(value: String(OptionSettingModel.previewMaxCount ?? 0))
        previewIsMutedBox.setSwitchIsOn(isOn: OptionSettingModel.previewIsMuted)
    }
    
    private func bindTextViews() {
        previewPlayMaxCount.textViewValueTracker = { text in
            if let n = NumberFormatter().number(from: text) {
                OptionSettingModel.previewMaxCount = Int(truncating: n)
            }
            else {
                OptionSettingModel.previewMaxCount = 0
            }
        }
    }
}
extension PreviewOptionBox : OptionSetSwitchBoxDelegate {
    func optionChange(type: OptionSetSwitchBox.OptionType, value: Bool) {
        switch type {
        case .previewIsMuted:
            OptionSettingModel.previewIsMuted = value
        default:
            break
        }
    }
}
extension PreviewOptionBox {
    private func setLayout() {
        let stack = UIStackView(arrangedSubviews:[titleLabel,
                                                 previewPlayMaxCount,
                                                 previewIsMutedBox])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        self.addSubview(stack)
        
        NSLayoutConstraint.activate([
            
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.heightAnchor.constraint(lessThanOrEqualToConstant: 5000),
            
            self.bottomAnchor.constraint(equalTo: stack.bottomAnchor)
        ])
    }
    
    
}
