//
//  ShopLiveMediaPickerConfiguration.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit


public final class ShopLiveMediaPickerVideoDurationOption : SLMediaPickerVideoDurationOption {
    public var minVideoDuration: Int = 3
    public var maxVideoDuration: Int = 60 * 15
    public var invalidDurationToastMessage: String?
    
    public init(minVideoDuration: Int = 3, maxVideoDuration: Int = 60 * 15, invalidDurationToastMessage : String? = nil) {
        self.minVideoDuration = minVideoDuration
        self.maxVideoDuration = maxVideoDuration
        self.invalidDurationToastMessage = invalidDurationToastMessage
    }
}


public final class ShopLiveMediaPickerConfiguration  {
    public var videoDurationOption : ShopLiveMediaPickerVideoDurationOption = ShopLiveMediaPickerVideoDurationOption()
    
    
    public init(videoDurationOption : ShopLiveMediaPickerVideoDurationOption) {
        self.videoDurationOption = videoDurationOption
    }
}


