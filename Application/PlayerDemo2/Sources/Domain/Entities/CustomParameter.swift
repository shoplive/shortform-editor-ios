//
//  CustomParam.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

struct CustomParameter: Codable {
    let customParameterId : Int
    var paramKey: String
    var paramValue: String?
    var isUseParam: Bool
    
    init(customParameterId : Int, paramKey: String, paramValue: String? = nil, isUseParam: Bool = false) {
        self.customParameterId = customParameterId
        self.paramKey = paramKey
        self.paramValue = paramValue
        self.isUseParam = isUseParam
    }
}
