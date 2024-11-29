//
//  CardModel.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 2023/07/27.
//

import Foundation

struct CardModel : Codable {
    let duration, playCount, playDuration: Int?
    let source: String?
    let videoId: String?
    let campaignId: String?
    let clips: [Clip]?
    // 웹클라이언트 요청으로 주석처리, 기존에 사용안하고 있음.
    // let srn: String?
    let videoUrl, previewVideoUrl: String?
    let originVideoUrl : String?
    let width : Double?
    let height : Double?
    let convertStatus : String?
    let screenshotUrl: String?
    let cardType: String?
    
    
    var validate: Bool {
        guard let cardType = cardType else {
            return false
        }
        
        switch cardType {
        case "VIDEO":
            guard let videoUrl = videoUrl,
                  !videoUrl.isEmpty else {
                return false
            }
            return true
        case "IMAGE":
            return false
        default:
            return false
        }
    }
}

struct Clip: Codable {
    let title, ClipTitle: String?
    let from, to: Int?
}
