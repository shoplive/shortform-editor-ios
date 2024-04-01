//
//  ShopLiveShortformUploadConfiguration.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 11/2/23.
//

import Foundation
import UIKit


public final class ShopLiveShortFormEditorAspectRatio : SLEditorAspectRatio {
    public var width : Int = 9
    public var height : Int = 16
    public var isFixed : Bool = true
    
    
    public init(width: Int = 9, height: Int = 16, isFixed : Bool = true) {
        self.width = width
        self.height = height
        self.isFixed = isFixed
    }
}

public final class ShopLiveShortFormEditorTrimOption : SLEditorTrimOption {
    public var maxVideoDuration: CGFloat = 60
    public var minVideoDuration: CGFloat = 1
    
    init(minVideoDuration : CGFloat = 1, maxVideoDuration : CGFloat = 60) {
        self.maxVideoDuration = maxVideoDuration
        self.minVideoDuration = minVideoDuration
    }
}

public final class ShopLiveShortFormEditorVisibleContent : SLVisibleContent {
    public var isDescriptionVisible : Bool = true
    public var isTagsVisible : Bool = true
    
    public init(isDescriptionVisible: Bool = true , isTagsVisible: Bool = true) {
        self.isDescriptionVisible = isDescriptionVisible
        self.isTagsVisible = isTagsVisible
    }
}

public final class ShopLiveShortformEditorConfiguration {
    
    public var videoCropOption : ShopLiveShortFormEditorAspectRatio = .init()
    public var visibleContents : ShopLiveShortFormEditorVisibleContent = .init()
    public var videoTrimOption : ShopLiveShortFormEditorTrimOption = .init()
    
    public init(videoCropOption: ShopLiveShortFormEditorAspectRatio,
                visibleContents : ShopLiveShortFormEditorVisibleContent?,
                minVideoDuration : CGFloat? = nil,
                maxVideoDuration : CGFloat? = nil) {
        self.videoCropOption = videoCropOption
        if let visibleContents = visibleContents {
            self.visibleContents = visibleContents
        }
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






// ShopliveShortformEditorConfiguration 2가지 타입으로
// gallery 우리꺼 쓰냐 고객사꺼 써서 바로 들어오냐
// 완료된 url 다시 떨어트려주는 delegate
//complete error cancel,
