//
//  EditorViewOptionBox.swift
//  shortform-examples
//
//  Created by sangmin han on 11/9/23.
//

import Foundation
import UIKit



class EditorViewOptionBox : UIView {
    
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Editor 옵션"
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    
    private let cropWidth = OptionTextViewInputBox(title: "crop 가로 비율")
    private let cropHeight = OptionTextViewInputBox(title: "crop 세로 비율")
    private let isFixedCrop = OptionSetSwitchBox(title: "crop 비율 고정",type: .editorIsFixedCrop)
    
    private let minVideoDuration = OptionTextViewInputBox(title: "최소 trim 시간")
    private let maxVideoDuration = OptionTextViewInputBox(title: "최대 trim 시간")
    
    private let descriptionBox = OptionSetSwitchBox(title: "설명 보이기",type: .editorDescription)
    private let tagBox = OptionSetSwitchBox(title: "태그 보이기",type: .editorTag)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setLayout()
        minVideoDuration.setKeyboardType(type: .decimalPad)
        maxVideoDuration.setKeyboardType(type: .decimalPad)
        cropWidth.setKeyboardType(type: .decimalPad)
        cropHeight.setKeyboardType(type: .decimalPad)
        
        
        
        isFixedCrop.delegate = self
        tagBox.delegate = self
        descriptionBox.delegate = self
        bindTextViews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setOptions() {
        
        cropWidth.setValue(value: String(OptionSettingModel.editorWidth))
        cropHeight.setValue(value: String(OptionSettingModel.editorheight))
        isFixedCrop.setSwitchIsOn(isOn: OptionSettingModel.editorIsFixed)
        
        minVideoDuration.setValue(value: String(OptionSettingModel.editorMinVideoDuration))
        maxVideoDuration.setValue(value: String(OptionSettingModel.editorMaxVideoDuration))
        descriptionBox.setSwitchIsOn(isOn: OptionSettingModel.editorShowDescription)
        tagBox.setSwitchIsOn(isOn: OptionSettingModel.editorShowTags)
    }
    
    private func bindTextViews() {
        
        cropWidth.textViewValueTracker = { text in
            if let n = NumberFormatter().number(from: text) {
                OptionSettingModel.editorWidth = Int(truncating: n)
            }
            else {
                OptionSettingModel.editorWidth = 9
            }
        }
        
        cropHeight.textViewValueTracker = { text in
            if let n = NumberFormatter().number(from: text) {
                OptionSettingModel.editorheight = Int(truncating: n)
            }
            else {
                OptionSettingModel.editorheight = 16
            }
        }
        
        minVideoDuration.textViewValueTracker = { text in
            if let n = NumberFormatter().number(from: text) {
                OptionSettingModel.editorMinVideoDuration = Double(truncating: n)
            }
            else {
                OptionSettingModel.editorMinVideoDuration = 1
            }
        }
        
        maxVideoDuration.textViewValueTracker = {text in
            if let n = NumberFormatter().number(from: text) {
                OptionSettingModel.editorMaxVideoDuration = Double(truncating: n)
            }
            else {
                OptionSettingModel.editorMaxVideoDuration = 1
            }
        }
    }
    
}
extension EditorViewOptionBox {
    private func setLayout() {
        let stack = UIStackView(arrangedSubviews:[titleLabel,
                                                  cropWidth,
                                                  cropHeight,
                                                  isFixedCrop,
                                                  minVideoDuration,
                                                 maxVideoDuration,
                                                 descriptionBox,
                                                 tagBox])
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
extension EditorViewOptionBox : OptionSetSwitchBoxDelegate {
    func optionChange(type: OptionSetSwitchBox.OptionType, value: Bool) {
        switch type {
        case .editorIsFixedCrop:
            OptionSettingModel.editorIsFixed = value
        case .editorTag:
            OptionSettingModel.editorShowTags = value
        case .editorDescription:
            OptionSettingModel.editorShowDescription = value
        default:
            break
        }
    }
}
