//
//  String+extension.swift
//  ShopliveCommon
//
//  Created by James Kim on 11/17/22.
//

import Foundation

public extension String {
    func versionCompare_SL(_ otherVersion: String) -> ComparisonResult {
        return self.compare(otherVersion, options: .numeric)
    }
    
    var trimmed_SL: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isEmptyText_SL: Bool {
        return self.filter{ $0 != " "}.isEmpty
    }
    
    var isSingleWordEmptyText_SL: Bool {
        return self == " " || self.isEmpty
    }
    
    var trimWhiteSpacing_SL: String {
        return self.filter{ $0 != " "}
    }
    
    var boolValue_SL: Bool? {
        switch self {
        case "true", "1", "yes":
            return true
        case "false", "0", "no":
            return false
        default:
            return nil
        }
    }
    
    func removeJWTPadding_SL() -> String {
        self.replacingOccurrences(of: "=", with: "")
    }
    
    var urlEncodedString_SL: String? {
        let customAllowedSet =  NSCharacterSet(charactersIn:"=\"#%/<>?@\\^`{|}+").inverted
        return self.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
    }
    
    var urlEncodedStringRFC3986_SL: String? {
        let unreserved = "-._~"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
    
    var dictionary_SL: [AnyHashable: Any]? {
        var dicData: Dictionary<AnyHashable, Any> = [AnyHashable: Any]()
        do {
            // 딕셔너리에 데이터 저장 실시
            dicData = try JSONSerialization.jsonObject(with: Data(self.utf8), options: []) as! [AnyHashable: Any]
        } catch {
            return nil
        }
        return dicData
    }
    
    func localizedString_SL(from: String = "Localizable", bundle: Bundle = Bundle.main, comment: String = "") -> String {
        bundle.localizedString(forKey: self, value: nil, table: from)
    }
    
    func fotmattedString_SL() -> String {
        guard let doubleSelf = Double(self) else {
            return ""
        }

        return doubleSelf.formattedString_SL(by: "yyyy.MM.dd (E) HH:mm.ss")
    }
    
    func CGFloatValue_SL() -> CGFloat? {
      guard let doubleValue = Double(self) else {
        return nil
      }

      return CGFloat(doubleValue)
    }
    
    var cgfloatValue_SL: CGFloat? {
        return CGFloat((self as NSString).floatValue)
    }

    var toJsonValue_SL: String {
        "\"\(self)\""
    }

    var base64Decoded_SL: String? {
       guard let decodedData = Data(base64Encoded: self) else { return nil }
       return String(data: decodedData, encoding: .utf8)
    }

    var base64Encoded_SL: String? {
        let plainData = data(using: .utf8)
        return plainData?.base64EncodedString()
    }
    
    var urlEncodedRFC3986: String? {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        return self.addingPercentEncoding(withAllowedCharacters: allowed)
    }
    
    func convert_SL<T>(to type: T.Type) -> T? where T: Codable {
        guard let selfData = self.data(using: .utf8) else { return nil }
        do {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            let data = try jsonDecoder.decode(T.self, from: selfData)
            return data
        } catch DecodingError.keyNotFound(let key, let context){
            //NSLog("could not find key \(key) in JSON: \(context.debugDescription)")
            return nil
        }
        catch DecodingError.valueNotFound(let key, let context){
            //NSLog("could not find key \(key) in JSON: \(context.debugDescription)")
            return nil
        }
        catch DecodingError.typeMismatch(let type, let context) {
            //NSLog("type mismatch for type \(type) in JSON: \(context.debugDescription)")
            return nil
        } catch DecodingError.dataCorrupted(let context) {
            //NSLog("data found to be corrupted in JSON: \(context.debugDescription)")
            return nil
        }
        catch let jsonError{
            //NSLog(jsonError.localizedDescription)
            return nil
        }
        catch {
            //NSLog(error.localizedDescription)
            return nil
        }
    }
}
