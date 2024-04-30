//
//  ShortFormConfigurationInfosManager.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/05/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon

public class ShortFormUploadConfigurationInfosManager {
    public static let shared = ShortFormUploadConfigurationInfosManager()
    private init() { }
    
    private(set) var shortsConfiguration = ShortFormUploadConfigurationInfoModel(shortformApiEndPoint: nil, datas: nil)
    
    public func getBaseUrl() -> String {
        return shortsConfiguration.shortformApiEndpoint
    }
    
    func setConfigurationURLToEmpty() {
        shortsConfiguration.baseUrl = ""
        shortsConfiguration.detailUrl = ""
    }
   
    func callShortsConfigurationAPI(accessKey : String? = nil, params : [String : Any]? = nil, completion : @escaping (Result<Void,ShopLiveCommonError>) -> ()){
        if let accessKey = accessKey {
            ShopLiveCommon.setAccessKey(accessKey: accessKey)
        }
        guard let accessKey = ShopLiveCommon.getAccessKey() else {
            completion(.failure(ShopLiveCommonErrorGenerator.generateError(errorCase: .NotInitializedAccessKey, error: nil, message:nil)))
            return
        }
        if shortsConfiguration.baseUrl != "" && shortsConfiguration.detailUrl != "" {
            completion(.success(()))
            return
        }
        let urlString = "https://config.shoplive.cloud/\(accessKey)/sdk_shorts_settings.json"
        guard let url = URL(string: urlString) else {
            let error = ShopLiveCommonErrorGenerator.generateError(errorCase: .UnexpectedError, error: nil, message: "failed to make urlComponents")
            completion(.failure(error))
            return
        }
        let task = URLSession(configuration: .default).dataTask(with: url) { [unowned self] data , response , error  in
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            if let commonError = ShopLiveCommonErrorGenerator.generateErrorFromNetwork(statusCode: statusCode, error: error, responseData: data) {
                completion( .failure(commonError) )
                return
            }
            
            if let data = data {
                if self.validateShortsConfigurationResponse(data: data) {
                    completion(.success(()))
                }
                else {
                    let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .NotInitializedShortformConfig, error: nil, message: nil)
                    completion(.failure( commonError ))
                }
            }
        }
        task.resume()
        if let params = params {
            if let ak = params["ak"] as? String {
                ShopLiveCommon.setAccessKey(accessKey: ak)
            }
            if let token = params["userJWT"] as? String {
                ShopLiveCommon.setAuthToken(authToken: token)
            }
            if let guestUid = params["guestUid"] as? String {
                ShopLiveCommon.setGuestUid(guestUid: guestUid)
            }
        }
    }
    
    private func validateShortsConfigurationResponse(data : Data) -> Bool {
        guard let configData = String(data: data, encoding: .utf8)?.convert_SL(to: ShortsSettingConfigJson.self) else {
            return false
        }
        guard let sdkConfiguration = configData.sdk, let _ = sdkConfiguration.detailUrl else {
            return false
        }
        self.setConfiguration(shortformApiEndPoint: configData.shortformApiEndpoint,
                              settingData: sdkConfiguration)
        return true
    }
    
    private func setConfiguration(shortformApiEndPoint : String?, settingData : ShortsSettingConfigSDK?){
        shortsConfiguration = ShortFormUploadConfigurationInfoModel(shortformApiEndPoint: shortformApiEndPoint, datas: settingData)
    }
    
}
