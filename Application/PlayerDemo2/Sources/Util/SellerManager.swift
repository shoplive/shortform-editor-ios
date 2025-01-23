//
//  SellerManager.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//


import Foundation
import UIKit
import ShopLiveSDK


class SellerManager {
    static let shared = SellerManager()
    
    
    
    func parseCommand(command : String, payload : [String : Any]?) {
        guard let payload = payload else { return }
        switch command {
        case "ON_CLICK_SELLER":
            self.onOnClickSeller(payload: payload)
        case "ON_CLICK_VIEW_SELLER_STORE":
            self.onClickViewSellerStore(payload: payload)
        case "ON_CLICK_SELLER_SUBSCRIPTION":
            self.onClickSellerSubscription(payload: payload)
        default:
            break
        }
    }
    
    
    private func onOnClickSeller(payload : [String : Any]) {
        var temp = payload
        temp["saved"] = true
        ShopLive.sendCommandMessage(command: "SET_SELLER_SAVED_STATE", payload: temp)
    }
    
    private func onClickViewSellerStore(payload : [String : Any]) {
        var sellerStoreData = SellerStoreData(dict: payload)
        if let urlString = sellerStoreData.seller?.storeUrl, let url = URL(string: urlString)  {
            UIApplication.shared.canOpenURL(url)
        }
    }
    
    private func onClickSellerSubscription(payload : [String : Any]) {
        var sellerSubsciptionData = SellerSubscriptionData(dict: payload)
        var sellerSavedData : [String : Any] = ["saved" : !(sellerSubsciptionData.saved ?? true)]
        
        ShopLive.sendCommandMessage(command: "SET_SELLER_SAVED_STATE", payload: sellerSavedData)
        ShopLivePlayerToastCommandManager.shared.showToast(message: "SET_SELLER_SAVED_DATA: \(!(sellerSubsciptionData.saved ?? true))")
    }
}


//command=ON_CLICK_VIEW_SELLER_STORE,
//data=
//{
//  "campaignKey": "684f5809a73e",
//  "campaignTitle": "티몬 Test Seller 방송2",
//  "campaignStatus": "ONAIR",
//  "seller": {
//    "sellerId": 3223,
//    "name": "티몬 Test Seller",
//    "sellerIdentifier": "TMON_TEST_SELLER",
//    "profileUrl": "https://image.shoplive.cloud/YWASvb9yHCl84uxSOYty/541c882b-a747-44d5-aa9b-d86f74da4526.jpg",
//    "storeUrl": "https://www.tmon.co.kr/",
//    "description": "티몬 테스트 셀러.",
//    "schemes": null
//  }
//}



//command=ON_CLICK_SELLER_SUBSCRIPTION,
//data=
//{
//  "campaignKey": "684f5809a73e",
//  "campaignTitle": "티몬 Test Seller 방송2",
//  "campaignStatus": "ONAIR",
//  "seller": {
//    "sellerId": 3223,
//    "name": "티몬 Test Seller",
//    "sellerIdentifier": "TMON_TEST_SELLER",
//    "profileUrl": "https://image.shoplive.cloud/YWASvb9yHCl84uxSOYty/541c882b-a747-44d5-aa9b-d86f74da4526.jpg",
//    "storeUrl": "https://www.tmon.co.kr/",
//    "description": "티몬 테스트 셀러.",
//    "schemes": null
//  },
//  "saved": false,
//  "isLogin": false
//}

