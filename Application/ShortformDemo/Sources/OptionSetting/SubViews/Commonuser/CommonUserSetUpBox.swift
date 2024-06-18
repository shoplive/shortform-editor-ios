//
//  CommonUserSetUpBox.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/07/28.
//

import Foundation
import UIKit
import ShopliveSDKCommon



class CommonUserSetUpBox : UIView {
    
    
    private var userIdBox = CommonUserInputBox(title: "userId :", placeHolder: "userId")
    private var nameBox = CommonUserInputBox(title: "name :", placeHolder: "name")
    private var ageBox = CommonUserInputBox(title: "age :", placeHolder: "99",keyboardType: .decimalPad)
    private var genderBox = CommonUserInputBox(title: "gender :", placeHolder: "male : m, female : f,netural : n")
    private var userScoreBox = CommonUserInputBox(title: "userScore :", placeHolder: "userScore",keyboardType: .decimalPad)
    
    
    private var jwtBox = CommonUserInputBox(title: "jwt :", placeHolder: "set jwt token")
    
    private var userJWTLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "userJWT :"
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private var userJWTValuelabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byCharWrapping
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private var setBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("SET USER", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    
    
    override init(frame : CGRect){
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setLayout()
        setInitialValue()
        setJWT()
        
        setBtn.addTarget(self, action: #selector(setBtnTapped(_: )), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setInitialValue() {
        userIdBox.setInitialValue(value: Defaults.userId)
        nameBox.setInitialValue(value: Defaults.userName)
        ageBox.setInitialValue(value: String(Defaults.userAge))
        genderBox.setInitialValue(value: Defaults.userGender)
        userScoreBox.setInitialValue(value: String(Defaults.userScore))
        jwtBox.setInitialValue(value: Defaults.jwt)
    }
    
    private func setJWT(){
        if let jwt = ShopLiveCommon.getAuthToken() {
            userJWTLabel.isHidden = false
            userJWTValuelabel.isHidden = false
            userJWTValuelabel.text = jwt
        }
        else {
            userJWTLabel.isHidden = true
            userJWTValuelabel.isHidden = true
        }
    }
    
    @objc func setBtnTapped(_ : UIButton){
        guard let accessKey = ShopLiveCommon.getAccessKey() else {
            userJWTValuelabel.text = "랜딩을 선택하여 accessKey를 설정해 주세요"
            userJWTValuelabel.isHidden = false
            return
        }
        if userIdBox.getValue() == "" {
            userJWTValuelabel.text = "userId는 필수 입력 사항입니다."
            userJWTValuelabel.isHidden = false
            return
        }
        if ["m","n","f"].contains(where: { $0 == genderBox.getValue().lowercased() }) == false {
            userJWTValuelabel.text = "성별은 m,n,f 3 중 하나를 선택해주세요"
            userJWTValuelabel.isHidden = false
            return 
        }
        
        var gender : ShopliveCommonUserGender = .female
        switch genderBox.getValue().lowercased() {
        case "m":
            gender = .male
        case "f":
            gender = .female
        case "n":
            gender = .netural
        default:
            return
        }
        
        ShopLiveCommon.setAccessKey(accessKey: accessKey)
        let user = ShopLiveCommonUser(userId: userIdBox.getValue(),
                                      userName: nameBox.getValue(),
                                      age: Int(ageBox.getValue()),
                                      gender: gender,
                                      userScore: Int(userScoreBox.getValue()))
        
        ShopLiveCommon.setUser(user: user,
                               accessKey: accessKey)
        
        Defaults.userId = userIdBox.getValue()
        Defaults.userName = nameBox.getValue()
        Defaults.userAge = Int(ageBox.getValue()) ?? 10
        Defaults.userGender = gender.rawValue
        Defaults.userScore = Int(userScoreBox.getValue()) ?? 0
        setJWT()
    }
    
}
extension CommonUserSetUpBox {
    private func setLayout(){
        let stack = UIStackView(arrangedSubviews: [userIdBox, nameBox, ageBox, genderBox, userScoreBox,userJWTLabel, userJWTValuelabel, setBtn])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.setCustomSpacing(3, after: userJWTLabel)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        self.addSubview(stack)
        
        NSLayoutConstraint.activate([
            setBtn.heightAnchor.constraint(equalToConstant: 40),
            
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.heightAnchor.constraint(lessThanOrEqualToConstant: 500),
            
            self.bottomAnchor.constraint(equalTo: stack.bottomAnchor)
        ])
        
    }
    
    
}
