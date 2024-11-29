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
    /**
     FFMpeg encoding 된 후 로컬에 저장된 url입니다.
     */
    public var localVideoUrl : String?
    /**
     서버에 올라간 원본 영상의 주소입니다.
     */
    public var remoteOriginUrl : String?
    /**
    서버에서 트랜스코딩이 완료된 영상의 주소입니다.
     */
    public var remoteVideoUrl : String?
    /**
     서버에서 내려주는 미리보기 영상의 주소 입니다.
     */
    public var remotePreviewVideoUrl : String?
    /**
     서버에서 생성한 Default 커버 이미지의 주소입니다.
     */
    public var remoteCoverImageUrl : String? // 이것은 서버에서의 screenShotUrl
    public var localCoverImage : UIImage?
    public var width : CGFloat?
    public var height : CGFloat?
    public var duration : Double?
    
    public init(shortsId: String? = nil,
                localVideoUrl: String? = nil,
                remoteOriginUrl : String? = nil,
                remoteVideoUrl : String? = nil,
                remotePreviewVideoUrl : String? = nil,
                remoteCoverImageUrl : String? = nil,
                localCoverImage: UIImage? = nil,
                width: CGFloat? = nil,
                height: CGFloat? = nil,
                duration: Double? = nil) {
        self.shortsId = shortsId
        self.localVideoUrl = localVideoUrl
        self.remoteOriginUrl = remoteOriginUrl
        self.remoteVideoUrl = remoteVideoUrl
        self.remotePreviewVideoUrl = remotePreviewVideoUrl
        self.remoteCoverImageUrl = remoteCoverImageUrl
        self.localCoverImage = localCoverImage
        self.width = width
        self.height = height
        self.duration = duration
    }
}


struct ShopLiveEditorResultInternalData {
    
    var shortsId : String?
    /**
     FFMpeg encoding 된 후 로컬에 저장된 url입니다.
     */
    var localVideoUrl : String?
    /**
     서버에 올라간 원본 영상의 주소입니다.
     */
    var remoteOriginUrl : String?
    /**
    서버에서 트랜스코딩이 완료된 영상의 주소입니다.
     */
    var remoteVideoUrl : String?
    /**
     서버에서 내려주는 미리보기 영상의 주소 입니다.
     */
    var remotePreviewVideoUrl : String?
    /**
     서버에서 생성한 Default 커버 이미지의 주소입니다.
     */
    var remoteCoverImageUrl : String? // 이것은 서버에서의 screenShotUrl
    var localCoverImage : UIImage?
    var width : CGFloat?
    var height : CGFloat?
    var duration : Double?
    
    init(shortsId: String? = nil,
         localVideoUrl: String? = nil,
         remoteOriginUrl : String? = nil,
         remoteVideoUrl : String? = nil,
         remotePreviewVideoUrl : String? = nil,
         remoteCoverImageUrl : String? = nil,
         localCoverImage: UIImage? = nil,
         width: CGFloat? = nil,
         height: CGFloat? = nil,
         duration: Double? = nil) {
        self.shortsId = shortsId
        self.localVideoUrl = localVideoUrl
        self.remoteOriginUrl = remoteOriginUrl
        self.remoteVideoUrl = remoteVideoUrl
        self.remotePreviewVideoUrl = remotePreviewVideoUrl
        self.remoteCoverImageUrl = remoteCoverImageUrl
        self.localCoverImage = localCoverImage
        self.width = width
        self.height = height
        self.duration = duration
    }
    
    
    func convertToClass() -> ShopliveEditorResultData {
        return ShopliveEditorResultData(shortsId: shortsId,
                                        localVideoUrl: localVideoUrl,
                                        remoteOriginUrl: remoteOriginUrl,
                                        remoteVideoUrl: remoteVideoUrl,
                                        remotePreviewVideoUrl: remotePreviewVideoUrl,
                                        remoteCoverImageUrl: remoteCoverImageUrl,
                                        localCoverImage: localCoverImage,
                                        width: width,
                                        height: height,
                                        duration: duration)
    }
    
}
