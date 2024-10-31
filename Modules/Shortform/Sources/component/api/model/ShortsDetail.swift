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
    public let creator : Creator?
    public let linkButton : LinkButton?
    

    
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
        self.creator = try container.decodeIfPresent(Creator.self, forKey: .creator)
        self.linkButton = try container.decodeIfPresent(LinkButton.self, forKey: .linkButton)
    }
    
    
    
    internal func toShortsDetailData() -> ShopLiveShortformDetailData {
        var productBannerData = productBanner?.toProductBannerData()
        var productsData : [ProductData] = []
        for product in products ?? [] {
            productsData.append(product.toProductData())
        }
        var brandData = brand?.toBrandData()
        
        var data = ShopLiveShortformDetailData(title: title,descriptions: description,tags: tags,productCount: productCount,productBanner: productBannerData,products: productsData,brand: brandData)
        return data
    }
}




@objc public class ShopLiveShortformDetailData : NSObject {
    public var title : String?
    public var descriptions : String?
    public var tags : [String]?
    public var productCount : Int?
    public var productBanner: ProductBannerData?
    public var products : [ProductData]?
    public var brand : BrandData?
    
    init(title: String? = nil, descriptions: String? = nil, tags: [String]? = nil, productCount: Int? = nil, productBanner: ProductBannerData? = nil, products: [ProductData]? = nil, brand: BrandData? = nil) {
        self.title = title
        self.descriptions = descriptions
        self.tags = tags
        self.productCount = productCount
        self.productBanner = productBanner
        self.products = products
        self.brand = brand
    }
}


