//
//  SLPhotoPickerPermissionHandler.swift
//  CustomImagePicker
//
//  Created by sangmin han on 5/3/24.
//

import Foundation
import UIKit
import Photos
import PhotosUI
import ShopliveSDKCommon



class SLPhotoPickerPermissionHandler : NSObject, SLReactor {
    
    
    enum Action {
        case setDelegate(ShopLivePermissionHandler?)
        case checkAlbumPermissions
        case checkCameraPermissions
    }
    
    enum Result {
        case openAlertController(UIAlertController)
        case showCamera
        case dismiss
        case requestLoadPhotos(limited : Bool)
    }
    
    var resultHandler: ((Result) -> ())?
    
    weak var shoplivePermissionDelegate : ShopLivePermissionHandler?
    
    
    func action(_ action: Action) {
        switch action {
        case .checkAlbumPermissions:
            self.onCheckAlbumPermissions()
        case .checkCameraPermissions:
            self.onCheckCameraPermissions()
        case .setDelegate(let delegate):
            self.onSetDelegate(delegate: delegate)
        }
    }
    
    private func onSetDelegate(delegate : ShopLivePermissionHandler?) {
        self.shoplivePermissionDelegate = delegate
    }
}
//MARK: - Camera Permission
extension SLPhotoPickerPermissionHandler {
    private func onCheckCameraPermissions() {
        let authorization = AVCaptureDevice.authorizationStatus(for: .video)
        switch authorization {
        case .authorized:
            self.showCamera()
        case .notDetermined:
            self.requestForCameraPermission()
        case .restricted, .denied:
            self.handleCameraPermission(status: .denied)
        @unknown default:
            break
        }
    }
    
    private func requestForCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] (authorized) in
            DispatchQueue.main.async { [weak self] in
                if authorized {
                    self?.showCamera()
                } else {
                    if let self = self {
                        self.handleCameraPermission(status: .denied)
                    }
                }
            }
        })
    }
    
    private func handleCameraPermission(status : ShopliveSDKCommon.PermissionStatus) {
        if let delegate = shoplivePermissionDelegate, let handler = delegate.handleCameraPermission?(status: status) {
            handler
        }
        else {
            self.openAlertController()
        }
    }
    
    private func showCamera() {
        resultHandler?( .showCamera )
    }
    
    
}
//MARK: - Album Permission
extension SLPhotoPickerPermissionHandler {
    private func onCheckAlbumPermissions() {
        var status : PHAuthorizationStatus
        if #available(iOS 14.0, *) {
             status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        }
        else {
            status = PHPhotoLibrary.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            self.requestForAlbumPermission()
        case .authorized:
            resultHandler?( .requestLoadPhotos(limited: false) )
        case .limited:
            resultHandler?( .requestLoadPhotos(limited: true) )
            self.handleAlbumPermission(status: .limited)
        case .denied, .restricted:
            self.handleAlbumPermission(status: .denied)
        @unknown default:
            break
        }
    }
    
    private func requestForAlbumPermission() {
        if #available(iOS 14.0, *) {
            PHPhotoLibrary.requestAuthorization(for:  .readWrite) { [weak self] _ in
                self?.onCheckAlbumPermissions()
            }
        } else {
            PHPhotoLibrary.requestAuthorization { [weak self] _ in
                self?.onCheckAlbumPermissions()
            }
        }
    }
    
    private func handleAlbumPermission(status : ShopliveSDKCommon.PermissionStatus) {
        if let delegate = shoplivePermissionDelegate, let handler = delegate.handlePhotoLibraryUsagePermission?(status: status) {
            handler
        }
        else {
            self.openAlertController()
        }
    }
    
}
extension SLPhotoPickerPermissionHandler {
    
    private func openAlertController() {
        let bundle = Bundle(for: type(of: self))
        let title = "alert.permission.denied.title"
            //.localizedString(bundle: bundle)
        let message = "alert.permission.denied.description"
            //.localizedString(bundle: bundle)
        let settingBtn = "alert.permission.denied.setting"
            //.localizedString(bundle: bundle)
        let cancelBtn = "alert.permission.denied.cancel"
            //.localizedString(bundle: bundle)
        
        let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: settingBtn, style: .default) { [weak self] (_) -> Void in
            self?.openSettingsApp()
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: cancelBtn, style: .default) { [weak self] _ in
            self?.resultHandler?( .dismiss )
        }
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async { [weak self] in
            self?.resultHandler?( .openAlertController(alertController) )
        }
    }
    
    private func openSettingsApp() {
        guard let settingUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingUrl){
            UIApplication.shared.open(settingUrl)
        }
    }
    
}
