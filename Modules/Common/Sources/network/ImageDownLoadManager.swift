//
//  ImageDownLoadManager.swift
//  ShopLiveSDKCommon
//
//  Created by sangmin han on 2023/07/31.
//

import Foundation



public class ImageDownLoaderManager {
    public static let shared = ImageDownLoaderManager()
    
    private let cache = NSCache<NSString,NSData>()
    
    
    public func download(imageUrl : URL,completion : @escaping((Result<Data,ShopLiveCommonError>) -> ()))  {
        
        if let imageData = cache.object(forKey: imageUrl.absoluteString as NSString) {
            completion(.success(imageData as Data))
            return
        }
        
        let task = URLSession.shared.downloadTask(with: imageUrl) { [unowned self] url, response, error in
            
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            if let commonError = ShopLiveCommonErrorGenerator.generateErrorFromNetwork(statusCode: statusCode, error: error, responseData: nil) {
                DispatchQueue.main.async {
                    completion( .failure(commonError))
                }
                return
            }
            
            
            guard let url = url else {
                let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .UnexpectedError, error: nil, message: "imageUrl is incorrect")
                DispatchQueue.main.async {
                    completion(.failure( commonError ))
                }
                return
            }
            
            do {
                let data = try Data(contentsOf: url)
                
                self.cache.setObject(data as NSData, forKey: imageUrl.absoluteString as NSString)
                DispatchQueue.main.async {
                    completion(.success(data))
                }
                
            }
            catch( let error ) {
                let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .UnexpectedError, error: error, message: "failed to get data from url")
                DispatchQueue.main.async {
                    completion(.failure( commonError) )
                }
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            task.resume()
        }
    }
    
    
    
    
}
