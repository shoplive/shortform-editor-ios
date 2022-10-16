//
//  SecretKeyInputAlertController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/20.
//

import UIKit
#if SDK_MODULE
import ShopLiveSDK
#endif

class SecretKeyInputAlertController: CustomBaseAlertController {

    lazy var keyTitleInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "userinfo.alert.placeholder.customer.title".localized()
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

    lazy var secretKeyInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "userinfo.alert.placeholder.secretKey.title".localized()
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
        view.addTarget(self, action: #selector(saveSecretKey), for: .touchUpInside)
        return view
    }()

    var saveEnable: Bool {
        return !(keyTitleInputField.text?.isEmpty ?? false) && !(secretKeyInputField.text?.isEmpty ?? false)
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

        alertItemView.addSubview(keyTitleInputField)
        alertItemView.addSubview(secretKeyInputField)
        alertItemView.addSubview(saveButton)

        keyTitleInputField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.top.equalToSuperview().offset(10)
            $0.height.equalTo(35)
        }

        secretKeyInputField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.top.equalTo(keyTitleInputField.snp.bottom).offset(10)
            $0.height.equalTo(35)
        }

        saveButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.top.equalTo(secretKeyInputField.snp.bottom).offset(10)
            $0.bottom.equalToSuperview().offset(-10)
            $0.height.equalTo(40)
        }
    }

    @objc func saveSecretKey() {
        guard saveEnable else { return }
        DemoSecretKeyTool.shared.save(key: .init(name: keyTitleInputField.text ?? "", key: secretKeyInputField.text ?? ""))
        self.dismiss(animated: false, completion: nil)

    }
}

extension SecretKeyInputAlertController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveButton.isEnabled = saveEnable
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case keyTitleInputField:
            self.secretKeyInputField.becomeFirstResponder()
            break
        case secretKeyInputField:
            saveSecretKey()
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

#if SDK_MODULE
extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))

        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.setBackgroundImage(backgroundImage, for: state)
    }
}
#endif
