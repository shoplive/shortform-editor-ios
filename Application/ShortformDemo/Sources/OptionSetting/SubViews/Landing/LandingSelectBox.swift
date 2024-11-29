//
//  LandingBox.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/07/28.
//

import Foundation
import UIKit


class LandingSelectBox : UIView {
    
    
    private var musinsaDevBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("무신사Dev", for: .normal)
        btn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
        btn.layer.borderWidth = 1
        btn.tag = -1
        return btn
    }()
    
    private var musinsadevLabel : UILabel = {
        let label = UILabel()
        label.text = "q3hZYwpJ1xukW8bTDsxj"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private var devBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("DEV", for: .normal)
        btn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
        btn.layer.borderWidth = 1
        btn.tag = 0
        return btn
    }()
    
    private var devLabel : UILabel = {
        let label = UILabel()
        label.text = "a1AW6QRCXeoZ9MEWRdDQ" //"" //"LvBx8jFdwpsNSM5Wg8Us" //"q3hZYwpJ1xukW8bTDsxj"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private var stageBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("STAGE", for: .normal)
        btn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
        btn.layer.borderWidth = 1
        btn.tag = 1
        return btn
    }()
    
    private var stageLabel : UILabel = {
        let label = UILabel()
        label.text = "53Q8PFmSRe7xyRNy5wUS"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private var qaBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("QA", for: .normal)
        btn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
        btn.layer.borderWidth = 1
        btn.tag = 2
        btn.isSelected = true
        return btn
    }()
    
    private var qaLabel : UILabel = {
        let label = UILabel()
        label.text = "e4cscSXMMHtEQnMiZI5E"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private var realBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("REAL", for: .normal)
        btn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
        btn.layer.borderWidth = 1
        btn.tag = 3
        return btn
    }()
    
    private var realLabel : UILabel = {
        let label = UILabel()
        label.text = "FRBrbbIsNLGNcRWvGGTb"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private var qa11stnBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("11번가QA", for: .normal)
        btn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
        btn.layer.borderWidth = 1
        btn.tag = 4
        return btn
    }()
    
    private var qa11stLabel : UILabel = {
        let label = UILabel()
        label.text = "RwZi6T7V8NiUScKvlh4W"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        return label
    }()

    
    private var qa11stDevBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("11번가DEV", for: .normal)
        btn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
        btn.layer.borderWidth = 1
        btn.tag = 5
        return btn
    }()
    
    private var qa11stDevLabel : UILabel = {
        let label = UILabel()
        label.text = "cbGFbQ8JoIupsWrOKdcu"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private var customBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("CUSTOM", for: .normal)
        btn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
        btn.layer.borderWidth = 1
        btn.tag = 6
        return btn
    }()
    
    private var customTextField : UITextField = {
        let label = UITextField()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        let attr = NSAttributedString(string: "set custom accessKey",attributes: [.foregroundColor : UIColor.darkGray,
                                                                                  .font : UIFont.systemFont(ofSize: 15, weight: .regular)])
        label.attributedPlaceholder = attr
        label.layer.borderColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 10
        label.leftView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 10, height: 10)))
        label.leftViewMode = .always
        label.text = Defaults.customAccessKey
