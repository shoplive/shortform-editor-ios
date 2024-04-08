//
//  CommonUserInputBox.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/07/28.
//

import Foundation
import UIKit


class CommonUserInputBox : UIView {
    
    private var label : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private var textField : UITextField = {
        let label = UITextField()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        
        label.layer.borderColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 10
        label.leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
        label.leftViewMode = .always
        return label
    }()
    
    
    init(title : String, placeHolder : String, keyboardType : UIKeyboardType? = nil){
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        let attr = NSAttributedString(string: placeHolder ,attributes: [.foregroundColor : UIColor.darkGray,
                                                                                  .font : UIFont.systemFont(ofSize: 15, weight: .regular)])
        textField.attributedPlaceholder = attr
        if let type = keyboardType {
            textField.keyboardType = type
        }
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getValue() -> String {
        return textField.text ?? ""
    }
    
    
    func setInitialValue(value : String?) {
        textField.text = value
    }
    
}
extension CommonUserInputBox {
    private func setLayout(){
        let stack = UIStackView(arrangedSubviews: [label,textField])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        self.addSubview(stack)
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 120),
            
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.heightAnchor.constraint(equalToConstant: 30),
            
            self.bottomAnchor.constraint(equalTo: stack.bottomAnchor)
        ])
    }
}
