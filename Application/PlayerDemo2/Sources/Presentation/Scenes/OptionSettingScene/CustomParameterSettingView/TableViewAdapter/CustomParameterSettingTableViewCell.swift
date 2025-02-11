//
//  AddParameterCell.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol CustomParameterSettingTableViewCellDelegate: AnyObject {
    func customParameterValueChanged(at customParamterId : Int, key : String, value : String, isUse : Bool)
}

class CustomParameterSettingTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    static let cellId = "CustomParameterSettingTableViewCellid"
    private lazy var keyInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = PlayerDemo2Strings.Userinfo.Add.Parameter.Key.placeholder
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.setPlaceholderColor(.darkGray)
        return view
    }()
    
    private lazy var valueInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = PlayerDemo2Strings.Userinfo.Add.Parameter.Value.placeholder
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.setPlaceholderColor(.darkGray)
        return view
    }()
    
    private lazy var switchButton : UISwitch = {
        let button = UISwitch()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var disposeBag = DisposeBag()
    
    
    weak var delegate: CustomParameterSettingTableViewCellDelegate?
    private var customParameterId : Int = 0

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(customParameterId : Int, key: String, value: String, isUse: Bool) {
        self.customParameterId = customParameterId
        self.keyInputField.text = key
        self.valueInputField.text = value
        self.switchButton.isOn = isUse
        self.disposeBag = DisposeBag()
        bindView()
    }
    
    private func bindView() {
        //action
        Observable.combineLatest(keyInputField.rx.text.orEmpty, valueInputField.rx.text.orEmpty, switchButton.rx.isOn)
            .withUnretained(self)
            .subscribe { (owner, triple)  in
                let (key, value, isUse) = triple
                owner.delegate?.customParameterValueChanged(at: owner.customParameterId, key: key, value: value, isUse: isUse)
            }
            .disposed(by: disposeBag)
    }
}
extension CustomParameterSettingTableViewCell {
    private func setLayout() {
        self.backgroundColor = .white
        let stack = UIStackView(arrangedSubviews: [keyInputField,valueInputField])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        self.contentView.addSubview(stack)
        self.contentView.addSubview(switchButton)
        
        stack.snp.makeConstraints{
            $0.leading.top.bottom.equalToSuperview()
            $0.trailing.equalTo(switchButton.snp.leading)
        }
        
        switchButton.snp.makeConstraints {
            $0.leading.equalTo(valueInputField.snp.trailing).offset(10)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
