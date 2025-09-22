//
//  ShopLiveInAppPipConfiguration.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/6/23.
//

import Foundation
import UIKit

@objc public class ShopLiveInAppPipSize: NSObject {
    private(set) public var pipMaxSize: CGFloat?
    private(set) public var pipFixedWidth: CGFloat?
    private(set) public var pipFixedheight: CGFloat?
    
    @objc public init(pipMaxSize: CGFloat) {
        self.pipMaxSize = pipMaxSize
        self.pipFixedWidth = nil
        self.pipFixedheight = nil
    }
    
    @objc public init(pipFixedWidth: CGFloat) {
        self.pipMaxSize = nil
        self.pipFixedWidth = pipFixedWidth
        self.pipFixedheight = nil
    }
    
    @objc public init(pipFixedHeight: CGFloat) {
        self.pipMaxSize = nil
        self.pipFixedWidth = nil
        self.pipFixedheight = pipFixedHeight
    }
}



@objc public class ShopLiveInAppPipConfiguration: NSObject {
    public var useCloseButton: Bool?
    public var pipPosition: ShopLive.PipPosition?
    public var pipPinPositions: [ShopLive.PipPosition] = [ ]
    public var enableSwipeOut: Bool?
    public var pipSize: ShopLiveInAppPipSize?
    public var pipRadius: CGFloat = 10

    public init(useCloseButton: Bool? = nil, pipPosition: ShopLive.PipPosition? = nil, enableSwipeOut: Bool? = nil, pipSize: ShopLiveInAppPipSize? = nil,pipRadius: CGFloat = 10, pipPinPositions: [ShopLive.PipPosition]? = nil) {
        self.useCloseButton = useCloseButton
        self.pipPosition = pipPosition
        self.enableSwipeOut = enableSwipeOut
        self.pipSize = pipSize
        self.pipRadius = pipRadius
        if let pipPinPositions = pipPinPositions {
            self.pipPinPositions = pipPinPositions
        }
        else {
            self.pipPinPositions = [.topLeft,.topRight,.bottomLeft,.bottomRight]
        }
    }
}
