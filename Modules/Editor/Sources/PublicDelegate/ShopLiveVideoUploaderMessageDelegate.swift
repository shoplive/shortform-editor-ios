//
//  ShopLiveShortformUploaderMessageDelegate.swift
//  ShopLiveShortformEditorSDK
//
//  Created by Tabber on 4/1/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

@objc public protocol ShopLiveShortformUploaderMessageDelegate: AnyObject {
    @objc optional func upload(id: String)
    @objc optional func successCoverChange()
}
