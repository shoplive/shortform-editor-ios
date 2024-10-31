//
//  InternalShortformCollectionDTO.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 4/17/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation


internal class InternalShortformCollectionDto {
    var tags : [String]?
    var tagSearchOperator : String?
    var brands : [String]?
    var shuffle : Bool?
    var skus : [String]?
    var shortsCollectionId : String?
    var delegate : ShopLiveShortformReceiveHandlerDelegate?
}

