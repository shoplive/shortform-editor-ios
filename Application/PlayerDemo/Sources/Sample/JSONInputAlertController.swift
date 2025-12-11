//
//  JSONInputAlertController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2024/12/05.
//

import UIKit

class JSONInputAlertController: CustomBaseAlertController {

    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        view.font = .systemFont(ofSize: 16, weight: .heavy)
        return view
    }()

    lazy var textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.font = .systemFont(ofSize: 14)
        view.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        view.isScrollEnabled = true
        return view
    }()
    
    lazy var placeholderLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.textColor = .darkGray
        view.font = .systemFont(ofSize: 14)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var errorLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.textColor = .red
        view.font = .systemFont(ofSize: 12)
        view.isHidden = true
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
    private var validate: ((String) -> (isValid: Bool, errorMessage: String?))?
    private var headerTitle: String = ""
    private var placeHolder: String = ""
    private var data: String?

    init(header: String, 
         data: String?, 
         placeHolder: String, 
         validate: ((String) -> (isValid: Bool, errorMessage: String?))? = nil,
         saveClosure: @escaping ((String) -> Void)) {
        super.init(nibName: nil, bundle: nil)
        self.headerTitle = header
        self.placeHolder = placeHolder
        self.save = saveClosure
        self.validate = validate
        self.data = data
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        placeholderLabel.text = self.placeHolder
        textView.text = self.data ?? ""
        titleLabel.text = self.headerTitle
        
        textView.delegate = self
        updatePlaceholderVisibility()
        
        // 키보드 알림 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func setupViews() {
        super.setupViews()
        self.view.addSubview(alertItemView)
        alertItemView.addSubview(titleLabel)
        alertItemView.addSubview(textView)
        alertItemView.addSubview(placeholderLabel)
        alertItemView.addSubview(errorLabel)
        alertItemView.addSubview(cancelButton)
        alertItemView.addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            alertItemView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            alertItemView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            alertItemView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9),
            alertItemView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300),
            
            titleLabel.topAnchor.constraint(equalTo: alertItemView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: alertItemView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: alertItemView.trailingAnchor, constant: -15),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            textView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 150),
            
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 16),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 13),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -13),
            
            errorLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 5),
            errorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            confirmButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 15),
            confirmButton.trailingAnchor.constraint(equalTo: alertItemView.trailingAnchor, constant: -15),
            confirmButton.bottomAnchor.constraint(equalTo: alertItemView.bottomAnchor, constant: -15),
            confirmButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 20),
            confirmButton.heightAnchor.constraint(equalToConstant: 30),
            
            cancelButton.topAnchor.constraint(equalTo: confirmButton.topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: confirmButton.bottomAnchor),
            cancelButton.widthAnchor.constraint(equalTo: confirmButton.widthAnchor, multiplier: 1),
            cancelButton.heightAnchor.constraint(equalTo: confirmButton.heightAnchor, multiplier: 1),
            cancelButton.trailingAnchor.constraint(equalTo: confirmButton.leadingAnchor, constant: -15)
        ])
    }
    
    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) {
            self.alertItemView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight / 3)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.alertItemView.transform = .identity
        }
    }

    @objc func cancelAct() {
        textView.resignFirstResponder()
        self.dismiss(animated: false, completion: nil)
    }

    @objc func confirmAct() {
        let text = textView.text ?? ""
        
        // 유효성 검사
        if let validate = validate {
            let result = validate(text)
            if !result.isValid {
                errorLabel.text = result.errorMessage ?? "유효하지 않은 입력입니다."
                errorLabel.isHidden = false
                return
            }
        }
        
        errorLabel.isHidden = true
        save?(text)
        textView.resignFirstResponder()
        self.dismiss(animated: false, completion: nil)
    }
}

extension JSONInputAlertController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
        errorLabel.isHidden = true
    }
}

