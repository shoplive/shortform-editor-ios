import Foundation
import ShopliveSDKCommon

extension ShopLiveShortform {
    public struct ShortsCollectionModel : BaseResponsable, RawDataRepresantable {
        typealias Model = ShopLiveShortform.ShortsCollectionModel
        public var _s: Int?
        public var _e: String?
        
        public let srn, title: String?
        public let shortsList: [ShortsModel]?
        public let reference: String?
        public let referenceByType : ReferenceByType?
        public let hasMore: Bool?
        public var rawData: Data?
        
        public init(from decoder: Decoder) throws {
            if let userInfoKey = CodingUserInfoKey(rawValue: "rawData") {
                self.rawData = decoder.userInfo[userInfoKey] as? Data
            }
        
            let container: KeyedDecodingContainer<Model.CodingKeys> = try decoder.container(keyedBy: Model.CodingKeys.self)
            let parser = SLFlexibleParser(container: container)
            
            self._s = try? parser.parse(targetType: Int.self, key: Model.CodingKeys._s)
            self._e = try? parser.parse(targetType: String.self, key: Model.CodingKeys._e)
            self.srn = try? parser.parse(targetType: String.self, key: Model.CodingKeys.srn)
            self.title = try? parser.parse(targetType: String.self, key: Model.CodingKeys.title)
            self.shortsList = try? container.decodeIfPresent([ShopLiveShortform.ShortsModel].self, forKey: Model.CodingKeys.shortsList)
            self.reference = try? parser.parse(targetType: String.self, key: Model.CodingKeys.reference)
            self.referenceByType = try? parser.parse(targetType: ReferenceByType.self, key: Model.CodingKeys.referenceByType)
            self.hasMore = try? parser.parse(targetType: Bool.self, key: Model.CodingKeys.hasMore)
        }
        
        public func getRawDataDict() -> [String : Any]? {
            guard let data = rawData else { return nil }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                return json
            }
            catch(_) {
                return nil
            }
        }
        
    }
}
