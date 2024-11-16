//
//  ShopLiveMediaPicker.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import Photos
import PhotosUI
import MobileCoreServices




public class ShopLiveMediaPicker : NSObject {
    public static let shared = ShopLiveMediaPicker()
    override public init() { }
    
    
    public static var sdkVersion = ShopLiveCommon.videoEditorSdkversion
    
    private var permissionHandler : ShopLivePermissionHandler?
    private var delegate : ShopLiveMediaPickerDelegate?
    private var ffmpegValidator = FFmpegVideoValidator()
    private var navigationController : SLPickerNavigationController?
    
    @discardableResult
    public func setPermissionHandler(_ permissionHandler : ShopLivePermissionHandler?) -> Self {
        Self.shared.permissionHandler = permissionHandler
        return self
    }
    
    @discardableResult
    public func setDelegate(_ delegate : ShopLiveMediaPickerDelegate?) -> Self {
        Self.shared.delegate = delegate
        return self
    }
    
    @discardableResult
    public func setConfiguration(_ configuration : ShopLiveMediaPickerConfiguration?) -> Self {
        if let videoDurationOption = configuration?.videoDurationOption {
            ShopLiveEditorConfigurationManager.shared.mediaPickerVideoDurationOption = videoDurationOption
        }
        return self
    }
    
    public func start(_ vc : UIViewController, type : SLMediaType ) {
        let photoPicker = SLPhotosPickerViewController(mediaType: type , permissionDelegate: permissionHandler)
        photoPicker.delegate = self
        
        self.navigationController = SLPickerNavigationController(rootViewController: photoPicker)
        navigationController?.isNavigationBarHidden = true
        navigationController?.modalPresentationCapturesStatusBarAppearance = true
        navigationController?.modalPresentationStyle = .overFullScreen
        vc.present(navigationController!, animated: true)
    }
    
    public func close() {
        Self.shared.navigationController?.viewControllers.first?.dismiss(animated: true)
        self.navigationController?.dismiss(animated: true)
        self.navigationController = nil
    }
}
extension ShopLiveMediaPicker : SLPhotosPickerViewControllerDelegate {
    func photoPicker(didSelectVideo absoluteUrl: URL, relativeUrl: URL) {
        ffmpegValidator.checkValidCodec(videoUrl: relativeUrl) { [weak self] isValidCodec in
            guard let self = self else { return }
            if isValidCodec {
                Self.shared.delegate?.onShopLiveMediaPickerDidPickVideo?(absoluteUrl: absoluteUrl, relativeUrl: relativeUrl)
            }
            else {
                let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .UnsupportedMedia, error: nil, message: "Video codec is not valid")
                Self.shared.delegate?.onShopLiveMediaPickerError?(error: commonError)
            }
        }
    }
    
    func photoPicker(didSelectImage url: URL) {
        Self.shared.delegate?.onShopLiveMediaPickerDidPickImage?(imageUrl: url)
    }
    
    func photoPiker(onClose picker: UIViewController) {
        Self.shared.close()
        Self.shared.delegate?.onShopLiveMediaPickerCancelled?()
    }
}
