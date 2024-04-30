//
//  ShopLiveEvent.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 4/11/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit




public struct ShopLiveEvent {
    
    public static func sendConversionEvent(data : ShopLiveConversionData) {
        
        ShopLiveCommonConfigurationManager.shared.callHostConfigAPI { result in
            switch result {
            case .success(_):
                let currentMilliSeconds = Int(Date().timeIntervalSince1970 * 1000)
                let customJsonString = data.custom?.toJSONString_SL()
                
                
                
                ShopLiveConversionEventAPI(anonId: ShopLiveCommon.getAnonId(),
                                           custom: customJsonString,
                                           env: "SDK",
                                           ceId: ShopLiveCommon.getCeId(),
                                           idfv: UIDevice.idfv_sl,
                                           idfa: ShopLiveCommon.getAdIdentifier(),
                                           osType: "i",
                                           products: data.products?.map{ $0.toShopLiveEventProduct() },
                                           referrer: data.referrer,
                                           type : data.type,
                                           userId : ShopLiveCommon.getUser()?.userId,
                                           orderId: data.orderId,
                                           createdAt: currentMilliSeconds ).request { result in
                    
                }
            case .failure(_):
                break
            }
            
        }
    }
    
}
