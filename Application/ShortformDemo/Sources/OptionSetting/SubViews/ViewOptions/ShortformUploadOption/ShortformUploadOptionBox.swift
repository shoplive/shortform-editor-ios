//
//  ShortformUploadOptionBox.swift
//  ShortformDemo
//
//  Created by Tabber on 4/2/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopLiveShortformSDK

class ShortformUploadOptionBox: UIView {
    
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "숏폼 업로더 옵션"
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    
    private let switchTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "UI 옵션"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    
    private let inputTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "데이터 옵션"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    
    private let hashTagSwitch = OptionSetSwitchBox(title: "해시태그 사용",type: .hashTag)
    private let videoChangeSwitch = OptionSetSwitchBox(title: "커버 변경 사용",type: .videoChange)
    private let ratingSwitch = OptionSetSwitchBox(title: "별점 사용",type: .rating)
    private let shortformEditModeSwitch = OptionSetSwitchBox(title: "숏폼 편집 모드 사용",type: .shortformEdit)
    
    private let skusBox = OptionTextViewInputBox(title: "Skus")
    private let tagBox = OptionTextViewInputBox(title: "Tags")
    
    private let stackView = UIStackView()
    
    private var hashTagBool: Bool = true
    private var videoChangeBool: Bool = false
    private var ratingBool: Bool = false
    private var shortformEditBool: Bool = false
    
    private var currentTags: String = ""
    private var currentSkus: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        
        hashTagSwitch.delegate = self
        videoChangeSwitch.delegate = self
        ratingSwitch.delegate = self
        shortformEditModeSwitch.delegate = self
        setData()
        
        tagBox.textViewValueTracker = { [weak self] value in
            self?.currentTags = value
        }
        
        skusBox.textViewValueTracker = { [weak self] value in
            self?.currentSkus = value
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setData() {
        
        hashTagBool = OptionSettingModel.shortFormUploadUsingHashTag
        videoChangeBool = OptionSettingModel.shortFormUploadUsingVideoChage
        ratingBool = OptionSettingModel.shortFormUploadUsingRating
        shortformEditBool = OptionSettingModel.shortFormEditMode
        
        currentTags = OptionSettingModel.shortFormUploadTags.joined(separator: ",")
        currentSkus = OptionSettingModel.shortFormUploadSkus.joined(separator: ",")
        
        hashTagSwitch.setSwitchIsOn(isOn: hashTagBool)
        videoChangeSwitch.setSwitchIsOn(isOn: videoChangeBool)
        ratingSwitch.setSwitchIsOn(isOn: ratingBool)
        shortformEditModeSwitch.setSwitchIsOn(isOn: shortformEditBool)
        
        tagBox.setValue(value: currentTags)
        skusBox.setValue(value: currentSkus)
    }
    
    func applyConfirm() {
        OptionSettingModel.shortFormUploadUsingHashTag = hashTagBool
        OptionSettingModel.shortFormUploadUsingVideoChage = videoChangeBool
        OptionSettingModel.shortFormUploadUsingRating = ratingBool
        OptionSettingModel.shortFormEditMode = shortformEditBool
        
        if !currentTags.isEmpty {
            OptionSettingModel.shortFormUploadTags = currentTags.components(separatedBy: ",")
        }
        
        if !currentSkus.isEmpty {
            OptionSettingModel.shortFormUploadSkus = currentSkus.components(separatedBy: ",")
        }
        
    }
    
}

extension ShortformUploadOptionBox {
    private func setLayout() {
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .leading
        
        self.addSubview(stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(switchTitleLabel)
        stackView.addArrangedSubview(hashTagSwitch)
        stackView.addArrangedSubview(videoChangeSwitch)
        stackView.addArrangedSubview(ratingSwitch)
        stackView.addArrangedSubview(shortformEditModeSwitch)
        
        stackView.addArrangedSubview(inputTitleLabel)
        stackView.addArrangedSubview(tagBox)
        stackView.addArrangedSubview(skusBox)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        hashTagSwitch.translatesAutoresizingMaskIntoConstraints = false
        videoChangeSwitch.translatesAutoresizingMaskIntoConstraints = false
        ratingSwitch.translatesAutoresizingMaskIntoConstraints = false
        shortformEditModeSwitch.translatesAutoresizingMaskIntoConstraints = false
        tagBox.translatesAutoresizingMaskIntoConstraints = false
        skusBox.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            hashTagSwitch.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            videoChangeSwitch.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            ratingSwitch.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            shortformEditModeSwitch.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            tagBox.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            skusBox.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            hashTagSwitch.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            videoChangeSwitch.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            shortformEditModeSwitch.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            ratingSwitch.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            tagBox.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            skusBox.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
        ])
        
    }
}

extension ShortformUploadOptionBox: OptionSetSwitchBoxDelegate {
    func optionChange(type: OptionSetSwitchBox.OptionType, value: Bool) {
        switch type {
        case .hashTag:
            hashTagBool = value
        case .videoChange:
            videoChangeBool = value
        case .rating:
            ratingBool = value
        case .shortformEdit:
            shortformEditBool = value
        default:
            break
        }
    }
}
