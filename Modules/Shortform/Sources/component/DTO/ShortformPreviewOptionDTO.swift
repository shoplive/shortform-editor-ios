//
//  ShortformPreviewOptionDTO.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 4/17/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit


struct ShortformPreviewOptionDTO {
    let previewPosition : ShopLiveShortform.PreviewPosition?
    let previewScale : CGFloat?
    let previewEdgeInset : UIEdgeInsets?
    let previewFloatingOffset : UIEdgeInsets?
    let useCloseBtn : Bool?
    let previewIsMuted : Bool?
    let enableSwipeOut : Bool?
    
    init(previewPosition: ShopLiveShortform.PreviewPosition?, previewScale: CGFloat?, previewEdgeInset: UIEdgeInsets?, previewFloatingOffset: UIEdgeInsets?, useCloseBtn: Bool?,previewIsMuted : Bool?, enableSwipeOut : Bool?) {
        self.previewPosition = previewPosition
        self.previewScale = previewScale
        self.previewEdgeInset = previewEdgeInset
        self.previewFloatingOffset = previewFloatingOffset
        self.useCloseBtn = useCloseBtn
        self.previewIsMuted = previewIsMuted
        self.enableSwipeOut = enableSwipeOut
    }
    
    init(previewData : ShopLiveShortformPreviewData) {
        self.previewPosition = previewData.previewPosition
        self.previewScale = previewData.previewScale
        self.previewEdgeInset = previewData.previewEdgeInset
        self.previewFloatingOffset = previewData.previewFloatingOffset
        self.useCloseBtn = previewData.useCloseButton
        self.previewIsMuted = previewData.isMuted
        self.enableSwipeOut = previewData.enableSwipeOut
    }
}
