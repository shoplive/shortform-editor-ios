//
//  ShopLiveInAppPipConfiguration.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/6/23.
//

import Foundation
import UIKit

@objc public class ShopLiveInAppPipSize : NSObject {
    private(set) public var pipMaxSize : CGFloat?
    private(set) public var pipFixedWidth : CGFloat?
    private(set) public var pipFixedheight : CGFloat?
    
    public init(pipMaxSize : CGFloat?){
        self.pipMaxSize = pipMaxSize
    }
    
    public init(pipFixedWidth : CGFloat?) {
        self.pipFixedWidth = pipFixedWidth
    }
    
    public init(pipFixedHeight : CGFloat?){
        self.pipFixedheight = pipFixedHeight
    }
}



@objc public class ShopLiveInAppPipConfiguration : NSObject {
    public var useCloseButton : Bool?
    public var pipPosition : ShopLive.PipPosition?
    public var enableSwipeOut : Bool?
    public var pipSize : ShopLiveInAppPipSize?
    
    public init(useCloseButton: Bool? = nil, pipPosition: ShopLive.PipPosition? = nil, enableSwipeOut: Bool? = nil, pipSize: ShopLiveInAppPipSize? = nil) {
        self.useCloseButton = useCloseButton
        self.pipPosition = pipPosition
        self.enableSwipeOut = enableSwipeOut
        self.pipSize = pipSize
    }
}
