//
//  ShopLiveVideoEditorDelegate.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 3/26/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import UIKit

@objc public protocol ShopLiveVideoEditorDelegate : AnyObject {
    @objc optional func onShopLiveVideoEditorError(editor : UIViewController?, error : ShopLiveCommonError)
    @objc optional func onShopLiveVideoEditorVideoConvertSuccess(editor : UIViewController?,videoPath : String)
    @objc optional func onShopLiveVideoEditorUploadSuccess(editor : UIViewController?, result : ShopliveEditorResultData?)
    @objc optional func onShopLiveVideoEditorCancelled(editor : UIViewController?)
    @objc optional func onShopLiveVideoEditorOnEvent(editor : UIViewController?,name : String, payload : [String : Any]?)
}
