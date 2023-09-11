//
//  AddParameterCell.swift
//  ShopLiveSDK
//
//  Created by vex on 2022/08/21.
//

import Foundation
import UIKit

protocol AddParameterCellDelegate: AnyObject {
    func parameter(index: Int, key: String, value: String, isUse: Bool)
}

class AddParameterCell: UITableViewCell, UITextFieldDelegate {
    
    weak var delegate: AddParameterCellDelegate?
    lazy var keyInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "userinfo.add.parameter.key.placeholder".localized()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        view.accessibilityIdentifier = "keyInputField"
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        view.delegate = self
        return view
    }()
    
    lazy var valueInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "userinfo.add.parameter.value.placeholder".localized()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        view.accessibilityIdentifier = "valueInputField"
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        view.delegate = self
        return view
    }()
    
    lazy var isUseCheckBox: ShopLiveCheckBoxButton = {
        let view = ShopLiveCheckBoxButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(identifier: "useCustomParam", description: "use Param")
        view.delegate = self
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(key: String, value: String, isUse: Bool) {
        self.keyInputField.text = key
        self.valueInputField.text = value
        self.isUseCheckBox.isSelected = isUse
    }
    
    private func setupViews() {
        self.contentView.addSubview(keyInputField)
        self.contentView.addSubview(valueInputField)
        self.contentView.addSubview(isUseCheckBox)
        self.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            keyInputField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            keyInputField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            keyInputField.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1),
            keyInputField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            valueInputField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3),
            valueInputField.leadingAnchor.constraint(equalTo: keyInputField.trailingAnchor,constant: 10),
            valueInputField.widthAnchor.constraint(equalTo: keyInputField.widthAnchor, multiplier: 1),
            valueInputField.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1),
            valueInputField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            isUseCheckBox.leadingAnchor.constraint(equalTo: valueInputField.trailingAnchor, constant: 10),
            isUseCheckBox.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            isUseCheckBox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
//        keyInputField.snp.makeConstraints {
//            $0.width.equalToSuperview().multipliedBy(0.3)
//            $0.leading.equalToSuperview()
//            $0.height.equalToSuperview()
//            $0.leading.equalToSuperview()
//        }
//
//        valueInputField.snp.makeConstraints {
//            $0.width.equalToSuperview().multipliedBy(0.3)
//            $0.leading.equalTo(keyInputField.snp.trailing).offset(10)
//            $0.width.equalTo(keyInputField)
//            $0.height.equalToSuperview()
//            $0.centerY.equalToSuperview()
//        }
//
//        isUseCheckBox.snp.makeConstraints {
//            $0.leading.equalTo(valueInputField.snp.trailing).offset(10)
//            $0.trailing.equalToSuperview()
//            $0.centerY.equalToSuperview()
//        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 4, left: 0, bottom: 10, right: 0))
    }
}

extension AddParameterCell: ShopLiveCheckBoxButtonDelegate {
    func didChecked(_ sender: ShopLiveCheckBoxButton) {
        delegate?.parameter(index: self.keyInputField.tag, key: self.keyInputField.text ?? "", value: self.valueInputField.text ?? "", isUse: self.isUseCheckBox.isChecked)
    }
}
