//
//  StudioAPIDefinition.swift
//  ShopliveCommon
//
//  Created by James Kim on 11/15/22.
//

import Foundation
import UIKit



public protocol RawDataRepresantable {
    var rawData: Data? { set get }
    
    func getRawDataDict() -> [String : Any]?
}

public protocol BaseResponsable: Codable {
    var _s: Int? { set get }
    var _e: String? { set get }
}

public extension BaseResponsable {
    var isBaseModel: Bool {
        return _s != nil && _e != nil
    }
    
    var isSuccess: Bool {
        return _s == 0
    }
}

public struct BaseResponse: BaseResponsable {
    public var _s: Int?
    public var _e: String?
}

public struct EmptyResponse : BaseResponsable {
    public var _s : Int?
    public var _e : String?
}

public enum HTTPVersion: String {
    case v1, v2
}

public enum SLHTTPMethod {
    case get
    case post
    case put
    case delete
    
    var converted: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .delete: return "DELTE"
        }
    }
}

public protocol APIDefinition {
    associatedtype ResultType: BaseResponsable
    var baseUrl: String { get }
    var urlPath: String { get }
    var method: SLHTTPMethod { get }
    var parameters: [String:Any]? { get }
    var uploadParameters: [String: Any] { get }
    var timeoutInterval: Double { get }
    var headers: [String:String] { get }
    var version: HTTPVersion { get }
    var needToShowLoadingIndicator: Bool { get }
}

public extension APIDefinition {
    var method: SLHTTPMethod {
        return .get
    }
    
    var baseUrl: String {
        guard let generator = ShopLiveCommon.baseURLGenerator else { return "" }
        return generator(version)
    }
    
    var parameters: [String:Any]? {
        return nil
    }
    
    var timeoutInterval: Double {
        return 5
    }
    
    var headers: [String:String] {
        return [:]
    }
    
    var version: HTTPVersion {
        return .v1
    }
    
    var needToShowLoadingIndicator: Bool {
        return false
    }
    
    var uploadParameters: [String: Any] {
        return [:]
    }
}

public final class APIDefinitionCancellable {
    init(task: URLSessionTask) {
        self.task = task
    }
    
    public func cancel() {
        task?.cancel()
        task = nil
    }
    
    private weak var task: URLSessionTask?
}

public extension APIDefinition {
    
    func request(handler: ((Result<ResultType, ShopLiveCommonError>) -> ())? = nil ) {
        if needToShowLoadingIndicator {
            LoadingIndicatorView.show()
        }
        
        var urlString = baseUrl
        
        if urlPath.isNotEmpty_SL {
            if  urlPath.starts(with: "/") {
                urlString += urlPath
            }
            else {
                urlString += "/\(urlPath)"
            }
        }
        
        self.processNetworkRequest(urlString: urlString, handler: handler)
    }
    
    private func processNetworkRequest(urlString : String, handler : ((Result<ResultType, ShopLiveCommonError>) -> ())? = nil) {
        // Headers
        guard var urlComponents = URLComponents(string: urlString) else {
            let error = ShopLiveCommonErrorGenerator.generateError(errorCase: .UnexpectedError, error: nil, message: "failed to make urlComponents")
            handler?( .failure(error) )
            return
        }
        
        if method == .get || method == .delete {
            var queryItems : [URLQueryItem] = []
            for (key, value) in parameters ?? [:] {
                let queryItem = URLQueryItem(name: key, value: String(describing: value ))
                queryItems.append(queryItem)
            }
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            return
        }
        
        var requestUrl = URLRequest(url: url)
        requestUrl.httpMethod = method.converted
        
        var finalHeaders = Self.defaultHeaders
        for (key, value) in headers {
            guard value.isNotEmpty_SL else {
                finalHeaders[key] = nil
                continue
            }
            finalHeaders[key] = value
        }
        
        for (key,value) in finalHeaders {
            requestUrl.setValue(value, forHTTPHeaderField: key)
        }
        
        
        if method == .post || method == .put {
            do {
                let httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                requestUrl.httpBody = httpBody
            }
            catch(let error) {
                let err = ShopLiveCommonErrorGenerator.generateError(errorCase: .FailedJSONParsing, error: error, message: nil)
                handler?( .failure(err) )
                return
            }
        }
        
        
        let task = URLSession.shared.dataTask(with: requestUrl) { data, response, error  in
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            if let commonError = ShopLiveCommonErrorGenerator.generateErrorFromNetwork(statusCode: statusCode, error: error, responseData: data) {
                DispatchQueue.main.async {
                    handler?( .failure(commonError) )
                }
                return
            }
            
            guard let data = data else {
                let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .FailedNetwork, error: nil, message: "empty response")
                handler?( .failure( commonError ) )
                return
            }
            
            if ResultType.self == EmptyResponse.self {
                let emptyResponse = EmptyResponse(_s: 0, _e: nil)
                DispatchQueue.main.async {
                    handler?(.success(emptyResponse as! Self.ResultType))
                }
            }
            else {
                do {
                    var decoder = JSONDecoder()
                    if let userInfoKey = CodingUserInfoKey(rawValue: "rawData") {
                        decoder.userInfo = [ userInfoKey: data]
                    }

                    var decoded = try decoder.decode(ResultType.self, from: data)

                    DispatchQueue.main.async {
                        handler?(.success(decoded))
                    }
                }
                catch( let error) {
                    let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .FailedJSONParsing, error: error, message: nil)
                    DispatchQueue.main.async {
                        handler?( .failure(commonError) )
                    }
                    return
                }
            }

