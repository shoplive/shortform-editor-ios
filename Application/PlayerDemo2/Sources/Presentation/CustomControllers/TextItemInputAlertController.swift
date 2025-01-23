//
//  TextItemInputAlertController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

class TextItemInputAlertController: CustomBaseAlertController {

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        view.font = .systemFont(ofSize: 16, weight: .heavy)
        return view
    }()

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

    lazy var cancelButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("alert.msg.cancel".localized(), for: .normal)
        view.backgroundColor = .white
        view.setTitleColor(.black, for: .normal)
        view.addTarget(self, action: #selector(cancelAct), for: .touchUpInside)
        return view
    }()

    lazy var confirmButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("alert.msg.confirm".localized(), for: .normal)
        view.backgroundColor = .white
        view.setTitleColor(.black, for: .normal)
        view.addTarget(self, action: #selector(confirmAct), for: .touchUpInside)
        return view
    }()

    private var save: ((String) -> Void)?
    private var headerTitle: String = ""
    private var placeHolder: String = ""
    private var data: String?

    init(header: String, data: String?, placeHolder: String, saveClosure: @escaping ((String) -> Void)) {
        super.init(nibName: nil, bundle: nil)
        self.headerTitle = header
        self.placeHolder = placeHolder
        self.save = saveClosure
        self.data = data
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        textInputField.placeholder = self.placeHolder
        textInputField.text = self.data ?? ""
        titleLabel.text = self.headerTitle
        textInputField.setPlaceholderColor(.darkGray)

    }

    override func setupViews() {
        super.setupViews()
        self.view.addSubview(alertItemView)
        alertItemView.addSubview(titleLabel)
        alertItemView.addSubview(textInputField)
        alertItemView.addSubview(cancelButton)
        alertItemView.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            alertItemView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            alertItemView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            alertItemView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9),
            alertItemView.heightAnchor.constraint(greaterThanOrEqualToConstant: 160),
            
            titleLabel.topAnchor.constraint(equalTo: alertItemView.topAnchor,constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: alertItemView.leadingAnchor,constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: alertItemView.trailingAnchor,constant: -15),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            textInputField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            textInputField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            textInputField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            textInputField.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            
            confirmButton.topAnchor.constraint(equalTo: textInputField.bottomAnchor,constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: alertItemView.trailingAnchor,constant: -15),
            confirmButton.bottomAnchor.constraint(equalTo: alertItemView.bottomAnchor,constant: -15),
            confirmButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),
            confirmButton.heightAnchor.constraint(equalToConstant: 30),
            
            cancelButton.topAnchor.constraint(equalTo: confirmButton.topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: confirmButton.bottomAnchor),
            cancelButton.widthAnchor.constraint(equalTo: confirmButton.widthAnchor, multiplier: 1),
            cancelButton.heightAnchor.constraint(equalTo: confirmButton.heightAnchor, multiplier: 1),
            cancelButton.trailingAnchor.constraint(equalTo: confirmButton.leadingAnchor,constant: -15)
        ])
        
        
        
//        alertItemView.snp.makeConstraints {
//            $0.center.equalToSuperview()
//            $0.width.equalToSuperview().multipliedBy(0.9)
//            $0.height.greaterThanOrEqualTo(160)
//        }
//
//
//        titleLabel.snp.makeConstraints {
//            $0.leading.top.equalToSuperview().offset(15)
//            $0.trailing.equalToSuperview().offset(-15)
//            $0.height.equalTo(30)
//        }
//
//        textInputField.snp.makeConstraints {
//            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
//            $0.leading.trailing.equalTo(titleLabel)
//            $0.height.greaterThanOrEqualTo(30)
//        }
//
//        confirmButton.snp.makeConstraints {
//            $0.top.equalTo(textInputField.snp.bottom).offset(20)
//            $0.bottom.trailing.equalToSuperview().offset(-15)
//            $0.width.greaterThanOrEqualTo(20)
//            $0.height.equalTo(30)
//        }
//
//        cancelButton.snp.makeConstraints {
//            $0.top.bottom.width.height.equalTo(confirmButton)
//            $0.trailing.equalTo(confirmButton.snp.leading).offset(-15)
//
//        }
    }

    @objc func cancelAct() {
        self.dismiss(animated: false, completion: nil)
    }

    @objc func confirmAct() {
        save?(textInputField.text ?? "")
        self.dismiss(animated: false, completion: nil)
    }

}

