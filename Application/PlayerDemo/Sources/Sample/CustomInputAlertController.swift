//
//  CustomInputAlertController.swift
//  ShopLiveSDK
//
//  Created by Vincent on 2/14/23.
//

import Foundation
import UIKit

class CustomInputAlertController: CustomBaseAlertController {
    
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
    
    private var placeHolder: String = ""
    
    private var completion: (() -> Void)?
    
    init(completion: @escaping (() -> Void)) {
        super.init(nibName: nil, bundle: nil)
        self.completion = completion
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupAlert() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAlert()
    }
    
    override func setupViews() {
        super.setupViews()
        self.view.addSubview(alertItemView)
        alertItemView.addSubview(textInputField)
        alertItemView.addSubview(deleteButton)
        alertItemView.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            alertItemView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            alertItemView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            alertItemView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9),
            alertItemView.heightAnchor.constraint(greaterThanOrEqualToConstant: 84),
            
            textInputField.leadingAnchor.constraint(equalTo: alertItemView.leadingAnchor,constant: 15),
            textInputField.topAnchor.constraint(equalTo: alertItemView.topAnchor,constant: 15),
            textInputField.trailingAnchor.constraint(equalTo: alertItemView.trailingAnchor,constant: -15),
            textInputField.heightAnchor.constraint(equalToConstant: 30),
            
            deleteButton.topAnchor.constraint(equalTo: textInputField.bottomAnchor, constant: 8),
            deleteButton.bottomAnchor.constraint(equalTo: alertItemView.bottomAnchor,constant: -8),
            deleteButton.leadingAnchor.constraint(equalTo: textInputField.leadingAnchor),
            deleteButton.heightAnchor.constraint(equalToConstant: 30),
            
            saveButton.topAnchor.constraint(equalTo: deleteButton.topAnchor),
            saveButton.bottomAnchor.constraint(equalTo: deleteButton.bottomAnchor),
            saveButton.widthAnchor.constraint(equalTo: deleteButton.widthAnchor, multiplier: 1),
            saveButton.heightAnchor.constraint(equalTo: deleteButton.heightAnchor, multiplier: 1),
            saveButton.leadingAnchor.constraint(equalTo: deleteButton.trailingAnchor,constant: 10),
            saveButton.trailingAnchor.constraint(equalTo: textInputField.trailingAnchor)
        ])
        
        
//        alertItemView.snp.makeConstraints {
//            $0.center.equalToSuperview()
//            $0.width.equalToSuperview().multipliedBy(0.9)
//            $0.height.greaterThanOrEqualTo(84)
//        }
//        
//        textInputField.snp.makeConstraints {
//            $0.leading.top.equalToSuperview().offset(15)
//            $0.trailing.equalToSuperview().offset(-15)
//            $0.height.equalTo(30)
//        }
//        
//        deleteButton.snp.makeConstraints {
//            $0.top.equalTo(textInputField.snp.bottom).offset(8)
//            $0.bottom.equalToSuperview().offset(-8)
//            $0.leading.equalTo(textInputField)
//            $0.height.equalTo(30)
//        }
//        
//        saveButton.snp.makeConstraints {
//            $0.top.bottom.width.height.equalTo(deleteButton)
//            $0.leading.equalTo(deleteButton.snp.trailing).offset(10)
//            $0.width.equalTo(deleteButton)
//            $0.trailing.equalTo(textInputField)
//        }
    }
    
    @objc func deleteAct() {
        delete()
        completion?()
        self.dismiss(animated: false, completion: nil)
    }
    
    func delete() {
        
    }
    
    func save() {
        
    }
    
    @objc func saveAct() {
        save()
        completion?()
        self.dismiss(animated: false, completion: nil)
    }

}
