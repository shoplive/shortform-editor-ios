//
//  StudioAPIDefinition.swift
//  ShopliveCommon
//
//  Created by James Kim on 11/15/22.
//

import Foundation
import UIKit

private var uploadDelegates: [String: UploadProgressDelegate] = [:]
private let uploadDelegatesQueue = DispatchQueue(label: "upload.delegates.queue", attributes: .concurrent)

public protocol RawDataRepresantable {
    var rawData: Data? { set get }
    
    func getRawDataDict() -> [String: Any]?
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

public struct EmptyResponse: BaseResponsable {
    public var _s: Int?
    public var _e: String?
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
        case .delete: return "DELETE"
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
    var showRequestLog: Bool { get }
    var showResponseLog: Bool { get }
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
    
    var showRequestLog: Bool {
        return true
    }
    
    var showResponseLog: Bool {
        return false
    }
}

public final class APIDefinitionCancellable {
    init(task: URLSessionTask?) {
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
            SLLoadingIndicatorView.show()
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
    
    private func processNetworkRequest(urlString: String, handler: ((Result<ResultType, ShopLiveCommonError>) -> ())? = nil) {
        // Headers
        guard var urlComponents = URLComponents(string: urlString) else {
            let error = ShopLiveCommonErrorGenerator.generateError(errorCase: .UnexpectedError, error: nil, message: "failed to make urlComponents")
            handler?( .failure(error) )
            return
        }
        
        //utm관련된 것들은 모든 api에 query로 붙여서 보냄
        var utmQueryItems: [URLQueryItem] = []
        for (key, value) in Self.commonQueries {
            let queryItem = URLQueryItem(name: key, value: String(describing: value ))
            utmQueryItems.append(queryItem)
        }
        urlComponents.queryItems = utmQueryItems
        
        if method == .get || method == .delete {
            var queryItems: [URLQueryItem] = []
            for (key, value) in parameters ?? [:] {
                let queryItem = URLQueryItem(name: key, value: String(describing: value ))
                queryItems.append(queryItem)
            }
            urlComponents.queryItems = utmQueryItems + queryItems
        }
        
        guard let urlString = urlComponents.url?.absoluteString,
              let percentEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: percentEncoded) else { return }
        
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
        
        
        if let param = self.parameters, (method == .post || method == .put) {
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
        
        if self.showRequestLog {
            var log = "[HASSAN LOG] requestLog \n"
            log += "url: \(requestUrl.url?.absoluteString ?? "")\n"
            log += "param: \(parameters ?? [:])\n"
            log += "header: \(finalHeaders)\n"
            log += "=========================="
            ShopLiveLogger.tempLog(log)
        }
        
        let task = URLSession.shared.dataTask(with: requestUrl) { data, response, error  in
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            if let commonError = ShopLiveCommonErrorGenerator.generateErrorFromNetwork(statusCode: statusCode, error: error, responseData: data, endpoint: requestUrl.url?.path ?? "") {
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
            
            if self.showResponseLog {
                var log = "[HASSAN LOG] responseLog \n"
                log += "url: \(requestUrl.url?.absoluteString ?? "")\n"
                log += "param: \(parameters ?? [:])\n"
                log += "header: \(finalHeaders)\n"
                log += "statusCode: \(statusCode)"
                log += "body: \n"
                log += "\(String(data: data, encoding: .utf8) ?? "") \n "
                log += "=========================="
                ShopLiveLogger.tempLog(log)
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
        
        DispatchQueue.global().async {
            task.resume()
        }
        
    }
    
    
    func upload(handler: ((Result<ResultType, ShopLiveCommonError>) -> ())? = nil, progressHandler: ((Double) -> ())? = nil ) -> APIDefinitionCancellable {
        
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
        
        if urlPath.isNotEmpty_SL {
            if  urlPath.starts(with: "/") {
                urlString += urlPath
            }
            else {
                urlString += "/\(urlPath)"
            }
        }
        
        ShopLiveLogger.tempLog("URL String \(urlString)")
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method.converted
        for (key, value) in finalHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let sessionConfg = URLSessionConfiguration.default
        sessionConfg.timeoutIntervalForRequest = 999
        
        if self.showRequestLog {
            var log = "[HASSAN LOG] requestLog \n"
            log += "url: \(request.url?.absoluteString ?? "")\n"
            log += "param: \(parameters ?? [:])\n"
            log += "header: \(finalHeaders)\n"
            log += "=========================="
            ShopLiveLogger.tempLog(log)
        }
        
        let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("upload_\(UUID().uuidString).tmp")
        do {
            let bodyData = createBody(boundary: boundary)
            try bodyData.write(to: tempFileURL)
        } catch {
            let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .UnexpectedError, error: error, message: "Failed to create temporary file")
            handler?(.failure(commonError))
            return APIDefinitionCancellable(task: nil)
        }
        
        let delegateKey = UUID().uuidString
        
        let delegate = UploadProgressDelegate(
            delegateKey: delegateKey,
            progressHandler: progressHandler,
            completionHandler: { data, response, error in
                try? FileManager.default.removeItem(at: tempFileURL)
                
                uploadDelegatesQueue.async(flags: .barrier) {
                    uploadDelegates.removeValue(forKey: delegateKey)
                }
                
                if self.showResponseLog {
                    ShopLiveLogger.tempLog("[UPLOADRESPONSE] \(String(data: data ?? Data(), encoding: .utf8) ?? "no data")")
                }
                
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                if let commonError = ShopLiveCommonErrorGenerator.generateErrorFromNetwork(statusCode: statusCode, error: error, responseData: data, endpoint: request.url?.path ?? "") {
                    DispatchQueue.main.async {
                        handler?(.failure(commonError))
                    }
                    return
                }
                
                guard let data = data else {
                    let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .UnexpectedError, error: error, message: "empty response")
                    DispatchQueue.main.async {
                        handler?(.failure(commonError))
                    }
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(ResultType.self, from: data)
                    DispatchQueue.main.async {
                        handler?(.success(decoded))
                    }
                } catch let decodeError {
                    if self.showResponseLog {
                        ShopLiveLogger.tempLog("[UPLOADRESPONSE] JsonDecoding Error \(decodeError.localizedDescription)")
                    }
                    let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .FailedJSONParsing, error: decodeError, message: nil)
                    DispatchQueue.main.async {
                        handler?(.failure(commonError))
                    }
                    return
                }
                
                Self.parseHeaders(headers: (response as? HTTPURLResponse)?.allHeaderFields)
            }
        )
        
        uploadDelegatesQueue.async(flags: .barrier) {
            uploadDelegates[delegateKey] = delegate
        }
        
        let session = URLSession(configuration: sessionConfg, delegate: delegate, delegateQueue: nil)
        let task = session.uploadTask(with: request, fromFile: tempFileURL)
        
        DispatchQueue.global().async {
            task.resume()
        }
        
        return APIDefinitionCancellable(task: task)
    }
    
    
    func createBody(boundary: String) -> Data {
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
        
        if let videoWidth = self.uploadParameters["videoWidth"] as? CGFloat {
            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"videoWidth\"\(lineBreak + lineBreak)".data(using: .utf8)!)
            body.append("\(Int64(videoWidth))\(lineBreak)".data(using: .utf8)!)
        }
        
        if let videoHeight = self.uploadParameters["videoHeight"] as? CGFloat {
            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"videoHeight\"\(lineBreak + lineBreak)".data(using: .utf8)!)
            body.append("\(Int64(videoHeight))\(lineBreak)".data(using: .utf8)!)
        }
        
