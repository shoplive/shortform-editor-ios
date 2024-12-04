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


public class ShopliveVideoEditor {
    public static let shared = ShopliveVideoEditor()
    public init() {
        
    }
    
    public static var sdkVersion = ShopLiveCommon.videoEditorSdkversion
    private weak var delegate : ShopLiveVideoEditorDelegate?
    private weak var permissionHandler : ShopLivePermissionHandler?
    
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
        
        if let videoOutputOption = configuration?.videoOutputOption {
            ShopLiveEditorConfigurationManager.shared.videoOutputOption = videoOutputOption
        }
        
        if let visibleContents = configuration?.visibleContents {
            ShopLiveEditorConfigurationManager.shared.visibleContents = visibleContents
        }
        
        return self
    }
    
    @discardableResult
    public func setDelegate(_ delegate : ShopLiveVideoEditorDelegate?) -> Self {
        self.delegate = delegate
        return self
    }
    
    public func build(data : ShopLiveVideoEditorData,completion : @escaping(UIViewController) -> ()) {
        if let remoteVideoUrl = data.videoRemoteUrl {
            self.showWithRemoteData(remoteUrl: remoteVideoUrl,isCreateShortform: data.isCreatedShortform,completion: completion)
        }
        else if let videoAbsoluteUrl = data.videoAbsoluteUrl, let videoRelativeUrl = data.videoRelativeUrl {
            let tempAbsoluteVideoUrlString = SLCodecValidator.makeTempVideoUrl(videoPath: videoAbsoluteUrl.relativePath)
            let tempAbsoluteVideoUrl = URL(string: tempAbsoluteVideoUrlString)!
            let tempRelativeVideoUrlString = SLCodecValidator.makeTempVideoUrl(videoPath: videoRelativeUrl.absoluteString)
            let tempRelativeVideoUrl = URL(string: tempRelativeVideoUrlString)!
            self.showWithLocalData(absoluteUrl: tempAbsoluteVideoUrl, relativeUrl: tempRelativeVideoUrl,isCreateShortform: data.isCreatedShortform,completion: completion)
        }
        else if let videoAbsoluteUrl = data.videoAbsoluteUrl {
            let tempVideoUrlString = SLCodecValidator.makeTempVideoUrl(videoPath: videoAbsoluteUrl.relativePath)
            let tempVideoUrl = URL(string: tempVideoUrlString)!
            self.showWithLocalDataSingleUrl(url: tempVideoUrl,isCreateShortform: data.isCreatedShortform,completion: completion)
        }
    }
    
    private func showWithLocalDataSingleUrl(url : URL, isCreateShortform : Bool,completion : @escaping(UIViewController) -> ()) {
        callFilterListAPI()
        self.callConfigAPI { [weak self] in
            guard let self = self else { return }
            SLCodecValidator.runFFProbCommand(videoPath: url.absoluteString) { isValidCodec in
                if isValidCodec == false {
                    self.delegate?.onShopLiveVideoEditorError?(editor: nil, error: ShopLiveCommonErrorGenerator.generateError(errorCase: .UnsupportedMedia, error: nil, message: "codec is not valid"))
                }
                else {
                    let shortsVideo = ShortsVideo(localAbsoluteUrl: url, localRelativeUrl: url)
                    DispatchQueue.main.async {
                        let vc = self.showEditorViewController(shortsVideo: shortsVideo,isCreateShortform: isCreateShortform)
                        completion(vc)
                    }
                }
            }
        }
    }
    
    private func showWithLocalData(absoluteUrl : URL, relativeUrl : URL, isCreateShortform : Bool,completion : @escaping(UIViewController) -> ()) {
        callFilterListAPI()
        self.callConfigAPI { [weak self] in
            guard let self = self else { return }
            SLCodecValidator.runFFProbCommand(videoPath: relativeUrl.absoluteString) { isValidCodec in
                if isValidCodec == false {
                    self.delegate?.onShopLiveVideoEditorError?(editor: nil, error: ShopLiveCommonErrorGenerator.generateError(errorCase: .UnsupportedMedia, error: nil, message: "codec is not valid"))
                }
                else {
                    let shortsVideo = ShortsVideo(localAbsoluteUrl: absoluteUrl, localRelativeUrl: relativeUrl)
                    DispatchQueue.main.async {
                        let vc = self.showEditorViewController(shortsVideo: shortsVideo,isCreateShortform: isCreateShortform)
                        completion(vc)
                    }
                }
            }
        }
    }
    
    private func showWithRemoteData(remoteUrl : URL, isCreateShortform : Bool,completion : @escaping(UIViewController) -> ()) {
        callFilterListAPI()
        self.callConfigAPI { [weak self] in
            guard let self = self else { return }
            let shortsVideo = ShortsVideo(localAbsoluteUrl: remoteUrl, localRelativeUrl: remoteUrl)
            DispatchQueue.main.async {
                let vc = self.showEditorViewController(shortsVideo: shortsVideo,isCreateShortform: isCreateShortform)
                completion(vc)
            }
        }
    }

    private func showEditorViewController(shortsVideo : ShortsVideo, isCreateShortform : Bool) -> UIViewController {
        let editorVC = SLVideoEditorMainViewController(video: shortsVideo,isCreateShortform: isCreateShortform)
        editorVC.delegate = self
        return editorVC
    }
    
    private func callConfigAPI(completion : @escaping () -> ()) {
        ShortFormUploadConfigurationInfosManager.shared.callShortsConfigurationAPI { result in
            switch result {
            case .success():
                completion()
            case .failure(let error):
                Self.shared.delegate?.onShopLiveVideoEditorError?(editor: nil, error: error)
            }
        }
    }
    
    private func callFilterListAPI() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            ShopLiveShortformEditorFilterListManager.shared.videoEditorDelegate = self.delegate
            ShopLiveShortformEditorFilterListManager.shared.callFilterListAPI { }
        }
    }
    
    public func cleanUpMemory() {
        SLFileManager.deleteEditorDirectoryFiles()
        ShopLiveShortformEditorFilterListManager.shared.videoEditorDelegate = nil
        Self.shared.permissionHandler = nil
        Self.shared.delegate = nil
    }
}
extension ShopliveVideoEditor : SLVideoEditorViewControllerDelegate {
    func videoEditorDidCancelConvertVideo(editor: UIViewController?) {
        
    }
    
    func videoEditorDidFinishConvertVideo(editor: UIViewController?, videoPath: String) {
        Self.shared.delegate?.onShopLiveVideoEditorVideoConvertSuccess?(editor: editor, videoPath: videoPath)
    }
    
    func videoEditorRequestPopView(editor: UIViewController?) {
        Self.shared.delegate?.onShopLiveVideoEditorCancelled?(editor: editor)
    }
    
    func videoEditorDidFinishUpload(editor: UIViewController?, result: ShopLiveEditorResultInternalData?) {
        Self.shared.delegate?.onShopLiveVideoEditorUploadSuccess?(editor: editor, result: result?.convertToClass())
    }
   
    func videoEditorError(editor: UIViewController?,error: ShopLiveCommonError) {
        Self.shared.delegate?.onShopLiveVideoEditorError?(editor : editor, error: error)
    }
    
    func videoEditorOnEvent(editor: UIViewController?,name: EventTrace, payload: [String : Any]?) {
        Self.shared.delegate?.onShopLiveVideoEditorOnEvent?(editor : editor, name: name.rawValue, payload: payload)
    }
}
