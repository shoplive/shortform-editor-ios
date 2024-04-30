import Foundation
import ShopliveSDKCommon

struct CardModel : Codable {
    let duration, playCount, playDuration: Int?
    let source: String?
    let videoId: String?
    let campaignId: String?
    let clips: [Clip]?
    // 웹클라이언트 요청으로 주석처리, 기존에 사용안하고 있음.
    // let srn: String?
    let videoUrl, previewVideoUrl: String?
    let screenshotUrl: String? //1순위
    let specifiedScreenShotUrl : String? //2순위
    let cardType: String?
    
    
    
    //added 2024-03
    let srn : String?
    let playerType : String?
    let timeOnlyClips : [TimeOnlyClip]?
    let width : CGFloat?
    let height : CGFloat?
    
    //유투브용
    let externalVideoType : String?
    let externalVideoUrl : String?
    let externalVideoId : String?
    let externalVideoThumbnail : String?
    
    
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
    
    var validate: Bool {
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
}

struct Clip: Codable {
    let title, ClipTitle: String?
    let from, to: Int?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self.title = try? parser.parse(targetType: String.self, key: CodingKeys.title)
        self.ClipTitle = try? parser.parse(targetType: String.self, key: CodingKeys.ClipTitle)
        self.from = try? parser.parse(targetType: Int.self, key: CodingKeys.from)
        self.to = try? parser.parse(targetType: Int.self, key: CodingKeys.to)
    }
}

struct TimeOnlyClip : Codable {
    let title : String?
    let from : Double?
    let to : Double?
    let subtitles : [String]?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self.title = try? parser.parse(targetType: String.self, key: CodingKeys.title)
        self.from = try? parser.parse(targetType: Double.self, key: CodingKeys.from)
        self.to = try? parser.parse(targetType: Double.self, key: CodingKeys.to)
        self.subtitles = try? parser.parse(targetType: [String].self, key: CodingKeys.subtitles)
    }
}
