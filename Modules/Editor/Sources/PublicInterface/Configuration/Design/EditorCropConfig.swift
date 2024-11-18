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
    
    public var videoPlayerCornerRadius : CGFloat = 20
    
    public var closeButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slCloseButton.image.withRenderingMode(.alwaysTemplate)
    public var closeButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    public var closeButtonIconTintColor : UIColor = .white
    
    public var playButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcPlay.image.withRenderingMode(.alwaysTemplate)
    public var playButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    public var playButtonIconTintColor : UIColor = .white
    
    public var pauseButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcPause.image.withRenderingMode(.alwaysTemplate)
    public var pauseButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    public var pauseButtonIconTintColor : UIColor = .white
    
    public var confirmButtonCornerRadius : CGFloat = 20
    public var confirmButtonBackgroundColor : UIColor = .white
    public var confirmButtonTextColor : UIColor =  .black
}


