//
//  ShopLiveInAppConfigurationObjc.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 1/10/24.
//

import Foundation
import UIKit

@objc public class ShopLiveInAppConfigurationObjc : ShopLiveInAppPipConfiguration {
    @objc public var _pipMaxsize : Float {
        set {
            super.pipMaxSize = CGFloat(newValue)
        }
        get{
            return Float(super.pipMaxSize ?? 0)
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
    
    @objc public init(pipMaxSize : Float, userCloseButton : Bool, pipPosition : ShopLive.PipPosition, enableSwipeOut : Bool) {
        super.init(pipMaxSize: CGFloat(pipMaxSize) , useCloseButton: userCloseButton, pipPosition: pipPosition, enableSwipeOut: enableSwipeOut)
    }
    
    
}
