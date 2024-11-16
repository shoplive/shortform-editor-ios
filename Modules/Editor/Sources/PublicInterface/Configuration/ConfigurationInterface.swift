//
//  ConfigurationInterface.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 3/26/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit

protocol SLEditorAspectRatio {
    var width : Int { get set }
    var height : Int { get set }
    var isFixed : Bool { get set }
}

protocol SLMediaPickerVideoDurationOption {
    var minVideoDuration : Int { get set }
    var maxVideoDuration : Int { get set }
}

/**
 비디오 에디팅의 결과물 최소 최대 시간 가능 여부
 */
protocol SLEditorTrimOption {
    var maxVideoDuration : CGFloat { get set }
    var minVideoDuration : CGFloat { get set }
}

protocol SLVisibleContent {
    var isDescriptionVisible : Bool { get set }
    var isTagsVisible : Bool { get set }
    var editOptions : [SLEditOptions] { get set }
}

public enum SLVideoOutputQuality {
    case normal
    case high
    case max
}

public enum SLVideoOutputResolution : Int {
    case _360 = 360
    case _480 = 480
    case _720 = 720
    case _1080 = 1080
}

protocol SLVideoOutputConfigOption {
    var videoOutputQuality : SLVideoOutputQuality { get set }
    var videoOutputResolution : SLVideoOutputResolution { get set }
}
