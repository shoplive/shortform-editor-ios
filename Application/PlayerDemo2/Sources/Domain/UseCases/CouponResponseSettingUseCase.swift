//
//  CouponResponseSettingUseCase.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/12/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import ShopLiveSDK


protocol CouponResponseSettingUseCase {
    func setSuccessResults(message : String, status : ShopLiveResultStatus, alertType : ShopLiveResultAlertType)
    func setFailedResults(message : String, status : ShopLiveResultStatus, alertType : ShopLiveResultAlertType)
    
    
    func getSuccessResults() -> (message : String?, status : ShopLiveResultStatus?, alertType : ShopLiveResultAlertType?)
    func getFailedResults() -> (message : String?, status : ShopLiveResultStatus?, alertType : ShopLiveResultAlertType?)
}




final class DefaultCouponResponseSettingUseCase : CouponResponseSettingUseCase {
    
    private let sdkConfigurationRepository : any OptionSettingRepository<SDKConfiguration>
    private let sdkConfigurationMapperUseCase : SDKConfigurationMapperUseCase
    
    private var sdkConfiguration : SDKConfiguration?
    
    init(sdkConfigurationRepository: any OptionSettingRepository<SDKConfiguration>,
         sdkConfigurationMapperUseCase : SDKConfigurationMapperUseCase) {
        self.sdkConfigurationRepository = sdkConfigurationRepository
        self.sdkConfigurationMapperUseCase = sdkConfigurationMapperUseCase
        loadSDKConfiguration()
    }
    
    private func loadSDKConfiguration() {
        self.sdkConfiguration = sdkConfigurationRepository.getOptions()
    }

    
    func setSuccessResults(message: String, status: ShopLiveResultStatus, alertType: ShopLiveResultAlertType) {
        guard let sdkConfig = sdkConfiguration else { return }
        var newValue = sdkConfig
        newValue.downloadCouponSuccessMessage = message
        newValue.downloadCouponSucessStatus = status
        newValue.downloadCouponSuccessAlertType = alertType
        self.sdkConfiguration = newValue
        sdkConfigurationRepository.saveOptions(data: newValue)
    }
    
    func setFailedResults(message: String, status: ShopLiveResultStatus, alertType: ShopLiveResultAlertType) {
        guard let sdkConfig = sdkConfiguration else { return }
        var newValue = sdkConfig
        newValue.downloadCoupontFailedMessage = message
        newValue.downloadCouponFailedStatus = status
        newValue.downloadCouponFailedAlertType = alertType
        self.sdkConfiguration = newValue
        sdkConfigurationRepository.saveOptions(data: newValue)
    }
    
    func getFailedResults() -> (message: String?, status: ShopLiveResultStatus?, alertType: ShopLiveResultAlertType?) {
        return (sdkConfiguration?.downloadCoupontFailedMessage,sdkConfiguration?.downloadCouponFailedStatus,sdkConfiguration?.downloadCouponFailedAlertType)
    }
    
    func getSuccessResults() -> (message: String?, status: ShopLiveResultStatus?, alertType: ShopLiveResultAlertType?) {
        return (sdkConfiguration?.downloadCouponSuccessMessage,sdkConfiguration?.downloadCouponSucessStatus,sdkConfiguration?.downloadCouponSuccessAlertType)
    }
    
}
