//
//  ShopLiveVideoUploadPreview.swift
//  ShopLiveShortformEditorSDK
//
//  Created by Tabber on 3/26/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import Photos
import PhotosUI
import MobileCoreServices

public class ShopLiveVideoUploadPreview: NSObject {
    public static let shared = ShopLiveVideoUploadPreview()
    
    private var url: String? = nil
    
    @discardableResult
    public func setUrl(url: String) -> Self {
        self.url = url
        return self
    }
    
    public func build(completion: @escaping(UIViewController) -> ()) {
        let vc = showShopLiveVideoUploadPreviewController()
        completion(vc)
    }
    
    private func showShopLiveVideoUploadPreviewController() -> UIViewController {
        guard let url = url else { return UIViewController() }
        return ShopLiveShortformUploaderPreviewController(url: url)
    }
}
