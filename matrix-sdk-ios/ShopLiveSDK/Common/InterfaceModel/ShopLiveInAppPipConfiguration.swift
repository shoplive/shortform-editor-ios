//
//  ShopLiveInAppPipConfiguration.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/6/23.
//

import Foundation
import UIKit


public class ShopLiveInAppPipConfiguration : NSObject {
    public var pipMaxSize : CGFloat?
    public var useCloseButton : Bool?
    public var pipPosition : ShopLive.PipPosition?
    public var enableSwipeOut : Bool?
    
    public init(pipMaxSize: CGFloat?, useCloseButton: Bool?,pipPosition : ShopLive.PipPosition?, enableSwipeOut : Bool?) {
        self.pipMaxSize = pipMaxSize
        self.useCloseButton = useCloseButton
        self.pipPosition = pipPosition
        self.enableSwipeOut = enableSwipeOut
    }
        
}
