//
//  ShopLiveShortformUploaderDelegate.swift
//  ShopLiveShortformEditorSDK
//
//  Created by Tabber on 3/27/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopliveSDKCommon

@objc public protocol ShopLiveShortformUploaderDelegate: AnyObject {
    @objc optional func onShopLiveShortformUploaderOpenVideoEditor()
    @objc optional func onShopLiveShortformUploaderUploadSuccess()
    @objc optional func onShopLiveShortformUploaderPlayPreview(root: UIViewController, url: String)
    @objc optional func onShopLiveShortformUploaderOpenCoverPicker(editor: UIViewController?, shortsId: String, videoUrl: String?)
    @objc optional func onShopLiveShortformUploaderEvent(command: String, payload: [String : Any]?)
    @objc optional func onShopLiveShortformUploaderError(error: ShopLiveCommonError)
}
