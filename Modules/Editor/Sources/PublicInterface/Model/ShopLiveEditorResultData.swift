//
//  ShopLiveEditorResultData.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/22/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit

@objc public class ShopliveEditorResultData : NSObject {
    public var shortsId : String?
    public var videoUrl : String?
    public var coverImage : UIImage?
    public var width : CGFloat?
    public var height : CGFloat?
    public var duration : Double?
    
    public init(shortsId: String? = nil, videoUrl: String? = nil, coverImage: UIImage? = nil, width: CGFloat? = nil, height: CGFloat? = nil, duration: Double? = nil) {
        self.shortsId = shortsId
        self.videoUrl = videoUrl
        self.coverImage = coverImage
        self.width = width
        self.height = height
        self.duration = duration
    }
}


struct ShopLiveEditorResultInternalData {
    
    var shortsId : String?
    var videoUrl : String?
    var coverImage : UIImage?
    var width : CGFloat?
    var height : CGFloat?
    var duration : Double?
    
    init(shortsId: String? = nil, videoUrl: String? = nil, coverImage: UIImage? = nil, width: CGFloat? = nil, height: CGFloat? = nil, duration: Double? = nil) {
        self.shortsId = shortsId
        self.videoUrl = videoUrl
        self.coverImage = coverImage
        self.width = width
        self.height = height
        self.duration = duration
    }
    
    
    func convertToClass() -> ShopliveEditorResultData {
        return ShopliveEditorResultData(shortsId: shortsId, videoUrl: videoUrl, coverImage: coverImage, width: width, height: height, duration: duration)
    }
    
}
