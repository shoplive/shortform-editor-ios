//
//  UserInfoViewModel.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/21/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopLiveSDK
import ShopliveSDKCommon

class UserInfoViewModel {
    
    private(set) var parameterList: [String: String] = [:]
    private(set) var keysArray: [Dictionary<String, String>.Keys.Element] = []
    private(set) var valueArray: [Dictionary<String, String>.Values.Element] = []
    private(set) var user: ShopLiveCommonUser = ShopLiveCommonUser(userId: "")
//    DemoConfiguration.shared.user
    private(set) var newUser: ShopLiveCommonUser?
    private(set) var radioGroup: [ShopLiveRadioButton] = []
    
    var userInfoUseCase: UserInfoUseCase
    
    init(userInfoUseCase: UserInfoUseCase) {
        self.userInfoUseCase = userInfoUseCase
    }
    
    var secretKeyButtonTitle: String {
        guard let key = DemoSecretKeyTool.shared.currentKey()?.key, !key.isEmpty else {
            return "userinfo.button.chooseSecret.input.title".localized()
        }

        return "userinfo.button.chooseSecret.change.title".localized()
    }
    
    
    func setRadioGroup(_ data: [ShopLiveRadioButton]) {
        radioGroup = data
    }
    
    func setupParameterList() {
//        guard let param = DemoConfiguration.shared.userParameters else {
//            return
//        }
//        param.forEach { (key: String, value: Any?) in
//            parameterList[key] = "\(value ?? "null")"
//        }
//        keysArray = Array(parameterList.keys)
//        valueArray = Array(parameterList.values)
    }
    
    func setUser(userId: String, userName: String, gender: ShopliveCommonUserGender, age: String?, userScore: String) {
        user.userId = userId
        user.userName = userName
        user.gender = gender
        if let ageText = age, !ageText.isEmpty, let age = Int(ageText), age >= 0 {
            user.age = age
        } else {
            user.age = nil
        }
        user.userScore = Int(userScore) ?? 0
    }
    
    func setUserModel(_ user: ShopLiveCommonUser) {
        self.user = user
    }
    
    func saveParameterList() {
        
        for index in 0..<keysArray.count {
            parameterList.updateValue(valueArray[index], forKey: keysArray[index])
        }
        for (key, value) in parameterList {
            user.custom?.updateValue(key, forKey: value)
        }
//        DemoConfiguration.shared.userParameters = self.parameterList
    }
    
    func isEqualUser(user: ShopLiveCommonUser) -> Bool {
        if newUser == nil {
            return false
        }

        if let curUser = newUser,
            curUser.userId == user.userId &&
            curUser.userName == user.userName &&
            curUser.age == user.age &&
            curUser.userScore == user.userScore &&
            curUser.gender == user.gender {
            return true
        }

        return false
    }
    
    func deleteDatas(_ indexPath: Int) {
        
        let key = keysArray[indexPath]
        
        parameterList.removeValue(forKey: key)
        keysArray.remove(at: indexPath)
        valueArray.remove(at: indexPath)
    }
    
    func appendData() {
        keysArray.append("")
        valueArray.append("")
    }
    
    func appendKey(text: String) {
        keysArray[keysArray.firstIndex(of: "") ?? keysArray.endIndex - 1] = text
    }
    
    func appendValue(text: String) {
        valueArray[valueArray.firstIndex(of: "") ?? valueArray.endIndex - 1] = text
    }
}
