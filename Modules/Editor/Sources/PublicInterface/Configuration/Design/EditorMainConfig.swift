//
//  EditorMainConfig.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/17/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit

public class EditorMainConfig {
    public static let global = EditorMainConfig()
    
    var videoPlayerCornerRadius : CGFloat = 24
    
    var backButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slBackArrow.image.withRenderingMode(.alwaysTemplate)
    var backButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    var backButtonIconTintColor : UIColor = .white
    
    var nextButtonCornerRadius : CGFloat = 20
    
    var videoSpeedButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcSpeedometer.image.withRenderingMode(.alwaysTemplate)
    var videoSpeedButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 13, right: 10)
    var videoSpeedButtonIconTintColor : UIColor = .white
    
    var videoSoundButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcEditUnmute.image.withRenderingMode(.alwaysTemplate)
    var videoSoundButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    var videoSoundButtonIconTintColor : UIColor = .white
    
    var videoCropButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcCrop.image.withRenderingMode(.alwaysTemplate)
    var videoCropButtonIconPadding : UIEdgeInsets =  UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    var videoCropButtonIconTintColor : UIColor = .white
    
    var videoFilterButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcFilter.image.withRenderingMode(.alwaysTemplate)
    var videoFilterButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    var videofilterButtonIconTintColor : UIColor = .white
    
    var sliderIndicatorCornerRadius : CGFloat = 2
}



