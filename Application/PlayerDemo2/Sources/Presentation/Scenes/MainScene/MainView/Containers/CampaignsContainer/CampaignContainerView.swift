//
//  CampaignContainerView.swift
//  PlayerDemo2
//
//  Created by Tabber on 2/4/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

protocol CampaignContainerDelegate: AnyObject {
    func updateKeySet(_ keyset: ShopLiveKeySet)
    func showCampaignsViewController()
}

class CampaignContainerView: UIView {

    weak var delegate: CampaignContainerDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "[\("base.section.campaignInfo.title".localized())]"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var guideTitleInputField: UITextField = {
        let view = UITextField()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.placeholder = "base.section.campaignInfo.campaign.none.title".localized()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        return view
    }()

    private lazy var chooseButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.layer.cornerRadius = 6
        view.contentEdgeInsets = .init(top: 7, left: 9, bottom: 7, right: 9)
        view.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        view.addTarget(self, action: #selector(didTouchButton), for: .touchUpInside)
        view.setTitle("base.section.campaignInof.button.chooseCampaign.title".localized(), for: .normal)
        return view
    }()

    private lazy var accessKeyInputField: UITextField = {
        let view = UITextField()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.placeholder = "accessKey"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        return view
    }()

    lazy var campaignKeyInputField: UITextField = {
        let view = UITextField()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.placeholder = "campaignKey"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(keySet: ShopLiveKeySet?) {
        guideTitleInputField.text = keySet?.alias ?? ""
        campaignKeyInputField.text = keySet?.campaignKey ?? ""
        accessKeyInputField.text = keySet?.accessKey ?? ""
    }
}

extension CampaignContainerView {
    private func setLayout() {
        self.backgroundColor = .white
        self.addSubview(titleLabel)
        
        self.addSubview(guideTitleInputField)
        self.addSubview(chooseButton)
        self.addSubview(accessKeyInputField)
        self.addSubview(campaignKeyInputField)
        
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(15)
            $0.leading.equalTo(self.snp.leading).offset(15)
            $0.height.equalTo(22)
        }
        
        guideTitleInputField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.trailing.equalTo(self.snp.trailing).inset(100)
            $0.height.equalTo(30)
        }
        
        chooseButton.snp.makeConstraints {
            $0.trailing.equalTo(self.snp.trailing).inset(15)
            $0.centerY.equalTo(guideTitleInputField.snp.centerY)
            $0.width.lessThanOrEqualTo(60)
            $0.height.equalTo(35)
        }
        
        accessKeyInputField.snp.makeConstraints {
            $0.top.equalTo(guideTitleInputField.snp.bottom).offset(10)
            $0.leading.equalTo(self.snp.leading).offset(15)
            $0.trailing.equalTo(self.snp.trailing).inset(15)
            $0.height.equalTo(30)
        }
        
        campaignKeyInputField.snp.makeConstraints {
            $0.top.equalTo(accessKeyInputField.snp.bottom).offset(15)
            $0.leading.equalTo(self.snp.leading).offset(15)
            $0.trailing.equalTo(self.snp.trailing).inset(15)
            $0.height.equalTo(30)
            $0.bottom.equalTo(self.snp.bottom)
        }
    }
}

// objc
extension CampaignContainerView {
    @objc private func didTouchButton() {
        delegate?.showCampaignsViewController()
    }
}

extension CampaignContainerView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let newText = string.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let text = textField.text, let predictRange = Range(range, in: text) else { return true }

        let predictedText = text.replacingCharacters(in: predictRange, with: newText)
        
        var alias = guideTitleInputField.text ?? "base.section.campaignInfo.campaign.none.title".localized()
        var campaignKey = campaignKeyInputField.text ?? "campaignKey"
        var accessKey = accessKeyInputField.text ?? "accessKey"
        
        switch textField {
        case campaignKeyInputField:
            campaignKey = predictedText
            break
        case accessKeyInputField:
            accessKey = predictedText
            break
        case guideTitleInputField:
            alias = predictedText
            break
        default:
            break
        }
        
        let keyset = ShopLiveKeySet(alias: alias.trimmingCharacters(in: .whitespacesAndNewlines),
                                    campaignKey: campaignKey.trimmingCharacters(in: .whitespacesAndNewlines),
                                    accessKey: accessKey.trimmingCharacters(in: .whitespacesAndNewlines))

        self.delegate?.updateKeySet(keyset)
        return true
    }
}
