//
//  ShortFormConfigurationInfosManager.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/05/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon

public class ShortFormConfigurationInfosManager {
    public static let shared = ShortFormConfigurationInfosManager()
    private init() { }
    
    private(set) var shortsConfiguration = ShortFormConfigurationInfoModel(shortformApiEndPoint: nil, datas: nil)
    
    public func getBaseUrl() -> String {
        return shortsConfiguration.shortformApiEndpoint
    }
    
    public func setConfigurationURLToEmpty() {
        shortsConfiguration.detailUrl = ""
        shortsConfiguration.shortformApiEndpoint = ""
    }
   
    //Result<isRenewd: Bool,ShopLiveCommonError>
    func callShortsConfigurationAPI(accessKey : String? = nil, params : [String : Any]? = nil, completion : @escaping (Result<Bool,ShopLiveCommonError>) -> ()){
        if let accessKey = accessKey {
            ShortFormAuthManager.shared.setAccessKey(accessKey: accessKey)
        }
        guard let accessKey = ShortFormAuthManager.shared.getAccessKey() else {
            
            completion( .failure(
                ShopLiveCommonErrorGenerator.generateError(errorCase: .NotInitializedAccessKey, error: nil, message:nil)))
            return
        }
        if shortsConfiguration.shortformApiEndpoint != "" && shortsConfiguration.detailUrl != ""  {
            completion(.success(false))
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
                    DispatchQueue.main.async(flags: .barrier) {
                        completion(.success(true))
                    }
                }
                else {
                    let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .NotInitializedShortformConfig, error: nil, message: nil)
                    DispatchQueue.main.async {
                        completion( .failure( commonError ) )
                    }
                }
            }
        }
        DispatchQueue.global(qos: .background).async {
            task.resume()
        }
        if let params = params {
            ShortFormAuthManager.shared.setAuthInfo(params)
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
        shortsConfiguration = ShortFormConfigurationInfoModel( shortformApiEndPoint: shortformApiEndPoint, datas: settingData)
    }
    
    func setWhenMutedStart(isMuted : Bool){
        self.shortsConfiguration.mutedWhenStart = isMuted
    }
}
