//
//  ShopLiveShortformConfigurationManager.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 11/2/23.
//

import Foundation




class ShopLiveEditorConfigurationManager {
    static let shared = ShopLiveEditorConfigurationManager()
    
    var videoCropOption : SLEditorAspectRatio = ShopLiveShortFormEditorAspectRatio()
    var visibleContents : SLVisibleContent  = ShopLiveShortFormEditorVisibleContent()
    var videoTrimOption : SLEditorTrimOption = ShopLiveShortFormEditorTrimOption()
    
}
