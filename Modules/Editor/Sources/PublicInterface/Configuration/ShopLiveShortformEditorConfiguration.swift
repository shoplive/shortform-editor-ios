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

public enum SLEditOptions : CaseIterable {
    case filter
    case playBackSpeed
    case volume
    case crop
}

public final class ShopLiveShortFormEditorVisibleContent : SLVisibleContent {
    public var isDescriptionVisible : Bool = true
    public var isTagsVisible : Bool = true
    public var editOptions : [SLEditOptions] = [.filter, .playBackSpeed, .volume, .crop]
    
    public init(isDescriptionVisible: Bool = true , isTagsVisible: Bool = true, editOptions : [SLEditOptions] = [.filter, .playBackSpeed, .volume, .crop] ) {
        self.isDescriptionVisible = isDescriptionVisible
        self.isTagsVisible = isTagsVisible
        self.editOptions = editOptions
    }
}

public final class ShopLiveShortformEditorVideoOuputOption : SLVideoOutputConfigOption {
    public var videoOutputQuality: SLVideoOutputQuality = .high
    public var videoOutputResolution: SLVideoOutputResolution = ._720
    
    public init(videoOutputQuality: SLVideoOutputQuality = .high, videoOutputResoltuion: SLVideoOutputResolution = ._720) {
        self.videoOutputQuality = videoOutputQuality
        self.videoOutputResolution = videoOutputResoltuion
    }
}

public final class ShopLiveShortformEditorConfiguration {
    
    public var videoCropOption : ShopLiveShortFormEditorAspectRatio = .init()
    public var visibleContents : ShopLiveShortFormEditorVisibleContent = .init()
    public var videoTrimOption : ShopLiveShortFormEditorTrimOption = .init()
    public var videoOutputOption : ShopLiveShortformEditorVideoOuputOption = .init()
    public var videoDurationOption : ShopLiveMediaPickerVideoDurationOption = .init()
    
    public init(videoCropOption: ShopLiveShortFormEditorAspectRatio,
                visibleContents : ShopLiveShortFormEditorVisibleContent?,
                videoOutputOption : ShopLiveShortformEditorVideoOuputOption?,
                mediaPickerVideoDurationOption : ShopLiveMediaPickerVideoDurationOption?,
                minVideoDuration : CGFloat? = nil,
                maxVideoDuration : CGFloat? = nil) {
        self.videoCropOption = videoCropOption
        if let visibleContents = visibleContents {
            self.visibleContents = visibleContents
        }
        
        if let minVideoDuration = minVideoDuration, minVideoDuration > 0 {
            self.videoTrimOption.minVideoDuration = minVideoDuration
        }
        
        if let videoOutputOption = videoOutputOption {
            self.videoOutputOption = videoOutputOption
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
