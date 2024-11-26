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
    @objc optional func onShopLiveCoverPickerError(error : ShopLiveCommonError)
    @objc optional func onShopLiveCoverPickerCoverImageSuccess(image : UIImage?)
    @objc optional func onShopLiveCoverPickerUploadSuccess(result : ShopliveEditorResultData?)
    @objc optional func onShopLiveCoverPickerCancelled()
    @objc optional func onShopLiveCoverPickerOnEvent(name : String, payload : [String : Any]?)

}
