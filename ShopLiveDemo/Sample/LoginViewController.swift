//
//  LoginViewController.swift
//  ShopLiveSwiftSample
//
//  Created by ShopLive on 2022/03/23.
//

import UIKit

protocol LoginDelegate: AnyObject {
    func loginSuccess()
}

final class LoginViewController: UIViewController {

    weak var delegate: LoginDelegate?
    
    private let customFontRegular: UIFont? = UIFont(name: "NotoSansKR-Regular", size: 14)
    private let customFontMedium: UIFont? = UIFont(name: "NotoSansKR-Medium", size: 14)
    
    private lazy var userIdLabel: UILabel = {
        let userId = UILabel()
        userId.translatesAutoresizingMaskIntoConstraints = false
        userId.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        userId.font = customFontMedium?.withSize(16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        var paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = 0.79
        userId.attributedText = NSMutableAttributedString(string: "login.id.label".localized(),
                                                          attributes: [NSAttributedString.Key.kern: -0.28,
                                                                       NSAttributedString.Key.paragraphStyle: paragraphStyle])
        userId.numberOfLines = 0
        return userId
    }()

    private lazy var userIdField: UITextField = {
        let userId = LoginTextField(type: .id)
        userId.text = "shoplive"
        userId.isUserInteractionEnabled = false
        userId.translatesAutoresizingMaskIntoConstraints = false
        return userId
    }()

    private lazy var userPwdLabel: UILabel = {
        let userPwd = UILabel()
        userPwd.translatesAutoresizingMaskIntoConstraints = false
        userPwd.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        userPwd.font = customFontMedium?.withSize(16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.79
        userPwd.attributedText = NSMutableAttributedString(string: "login.pwd.label".localized(),
                                                        attributes: [NSAttributedString.Key.kern: -0.28,
                                                                     NSAttributedString.Key.paragraphStyle: paragraphStyle])
        userPwd.numberOfLines = 0
        return userPwd
    }()

    private lazy var userPwdField: LoginTextField = {
        let userPwd = LoginTextField(type: .pwd)
        userPwd.text = "shoplive"
        userPwd.isUserInteractionEnabled = false
        userPwd.translatesAutoresizingMaskIntoConstraints = false
        return userPwd
    }()
    
    private lazy var loginButton: UIButton = {
        let login = UIButton(type: .custom)
        login.translatesAutoresizingMaskIntoConstraints = false
        login.setBackgroundColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1), for: .normal)
        login.setBackgroundColor(UIColor(red: 0.886, green: 0.886, blue: 0.886, alpha: 1), for: .disabled)
        login.setTitle("login.send.title".localized(), for: .normal)
        login.titleLabel?.font = customFontMedium ?? UIFont.systemFont(ofSize: 14, weight: .medium)
        login.setTitleColor(.white, for: .normal)
        login.setTitleColor(.init(red: 0.796, green: 0.796, blue: 0.796, alpha: 1.0), for: .disabled)
        login.layer.cornerRadius = 4
        login.layer.masksToBounds = true
        login.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        return login
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        hideKeyboard()
    }
    
    private func setupViews() {
        self.view.backgroundColor = .white
        self.view.addSubviews(userIdLabel, userIdField, userPwdLabel, userPwdField, loginButton)
        
        userIdLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.lessThanOrEqualToSuperview().offset(-40)
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(90)
        }

        userIdField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-40)
            $0.top.equalTo(userIdLabel.snp.bottom).offset(6)
            $0.height.equalTo(46)

        }

        userPwdLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.lessThanOrEqualToSuperview().offset(-40)
            $0.top.equalTo(userIdField.snp.bottom).offset(24)
        }

        userPwdField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-40)
            $0.top.equalTo(userPwdLabel.snp.bottom).offset(6)
            $0.height.equalTo(46)
        }

        loginButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(userPwdField)
            $0.top.equalTo(userPwdField.snp.bottom).offset(40)
            $0.height.equalTo(46)
        }
    }
    
    @objc func loginAction() {
        delegate?.loginSuccess()
        self.navigationController?.popViewController(animated: true)
    }

}
