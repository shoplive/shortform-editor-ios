import Foundation
import UIKit
import ShopliveSDKCommon

extension ShopLiveShortform {
    public struct ShortsModel: BaseResponsable, RawDataRepresantable,  Equatable {
        
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
        public var rawData: Data?
        
        public init(from decoder: Decoder) throws {
            if let userInfoKey = CodingUserInfoKey(rawValue: "rawData") {
                self.rawData = decoder.userInfo[userInfoKey] as? Data
            }
            
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
        
        
        public func getRawDataDict() -> [String : Any]? {
            guard let data = rawData else { return nil }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String : Any],
                      let shortsList = json["shortsList"] as? [[String : Any]] else { return nil }
                
                for shortsDetail in shortsList {
                    if let shortsIdFromArr = shortsDetail["shortsId"] as? String,
                       let currentShortsId = self.shortsId,
                       shortsIdFromArr == currentShortsId {
                        return shortsDetail
                    }
                }
                return nil
            }
            catch(_) {
                return nil
            }
        }
        
        func toShopLiveShortformData() -> ShopLiveShortformData {
            return .init(shortsId: self.shortsId,
                         srn: self.srn,
                         activity: self.activity?.toShopLiveShortformActivityData(),
                         cards: cards?.map({ $0.toShopLiveShortformCardData() }),
                         shortsDetail: shortsDetail?.toShortsDetailData(),
                         shortsType: self.shortsType,
                         rawDictionary: self.getRawDataDict())
        }
    }
}

@objc public final class ShopLiveShortformData : NSObject {
    
    public var shortsId : String?
    public var srn : String?
    public var activity : ShopLiveShortformActivityData?
    public var cards : [ShopLiveShortformCardData]?
    public var shortsDetail : ShopLiveShortformDetailData?
    public var shortsType : String?
    public var rawDictionary : [String : Any]?
    
    public init(shortsId: String? = nil, srn: String? = nil, activity: ShopLiveShortformActivityData? = nil, cards: [ShopLiveShortformCardData]? = nil, shortsDetail: ShopLiveShortformDetailData? = nil, shortsType: String? = nil, rawDictionary: [String : Any]? = nil) {
        self.shortsId = shortsId
        self.srn = srn
        self.activity = activity
        self.cards = cards
        self.shortsDetail = shortsDetail
        self.shortsType = shortsType
        self.rawDictionary = rawDictionary
    }
    
}
