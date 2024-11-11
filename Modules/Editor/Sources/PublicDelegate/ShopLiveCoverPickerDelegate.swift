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
    @objc optional func onShopLiveCoverPickerSuccess(image : UIImage?)
    @objc optional func onShopLiveCoverPickerClosed()
}
