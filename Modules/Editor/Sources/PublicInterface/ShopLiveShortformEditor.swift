//
//  ShopLiveShortformUpload.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 2023/07/27.
//

import Foundation
import UIKit
import ShopliveSDKCommon


public class ShopLiveShortformEditor { 
    public static var sdkVersion = "1.5.6"
    
    
    internal static let shared = ShopLiveShortformEditor()
    
    private var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
    private var permissionHandler : ShopLivePermissionHandler?
    
    public init(){ }
    
    
    @discardableResult
    public func setPermissionHandler(_ permissionHandler : ShopLivePermissionHandler?) -> Self {
        self.permissionHandler = permissionHandler
        return self
    }
    
    @discardableResult
    public func setConfiguration(_ configuration : ShopLiveShortformEditorConfiguration?) -> Self {
        ShopLiveShortformEditorConfigurationManager.shared.shortformUploadConfiguration = configuration
        return self
    }
    
    @discardableResult
    public func setShortFormEditorDelegate(delegate : ShopLiveShortformEditorDelegate) -> Self{
        self.shortformEditorDelegate = delegate
        return self
    }
    
    public func start(_ vc : UIViewController) {
        ShortFormUploadConfigurationInfosManager.shared.callShortsConfigurationAPI { [weak self] result in
            guard let self = self else { return }
            switch result {
            case.success():
                DispatchQueue.main.async {
                    self.presentUpload(vc: vc)
                }
            case .failure(let error):
                shortformEditorDelegate?.onShortformUploadError(error: error)
            }
        }
    }
    
    private func presentUpload(vc : UIViewController) {
        let videoPicker = SLPhotosPickerViewController()
        videoPicker.shoplivePermissionDelegate = permissionHandler
        videoPicker.shortformEditorDelegate = shortformEditorDelegate
        let navi = SLPickerNavigationController(rootViewController: videoPicker)
        navi.isNavigationBarHidden = true
        navi.modalPresentationCapturesStatusBarAppearance = true
        navi.modalPresentationStyle = .overFullScreen
        vc.present(navi, animated: true)
    }
    
    
    
}
