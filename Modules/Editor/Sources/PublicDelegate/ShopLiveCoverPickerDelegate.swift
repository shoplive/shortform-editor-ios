//
//  ShopLiveCoverPickerDelegate.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/7/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import UIKit


@objc public protocol ShopLiveCoverPickerDelegate : AnyObject {
    @objc optional func onShopLiveCoverPickerError(picker : UIViewController?, error : ShopLiveCommonError)
    @objc optional func onShopLiveCoverPickerCoverImageSuccess(picker : UIViewController?,image : UIImage?)
    @objc optional func onShopLiveCoverPickerUploadSuccess(picker : UIViewController?,result : ShopliveEditorResultData?)
    @objc optional func onShopLiveCoverPickerCancelled(picker : UIViewController?)
    @objc optional func onShopLiveCoverPickerOnEvent(picker : UIViewController?,name : String, payload : [String : Any]?)
}
