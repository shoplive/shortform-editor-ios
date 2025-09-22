//
//  ShopLiveCommonUser.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2023/05/23.
//

import Foundation

public class ShopLiveCommonUser: NSObject  {
    public var userId: String
    public var userName: String?
    public var age: Int?
    public var gender: ShopliveCommonUserGender?
    public var userScore: Int?
    public var custom: [String: Any]?
    
    
    
    
    
    public func toDictionary() -> [String: Any]{
        var dict: [String: Any] = [:]
        
        dict["userId"] = userId
        
        if let name = userName {
            dict["userName"] = name
        }
        if let age = age {
            dict["age"] = age
        }
        if let gender = gender {
            dict["gender"] = gender.rawValue
        }
        if let userScore = userScore {
            dict["userScore"] = userScore
        }
        if let custom = custom {
            for (key,value) in custom {
                dict[key] = value
            }
        }
        return dict
    }
    
    public init(userId: String, userName: String? = nil, age: Int? = nil, gender: ShopliveCommonUserGender? = nil, userScore: Int? = nil, custom: [String: Any]? = nil) {
        self.userId = userId
        self.userName = userName
        self.age = age
        self.gender = gender
        self.userScore = userScore
        self.custom = custom
    }
    
    public init(userId: String, userName: String?, age: NSNumber?, gender: String?, userScore: NSNumber?, custom: Dictionary<String,Any>? ) {
        self.userId = userId
        self.userName = userName
        self.age = age?.intValue
        if let gender = gender {
            switch gender {
            case "m":
                self.gender = .male
            case "f":
                self.gender = .female
            case "n":
                self.gender = .netural
            default:
                break
            }
        }
        self.userScore = userScore?.intValue
        self.custom = custom
    }
}

public enum ShopliveCommonUserGender: String, CaseIterable {
    case male = "m"
    case female = "f"
    case netural = "n"
}

