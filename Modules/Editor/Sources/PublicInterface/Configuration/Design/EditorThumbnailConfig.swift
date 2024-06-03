//
//  EditorThumbnailConfig.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/17/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit


public class EditorThumbnailConfig {
    public static let global = EditorThumbnailConfig()
    
    var videoPlayerCornerRadius : CGFloat = 20
    
    var closeButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slBackArrow.image.withRenderingMode(.alwaysTemplate)
    var closeButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    var closeButtonIconTintColor : UIColor = .white
    
    var confirmButtonBackgroundColor : UIColor = .white
    var confirmButtonTextColor : UIColor = .black
    var confirmButtonCornerRadius : CGFloat = 20
    
    
    var thumbnailSliderCornerRadius : CGFloat = 8
    var thumbnailSliderThumbViewBorderColor : UIColor = .white
    
    
    var cameraRollButtonBackgroundColor : UIColor = .white
    var cameraRollButtonTextColor : UIColor = .black
    var cameraRollButtonCornerRadius : CGFloat = 20
    
    
    var cancelPopupCornerRadius : CGFloat = 16
    var cancelPopupButtonCornerRadius : CGFloat = 10
    var cancelPopupCloseButtonBackgroundColor : UIColor = .white
    var cancelPopupCloseButtonTextColor : UIColor = .black
    var cancelPopupConfirmButtonBackgroundColor : UIColor = .init(red: 51, green: 51, blue: 51)
    var cancelPopupConfirmButtonTextColor : UIColor = .white
}
