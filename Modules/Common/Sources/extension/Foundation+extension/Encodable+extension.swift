//
//  Encodable+extension.swift
//  ShopLiveSDKCommon
//
//  Created by 김우현 on 3/2/23.
//

import Foundation

public extension Encodable {
    func toDictionary_SL(_ encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
        let data = try encoder.encode(self)
        let object = try JSONSerialization.jsonObject(with: data)
        guard let json = object as? [String: Any] else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Deserialized object is not a dictionary")
            throw DecodingError.typeMismatch(type(of: object), context)
        }
        return json
    }
    
    var dictionary_SL: [String: Any]? {
      guard let data = try? JSONEncoder().encode(self) else { return nil }
      return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

public extension Decodable {
    static func decode_SL<T: Decodable>(dictionary : [String : Any]) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [.fragmentsAllowed])
        return try JSONDecoder().decode(T.self,from: data)
    }
}
