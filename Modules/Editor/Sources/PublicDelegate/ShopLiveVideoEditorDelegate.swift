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
    @objc optional func onShopLiveVideoEditorVideoConvertSuccess(videoPath : String)
//    @objc optional func onShopLiveVideoEditorUploadSuccess(shortsId : String)
    @objc optional func onShopLiveVideoEditorUploadSuccess(result : ShopliveEditorResultData?)
    @objc optional func onShopLiveVideoEditorClosed()
    @objc optional func onShopLiveVideoEditorCancelled()
    @objc optional func onShopLiveVideoEditorOnEvent(name : String, payload : [String : Any]?)
}