        if let videoDuration = self.uploadParameters["videoDuration"] as? Double {
            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"videoDuration\"\(lineBreak + lineBreak)".data(using: .utf8)!)
            body.append("\(Int64(videoDuration))\(lineBreak)".data(using: .utf8)!)
        }
        
        
        if let video = self.uploadParameters["video"] as? (path: URL, name: String) {
            body.append(boundaryPrefix.data(using: .utf8)!)
            let fileName = video.name.isEmpty ? video.path.lastPathComponent: video.name
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
        else if let imageData = self.uploadParameters["imageData"] as? Data {
            let fileName = uploadParameters["imageFileName"] as? String ?? "image"
            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(fileName)\"; filename=\"\(UUID().uuidString)\"\(lineBreak)".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\(lineBreak + lineBreak)".data(using: .utf8)!)
            body.append(imageData)
            body.append(lineBreak.data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\(lineBreak)".data(using: .utf8)!)
       
        return body
        
    }

    private static var commonQueries: [String: String] {
        var queries: [String: String] = [:]
        
        if let utmSource = ShopLiveCommon.getUtmSource(), utmSource.isNotEmpty_SL {
            queries["utm_source"] = utmSource
        }
        
        if let utmMedium = ShopLiveCommon.getUtmMedium(), utmMedium.isNotEmpty_SL {
            queries["utm_medium"] = utmMedium
        }
        
        if let utmCampaign = ShopLiveCommon.getUtmCampaign(), utmCampaign.isNotEmpty_SL {
            queries["utm_campaign"] = utmCampaign
        }
        
        if let utmContent = ShopLiveCommon.getUtmContent(), utmContent.isNotEmpty_SL {
            queries["utm_content"] = utmContent
        }
        
        return queries
    }
    
    static var defaultHeaders: [String: String] {
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
            headers[CommonKeys.x_sl_idfa] = adIdentifier
        }
        
        if let ceId = ShopLiveCommon.getCeId(), !ceId.isEmpty {
            headers[CommonKeys.x_sl_ce_id] = ceId
        }
        
        if let idfv = UIDevice.idfv_sl, idfv.isNotEmpty_SL {
            headers[CommonKeys.x_sl_idfv] = idfv
        }
        
        headers[CommonKeys.x_sl_player_device] = UIDevice.deviceIdentifier_sl
        headers[CommonKeys.x_sl_player_app_version] = UIApplication.appVersion()
        headers[CommonKeys.x_sl_player_sdk_version] = ShopLiveCommon.playerSdkVersion
        headers[CommonKeys.x_sl_player_os_version] = ShopLiveDefines.osVersion
        headers[CommonKeys.x_sl_player_os_type] = "i"
        
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
            headers[CommonKeys.x_sl_idfa] = adIdentifier
        }
        
        if let ceId = ShopLiveCommon.getCeId(), !ceId.isEmpty {
            headers[CommonKeys.x_sl_ce_id] = ceId
        }
        
        if let anonId = ShopLiveCommon.getAnonId(), !anonId.isEmpty {
            headers[CommonKeys.x_sl_anon_id] = anonId
        }
        
        if let idfv = UIDevice.idfv_sl, idfv.isNotEmpty_SL {
            headers[CommonKeys.x_sl_idfv] = idfv
        }
        
        
        headers[CommonKeys.x_sl_player_device] = UIDevice.deviceIdentifier_sl
        headers[CommonKeys.x_sl_player_app_version] = UIApplication.appVersion()
        headers[CommonKeys.x_sl_player_sdk_version] = ShopLiveCommon.playerSdkVersion
        headers[CommonKeys.x_sl_player_os_version] = ShopLiveDefines.osVersion
        headers[CommonKeys.x_sl_player_os_type] = "i"
        
        return headers
    }
    
    
    private static func parseHeaders(headers: [AnyHashable: Any]?) {
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
