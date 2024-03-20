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
}


//youtube 한정
public struct Creator : Codable {
    
    var uid : String?
    var userId : String?
    var displayUserId : String?
    var customerCreatorType : String?
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self.uid = try? parser.parse(targetType: String.self, key: CodingKeys.uid)
        self.userId = try? parser.parse(targetType: String.self, key: CodingKeys.userId)
        self.displayUserId = try? parser.parse(targetType: String.self, key: CodingKeys.displayUserId)
        self.customerCreatorType = try? parser.parse(targetType: String.self, key: CodingKeys.customerCreatorType)
    }
    
}

//youtube 한정
public struct LinkButton : Codable {
    
    var imageUrl : String?
    var text : String?
    var scheme : String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self.imageUrl = try? parser.parse(targetType: String.self, key: CodingKeys.imageUrl)
        self.text = try? parser.parse(targetType: String.self, key: CodingKeys.text)
        self.scheme = try? parser.parse(targetType: String.self, key: CodingKeys.scheme)
    }
    
}
