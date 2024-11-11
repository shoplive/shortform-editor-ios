//
//  ShopLiveShortformUploadDelegate.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 2023/07/27.
//

import Foundation
import ShopliveSDKCommon


@objc public protocol ShopLiveShortformEditorDelegate : AnyObject {
    @objc optional func onShopLiveShortformEditorError(error : ShopLiveCommonError)
    @objc optional func onShopLiveShortformEditorUploadSuccess(videoPath : String)
    @objc optional func onShopLiveShortformEditorClosed()
}

