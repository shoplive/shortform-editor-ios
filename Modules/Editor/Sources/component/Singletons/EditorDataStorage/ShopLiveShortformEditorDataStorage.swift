//
//  ShopLiveShortformEditorStorage.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/19/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation



class ShopLiveShortformEditorDataStorage {
    static let shared = ShopLiveShortformEditorDataStorage()
    
    /**
     무신사 전용 요청사항이라 일단 예외 케이스로 관리
     */
    var mediaPickerVideoCreationDate : Date?
}
