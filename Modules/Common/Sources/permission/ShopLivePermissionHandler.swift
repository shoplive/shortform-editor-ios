//
//  ShopLivePermissionHandler.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2023/05/30.
//

import Foundation
import AVKit



@objc public protocol ShopLivePermissionHandler {
    @objc optional func handleCameraPermission(status : PermissionStatus)
    @objc optional func handleMicroPhonePermission(status : PermissionStatus)
    @objc optional func handleMediaLibraryUsagePermission(status : PermissionStatus)
    @objc optional func handlePhotoLibraryUsagePermission(status : PermissionStatus)
}

