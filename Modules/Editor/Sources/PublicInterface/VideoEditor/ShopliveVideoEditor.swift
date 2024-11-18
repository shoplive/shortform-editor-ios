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
    
    private var delegate : ShopLiveVideoEditorDelegate?
    private var permissionHandler : ShopLivePermissionHandler?
    private var navigationController : SLPickerNavigationController?
    
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
    public func setDelegate(_ delegate : ShopLiveVideoEditorDelegate) -> Self {
        self.delegate = delegate
        return self
    }
    
    public func start(_ vc : UIViewController, data : ShopLiveVideoEditorData) {
        if let remoteVideoUrl = data.videoRemoteUrl {
            self.showWithRemoteData(vc, remoteUrl: remoteVideoUrl)
        }
        else if let videoAbsoluteUrl = data.videoAbsoluteUrl, let videoRelativeUrl =  data.videoRelativeUrl {
            self.showWithLocalData(vc, absoluteUrl: videoAbsoluteUrl, relativeUrl: videoRelativeUrl)
        }
        else if let videoAbsoluteUrl = data.videoAbsoluteUrl {
            self.showWithLocalDataSingleUrl(vc, url: videoAbsoluteUrl)
        }
    }
    
    private func showWithLocalDataSingleUrl(_ vc : UIViewController, url : URL) {
        callFilterListAPI()
        self.callConfigAPI { [weak self] in
            guard let self = self else { return }
            SLCodecValidator.runFFProbCommand(videoPath: url.absoluteString) { isValidCodec in
                if isValidCodec == false {
                    self.delegate?.onShopLiveVideoEditorError?(error: ShopLiveCommonErrorGenerator.generateError(errorCase: .UnsupportedMedia, error: nil, message: "codec is not valid"))
                }
                else {
                    DispatchQueue.main.async {
                        let shortsVideo = ShortsVideo(localAbsoluteUrl: url, localRelativeUrl: url)
                        let editorVC = SLVideoEditorMainViewController(video: shortsVideo)
                        editorVC.delegate = self
                        let navi = SLPickerNavigationController(rootViewController: editorVC)
                        Self.shared.navigationController = navi
                        navi.isNavigationBarHidden = true
                        navi.modalPresentationCapturesStatusBarAppearance = true
                        navi.modalPresentationStyle = .overFullScreen
                        vc.present(navi, animated: true)
                    }
                }
            }
        }
    }
    
    private func showWithLocalData(_ vc : UIViewController, absoluteUrl : URL, relativeUrl : URL) {
        callFilterListAPI()
        self.callConfigAPI { [weak self] in
            guard let self = self else { return }
            SLCodecValidator.runFFProbCommand(videoPath: relativeUrl.absoluteString) { isValidCodec in
                if isValidCodec == false {
                    self.delegate?.onShopLiveVideoEditorError?(error: ShopLiveCommonErrorGenerator.generateError(errorCase: .UnsupportedMedia, error: nil, message: "codec is not valid"))
                }
                else {
                    DispatchQueue.main.async {
                        let shortsVideo = ShortsVideo(localAbsoluteUrl: absoluteUrl, localRelativeUrl: relativeUrl)
                        let editorVC = SLVideoEditorMainViewController(video: shortsVideo)
                        editorVC.delegate = self
                        let navi = SLPickerNavigationController(rootViewController: editorVC)
                        Self.shared.navigationController = navi
                        navi.isNavigationBarHidden = true
                        navi.modalPresentationCapturesStatusBarAppearance = true
                        navi.modalPresentationStyle = .overFullScreen
                        vc.present(navi, animated: true)
                    }
                }
            }
        }
    }
    
    private func showWithRemoteData(_ vc : UIViewController, remoteUrl : URL) {
        callFilterListAPI()
        self.callConfigAPI { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let shortsVideo = ShortsVideo(localAbsoluteUrl: remoteUrl, localRelativeUrl: remoteUrl)
                let editorVC = SLVideoEditorMainViewController(video: shortsVideo)
                editorVC.delegate = self
                let navi = SLPickerNavigationController(rootViewController: editorVC)
                Self.shared.navigationController = navi
                navi.isNavigationBarHidden = true
                navi.modalPresentationCapturesStatusBarAppearance = true
                navi.modalPresentationStyle = .overFullScreen
                vc.present(navi, animated: true)
            }
        }
    }
    
    public func close() {
        Self.shared.navigationController?.viewControllers.first?.dismiss(animated: true)
        Self.shared.navigationController?.dismiss(animated: true)
        Self.shared.navigationController = nil
    }
    
    
    private func callConfigAPI(completion : @escaping () -> ()) {
        ShortFormUploadConfigurationInfosManager.shared.callShortsConfigurationAPI { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success():
                completion()
            case .failure(let error):
                Self.shared.delegate?.onShopLiveVideoEditorError?(error: error)
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
}
extension ShopliveVideoEditor : SLVideoEditorViewControllerDelegate {
    
    func videoEditorRequestPopView() {
        Self.shared.close()
        Self.shared.delegate?.onShopLiveVideoEditorCancelled?()
    }
    
    func videoEditorDidCancelConvertVideo() {
        
    }
    
    func videoEditorDidFinishConvertVideo(videoPath: String) {
        Self.shared.delegate?.onShopLiveVideoEditorVideoConvertSuccess?(videoPath: videoPath)
    }
    
    func videoEditorDidFinishUpload(shortsId: String) {
        Self.shared.delegate?.onShopLiveVideoEditorUploadSuccess?(shortsId: shortsId)
    }
    
    func videoEditorError(error: ShopLiveCommonError) {
        Self.shared.delegate?.onShopLiveVideoEditorError?(error: error)
    }
}
