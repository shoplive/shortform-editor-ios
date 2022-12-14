//
//  CustomAppVersionInputAlertController.swift
//  ShopLiveSDK
//
//  Created by 김우현 on 12/8/22.
//

import Foundation
import UIKit


class CustomAppVersionInputAlertController: CustomBaseAlertController {

    lazy var textInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        return view
    }()

    lazy var deleteButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("alert.msg.delete".localized(), for: .normal)
        view.backgroundColor = .gray
        view.setTitleColor(.black, for: .normal)
        view.addTarget(self, action: #selector(deleteAct), for: .touchUpInside)
        return view
    }()

    lazy var saveButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("alert.msg.confirm".localized(), for: .normal)
        view.backgroundColor = .lightGray
        view.setTitleColor(.black, for: .normal)
        view.addTarget(self, action: #selector(saveAct), for: .touchUpInside)
        return view
    }()

    private var placeHolder: String = "appversion.alert.placeholder".localized()

    private var completion: (() -> Void)?
    
    init(completion: @escaping (() -> Void)) {
        super.init(nibName: nil, bundle: nil)
        self.completion = completion
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textInputField.text = DemoConfiguration.shared.customAppVersion ?? ""
        textInputField.placeholder = self.placeHolder
        textInputField.setPlaceholderColor(.darkGray)
    }

    override func setupViews() {
        super.setupViews()

        self.view.addSubview(alertItemView)
        alertItemView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.9)
            $0.height.greaterThanOrEqualTo(84)
        }

        alertItemView.addSubview(textInputField)
        alertItemView.addSubview(deleteButton)
        alertItemView.addSubview(saveButton)

        textInputField.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.height.equalTo(30)
        }

        deleteButton.snp.makeConstraints {
            $0.top.equalTo(textInputField.snp.bottom).offset(8)
            $0.bottom.equalToSuperview().offset(-8)
            $0.leading.equalTo(textInputField)
            $0.height.equalTo(30)
        }

        saveButton.snp.makeConstraints {
            $0.top.bottom.width.height.equalTo(deleteButton)
            $0.leading.equalTo(deleteButton.snp.trailing).offset(10)
            $0.width.equalTo(deleteButton)
            $0.trailing.equalTo(textInputField)
        }
    }

    @objc func deleteAct() {
        DemoConfiguration.shared.customAppVersion = ""
        completion?()
        self.dismiss(animated: false, completion: nil)
    }

    @objc func saveAct() {
        DemoConfiguration.shared.customAppVersion = textInputField.text ?? ""
        completion?()
        self.dismiss(animated: false, completion: nil)
    }

}
