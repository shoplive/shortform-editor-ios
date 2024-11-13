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
}

