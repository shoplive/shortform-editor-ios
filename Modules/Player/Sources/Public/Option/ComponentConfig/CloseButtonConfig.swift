//
//  CloseButtonConfig.swift
//  ShopLiveSDK
//
//  Created by Kio on 12/1/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

@objc public enum ShopLiveBlurMaskStyle: Int {
    case normal
    case solid
    case inner
    case outer
}

@objc public class CloseButtonConfig: NSObject {
    public var position: ShopLive.PreviewCloseButtonPositionConfig?
    public var width: CGFloat?
    public var height: CGFloat?
    public var offsetX: CGFloat?
    public var offsetY: CGFloat?
    public var color: UIColor?
    public var shadowOffsetX: CGFloat?
    public var shadowOffsetY: CGFloat?
    public var shadowBlur: CGFloat?
    public var shadowBlurStyle: ShopLiveBlurMaskStyle?
    public var shadowColor: UIColor?
    public var imageStr: String?
    
    public init(
        position: ShopLive.PreviewCloseButtonPositionConfig? = .topLeft,
        width: CGFloat? = 30,
        height: CGFloat? = 30,
        offsetX: CGFloat? = 5,
        offsetY: CGFloat? = 5,
        color: UIColor? = .white,
        shadowOffsetX: CGFloat? = nil,
        shadowOffsetY: CGFloat? = nil,
        shadowBlur: CGFloat? = nil,
        shadowBlurStyle: ShopLiveBlurMaskStyle? = nil,
        shadowColor: UIColor? = nil,
        imageStr: String? = nil
    ) {
        self.position = position
        self.width = width
        self.height = height
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.color = color
        self.shadowOffsetX = shadowOffsetX
        self.shadowOffsetY = shadowOffsetY
        self.shadowBlur = shadowBlur
        self.shadowBlurStyle = shadowBlurStyle
        self.shadowColor = shadowColor
        self.imageStr = imageStr
        super.init()
    }
}
