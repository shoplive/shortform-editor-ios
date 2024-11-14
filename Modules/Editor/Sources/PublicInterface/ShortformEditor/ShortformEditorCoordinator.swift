//
//  ShortformEditorCoordinator.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/7/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon


class ShopliveShortformCoordinator : NSObject {
    typealias ShortformEditor = ShopLiveShortformEditor
    
   
    private var permissionHandler : ShopLivePermissionHandler?
    private var editorDelegate : ShopLiveShortformEditorDelegate?
    private var ffmpegValidator = FFmpegVideoValidator()
    
    private var navigationController : SLPickerNavigationController?
    
    func showPhotoPicker(vc : UIViewController, permissionHandler : ShopLivePermissionHandler?, editorDelegate : ShopLiveShortformEditorDelegate?) {
        self.permissionHandler = permissionHandler
        self.editorDelegate = editorDelegate
        
        let photoPicker = SLPhotosPickerViewController(mediaType: .video, permissionDelegate: permissionHandler)
        photoPicker.delegate = self
        photoPicker.editorDelegate = editorDelegate
        
        self.callFilterListAPI()
        
        self.navigationController = SLPickerNavigationController(rootViewController: photoPicker)
        navigationController?.isNavigationBarHidden = true
        navigationController?.modalPresentationCapturesStatusBarAppearance = true
        navigationController?.modalPresentationStyle = .overFullScreen
        vc.present(navigationController!, animated: true)
    }
    
    
    private func callFilterListAPI() {
        DispatchQueue.global(qos: .background).async {
            ShopLiveShortformEditorFilterListManager.shared.shortformEditorDelegate = self.editorDelegate
            ShopLiveShortformEditorFilterListManager.shared.callFilterListAPI { }
        }
    }
    
    func close() {
        self.navigationController?.dismiss(animated: true)
        self.navigationController = nil 
    }
    
    func getPermissionHandler() -> ShopLivePermissionHandler? {
        return self.permissionHandler
    }
}

extension ShopliveShortformCoordinator : SLPhotosPickerViewControllerDelegate  {
    func photoPicker(didSelectVideo absoluteUrl: URL, relativeUrl: URL) {
        ffmpegValidator.checkValidCodec(videoUrl: relativeUrl) { [weak self] isValidCodec in
            guard let self = self else { return }
            if isValidCodec {
                self.showSLVideoEditorViewController(video: ShortsVideo(localAbsoluteUrl: absoluteUrl, localRelativeUrl: relativeUrl))
            }
        }
    }
    
    func photoPicker(didSelectImage url: URL) {
        
    }
    
    func photoPiker(onClose picker: UIViewController) {
        self.close()
    }
}
extension ShopliveShortformCoordinator : SLVideoEditorViewControllerDelegate {
    private func showSLVideoEditorViewController(video : ShortsVideo) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.navigationController?.viewControllers.filter({ $0.isKind(of: SLVideoEditorMainViewController.self) }).count == 0 else {
                return
            }
            
            let editor = SLVideoEditorMainViewController(video: video, isRoot: false)
            editor.delegate = self
            editor.shortformEditorDelegate = self.editorDelegate
            self.navigationController?.pushViewController(editor, animated: true)
        }
    }
    
    func cancelConvertVideo() {
        guard let vc = navigationController?.topViewController else { return }
        let bundle = Bundle(for: type(of: self))
        vc.showToast(message: "toast.cancel.encoding.title".localizedString(bundle: bundle), duration: .long)
    }
}
