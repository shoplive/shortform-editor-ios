//
//  ShopLiveCommonConfigurationManager.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 4/23/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation


public class ShopLiveCommonConfigurationManager {
    public static let shared = ShopLiveCommonConfigurationManager()
    
    
    private var hostConfigModel : HostConfigModel?
    
    public func getShortformEventTraceHostUrl() -> String {
        return hostConfigModel?.shortform?.eventTraceHost ?? ""
    }
    
    
    public func clearHostConfigModel() {
        hostConfigModel = nil
    }
    
    func setHostConfigModel(model : HostConfigModel) {
        self.hostConfigModel = model
    }
    
    
    public func callHostConfigAPI(completion : @escaping ( (Result<Void,ShopLiveCommonError>) -> () )) {
        if hostConfigModel != nil {
            completion(.success(()) )
            return
        }
        
        guard let accesskey = ShopLiveCommon.getAccessKey() else {
            completion( .failure(
                ShopLiveCommonErrorGenerator.generateError(errorCase: .NotInitializedAccessKey, error: nil, message:nil)))
            return
        }
        
        HostConfigAPI()
            .request { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.hostConfigModel = response
                    ShopLiveConversionEventAPI.baseurl = response.campaign?.conversionTrackingHost ?? ""
                    completion(.success(()) )
                case .failure(let error):
                    completion( .failure(error) )
                }
            }
    }
    
    
}
