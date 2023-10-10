//
//  LiveUrlFetchAPI.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/19/23.
//

import Foundation



//MARK: - TODO 나중에 커먼 모듈 붙이면 그쪽 네트워크 모듈 이용해서 만들것
enum ShopLiveNetWorkError : Error {
    case invalidUrl
    case statusCodeError(Int)
    case other(Error)
    case noData
}

class LiveUrlFetchAPI {
    
    
    class func fetchUrl(accessKey : String, campaignKey : String, completion : @escaping(Result<LiveFetchUrlModel, ShopLiveNetWorkError>) -> ()){
        
        let urlString = "https://config.shoplive.cloud/\(accessKey)/live/\(campaignKey).json"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidUrl))
            return
        }
        
        let task = URLSession(configuration: .default).dataTask(with: url) { data, response , error  in
            if let error = error {
                completion(.failure(.other(error)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if !(200..<400 ~= httpResponse.statusCode) {
                    completion(.failure(.statusCodeError(httpResponse.statusCode)))
                    return
                }
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(LiveFetchUrlModel.self, from: data)
                completion(.success(decoded))
            }
            catch(let error) {
                completion(.failure(.other(error)))
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            task.resume()
        }
        
    }
    
    
}
