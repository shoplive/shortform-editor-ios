//
//  SLUploadResponse.swift
//  shortform-upload
//
//  Created by 김우현 on 5/16/23.
//

import Foundation
import ShopliveSDKCommon

// MARK: - UploadResponse
struct SLUploadResponse: BaseResponsable {
    var _s: Int?
    var _e: String?
    
    let thumbnailImageUrl: String?
    let customerID: Int?
//    let resolutionVideoCuts: ResolutionVideoCuts?
    let videoId: Int?
    let title, videoRealtimeLiveURL: String?
    let autoplay: Bool?
    let videoLiveURL: String?
}

// MARK: - ResolutionVideoCuts
//struct ResolutionVideoCuts: Codable {
//}
