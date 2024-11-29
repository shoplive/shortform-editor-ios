//
//  Card.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 11/29/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
public struct CardModel : Codable {
    public let duration, playCount, playDuration: Int?
    public let source: String?
    public let videoId: String?
    public let campaignId: String?
    public let clips: [Clip]?
    // 웹클라이언트 요청으로 주석처리, 기존에 사용안하고 있음.
    // let srn: String?
    public let videoUrl, previewVideoUrl: String?
    public let originVideoUrl : String?
    public let convertStatus : String?
    public let screenshotUrl: String? //1순위
    public let specifiedScreenShotUrl : String? //2순위
    public let cardType: String?
    
    
    
    //added 2024-03
    public let srn : String?
    public let playerType : String?
    public let timeOnlyClips : [TimeOnlyClip]?
    public let width : CGFloat?
    public let height : CGFloat?
    
    //유투브용
    public let externalVideoType : String?
    public let externalVideoUrl : String?
    public let externalVideoId : String?
    public let externalVideoThumbnail : String?
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self.duration = try? parser.parse(targetType: Int.self, key: CodingKeys.duration)
        self.playCount = try? parser.parse(targetType: Int.self, key: CodingKeys.playCount)
        self.playDuration = try? parser.parse(targetType: Int.self, key: CodingKeys.playDuration)
        self.source = try? parser.parse(targetType: String.self, key: CodingKeys.source)
        self.videoId = try? parser.parse(targetType: String.self, key: CodingKeys.videoId)
        self.campaignId = try? parser.parse(targetType: String.self, key: CodingKeys.campaignId)
        self.clips = try container.decodeIfPresent([Clip].self, forKey: .clips)
        self.videoUrl = try? parser.parse(targetType: String.self, key: CodingKeys.videoUrl)
        self.previewVideoUrl = try? parser.parse(targetType: String.self, key: CodingKeys.previewVideoUrl)
        self.originVideoUrl = try? parser.parse(targetType: String.self, key: CodingKeys.originVideoUrl)
        self.convertStatus = try? parser.parse(targetType: String.self, key: CodingKeys.convertStatus)
        self.screenshotUrl = try? parser.parse(targetType: String.self, key: CodingKeys.screenshotUrl)
        self.specifiedScreenShotUrl = try? parser.parse(targetType: String.self, key: CodingKeys.specifiedScreenShotUrl)
        self.cardType = try? parser.parse(targetType: String.self, key: CodingKeys.cardType)
        self.srn = try? parser.parse(targetType: String.self, key: CodingKeys.srn)
        self.playerType = try? parser.parse(targetType: String.self, key: CodingKeys.playerType)
        self.timeOnlyClips = try container.decodeIfPresent([TimeOnlyClip].self, forKey: CodingKeys.timeOnlyClips)
        
        
        self.externalVideoUrl = try? parser.parse(targetType: String.self, key: CodingKeys.externalVideoUrl)
        self.externalVideoType = try? parser.parse(targetType: String.self, key: CodingKeys.externalVideoType)
        self.externalVideoId = try? parser.parse(targetType: String.self, key: CodingKeys.externalVideoId)
        self.externalVideoThumbnail = try? parser.parse(targetType: String.self, key: CodingKeys.externalVideoThumbnail)
        
        self.width = try? parser.parse(targetType: CGFloat.self, key: CodingKeys.width)
        self.height = try? parser.parse(targetType: CGFloat.self, key: CodingKeys.height)
    }
    
    public var validate: Bool {
        guard let cardType = cardType else {
            return false
        }
        
        switch cardType {
        case "VIDEO":
            if let videoUrl = videoUrl, videoUrl.isEmpty == false {
                return true
            }
            else if let externalVideoUrl = externalVideoUrl, externalVideoUrl.isEmpty == false {
                return true
            }
            else {
                return false
            }
        case "IMAGE":
            return false
        default:
            return false
        }
    }
    
    public func toShopLiveShortformCardData() -> ShopLiveShortformCardData {
        return .init(duration: duration,
                     playCount: playCount,
                     playDuration: playDuration,
                     source: source,
                     videoId: videoId,
                     campaignId: campaignId,
                     clips: clips?.map({ clip -> ShopLiveShortformClipData in
            return .init(title: clip.title,
                         clipTitle: clip.ClipTitle,
                         from: clip.from,
                         to: clip.to)
        }),
                     videoUrl: videoUrl,
                     previewVideoUrl: previewVideoUrl,
                     screenShotUrl: screenshotUrl,
                     specifiedScreenShotUrl: specifiedScreenShotUrl,
                     cardType: cardType,
                     srn: srn,
                     playerType: playerType,
                     timeOnlyClips: timeOnlyClips?.map({ clip -> ShopLiveShortformTimeOnlyClipData in
            return .init(title: clip.title,
                         from: clip.from,
                         to: clip.to,
                         subTitles: clip.subtitles)
        }),
                     width: width,
                     heigh: height,
                     externalVideoType: externalVideoType,
                     externalVideoUrl: externalVideoUrl,
                     externalVideoId: externalVideoId,
                     externalVideoThumbnail: externalVideoThumbnail)
    }
    
}

