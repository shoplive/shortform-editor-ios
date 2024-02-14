//
//  ListOptionTextViewInputBox.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/07/28.
//

import Foundation
import UIKit


class OptionTextViewInputBox : UIView {
    
    private var label : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    lazy private var textView : UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .black
        textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.isScrollEnabled = false
        textView.layer.borderColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
        textView.layer.borderWidth = 1
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 10
        textView.delegate = self
        return textView
    }()
    
    
    var textViewValueTracker : ((String) -> ())?
    init(title : String){
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.label.text = title
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValue(value : String){
        self.textView.text = value
    }
    
    func setKeyboardType(type : UIKeyboardType){
        self.textView.keyboardType = type
    }
    
    
}
extension OptionTextViewInputBox : UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewValueTracker?(textView.text)
    }
}
extension OptionTextViewInputBox {
    private func setLayout(){
        let stack = UIStackView(arrangedSubviews: [label,textView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 5
        self.addSubview(stack)
        
        NSLayoutConstraint.activate([
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            textView.heightAnchor.constraint(lessThanOrEqualToConstant: 500),
            
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.heightAnchor.constraint(lessThanOrEqualToConstant: 500),
            
            self.bottomAnchor.constraint(equalTo: stack.bottomAnchor)
        ])
    }
    
    
}
