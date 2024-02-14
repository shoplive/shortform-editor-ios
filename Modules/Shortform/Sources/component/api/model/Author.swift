import Foundation
import ShopliveSDKCommon

struct Author : Codable {
	let name : String?
	let profileUrl : String?
	let action : String?
	let payload : String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self.name = try? parser.parse(targetType: String.self, key: CodingKeys.name)
        self.profileUrl = try? parser.parse(targetType: String.self, key: CodingKeys.profileUrl)
        self.action = try? parser.parse(targetType: String.self, key: CodingKeys.action)
        self.payload = try? parser.parse(targetType: String.self, key: CodingKeys.payload)
    }
    
}
