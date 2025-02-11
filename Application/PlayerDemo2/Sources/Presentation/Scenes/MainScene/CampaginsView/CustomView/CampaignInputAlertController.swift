//
//  CampaignInputAlertController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

protocol CampaignInputAlertDelegate: NSObjectProtocol {
    func saveData(data: ShopLiveKeySet)
}

class CampaignInputAlertController: CustomBaseAlertController {

    lazy var titleInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Title"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        view.keyboardType = .default
        view.delegate = self
        view.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        return view
    }()

    lazy var accessInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Access Key"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        view.keyboardType = .default
        view.delegate = self
        view.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        return view
    }()

    lazy var campaignInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Campaign Key"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        view.keyboardType = .default
        view.delegate = self
        view.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        return view
    }()

    lazy var saveButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("userinfo.new.button.save".localized(), for: .normal)
        view.layer.cornerRadius = 6
        view.setBackgroundColor(.red, for: .normal)
        view.setBackgroundColor(.darkGray, for: .disabled)
        view.isEnabled = self.saveEnable
        view.addTarget(self, action: #selector(saveCampaign), for: .touchUpInside)
        return view
    }()

    var saveEnable: Bool {
        return !(titleInputField.text?.isEmpty ?? false) && !(accessInputField.text?.isEmpty ?? false) && !(campaignInputField.text?.isEmpty ?? false)
    }
    
    weak var delegate: CampaignInputAlertDelegate?
    
    init(keyset: ShopLiveKeySet) {
        super.init(nibName: nil, bundle: nil)
        titleInputField.text = keyset.alias
        campaignInputField.text = keyset.campaignKey
        accessInputField.text = keyset.accessKey
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func setupViews() {
        super.setupViews()

        self.view.addSubview(alertItemView)
        alertItemView.addSubview(titleInputField)
        alertItemView.addSubview(accessInputField)
        alertItemView.addSubview(campaignInputField)
        alertItemView.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            alertItemView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            alertItemView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            alertItemView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9),
            alertItemView.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),
            
            titleInputField.leadingAnchor.constraint(equalTo: alertItemView.leadingAnchor,constant: 10),
            titleInputField.trailingAnchor.constraint(equalTo: alertItemView.trailingAnchor, constant: -10),
            titleInputField.topAnchor.constraint(equalTo: alertItemView.topAnchor,constant: 10),
            titleInputField.heightAnchor.constraint(equalToConstant: 35),
            
            accessInputField.leadingAnchor.constraint(equalTo: alertItemView.leadingAnchor,constant: 10),
            accessInputField.trailingAnchor.constraint(equalTo: alertItemView.trailingAnchor, constant: -10),
            accessInputField.topAnchor.constraint(equalTo: titleInputField.bottomAnchor,constant: 10),
            accessInputField.heightAnchor.constraint(equalToConstant: 35),
            
            campaignInputField.leadingAnchor.constraint(equalTo: alertItemView.leadingAnchor,constant: 10),
            campaignInputField.trailingAnchor.constraint(equalTo: alertItemView.trailingAnchor,constant: -10),
            campaignInputField.topAnchor.constraint(equalTo: accessInputField.bottomAnchor,constant: 10),
            campaignInputField.heightAnchor.constraint(equalToConstant: 35),
            
            saveButton.leadingAnchor.constraint(equalTo: alertItemView.leadingAnchor,constant: 10),
            saveButton.trailingAnchor.constraint(equalTo: alertItemView.trailingAnchor,constant: -10),
            saveButton.topAnchor.constraint(equalTo: campaignInputField.bottomAnchor, constant: 10),
            saveButton.bottomAnchor.constraint(equalTo: alertItemView.bottomAnchor,constant: -10),
            saveButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc func saveCampaign() {
        guard saveEnable else { return }
        guard let alias = titleInputField.text else { return }
        
        delegate?.saveData(data: .init(
            alias: alias,
            campaignKey: campaignInputField.text ?? "", accessKey: accessInputField.text ?? ""
        ))
        self.dismiss(animated: false, completion: nil)

    }
}

extension CampaignInputAlertController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveButton.isEnabled = saveEnable
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case titleInputField:
            self.accessInputField.becomeFirstResponder()
            break
        case accessInputField:
            self.campaignInputField.becomeFirstResponder()
            break
        case campaignInputField:
            saveCampaign()
            break
        default:
            break
        }

        return true
    }

    @objc func textFieldDidChange(_ sender: UITextField) {
        saveButton.isEnabled = saveEnable
    }

}

