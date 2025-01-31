//
//  User.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/31/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon

struct User : Codable {
    var userId : String
    var useName : String?
    var age : Int?
    var gender : Gender
    var userScore : Int?
    var custom : CodableDictionary?
}


enum Gender : String, Codable {
    case male = "m"
    case female = "f"
    case netural = "n"
    
    func toShopLiveCommonUserGender() -> ShopliveCommonUserGender {
        switch self {
        case .male: return .male
        case .female: return .female
        case .netural: return .netural
        }
    }
}

