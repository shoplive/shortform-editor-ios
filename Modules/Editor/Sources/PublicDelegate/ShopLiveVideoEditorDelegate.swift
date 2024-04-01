//
//  ShopLiveVideoEditorDelegate.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 3/26/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon

@objc public protocol ShopLiveVideoEditorDelegate : AnyObject {
    @objc optional func onShopLiveVideoEditorError(error : ShopLiveCommonError)
    @objc optional func onShopLiveVideoEditorSuccess(videoPath : String)
    @objc optional func onShopLiveVideoEditorClosed()
}
