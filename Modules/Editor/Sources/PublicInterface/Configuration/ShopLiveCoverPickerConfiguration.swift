//
//  ShopLiveCoverPickerConfiguration.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit

public enum SLCoverEditOptions : CaseIterable {
   case crop
}
public final class ShopLiveCoverPickerVisibleActionButton {
    public var editOptions : [SLCoverEditOptions] = [.crop]
    
    public init(editOptions: [SLCoverEditOptions] = [.crop]) {
        self.editOptions = editOptions
    }
}

public final class ShopLiveCoverPickerConfiguration {
    public var cropOption : ShopLiveShortFormEditorAspectRatio = .init()
    public var visibleActionButton : ShopLiveCoverPickerVisibleActionButton = .init()
    
    public init(cropOption : ShopLiveShortFormEditorAspectRatio,
                visibleActionButton : ShopLiveCoverPickerVisibleActionButton) {
        self.cropOption = cropOption
        self.visibleActionButton = visibleActionButton
    }
}