            Self.parseHeaders(headers: (response as? HTTPURLResponse)?.allHeaderFields)
            
        }
        
        DispatchQueue.global(qos: .background).async {
            task.resume()
        }
        
    }
    
    
    
    
    func upload(handler : ((Result<ResultType, ShopLiveCommonError>) -> ())? = nil ) {
        
        // Headers
        var finalHeaders = Self.defaultHeaders
        for (key, value) in headers {
            guard value.isNotEmpty_SL else {
                finalHeaders[key] = nil
                continue
            }
            finalHeaders[key] = value
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        finalHeaders["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        
        var urlString = baseUrl
       
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        for (key, value) in finalHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = createBody(boundary: boundary)
        
        let task = URLSession.shared.dataTask(with: request) { data , response , error  in
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            if let commonError = ShopLiveCommonErrorGenerator.generateErrorFromNetwork(statusCode: statusCode, error: error, responseData: data) {
                DispatchQueue.main.async {
                    handler?( .failure(commonError) )
                }
                return
            }
            
            guard let data = data else {
                let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .UnexpectedError, error: error, message: "empty response")
                handler?( .failure(commonError) )
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(ResultType.self, from: data)
                DispatchQueue.main.async {
                    handler?(.success(decoded))
                }
            }
            catch( let error) {
                let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .FailedJSONParsing, error: error, message: nil)
                DispatchQueue.main.async {
                    handler?( .failure(commonError) )
                }
                return
            }
            
            Self.parseHeaders(headers: (response as? HTTPURLResponse)?.allHeaderFields)
            
           
        }
        
        DispatchQueue.global(qos: .background).async {
            task.resume()
        }
        
        
    }
    
    
    func createBody(boundary : String) -> Data {
        var body = Data()
        let lineBreak = "\r\n"
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters ?? [:] {
            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)".data(using: .utf8)!)
            body.append("\(value)\(lineBreak)".data(using: .utf8)!)
        }
        
        if let sessionSecret = self.uploadParameters["sessionSecret"] as? String {
            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"sessionSecret\"\(lineBreak + lineBreak)".data(using: .utf8)!)
            body.append("\(sessionSecret)\(lineBreak)".data(using: .utf8)!)
        }
        
        
        if let video = self.uploadParameters["video"] as? (path: URL, name: String) {
            body.append(boundaryPrefix.data(using: .utf8)!)
            let fileName = video.name.isEmpty ? video.path.lastPathComponent : video.name
            body.append("Content-Disposition: form-data; name=\"video\"; filename=\"\(fileName)\"\(lineBreak)".data(using: .utf8)!)
            body.append("Content-Type: video/mp4\(lineBreak + lineBreak)".data(using: .utf8)!)
            
            do {
                let videoData = try Data(contentsOf: video.path)
                body.append(videoData)
            }
            catch(let error) {
                print(error)
            }
            body.append(lineBreak.data(using: .utf8)!)
        }
        
        
        if let image = self.uploadParameters["image"] as? URL {
            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(image)\"\(lineBreak)".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\(lineBreak + lineBreak)".data(using: .utf8)!)
            do {
                let imageData = try Data(contentsOf: image)
                body.append(imageData)
            }
            catch(let error) {
                print(error)
            }
            
            body.append(lineBreak.data(using: .utf8)!)
        }
        
        
        
        body.append("--\(boundary)--\(lineBreak)".data(using: .utf8)!)
        
        return body
    }
    
    private static var defaultHeaders: [String: String] {
        var headers: [String: String] = [
            "Content-Type": "application/json"
        ]
        
        if let token = ShopLiveCommon.getAuthToken(), token.isNotEmpty_SL {
            headers[CommonKeys.Authorization] = "Bearer \(token)"
        }
        
        if let guestUid = ShopLiveCommon.getGuestUid(), guestUid.isNotEmpty_SL {
            headers[CommonKeys.x_sl_guest_uid] = guestUid
        }
        
        if let adIdentifier = ShopLiveCommon.getAdIdentifier(), adIdentifier.isNotEmpty_SL {
            headers[CommonKeys.x_sl_ad_identifier] = adIdentifier
        }
        
        if let utmSource = ShopLiveCommon.getUtmSource(), utmSource.isNotEmpty_SL {
            headers[CommonKeys.x_sl_utm_source] = utmSource
        }
        
        if let utmMedium = ShopLiveCommon.getUtmMedium(), utmMedium.isNotEmpty_SL {
            headers[CommonKeys.x_sl_utm_medium] = utmMedium
        }
        
        if let utmCampaign = ShopLiveCommon.getUtmCampaign(), utmCampaign.isNotEmpty_SL {
            headers[CommonKeys.x_sl_utm_campaign] = utmCampaign
        }
        
        if let utmContent = ShopLiveCommon.getUtmContent(), utmContent.isNotEmpty_SL {
            headers[CommonKeys.x_sl_utm_content] = utmContent
        }
        
        headers[CommonKeys.x_sl_player_device] = UIDevice.deviceIdentifier_sl
        
        
        return headers
    }
    
    private static var postHeaders: [String: String] {
        var headers: [String: String] = [
            "Content-Type": "application/json"
        ]
        
        if let token = ShopLiveCommon.getAuthToken(), token.isNotEmpty_SL {
            headers[CommonKeys.Authorization] = "Bearer \(token)"
        }
        
        if let guestUid = ShopLiveCommon.getGuestUid(), guestUid.isNotEmpty_SL {
            headers[CommonKeys.x_sl_guest_uid] = guestUid
        }
        
        if let adIdentifier = ShopLiveCommon.getAdIdentifier(), adIdentifier.isNotEmpty_SL {
            headers[CommonKeys.x_sl_ad_identifier] = adIdentifier
        }
        
        if let utmSource = ShopLiveCommon.getUtmSource(), utmSource.isNotEmpty_SL {
            headers[CommonKeys.x_sl_utm_source] = utmSource
        }
        
        if let utmMedium = ShopLiveCommon.getUtmMedium(), utmMedium.isNotEmpty_SL {
            headers[CommonKeys.x_sl_utm_medium] = utmMedium
        }
        
        if let utmCampaign = ShopLiveCommon.getUtmCampaign(), utmCampaign.isNotEmpty_SL {
            headers[CommonKeys.x_sl_utm_campaign] = utmCampaign
        }
        
        if let utmContent = ShopLiveCommon.getUtmContent(), utmContent.isNotEmpty_SL {
            headers[CommonKeys.x_sl_utm_content] = utmContent
        }
        
        headers[CommonKeys.x_sl_player_device] = UIDevice.deviceIdentifier_sl
        
        return headers
    }
    
    
    private static func parseHeaders(headers: [AnyHashable : Any]?) {
        guard let headers = headers else { return }
        if let authorization = headers["Authorization"] as? String {
            let token = authorization.replacingOccurrences(of: "Bearer", with: "").trimmed_SL
            ShopLiveCommon.setAccessKey(accessKey: token)
        }
        
        if let guestUid = headers["x-sl-guest-uid"] as? String {
            ShopLiveCommon.setGuestUid(guestUid: guestUid)
        }
    }
}

