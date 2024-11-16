//
//  ShopLiveCoverPickerConfiguration.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit


public final class ShopLiveCoverPickerVisibleActionButton {
    public var isUsedCropButton : Bool = true
    
    public init(isUsedCropButton: Bool = true) {
        self.isUsedCropButton = isUsedCropButton
    }
}

public final class ShopLiveCoverPickerConfiguration {
    public var cropOption : ShopLiveShortFormEditorAspectRatio = .init()
    public var visibleActionButton : ShopLiveCoverPickerVisibleActionButton = .init(isUsedCropButton: true)
    
    public init(cropOption : ShopLiveShortFormEditorAspectRatio,
                visibleActionButton : ShopLiveCoverPickerVisibleActionButton) {
        self.cropOption = cropOption
        self.visibleActionButton = visibleActionButton
    }
}
