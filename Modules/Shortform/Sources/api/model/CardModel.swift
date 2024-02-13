import Foundation
import ShopLiveSDKCommon

struct CardModel : Codable {
    let duration, playCount, playDuration: Int?
    let source: String?
    let videoId: String?
    let campaignId: String?
    let clips: [Clip]?
    // 웹클라이언트 요청으로 주석처리, 기존에 사용안하고 있음.
    // let srn: String?
    let videoUrl, previewVideoUrl: String?
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
        self.cardType = try? parser.parse(targetType: String.self, key: CodingKeys.cardType)
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
