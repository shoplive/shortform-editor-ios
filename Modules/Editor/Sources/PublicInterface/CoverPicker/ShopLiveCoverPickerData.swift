//
//  ShopLiveCoverPickerData.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation


public class ShopLiveCoverPickerData {
    public var shortsId : String?
    public var videoUrl : URL
    
    public init( videoUrl: URL, shortsId: String? = nil) {
        self.videoUrl = videoUrl
        self.shortsId = shortsId
    }
}
