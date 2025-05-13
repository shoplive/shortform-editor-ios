//
//  ShopLiveShortformUploader.swift
//  ShopLiveShortformEditorSDK
//
//  Created by Tabber on 3/19/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import Photos
import PhotosUI
import MobileCoreServices

public class ShopLiveShortformUploader : NSObject {
    public static let shared = ShopLiveShortformUploader()
    override public init() { }
    
    private weak var delegate: ShopLiveShortformUploaderDelegate?
    private var uploaderData: ShopLiveShortformUploaderData = .init()
    
    @discardableResult
    public func setDelegate(_ delegate: ShopLiveShortformUploaderDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
    
    @discardableResult
    public func setUploaderData(_ data: ShopLiveShortformUploaderData) -> Self {
        self.uploaderData = data
        return self
    }
    
    public func build(completion: @escaping(UIViewController) -> ()) {
        let vc = showShopLiveShortformUploaderViewController()
        completion(vc)
    }
    
    private func showShopLiveShortformUploaderViewController() -> UIViewController {
        let videoUploaderVC = ShopLiveShortformUploaderViewController(uploaderData: uploaderData)
        
        videoUploaderVC.delegate = self
        return videoUploaderVC
    }
}

extension ShopLiveShortformUploader: ShopLiveShortformUploaderViewControllerDelegate {
    func onOpenVideoEditor() {
        delegate?.onShopLiveShortformUploaderOpenVideoEditor?()
    }
    
    func onPlayPreview(root: UIViewController, url: String) {
        delegate?.onShopLiveShortformUploaderPlayPreview?(root: root, url: url)
    }
    
    func onOpenCoverPicker(editor: UIViewController?, shortsId: String, videoUrl: String?) {
        delegate?.onShopLiveShortformUploaderOpenCoverPicker?(editor: editor, shortsId: shortsId, videoUrl: videoUrl)
    }
    
    func onEvent(name: String, Payload: [String : Any]?) {
        delegate?.onShopLiveShortformUploaderEvent?(command: name, payload: Payload)
    }
    
    func onError(error: ShopLiveCommonError) {
        delegate?.onShopLiveShortformUploaderError?(error: error)
    }
    
    func onUploadComplete() {
        delegate?.onShopLiveShortformUploaderUploadSuccess?()
    }
}
