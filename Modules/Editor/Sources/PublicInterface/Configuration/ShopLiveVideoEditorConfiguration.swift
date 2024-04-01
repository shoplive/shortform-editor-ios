//
//  ShopLiveVideoEditorConfiguration.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 3/26/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit



public final class ShopliveVideoEditorAspectRatio : SLEditorAspectRatio {
    public var width : Int = 9
    public var height : Int = 16
    public var isFixed : Bool = true
    
    
    public init(width: Int = 9, height: Int = 16, isFixed : Bool = true) {
        self.width = width
        self.height = height
        self.isFixed = isFixed
    }
}

public final class ShopliveVideoEditorTrimOption : SLEditorTrimOption {
    public var maxVideoDuration: CGFloat = 60
    public var minVideoDuration: CGFloat = 1
    
    init(minVideoDuration : CGFloat = 1, maxVideoDuration : CGFloat = 60) {
        self.maxVideoDuration = maxVideoDuration
        self.minVideoDuration = minVideoDuration
    }
}


public final class ShopliveVideoEditorConfiguration {
    public var videoCropOption : ShopliveVideoEditorAspectRatio = .init()
    public var videoTrimOption : ShopliveVideoEditorTrimOption = .init()
    
    public init(videoCropOption: ShopliveVideoEditorAspectRatio,
                minVideoDuration : CGFloat? = nil,
                maxVideoDuration : CGFloat? = nil) {
        self.videoCropOption = videoCropOption
       
        if let minVideoDuration = minVideoDuration, minVideoDuration > 0 {
            self.videoTrimOption.minVideoDuration = minVideoDuration
        }
        if let maxVideoDuration = maxVideoDuration  {
            if maxVideoDuration <= (minVideoDuration ?? 1) {
                self.videoTrimOption = .init()
            }
            else {
                self.videoTrimOption.maxVideoDuration = maxVideoDuration
            }
        }
    }
}
