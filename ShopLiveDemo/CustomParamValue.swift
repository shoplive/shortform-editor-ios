//
//  CustomParamValue.swift
//  ShopLiveSDK
//
//  Created by 김우현 on 4/10/23.
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
