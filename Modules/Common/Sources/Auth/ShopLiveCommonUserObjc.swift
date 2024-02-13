//
//  ShopLiveCommonUserObjc.swift
//  ShopLiveSDKCommon
//
//  Created by sangmin han on 1/10/24.
//

import Foundation

@objc public class ShopLiveCommonUserObjc : ShopLiveCommonUser {
    
    @objc public var _userId : String {
        set{
            super.userId = newValue
        }
        get {
            return super.userId
        }
    }
    
    @objc public var _name : String {
        set {
            super.name = newValue
        }
        get{
            return super.name ?? ""
        }
    }
    
    @objc public var _age : NSNumber {
        set {
            super.age = newValue.intValue
        }
        get{
            return NSNumber(value: super.age ?? 0)
        }
    }
    
    @objc public var _gender : String {
        set {
            self.parseStringToGenderType(text: newValue)
        }
        get {
            super.gender?.rawValue ?? ""
        }
    }
    
    @objc public var _userScore : NSNumber {
        set {
            super.userScore = newValue.intValue
        }
        get{
            return NSNumber(value: super.userScore ?? 0)
        }
    }
    
    @objc public var _custom : [String : Any]? {
        set {
            super.custom = newValue
        }
        get {
            return super.custom
        }
    }
    
    
    @objc public override init(userId : String, name : String?, age : NSNumber?, gender : String?, userScore : NSNumber?, custom : Dictionary<String,Any>?) {
        super.init(userId: userId, name: name, age: age, gender: gender, userScore: userScore, custom: custom)
    }
    
    
}
extension ShopLiveCommonUserObjc {
    private func parseStringToGenderType(text : String) {
        switch text {
        case "m":
            super.gender = .male
        case "f":
            super.gender = .female
        case "n":
            super.gender = .netural
        default:
            super.gender = .netural
        }
    }
}
