//
//  ShopLiveInAppConfigurationObjc.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 1/10/24.
//

import Foundation
import UIKit

@objc public class ShopLiveInAppConfigurationObjc : ShopLiveInAppPipConfiguration {
    
    @objc public var _pipSize : ShopLiveInAppPipSize? {
        set {
            super.pipSize = newValue
        }
        get {
            return super.pipSize
        }
    }
    
    @objc public var _useCloseButton : Bool {
        set {
            super.useCloseButton = newValue
        }
        get {
            return super.useCloseButton ?? false
        }
    }
    
    
    @objc public var _pipPosition : ShopLive.PipPosition {
        set {
            super.pipPosition = newValue
        }
        get {
            return pipPosition ?? .bottomRight
        }
    }
    
    @objc public var _enableSwipeOut: Bool {
        set {
            super.enableSwipeOut = newValue
        }
        get {
            return self.enableSwipeOut ?? false
        }
        
    }
    
    @objc public init(useCloseButton : Bool, pipPosition : ShopLive.PipPosition, enableSwipeOut : Bool,pipSize : ShopLiveInAppPipSize) {
        super.init(useCloseButton: useCloseButton, pipPosition: pipPosition, enableSwipeOut: enableSwipeOut, pipSize: pipSize)
    }
    
}
