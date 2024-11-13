//
//  ShopliveVideoEditor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 3/26/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import Photos
import PhotosUI
import MobileCoreServices
import ShopliveSDKCommon


public class ShopliveVideoEditor {
    public static let shared = ShopliveVideoEditor()
    public init() {
        
    }
    
    public static var sdkVersion = ShopLiveCommon.videoEditorSdkversion
    
    private var delegate : ShopLiveVideoEditorDelegate?
    private var permissionHandler : ShopLivePermissionHandler?
    private static weak var navigationController : SLPickerNavigationController?
    
    @discardableResult
    public func setPermissionHandler(_ permissionHandler : ShopLivePermissionHandler?) -> Self {
        self.permissionHandler = permissionHandler
        return self
    }
    
    @discardableResult
    public func setConfiguration(_ configuration : ShopliveVideoEditorConfiguration?) -> Self {
        if let videoCropOption = configuration?.videoCropOption {
            ShopLiveEditorConfigurationManager.shared.videoCropOption = videoCropOption
        }
        
        if let trimOption = configuration?.videoTrimOption {
            ShopLiveEditorConfigurationManager.shared.videoTrimOption = trimOption
        }
        
        return self
    }
    
    @discardableResult
    public func setDelegate(_ delegate : ShopLiveVideoEditorDelegate) -> Self {
        self.delegate = delegate
        return self
    }
    
    public func start(_ vc : UIViewController, absoluteUrl : URL, relativeUrl : URL) {
        self.callConfigAPI { [weak self] in
            guard let self = self else { return }
            SLCodecValidator.runFFProbCommand(videoPath: relativeUrl.absoluteString) { isValidCodec in
                if isValidCodec == false {
                    self.delegate?.onShopLiveVideoEditorError?(error: ShopLiveCommonErrorGenerator.generateError(errorCase: .UnsupportedMedia, error: nil, message: "codec is not valid"))
                }
                else {
                    DispatchQueue.main.async {
                        let shortsVideo = ShortsVideo(videoUrl: absoluteUrl)
                        let editorVC = SLVideoEditorMainViewController(video: shortsVideo)
                        editorVC.videoEditorDelegate = self.delegate
                        let navi = SLPickerNavigationController(rootViewController: editorVC)
                        Self.navigationController = navi
                        navi.isNavigationBarHidden = true
                        navi.modalPresentationCapturesStatusBarAppearance = true
                        navi.modalPresentationStyle = .overFullScreen
                        vc.present(navi, animated: true)
                    }
                }
            }
        }
    }
    
    public func start(_ vc : UIViewController, remoteUrl : URL) {
        self.callConfigAPI { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let shortsVideo = ShortsVideo(videoUrl: remoteUrl)
                let editorVC = SLVideoEditorMainViewController(video: shortsVideo)
                editorVC.videoEditorDelegate = self.delegate
                let navi = SLPickerNavigationController(rootViewController: editorVC)
                Self.navigationController = navi
                navi.isNavigationBarHidden = true
                navi.modalPresentationCapturesStatusBarAppearance = true
                navi.modalPresentationStyle = .overFullScreen
                vc.present(navi, animated: true)
            }
        }
    }
    
    public func close() {
        Self.navigationController?.dismiss(animated: true)
        Self.navigationController = nil
    }
    
    
    private func callConfigAPI(completion : @escaping () -> ()) {
        ShortFormUploadConfigurationInfosManager.shared.callShortsConfigurationAPI { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success():
                completion()
            case .failure(let error):
                delegate?.onShopLiveVideoEditorError?(error: error)
            }
        }
    }
    
    
    
}
