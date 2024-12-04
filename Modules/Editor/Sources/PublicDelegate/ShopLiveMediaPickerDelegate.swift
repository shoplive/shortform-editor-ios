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
    @objc optional func onShopLiveMediaPickerError(picker : UIViewController?,  error : ShopLiveCommonError)
    @objc optional func onShopLiveMediaPickerDidPickVideo(picker : UIViewController?,absoluteUrl : URL, relativeUrl : URL)
    @objc optional func onShopLiveMediaPickerDidPickImage(picker : UIViewController?,imageUrl : URL)
    @objc optional func onShopLiveMediaPickerCancelled(picker : UIViewController?)
    @objc optional func onShopLiveMediaPickerOnEvent(picker : UIViewController?, name : String, payload : [String : Any]?)
}
