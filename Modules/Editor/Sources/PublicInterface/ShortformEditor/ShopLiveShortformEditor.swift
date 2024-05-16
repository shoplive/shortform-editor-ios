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
    public static let shared = ShopLiveShortformEditor()
    
    private var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
    private var permissionHandler : ShopLivePermissionHandler?
    private var coordinator : ShopliveShortformCoordinator?
    
    
    public init(){ }
    
    
    @discardableResult
    public func setPermissionHandler(_ permissionHandler : ShopLivePermissionHandler?) -> Self {
        Self.shared.permissionHandler = permissionHandler
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
        Self.shared.shortformEditorDelegate = delegate
        return self
    }
    
    public func start(_ vc : UIViewController) {
        coordinator = ShopliveShortformCoordinator()
        coordinator?.showPhotoPicker(vc: vc,
                                     permissionHandler: Self.shared.permissionHandler,
                                     editorDelegate: Self.shared.shortformEditorDelegate)
        
    }
    
    public func close() {
        coordinator?.close()
    }
    
    func getShoplivePermissionHandler() -> ShopLivePermissionHandler? {
        return coordinator?.getPermissionHandler()
    }
}

