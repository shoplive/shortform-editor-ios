import Foundation
import UIKit
import ShopLiveSDKCommon

extension ShopLiveShortform {
    public struct ShortsModel: BaseResponsable, Equatable {
        
        typealias Model = ShopLiveShortform.ShortsModel
        
        public var _s: Int?
        public var _e: String?
        public var _d: String?
        
        public let shortsId: String?
        public let srn: String?
        public let startAt, endAt: Int?
        public let reference: String?
        public let shortsDetail: ShortsDetail?
        let activity: Activity?
        public let action, payload: String?
        let cards: [CardModel]?
        public let shortsType: String?
        public let traceId: String?
        public let url: String?
        public let reasonKey : String?
        
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<Model.CodingKeys> = try decoder.container(keyedBy: Model.CodingKeys.self)
            let parser = SLFlexibleParser(container: container)
            
            self.shortsId = try? parser.parse(targetType: String.self, key: Model.CodingKeys.shortsId)
            self.srn = try? parser.parse(targetType: String.self, key: Model.CodingKeys.srn)
            self.reference = try? parser.parse(targetType: String.self, key: Model.CodingKeys.reference)
            self.startAt = try? parser.parse(targetType: Int.self, key: Model.CodingKeys.startAt)
            self.endAt = try? parser.parse(targetType: Int.self, key: Model.CodingKeys.endAt)
            self.reasonKey = try? parser.parse(targetType: String.self, key: Model.CodingKeys.reasonKey)
            self.shortsType = try? parser.parse(targetType: String.self, key: Model.CodingKeys.shortsType)
            self.traceId = try? parser.parse(targetType: String.self, key: Model.CodingKeys.traceId)
            self.url = try? parser.parse(targetType: String.self, key: Model.CodingKeys.url)
            self.payload = try? parser.parse(targetType: String.self, key: Model.CodingKeys.payload)
            self.action = try? parser.parse(targetType: String.self, key: Model.CodingKeys.action)
            
            self.shortsDetail = try? container.decodeIfPresent(ShortsDetail.self, forKey: Model.CodingKeys.shortsDetail)
            self.activity = try? container.decodeIfPresent(Activity.self, forKey: Model.CodingKeys.activity)
            self.cards = try? container.decodeIfPresent([CardModel].self, forKey: Model.CodingKeys.cards)
        }
        
        public static func ==(lhs: ShortsModel, rhs: ShortsModel) -> Bool {
             return (lhs.shortsId == rhs.shortsId && lhs.srn == rhs.srn)
        }
        
        public var validate: Bool {
            guard let cards = cards,
                  cards.filter({ $0.validate }).count > 0 else {
                      return false
                  }
            
            return true
        }
    }

}

