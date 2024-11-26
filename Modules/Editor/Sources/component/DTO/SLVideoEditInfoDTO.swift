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
    
    var convertedVideoPath : String?
    var convertedVideoAsset : AVAsset?
    
    var cropTime : (start : CMTime, end : CMTime) = (.zero, .zero)
    /**
     실제 비디오를 크롭할때 사용하는 크기
     */
    var realVideoCropRect : CGRect = .zero
    /**
     크롭뷰를 위한 크기
     */
    var cropViewRect : CGRect = .zero
    /**
     영상의 프레임 크기 자체가 달라지므로 비율을 가지고 다니면서 그려야함
     */
    var cropViewRatio : CGRect = .zero
    
    var filterConfig : SLFilterConfig?
    var thumbnailTime : CMTime = .zero
    var thumbnailImage : UIImage?
    var thumbnailType : ThumbnailType = .video
    
    var isMuted : Bool = false
    var volume : Int = 100
    var videoSpeed : Double = 1.0
    
    
    
    private func getConvertedVideoAsset() -> AVAsset? {
        if let asset = convertedVideoAsset {
            return asset
        }
        guard let videoPath = convertedVideoPath else {
            return nil
        }
        let url = URL(fileURLWithPath: videoPath)
        return AVURLAsset(url: url)
    }
    
    func getConvertedVideoDuration() -> Double? {
        return self.getConvertedVideoAsset()?.duration.seconds
    }
    
    func getConvertedVideoSize() -> CGSize? {
        guard let track = self.getConvertedVideoAsset()?.tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}
