import Foundation
import ShopLiveSDKCommon

struct Activity: Codable {
    let viewCount, likeCount, commentCount, bookmarkCount: Int?
    let like, bookmark: Bool?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self.viewCount = try? parser.parse(targetType: Int.self, key: CodingKeys.viewCount)
        self.likeCount = try? parser.parse(targetType: Int.self, key: CodingKeys.likeCount)
        self.commentCount = try? parser.parse(targetType: Int.self, key: CodingKeys.commentCount)
        self.bookmarkCount = try? parser.parse(targetType: Int.self, key: CodingKeys.bookmarkCount)
        self.like = try? parser.parse(targetType: Bool.self, key: CodingKeys.like)
        self.bookmark = try? parser.parse(targetType: Bool.self, key: CodingKeys.bookmark)
    }
}
