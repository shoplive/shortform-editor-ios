//
//  ShopLiveShortformUploadDelegate.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 2023/07/27.
//

import Foundation
import ShopliveSDKCommon
import UIKit


@objc public protocol ShopLiveShortformEditorDelegate : AnyObject {
    @objc optional func onShopLiveShortformEditorError(error : ShopLiveCommonError)
    @objc optional func onShopLiveShortformEditorVideoConvertSuccess(videoPath : String)
    @objc optional func onShopLiveShortformEditorCoverImageSuccess(image : UIImage?)
    @objc optional func onShopLiveShortformEditorUploadSuccess(result : ShopliveEditorResultData?)
    @objc optional func onShopLiveShortformEditorClosed()
    @objc optional func onShopLiveShortformEditorOnEvent(name : String, payload : [String : Any]?)
}

