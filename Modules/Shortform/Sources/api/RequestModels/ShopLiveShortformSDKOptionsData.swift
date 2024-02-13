//
//  ShopLiveShortformSDKOptionsData.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/08/03.
//

import Foundation



/**
 event tracer로 넘겨주기위한 객체
 */
struct ShopLiveShortformSDKOptionsData {
    var isSnapEnabled : Bool = false
    var isPlayOnlyOnWifi : Bool = false
    var playableType : String = "" // FIRST, CENTER, ALL
    var isViewCountVisible : Bool = true
    var isBrandVisible : Bool = true
    var isTitleVisible : Bool = true
    var isProductCountVisible : Bool = true
    var isDescriptionVisible : Bool = true
    var cornerRadius : Double = 6
    
    
    func toDictionary() -> [String : Any] {
        var dict : [String : Any] = [:]
        dict["isSnapEnabled"] = isSnapEnabled
        dict["isPlayOnlyOnWifi"] = isPlayOnlyOnWifi
        dict["playableType"] = playableType
        dict["isViewCountVisible"] = isViewCountVisible
        dict["isBrandVisible"] = isBrandVisible
        dict["isTitleVisible"] = isTitleVisible
        dict["isProductCountVisible"] = isProductCountVisible
        dict["isDescriptionVisible"] = isDescriptionVisible
        dict["cornerRadius"] = cornerRadius
        return dict
    }
}
