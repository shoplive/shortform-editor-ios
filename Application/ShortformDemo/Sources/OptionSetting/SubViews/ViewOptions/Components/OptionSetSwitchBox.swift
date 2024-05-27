//
//  OptionSetSwitchBox.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/07/28.
//

import Foundation
import UIKit


protocol OptionSetSwitchBoxDelegate {
    func optionChange(type : OptionSetSwitchBox.OptionType, value : Bool)
}

class OptionSetSwitchBox : UIView {
    
    enum OptionType {
        case shuffle
        case viewCount
        case title
        case description
        case productCount
        case brand
        case snap
        case playOnlyOnWifi
        
        //DetailWebViewOptions -> used in DetailWebviewOptionBox.swift
        case detailWebViewBookMark
        case detailWebViewShareBtn
        case detailWebViewCommentBtn
        case detailWebViewLikeBtn
        
        //editorOptions -> used in EditorViewOptionBox
        case editorDescription
        case editorTag
        case editorIsFixedCrop
        
        case isEnabledVolumeKey
        case previewIsMuted
    }
    
    private var label : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private var switchBtn : UISwitch = {
        let switchBtn = UISwitch()
        switchBtn.onTintColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        switchBtn.tintColor = .white
        switchBtn.thumbTintColor = .white
        return switchBtn
    }()
    
    private var type : OptionType = .shuffle
    var delegate : OptionSetSwitchBoxDelegate?
    

    init(title : String,type : OptionType){
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.type = type
        self.label.text = title
        self.setLayout()
        switchBtn.addTarget(self, action: #selector(switchBtnTapped(sender: )), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setSwitchIsOn(isOn : Bool){
        self.switchBtn.isOn = isOn
    }
    
    @objc func switchBtnTapped(sender : UISwitch) {
        self.delegate?.optionChange(type: self.type, value: sender.isOn)
    }
    
}
extension OptionSetSwitchBox {
    private func setLayout(){
        let stack = UIStackView(arrangedSubviews: [label,switchBtn])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        self.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.heightAnchor.constraint(equalToConstant: 40),
            
            self.bottomAnchor.constraint(equalTo: stack.bottomAnchor)
        ])
    }
}
