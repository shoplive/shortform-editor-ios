import Foundation
import ShopLiveSDKCommon

extension ShopLiveShortform {
    public struct ShortsCollectionModel : BaseResponsable {
        typealias Model = ShopLiveShortform.ShortsCollectionModel
        public var _s: Int?
        public var _e: String?
        
        public let srn, title: String?
        public let shortsList: [ShortsModel]?
        public let reference: String?
        public let hasMore: Bool?
        
        public init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<Model.CodingKeys> = try decoder.container(keyedBy: Model.CodingKeys.self)
            let parser = SLFlexibleParser(container: container)
            
            self._s = try? parser.parse(targetType: Int.self, key: Model.CodingKeys._s)
            self._e = try? parser.parse(targetType: String.self, key: Model.CodingKeys._e)
            self.srn = try? parser.parse(targetType: String.self, key: Model.CodingKeys.srn)
            self.title = try? parser.parse(targetType: String.self, key: Model.CodingKeys.title)
            self.shortsList = try? container.decodeIfPresent([ShopLiveShortform.ShortsModel].self, forKey: Model.CodingKeys.shortsList)
            self.reference = try? parser.parse(targetType: String.self, key: Model.CodingKeys.reference)
            self.hasMore = try? parser.parse(targetType: Bool.self, key: Model.CodingKeys.hasMore)
        }
    }
}
