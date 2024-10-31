import Foundation
import ShopliveSDKCommon

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
    
    func toShopLiveShortformActivityData() -> ShopLiveShortformActivityData {
        return .init(viewCount: viewCount,
                     likeCount: likeCount,
                     commentCount: commentCount,
                     bookmarkCount: bookmarkCount,
                     like: like,
                     bookmark: bookmark)
    }
    
}

@objc public final class ShopLiveShortformActivityData : NSObject {

    public var viewCount : Int?
    public var likeCount : Int?
    public var commentCount : Int?
    public var bookmarkCount : Int?
    public var like : Bool?
    public var bookmark : Bool?

    public init(viewCount: Int? = nil, likeCount: Int? = nil, commentCount: Int? = nil, bookmarkCount: Int? = nil, like: Bool? = nil, bookmark: Bool? = nil) {
        self.viewCount = viewCount
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.bookmarkCount = bookmarkCount
        self.like = like
        self.bookmark = bookmark
    }
}