public struct Clip: Codable {
    public let title, ClipTitle: String?
    public let from, to: Int?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self.title = try? parser.parse(targetType: String.self, key: CodingKeys.title)
        self.ClipTitle = try? parser.parse(targetType: String.self, key: CodingKeys.ClipTitle)
        self.from = try? parser.parse(targetType: Int.self, key: CodingKeys.from)
        self.to = try? parser.parse(targetType: Int.self, key: CodingKeys.to)
    }
    
    public func toShopLiveShortformClipData() -> ShopLiveShortformClipData {
        return .init(title: title,
                     clipTitle: ClipTitle,
                     from: from,
                     to: to)
    }
    
}

public struct TimeOnlyClip : Codable {
    public let title : String?
    public let from : Double?
    public let to : Double?
    public let subtitles : [String]?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self.title = try? parser.parse(targetType: String.self, key: CodingKeys.title)
        self.from = try? parser.parse(targetType: Double.self, key: CodingKeys.from)
        self.to = try? parser.parse(targetType: Double.self, key: CodingKeys.to)
        self.subtitles = try? parser.parse(targetType: [String].self, key: CodingKeys.subtitles)
    }
    
    public func toShopLiveShortformTimeOnlyClipData() -> ShopLiveShortformTimeOnlyClipData {
        return .init(title: title,
                     from: from,
                     to: to,
                     subTitles: subtitles)
    }
}





@objc public final class ShopLiveShortformCardData : NSObject {
    public var duration : Int?
    public var playCount : Int?
    public var playDuration : Int?
    public var source : String?
    public var videoId : String?
    public var campaignId : String?
    public var clips : [ShopLiveShortformClipData]?
    public var videoUrl : String?
    public var previewVideoUrl : String?
    public var screenShotUrl : String?
    public var specifiedScreenShotUrl : String?
    public var cardType : String?
    
    public var srn : String?
    public var playerType : String?
    public var timeOnlyClips : [ShopLiveShortformTimeOnlyClipData]?
    public var width : CGFloat?
    public var heigh : CGFloat?
    
    public var externalVideoType : String?
    public var externalVideoUrl : String?
    public var externalVideoId : String?
    public var externalVideoThumbnail : String?
    
    public init(duration: Int? = nil, playCount: Int? = nil, playDuration: Int? = nil, source: String? = nil, videoId: String? = nil, campaignId: String? = nil, clips: [ShopLiveShortformClipData]? = nil, videoUrl: String? = nil, previewVideoUrl: String? = nil, screenShotUrl: String? = nil, specifiedScreenShotUrl: String? = nil, cardType: String? = nil, srn: String? = nil, playerType: String? = nil, timeOnlyClips: [ShopLiveShortformTimeOnlyClipData]? = nil, width: CGFloat? = nil, heigh: CGFloat? = nil, externalVideoType: String? = nil, externalVideoUrl: String? = nil, externalVideoId: String? = nil, externalVideoThumbnail: String? = nil) {
        self.duration = duration
        self.playCount = playCount
        self.playDuration = playDuration
        self.source = source
        self.videoId = videoId
        self.campaignId = campaignId
        self.clips = clips
        self.videoUrl = videoUrl
        self.previewVideoUrl = previewVideoUrl
        self.screenShotUrl = screenShotUrl
        self.specifiedScreenShotUrl = specifiedScreenShotUrl
        self.cardType = cardType
        self.srn = srn
        self.playerType = playerType
        self.timeOnlyClips = timeOnlyClips
        self.width = width
        self.heigh = heigh
        self.externalVideoType = externalVideoType
        self.externalVideoUrl = externalVideoUrl
        self.externalVideoId = externalVideoId
        self.externalVideoThumbnail = externalVideoThumbnail
    }
    
}

@objc public final class ShopLiveShortformClipData : NSObject {
    
    public var title : String?
    public var clipTitle : String?
    public var from : Int?
    public var to : Int?
    
    public init(title: String? = nil, clipTitle: String? = nil, from: Int? = nil, to: Int? = nil) {
        self.title = title
        self.clipTitle = clipTitle
        self.from = from
        self.to = to
    }
}


@objc public final class ShopLiveShortformTimeOnlyClipData : NSObject {
    public var title : String?
    public var from : Double?
    public var to : Double?
    public var subTitles : [String]?
    
    public init(title: String? = nil, from: Double? = nil, to: Double? = nil, subTitles: [String]? = nil) {
        self.title = title
        self.from = from
        self.to = to
        self.subTitles = subTitles
    }
}
