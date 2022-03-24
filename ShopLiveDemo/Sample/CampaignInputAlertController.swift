//
//  CampaignInputAlertController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/15.
//

import UIKit

class CampaignInputAlertController: CustomBaseAlertController {

    lazy var titleInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Title" // "campaign.input.alert.alias.placeholder".localized()
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
        view.placeholder = "Access Key" // "campaign.input.alert.accesskey.placeholder".localized()
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
        view.placeholder = "Campaign Key" // "campaign.input.alert.campaignkey.placeholder".localized()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func setupViews() {
        super.setupViews()

        self.view.addSubview(alertItemView)
        alertItemView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.height.greaterThanOrEqualTo(140)
        }

        alertItemView.addSubview(titleInputField)
        alertItemView.addSubview(accessInputField)
        alertItemView.addSubview(campaignInputField)
        alertItemView.addSubview(saveButton)

        titleInputField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.top.equalToSuperview().offset(10)
            $0.height.equalTo(35)
        }

        accessInputField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.top.equalTo(titleInputField.snp.bottom).offset(10)
            $0.height.equalTo(35)
        }

        campaignInputField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.top.equalTo(accessInputField.snp.bottom).offset(10)
            $0.height.equalTo(35)
        }
        saveButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.top.equalTo(campaignInputField.snp.bottom).offset(10)
            $0.bottom.equalToSuperview().offset(-10)
            $0.height.equalTo(40)
        }
    }

    @objc func saveCampaign() {
        guard saveEnable else { return }
        guard let alias = titleInputField.text else { return }
        ShopLiveDemoKeyTools.shared.save(key: .init(alias: alias, campaignKey: campaignInputField.text ?? "", accessKey: accessInputField.text ?? ""))
        ShopLiveDemoKeyTools.shared.saveCurrentKey(alias: alias)
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
