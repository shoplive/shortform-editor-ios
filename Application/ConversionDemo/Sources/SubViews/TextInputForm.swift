//
//  TextInputForm.swift
//  ConversionTrackingDemo
//
//  Created by sangmin han on 4/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit


class TextInputForms : UIView {
    
    
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    lazy private var textField : UITextField = {
        let txtField = UITextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.backgroundColor = .clear
        txtField.textColor = .black
        txtField.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        txtField.delegate = self
        txtField.textAlignment = .right
        return txtField
    }()
    
    
    private var stack : UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private var underBorderLine : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    
    
    init(title : String, placeHolder : String) {
         super.init(frame: .zero)
        setLayout()
        self.setPlaceHolder(placeHolder: placeHolder)
        self.setTitle(title: title)
        
        addDoneButtonOnKeyboard()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setPlaceHolder(placeHolder : String) {
        let attrString = NSAttributedString(string: placeHolder,attributes: [.foregroundColor : UIColor.lightGray,
                                                                             .font : UIFont.systemFont(ofSize: 15, weight: .regular)])
        self.textField.attributedPlaceholder = attrString
    }
    
    func setTitle(title : String) {
        self.titleLabel.text = title
    }
    
    func setValue(value : String?) {
        self.textField.text = value
    }
    
    func getValue() -> String? {
        return self.textField.text
    }
    
    func setKeyBoardType(type : UIKeyboardType ) {
        self.textField.keyboardType = type
    }
    
    
    private func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        textField.inputAccessoryView = doneToolbar
    }
    
    @objc private func doneButtonAction(){
        textField.resignFirstResponder()
    }
    
    
}
extension TextInputForms : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.layoutIfNeeded()
    }
}
extension TextInputForms {
    private func setLayout() {
        self.addSubview(stack)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(textField)
        
        self.addSubview(underBorderLine)
        
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            
            underBorderLine.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            underBorderLine.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            underBorderLine.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            underBorderLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    
}
