import Foundation
import ShopliveSDKCommon


public struct ShortsDetail : Codable {
	public let title : String?
    public let description : String?
    public let tags : [String]?
    public let productCount : Int?
    public let productBanner: ProductBanner?
    public let products : [Product]?
    public let brand : BrandModel?

    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        
        
        self.title = try? parser.parse(targetType: String.self, key: CodingKeys.title)
        self.description = try? parser.parse(targetType: String.self, key: CodingKeys.description)
        self.tags = try? parser.parse(targetType: [String].self, key: CodingKeys.tags)
        self.productCount = try? parser.parse(targetType: Int.self, key: CodingKeys.productCount)
        
        self.productBanner = try container.decodeIfPresent(ProductBanner.self, forKey: .productBanner)
        self.products = try container.decodeIfPresent([Product].self, forKey: .products)
        self.brand = try container.decodeIfPresent(BrandModel.self, forKey: .brand)
    }
    
    
}
