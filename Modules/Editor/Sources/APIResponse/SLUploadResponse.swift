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
    
    
    let videoID: String
    let customerID: Int
    let sellerID, customerVideoID: String?
    let title: String
    let description: String?
    let tags: [String]
    let filename: String
    let width, height: Double?
    let filesize: Int
    let resolutions: [String]
    let videoSourceURL, cdnVideoSourceURL: String
    let thumbnailImageURL: String?
    let vodStreamURL: String
    let duration: Double?
    let convertStatus: String
    let convertRate, adminID: Int
    let adminName: String?
    let uploadedAt, createdAt, updatedAt: Int
    
    enum CodingKeys: String, CodingKey {
        case videoID = "videoId"
        case customerID = "customerId"
        case sellerID = "sellerId"
        case customerVideoID = "customerVideoId"
        case title, description, tags, filename, width, height, filesize, resolutions
        case videoSourceURL = "videoSourceUrl"
        case cdnVideoSourceURL = "cdnVideoSourceUrl"
        case thumbnailImageURL = "thumbnailImageUrl"
        case vodStreamURL = "vodStreamUrl"
        case duration, convertStatus, convertRate
        case adminID = "adminId"
        case adminName, uploadedAt, createdAt, updatedAt
    }
    
}

// MARK: - ResolutionVideoCuts
//struct ResolutionVideoCuts: Codable {
//}
