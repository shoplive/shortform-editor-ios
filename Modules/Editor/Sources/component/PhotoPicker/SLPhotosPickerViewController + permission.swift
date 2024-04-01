//
//  SLPhotosPickerViewController + permission.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/6/23.
//

import Foundation
import UIKit
import Photos
import ShopliveSDKCommon

extension SLPhotosPickerViewController {
    func handleAlbumPermissions(picker: SLPhotosPickerViewController, status: ShopliveSDKCommon.PermissionStatus) {
        if let permissionDelegate = shoplivePermissionDelegate, let handler = permissionDelegate.handlePhotoLibraryUsagePermission?(status: status) {
            handler
        }
        else if status == .denied || status == .notDetermined {
            openAlertController()
        }
    }
    
    func handleCameraPermissions(picker: SLPhotosPickerViewController, status: ShopliveSDKCommon.PermissionStatus) {
        if let permissionDelegate = shoplivePermissionDelegate, let handler = permissionDelegate.handleCameraPermission?(status: status) {
            handler
        }
        else if status == .denied || status == .notDetermined {
            openAlertController()
        }
    }
    
    private func openAlertController(){
        let bundle = Bundle(for: type(of: self))
        let title = "alert.permission.denied.title".localizedString(bundle: bundle)
        let message = "alert.permission.denied.description".localizedString(bundle: bundle)
        let settingBtn = "alert.permission.denied.setting".localizedString(bundle: bundle)
        let cancelBtn = "alert.permission.denied.cancel".localizedString(bundle: bundle)
        
        let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: settingBtn, style: .default) { [weak self] (_) -> Void in
            self?.sendUsersToSettingsApp()
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: cancelBtn, style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func sendUsersToSettingsApp(){
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    
    
}
