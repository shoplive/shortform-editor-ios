//
//  ShopLiveMediaPickerDelegate.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import UIKit

@objc public protocol ShopLiveMediaPickerDelegate : AnyObject {
    @objc optional func onShopLiveMediaPickerError(error : ShopLiveCommonError)
    @objc optional func onShopLiveMediaPickerDidPickVideo(absoluteUrl : URL, relativeUrl : URL)
    @objc optional func onShopLiveMediaPickerDidPickImage(imageUrl : URL)
    @objc optional func onShopLiveMediaPickerCancelled()
    @objc optional func onShopLiveMediaPickerOnEvent(name : String, payload : [String : Any]?)
}
