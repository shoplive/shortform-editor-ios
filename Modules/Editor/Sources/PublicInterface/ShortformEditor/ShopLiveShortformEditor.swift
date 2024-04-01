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
    public static var sdkVersion = ShopLiveCommon.videoEditorSdkversion
    
    
    internal static let shared = ShopLiveShortformEditor()
    
    private var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
    private var permissionHandler : ShopLivePermissionHandler?
    private static weak var navigationController : SLPickerNavigationController?
    
    
    public init(){ }
    
    
    @discardableResult
    public func setPermissionHandler(_ permissionHandler : ShopLivePermissionHandler?) -> Self {
        self.permissionHandler = permissionHandler
        return self
    }
    
    @discardableResult
    public func setConfiguration(_ configuration : ShopLiveShortformEditorConfiguration?) -> Self {
        if let videoCropOption = configuration?.videoCropOption {
            ShopLiveEditorConfigurationManager.shared.videoCropOption = videoCropOption
        }
        
        if let trimOption = configuration?.videoTrimOption {
            ShopLiveEditorConfigurationManager.shared.videoTrimOption = trimOption
        }
        
        if let visibleContents = configuration?.visibleContents {
            ShopLiveEditorConfigurationManager.shared.visibleContents = visibleContents
        }
        
        return self
    }
    
    @discardableResult
    public func setDelegate(delegate : ShopLiveShortformEditorDelegate) -> Self{
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
                shortformEditorDelegate?.onShopLiveShortformEditorError?(error: error)
            }
        }
    }
    
    private func presentUpload(vc : UIViewController) {
        let videoPicker = SLPhotosPickerViewController()
        videoPicker.shoplivePermissionDelegate = permissionHandler
        videoPicker.shortformEditorDelegate = shortformEditorDelegate
        let navi = SLPickerNavigationController(rootViewController: videoPicker)
        Self.navigationController = navi
        navi.isNavigationBarHidden = true
        navi.modalPresentationCapturesStatusBarAppearance = true
        navi.modalPresentationStyle = .overFullScreen
        vc.present(navi, animated: true)
    }
    
    
    public func close() {
        Self.navigationController?.dismiss(animated: true)
        Self.navigationController = nil
    }
    
}
