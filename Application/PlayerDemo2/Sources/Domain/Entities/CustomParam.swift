//
//  CustomParam.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

class CustomParam: Codable {
    var paramKey: String
    var paramValue: String?
    var isUseParam: Bool
    
    init(paramKey: String, paramValue: String? = nil, isUseParam: Bool = false) {
        self.paramKey = paramKey
        self.paramValue = paramValue
        self.isUseParam = isUseParam
    }
}
