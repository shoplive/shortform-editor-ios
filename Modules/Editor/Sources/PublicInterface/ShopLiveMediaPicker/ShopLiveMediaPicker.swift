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
    private weak var permissionHandler : ShopLivePermissionHandler?
    private weak var delegate : ShopLiveMediaPickerDelegate?
    
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
    
    public func build(type : SLMediaType, completion : @escaping(UIViewController) -> () ) {
        let photoPicker = SLPhotosPickerViewController(mediaType: type , permissionDelegate: permissionHandler)
        photoPicker.delegate = self
        DispatchQueue.main.async {
            completion(photoPicker)
        }
    }
    
    public func cleanUpMemory() {
        SLFileManager.deleteEditorDirectoryFiles()
        Self.shared.permissionHandler = nil
        Self.shared.delegate = nil
    }
}
extension ShopLiveMediaPicker : SLPhotosPickerViewControllerDelegate {
    func photoPicker(picker : UIViewController,didSelectVideo absoluteUrl: URL, relativeUrl: URL) {
        let tempAbsoluteVideoUrlString = SLCodecValidator.makeTempVideoUrl(videoPath: absoluteUrl.absoluteString)
        let tempAbsoluteVideoUrl = URL(string: tempAbsoluteVideoUrlString)!
        let tempRelativeVideoUrlString = SLCodecValidator.makeTempVideoUrl(videoPath: relativeUrl.absoluteString)
        let tempRelativeVideoUrl = URL(string: tempRelativeVideoUrlString)!
        SLCodecValidator.runFFProbCommand(videoPath: tempRelativeVideoUrlString) { [weak self] isValidCodec in
            guard let self = self else { return }
            if isValidCodec {
                Self.shared.delegate?.onShopLiveMediaPickerDidPickVideo?(picker : picker, absoluteUrl: tempAbsoluteVideoUrl, relativeUrl: tempRelativeVideoUrl)
            }
            else {
                let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .UnsupportedMedia, error: nil, message: "Video codec is not valid")
                Self.shared.delegate?.onShopLiveMediaPickerError?(picker: picker, error: commonError)
            }
        }
    }
    
    func photoPicker(picker : UIViewController, didSelectImage url: URL) {
        Self.shared.delegate?.onShopLiveMediaPickerDidPickImage?(picker: picker,imageUrl: url)
    }
    
    func photoPiker(onClose picker: UIViewController) {
        Self.shared.delegate?.onShopLiveMediaPickerCancelled?(picker: picker)
    }
    
    func photoPickerOnEvent(picker: UIViewController, name: EventTrace, payload: [String : Any]?) {
        Self.shared.delegate?.onShopLiveMediaPickerOnEvent?(picker: picker, name: name.rawValue, payload: payload)
    }
}
