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
    
    public init(minVideoDuration: Int = 3, maxVideoDuration: Int = 60 * 15) {
        self.minVideoDuration = minVideoDuration
        self.maxVideoDuration = maxVideoDuration
    }
}


public final class ShopLiveMediaPickerConfiguration  {
    public var videoDurationOption : ShopLiveMediaPickerVideoDurationOption = ShopLiveMediaPickerVideoDurationOption()
    
    
    public init(videoDurationOption : ShopLiveMediaPickerVideoDurationOption) {
        self.videoDurationOption = videoDurationOption
    }
}


