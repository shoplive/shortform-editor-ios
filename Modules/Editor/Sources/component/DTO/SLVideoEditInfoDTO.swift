//
//  SLVideoEditInfoDTO.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/8/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit


class SLVideoEditInfoDTO {
    
    enum ThumbnailType {
        case video
        case image
    }
    
    var shortsVideo : ShortsVideo
    
    init(shortsVideo : ShortsVideo) {
        self.shortsVideo = shortsVideo
    }
    
    
    var cropTime : (start : CMTime, end : CMTime) = (.zero, .zero)
    /**
     실제 비디오를 크롭할때 사용하는 크기
     */
    var realVideoCropRect : CGRect = .zero
    /**
     크롭뷰를 위한 크기
     */
    var cropViewRect : CGRect = .zero
    
    var filterConfig : SLFilterConfig?
    var thumbnailTime : CMTime = .zero
    var thumbnailImage : UIImage?
    var thumbnailType : ThumbnailType = .video
    
    var isMuted : Bool = false
    var volume : Int = 100
    var videoSpeed : Double = 1.0
}
