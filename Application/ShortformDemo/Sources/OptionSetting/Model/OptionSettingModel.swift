//
//  OptionSettingModel.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/07/28.
//

import Foundation
import UIKit
import ShopLiveShortformSDK


class OptionSettingModel {
    var shuffle : Bool = false
    var viewCountVisible : Bool = true
    var tags : [String] = []
    var tagSearchOperate : ShopLiveTagSearchOperator = .OR
    var brands : [String] = []
    var skus : [String] = []
    var titleVisible : Bool = true
    var descriptionVisible : Bool = true
    var productCountVisible : Bool = true
    var brandVisible : Bool = true
    var cellSpacing : CGFloat = 8
    var cellCornerRadius : CGFloat = 16
    var snapEnabled : Bool = false
    var playOnlyWifi : Bool = false
    var cardType : ShopLiveShortform.CardViewType = .type1
    
    
    
    
    static var editorMinVideoDuration : Double = 1
    static var editorMaxVideoDuration : Double = 60
    static var editorShowDescription : Bool = true
    static var editorShowTags : Bool = true
    static var editorWidth : Int = 9
    static var editorheight : Int = 16
    static var editorIsFixed : Bool = true
    static var previewMaxCount : Int? = nil
}
