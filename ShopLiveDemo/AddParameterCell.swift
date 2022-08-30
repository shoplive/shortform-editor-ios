//
//  AddParameterCell.swift
//  ShopLiveSDK
//
//  Created by vex on 2022/08/21.
//

import Foundation
import UIKit

class AddParameterCell: UITableViewCell, UITextFieldDelegate {
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(key: String, value: String) {
        self.keyInputField.text = key
        self.valueInputField.text = value
    }
    
    private func setupViews() {
        self.contentView.addSubview(keyInputField)
        self.contentView.addSubview(valueInputField)
        self.backgroundColor = .white
        keyInputField.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(UIWindow.mainWindowFrame.frame.width / 2 - 20)
            $0.height.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        valueInputField.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(UIWindow.mainWindowFrame.frame.width / 2 - 20)
            $0.trailing.equalToSuperview()
            $0.height.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 4, left: 0, bottom: 10, right: 0))
    }
}
