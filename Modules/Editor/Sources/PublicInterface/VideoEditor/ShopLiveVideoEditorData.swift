//
//  ShopLiveVideoEditorData.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation

public class ShopLiveVideoEditorData {
    public var isCreatedShortform : Bool = true
    
    public var videoAbsoluteUrl : URL?
    public var videoRelativeUrl : URL?
    public var videoRemoteUrl : URL?
    
    
    public init(videoUrl : URL, isCreatedShortform : Bool = true) {
        self.videoAbsoluteUrl = videoUrl
        self.isCreatedShortform = isCreatedShortform
    }
    
    public init(videoAbsoluteUrl : URL, videoRelativeUrl : URL, isCreatedShortform : Bool = true) {
        self.videoAbsoluteUrl = videoAbsoluteUrl
        self.videoRelativeUrl = videoRelativeUrl
        self.isCreatedShortform = isCreatedShortform
    }
    
    
    public init(videoRemoteUrl : URL, isCreatedShortform : Bool = true) {
        self.videoRemoteUrl = videoRemoteUrl
        self.isCreatedShortform = isCreatedShortform
    }
}
