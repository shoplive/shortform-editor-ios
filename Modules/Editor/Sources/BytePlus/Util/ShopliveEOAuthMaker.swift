//
//  ShopliveEOAuthMaker.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 3/27/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import EffectOneKit
import ShopliveSDKCommon


class ShopLiveEOAuthMaker {
    static let shared = ShopLiveEOAuthMaker()
    init() {
    }
    
    
    let authFileName : String = "cloud.shoplive.dev.shortform-examples.licbag"
    //"cloud.shoplive.dev.shortform-examples"
    //"com.volcengine.effectone.inhouse.licbag"
    
    var isAuthSucceeded : Bool = false
    
    func makeAuth(completion : @escaping () -> ()) {
        let config = EOAuthorizationConfig {  initializer in
            initializer.isOnline = false
            initializer.licensePathForOffline = self.localBundle().path(forResource: self.authFileName, ofType: nil, inDirectory: "License")!
        }
        
        EOAuthorization.sharedInstance().makeAuth(with: config) { isSuccess, errMsg in
            self.isAuthSucceeded = isSuccess
            if isSuccess {
                EOSDK.initSDK {
                    EOSDK.setResourceBaseDir(EOSDK.defaultResourceDir(self.localBundle().bundlePath))
                    EOSDK.setResourceDefaultBuiltInConfig(EOSDK.defaultPanelConfigDir(self.localBundle().bundlePath))
                    completion()
                }
            }
        }
    }
    
    private func localBundle() -> Bundle {
//        let bundle = Bundle(for: type(of: self))
//        bundle.path(forResource: "EOLocalResources", ofType: "bundle")
//        return Bundle(path:bundle.path(forResource: "EOLocalResources", ofType: "bundle") ?? "") ?? Bundle.main
        
        return Bundle(path: Bundle.main.path(forResource: "EOLocalResources", ofType: "bundle") ?? "") ?? Bundle.main
    }
}
