//
//  ShopLiveShortformPreviewData.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 4/17/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit


public final class ShopLiveShortformPreviewData : ShopLiveShortformRelatedData {
    
    public var isMuted : Bool?
    public var isEnabledVolumeKey : Bool = false
    public var previewPosition : ShopLiveShortform.PreviewPosition?
    public var previewScale : CGFloat?
    public var previewRadius : CGFloat?
    public var previewEdgeInset : UIEdgeInsets?
    public var previewFloatingOffset : UIEdgeInsets?
    public var useCloseButton : Bool?
    public var useCustomAction : Bool = false
    public var enableSwipeOut : Bool?
    public var clickEventCallBack : (() -> ())?
    public var maxCount : Int?
    
    
    public init(shortsId: String? = nil, isEnabledVolumeKey : Bool = false, reference: String? = nil, productId: String? = nil,
                name: String? = nil, skus: [String]? = nil, url: String? = nil,
                tags: [String]? = nil, tagSearchOperator: ShopLiveTagSearchOperator? = nil, brands: [String]? = nil,
                shuffle: Bool? = nil, referrer: String? = nil, isMuted : Bool? =  nil,
                previewPosition : ShopLiveShortform.PreviewPosition? = nil, previewScale : CGFloat? = nil, previewRadius : CGFloat? = nil,
                previewEdgeInset : UIEdgeInsets? = nil,
                previewFloatingOffset : UIEdgeInsets? = nil, useCloseButton : Bool? = nil,
                enableSwipeOut : Bool? = nil, maxCount : Int? = nil , useCustomAction : Bool = false,
                clickEventCallBack : ( () -> () )? = nil ) {
        super.init(shortsId: shortsId, reference: reference, productId: productId, name: name, skus: skus, url: url, tags: tags, tagSearchOperator: tagSearchOperator, brands: brands, shuffle: shuffle, referrer: referrer)
        self.isMuted = isMuted
        self.isEnabledVolumeKey = isEnabledVolumeKey
        self.previewPosition = previewPosition
        self.previewScale = previewScale
        self.previewRadius = previewRadius
        self.previewEdgeInset = previewEdgeInset
        self.previewFloatingOffset = previewFloatingOffset
        self.useCloseButton = useCloseButton
        self.enableSwipeOut = enableSwipeOut
        self.useCustomAction = useCustomAction
        self.clickEventCallBack = clickEventCallBack
        self.maxCount = maxCount
    }
    
}
