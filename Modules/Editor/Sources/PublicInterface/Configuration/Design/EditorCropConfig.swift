//
//  EditorCropConfig.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/17/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit


public class EditorCropConfig {
    public static let global = EditorCropConfig()
    
    var videoPlayerCornerRadius : CGFloat = 20
    
    var closeButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slCloseButton.image.withRenderingMode(.alwaysTemplate)
    var closeButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    var closeButtonIconTintColor : UIColor = .white
    
    var playButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcPlay.image.withRenderingMode(.alwaysTemplate)
    var playButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    var playButtonIconTintColor : UIColor = .white
    
    var pauseButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcPause.image.withRenderingMode(.alwaysTemplate)
    var pauseButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    var pauseButtonIconTintColor : UIColor = .white
    
    var confirmButtonCornerRadius : CGFloat = 20
    var confirmButtonBackgroundColor : UIColor = .white
    var confirmButtonTextColor : UIColor =  .black
}


