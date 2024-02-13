//
//  LoginTextField.swift
//  ShopLiveSwiftSample
//
//  Created by ShopLive on 2021/10/25.
//

import UIKit

enum LoginFieldType {
    case id
    case pwd
}
class LoginTextField: BaseTextField {

    var type: LoginFieldType
    init(type: LoginFieldType) {
        self.type = type
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "clearall"), for: .normal)
        button.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        return button
    }()

    override func configure() {
        super.configure()

        let customFont: UIFont? = UIFont(name: "NotoSansKR-Regular", size: 13)
        
        delegate = self
        borderStyle = .none
        layer.backgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1).cgColor
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.15
        textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        typingAttributes = [.foregroundColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1),
                            .font: customFont ?? .systemFont(ofSize: 13, weight: .regular),
                                    .kern: -0.13,
                                    .paragraphStyle: paragraphStyle
                                ]
        let placeholderFont: UIFont = customFont?.withSize(14) ?? .systemFont(ofSize: 14, weight: .regular)
        attributedPlaceholder = .init(string: type == .id ? "login.id.placeholder".localized() : "login.pwd.placeholder".localized(), attributes: [ .font: placeholderFont,
                                                                                                 .foregroundColor: UIColor(red: 0.686, green: 0.686, blue: 0.686, alpha: 1),
                                                                                                 .kern: -0.14,
                                                                                                 .paragraphStyle: paragraphStyle,
                                                                                                 .baselineOffset: 1.5
                                                                                             ])

        layer.cornerRadius = 4.0

        clearButtonMode = .never

        leftView = nil


        rightView = clearButton
        rightViewMode = .whileEditing
        textContentType = (type == .id) ? .emailAddress : .password
        isSecureTextEntry = (type == .id) ? false : true
    }

    // MARK: - Interaction

    @objc
    func didTapClearButton() {
        text?.removeAll()
        rightViewMode = .never
    }

    // MARK: - Rect padding

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rectFrom = super.rightViewRect(forBounds: bounds)
        let padding: CGRect = .init(x: rectFrom.origin.x - 16, y: rectFrom.origin.y + 1, width: 20, height: 20)

        return padding
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 8.0, left: 12.0, bottom: 8.0, right: 0.0))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 8.0, left: 12.0, bottom: 8.0, right: 38.0))
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 8.0, left: 12.0, bottom: 8.0, right: 38.0))
    }

}

extension LoginTextField: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        /// Focus mode
        if text?.isEmpty ?? true {
            rightViewMode = .never
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        /// Resign mode
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let newText = string.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let text = textField.text, let predictRange = Range(range, in: text) else { return true }

        let predictedText = text.replacingCharacters(in: predictRange, with: newText)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if predictedText.isEmpty {
            rightViewMode = .never
        } else {
            rightViewMode = .whileEditing
        }

        return true
    }
}