//        label.text = "3cULfZQVMUTUKJ3dDwnA"
        return label
    }()
    
    
    private let normalBtnbackgroundColor : UIColor = .white
    private let selectedBtnbackgroundColor : UIColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
    
    private var selectedAccessKey : String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setLayout()
        
        
        musinsaDevBtn.addTarget(self, action: #selector(btnTapped(sender: )), for: .touchUpInside)
        devBtn.addTarget(self, action: #selector(btnTapped(sender: )), for: .touchUpInside)
        stageBtn.addTarget(self, action: #selector(btnTapped(sender: )), for: .touchUpInside)
        qaBtn.addTarget(self, action: #selector(btnTapped(sender: )), for: .touchUpInside)
        realBtn.addTarget(self, action: #selector(btnTapped(sender: )), for: .touchUpInside)
        customBtn.addTarget(self, action: #selector(btnTapped(sender: )), for: .touchUpInside)
        qa11stnBtn.addTarget(self, action: #selector(btnTapped(sender: )), for: .touchUpInside)
        qa11stDevBtn.addTarget(self, action: #selector(btnTapped(sender: )), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    @objc func btnTapped(sender : UIButton){
        musinsaDevBtn.isSelected = sender.tag == -1
        devBtn.isSelected = sender.tag == 0
        stageBtn.isSelected = sender.tag == 1
        qaBtn.isSelected = sender.tag == 2
        realBtn.isSelected = sender.tag == 3
        qa11stnBtn.isSelected = sender.tag == 4
        qa11stDevBtn.isSelected = sender.tag == 5
        customBtn.isSelected = sender.tag == 6
        
        musinsaDevBtn.backgroundColor = sender.tag == -1 ? selectedBtnbackgroundColor : normalBtnbackgroundColor
        devBtn.backgroundColor = sender.tag == 0 ? selectedBtnbackgroundColor : normalBtnbackgroundColor
        stageBtn.backgroundColor = sender.tag == 1 ? selectedBtnbackgroundColor : normalBtnbackgroundColor
        qaBtn.backgroundColor = sender.tag == 2 ? selectedBtnbackgroundColor : normalBtnbackgroundColor
        realBtn.backgroundColor = sender.tag == 3 ? selectedBtnbackgroundColor : normalBtnbackgroundColor
        qa11stnBtn.backgroundColor = sender.tag == 4 ? selectedBtnbackgroundColor : normalBtnbackgroundColor
        qa11stDevBtn.backgroundColor = sender.tag == 5 ? selectedBtnbackgroundColor : normalBtnbackgroundColor
        customBtn.backgroundColor = sender.tag == 6 ? selectedBtnbackgroundColor : normalBtnbackgroundColor
        
        switch sender.tag {
        case -1:
            self.selectedAccessKey = musinsadevLabel.text ?? ""
        case 0:
            self.selectedAccessKey = devLabel.text ?? ""
        case 1:
            self.selectedAccessKey = stageLabel.text ?? ""
        case 2:
            self.selectedAccessKey = qaLabel.text ?? ""
        case 3:
            self.selectedAccessKey = realLabel.text ?? ""
        case 4:
            self.selectedAccessKey = qa11stLabel.text ?? ""
        case 5:
            self.selectedAccessKey = qa11stDevLabel.text ?? ""
        case 5:
            self.selectedAccessKey = customTextField.text ?? ""
        default:
            break
        }
    }
    
    
    func getValue() -> String? {
        if devBtn.isSelected == true {
            return  devLabel.text ?? ""
        }
        else if stageBtn.isSelected == true {
            return  stageLabel.text ?? ""
        }
        else if qaBtn.isSelected == true {
            return  qaLabel.text ?? ""
        }
        else if realBtn.isSelected == true {
            return realLabel.text ?? ""
        }
        else if qa11stnBtn.isSelected == true {
            return qa11stLabel.text ?? ""
        }
        else if qa11stDevBtn.isSelected == true {
            return qa11stDevLabel.text ?? ""
        }
        else if customBtn.isSelected == true {
            let result = customTextField.text ?? ""
            Defaults.customAccessKey = result
            return result
        }
        else if musinsaDevBtn.isSelected == true {
            return musinsadevLabel.text ?? ""
        }
        return self.selectedAccessKey
    }
    
}
extension LandingSelectBox {
    private func setLayout(){
        
        let musinsadevStack = UIStackView(arrangedSubviews: [musinsaDevBtn,musinsadevLabel])
        musinsadevStack.translatesAutoresizingMaskIntoConstraints = false
        musinsadevStack.axis = .horizontal
        musinsadevStack.spacing = 10
        
        
        let devStack = UIStackView(arrangedSubviews: [devBtn,devLabel])
        devStack.translatesAutoresizingMaskIntoConstraints = false
        devStack.axis = .horizontal
        devStack.spacing = 10
        
        let stageStack = UIStackView(arrangedSubviews: [stageBtn,stageLabel])
        stageStack.translatesAutoresizingMaskIntoConstraints = false
        stageStack.axis = .horizontal
        stageStack.spacing = 10
        
        let qaStack = UIStackView(arrangedSubviews: [qaBtn,qaLabel])
        qaStack.translatesAutoresizingMaskIntoConstraints = false
        qaStack.axis = .horizontal
        qaStack.spacing = 10
        
        
        let realStack = UIStackView(arrangedSubviews: [realBtn,realLabel])
        realStack.translatesAutoresizingMaskIntoConstraints = false
        realStack.axis = .horizontal
        realStack.spacing = 10
        
        let qa11Stack = UIStackView(arrangedSubviews: [qa11stnBtn,qa11stLabel])
        qa11Stack.translatesAutoresizingMaskIntoConstraints = false
        qa11Stack.axis = .horizontal
        qa11Stack.spacing = 10
        
        let qa11stDevStack = UIStackView(arrangedSubviews: [qa11stDevBtn,qa11stDevLabel])
        qa11stDevStack.translatesAutoresizingMaskIntoConstraints = false
        qa11stDevStack.axis = .horizontal
        qa11stDevStack.spacing = 10
        
        let customStack = UIStackView(arrangedSubviews: [customBtn,customTextField])
        customStack.translatesAutoresizingMaskIntoConstraints = false
        customStack.axis = .horizontal
        customStack.spacing = 10
        
        
        let wholeStack = UIStackView(arrangedSubviews: [musinsadevStack,devStack,stageStack,qaStack,realStack,qa11Stack,qa11stDevStack,customStack])
        wholeStack.translatesAutoresizingMaskIntoConstraints = false
        wholeStack.axis = .vertical
        wholeStack.spacing = 10
        wholeStack.isLayoutMarginsRelativeArrangement = true
        wholeStack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        self.addSubviews_SL(wholeStack)
        
        NSLayoutConstraint.activate([
            musinsaDevBtn.widthAnchor.constraint(equalToConstant: 120),
            devBtn.widthAnchor.constraint(equalToConstant: 120),
            stageBtn.widthAnchor.constraint(equalToConstant: 120),
            qaBtn.widthAnchor.constraint(equalToConstant: 120),
            realBtn.widthAnchor.constraint(equalToConstant: 120),
            qa11stnBtn.widthAnchor.constraint(equalToConstant: 120),
            qa11stDevBtn.widthAnchor.constraint(equalToConstant: 120),
            customBtn.widthAnchor.constraint(equalToConstant: 120),

            musinsadevStack.heightAnchor.constraint(equalToConstant: 30),
            devStack.heightAnchor.constraint(equalToConstant: 30),
            stageStack.heightAnchor.constraint(equalToConstant: 30),
            qaStack.heightAnchor.constraint(equalToConstant: 30),
            realStack.heightAnchor.constraint(equalToConstant: 30),
            qa11Stack.heightAnchor.constraint(equalToConstant: 30),
            qa11stDevStack.heightAnchor.constraint(equalToConstant: 30),
            customStack.heightAnchor.constraint(equalToConstant: 30),
            
            wholeStack.topAnchor.constraint(equalTo: self.topAnchor),
            wholeStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            wholeStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            wholeStack.heightAnchor.constraint(lessThanOrEqualToConstant: 500),
            
            self.bottomAnchor.constraint(equalTo: wholeStack.bottomAnchor)
        ])
    }
}
