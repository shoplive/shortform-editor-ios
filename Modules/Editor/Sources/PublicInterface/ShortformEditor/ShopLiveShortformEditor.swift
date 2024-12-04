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
    
    private weak var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
    private weak var permissionHandler : ShopLivePermissionHandler?
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
        
        if let videoOutputOption = configuration?.videoOutputOption {
            ShopLiveEditorConfigurationManager.shared.videoOutputOption = videoOutputOption
        }
        return self
    }
    
    @discardableResult
    public func setDelegate(delegate : ShopLiveShortformEditorDelegate?) -> Self{
        Self.shared.shortformEditorDelegate = delegate
        return self
    }
    
    public func start(_ vc : UIViewController) {
        Self.shared.coordinator = ShopliveShortformCoordinator()
        Self.shared.coordinator?.showPhotoPicker(vc: vc,
                                     permissionHandler: Self.shared.permissionHandler,
                                     editorDelegate: Self.shared.shortformEditorDelegate)
    }
    
    public func close() {
        Self.shared.shortformEditorDelegate = nil
        Self.shared.permissionHandler = nil
        Self.shared.coordinator?.close()
    }
    
    func getShoplivePermissionHandler() -> ShopLivePermissionHandler? {
        return Self.shared.coordinator?.getPermissionHandler()
    }
}
extension ShopLiveShortformEditor {
    public class MediaPickerConfig {
        public static let global = MediaPickerConfig()
        
        public var closeButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slCloseButton.image
        public var cellCornerRadius : CGFloat = 6
    }
    
    
    public class EditorVolumeConfig {
        public static let global = EditorVolumeConfig()
        
        var videoPlayerCornerRadius : CGFloat = 20
        
        var closeButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slCloseButton.image.withRenderingMode(.alwaysTemplate)
        var closeButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        var closeButtonIconTintColor : UIColor = .white
        
        public var playButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcPlay.image.withRenderingMode(.alwaysTemplate)
        public var playButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        public var playButtonIconTintColor : UIColor = .white
        
        public var pauseButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcPause.image.withRenderingMode(.alwaysTemplate)
        public var pauseButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        public var pauseButtonIconTintColor : UIColor = .white
        
        public var confirmButtonCornerRadius : CGFloat = 20
        public var confirmButtonBackgroundColor : UIColor = .white
        public var confirmButtonTextColor : UIColor =  .black
        
        public var sliderThumbViewColor : UIColor = .white
        public var sliderCornerRaidus : CGFloat = 24
    }
    
    public class EditorSpeedConfig {
        public static let global = EditorSpeedConfig()
        
        var videoPlayerCornerRadius : CGFloat = 20
        
        var closeButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slCloseButton.image.withRenderingMode(.alwaysTemplate)
        var closeButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        var closeButtonIconTintColor : UIColor = .white
        
        public var playButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcPlay.image.withRenderingMode(.alwaysTemplate)
        public var playButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        public var playButtonIconTintColor : UIColor = .white
        
        public var pauseButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcPause.image.withRenderingMode(.alwaysTemplate)
        public var pauseButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        public var pauseButtonIconTintColor : UIColor = .white
        
        public var confirmButtonCornerRadius : CGFloat = 20
        public var confirmButtonBackgroundColor : UIColor = .white
        public var confirmButtonTextColor : UIColor =  .black
        
        public var sliderThumbViewColor : UIColor = .white
        public var sliderCornerRaidus : CGFloat = 24
    }
    
    public class EditorMainConfig {
        public static let global = EditorMainConfig()
        
        public var videoPlayerCornerRadius : CGFloat = 24
        
        public var backButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slBackArrow.image.withRenderingMode(.alwaysTemplate)
        public var backButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        public var backButtonIconTintColor : UIColor = .white
        
        public var editingCloseButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slCloseButton.image.withRenderingMode(.alwaysTemplate)
        public var editingCloseButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        public var editingCloseButtonIconTintColor : UIColor = .white
        
        public var nextButtonTitle : String = ShopLiveShortformEditorSDKStrings.Editor.Main.Btn.Next.shoplive
        public var nextButtonCornerRadius : CGFloat = 20
        
        public var videoSpeedButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcSpeedometer.image.withRenderingMode(.alwaysTemplate)
        public var videoSpeedButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 13, right: 10)
        public var videoSpeedButtonIconTintColor : UIColor = .white
        
        public var videoSoundButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcEditUnmute.image.withRenderingMode(.alwaysTemplate)
        public var videoSoundButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        public var videoSoundButtonIconTintColor : UIColor = .white
        
        public var videoCropButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcCrop.image.withRenderingMode(.alwaysTemplate)
        public var videoCropButtonIconPadding : UIEdgeInsets =  UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        public var videoCropButtonIconTintColor : UIColor = .white
        
        public var videoFilterButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcFilter.image.withRenderingMode(.alwaysTemplate)
        public var videoFilterButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        public var videofilterButtonIconTintColor : UIColor = .white
        
        public var sliderIndicatorCornerRadius : CGFloat = 2
        
        
        public var cancelPopupCornerRadius : CGFloat = 16
        public var cancelPopupButtonCornerRadius : CGFloat = 10
        public var cancelPopupCloseButtonBackgroundColor : UIColor = .white
        public var cancelPopupCloseButtonTextColor : UIColor = .black
        public var cancelPopupConfirmButtonBackgroundColor : UIColor = .init(red: 51, green: 51, blue: 51)
        public var cancelPopupConfirmButtonTextColor : UIColor = .white
    }
    
    public class EditorFilterConfig {
        public static let global = EditorFilterConfig()
        
        var videoPlayerCornerRadius : CGFloat = 20
        
        var closeButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slCloseButton.image.withRenderingMode(.alwaysTemplate)
        var closeButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        var closeButtonIconTintColor : UIColor = .white
        
        public var playButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcPlay.image.withRenderingMode(.alwaysTemplate)
        public var playButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        public var playButtonIconTintColor : UIColor = .white
        
        public var pauseButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcPause.image.withRenderingMode(.alwaysTemplate)
        public var pauseButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        public var pauseButtonIconTintColor : UIColor = .white
        
        
        public var confirmButtonCornerRadius : CGFloat = 20
        public var confirmButtonBackgroundColor : UIColor = .white
        public var confirmButtonTextColor : UIColor =  .black
        
        public var sliderThumbViewColor : UIColor = .white
        public var sliderCornerRaidus : CGFloat = 24
        
        public var filterCellCornerRadius : CGFloat = 12
        public var selectedCellBorderColor : UIColor = .white
        
    }

    public class EditorCropConfig {
        public static let global = EditorCropConfig()
        
        var videoPlayerCornerRadius : CGFloat = 20
        
        var closeButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slCloseButton.image.withRenderingMode(.alwaysTemplate)
        var closeButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        var closeButtonIconTintColor : UIColor = .white
        
        public var playButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcPlay.image.withRenderingMode(.alwaysTemplate)
        public var playButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        public var playButtonIconTintColor : UIColor = .white
        
        public var pauseButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcPause.image.withRenderingMode(.alwaysTemplate)
        public var pauseButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        public var pauseButtonIconTintColor : UIColor = .white
        
        public var confirmButtonCornerRadius : CGFloat = 20
        public var confirmButtonBackgroundColor : UIColor = .white
        public var confirmButtonTextColor : UIColor =  .black
    }
    
    public class EditorCoverPickerConfig {
        public static let global = EditorCoverPickerConfig()
        
        var videoPlayerCornerRadius : CGFloat = 20
        
        var closeButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slBackArrow.image.withRenderingMode(.alwaysTemplate)
        var closeButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        var closeButtonIconTintColor : UIColor = .white
        
        public var confirmButtonTitle : String = ShopLiveShortformEditorSDKStrings.Editor.Cover.Picker.Btn.Confirm.shoplive
        public var confirmButtonBackgroundColor : UIColor = .white
        public var confirmButtonTextColor : UIColor = .black
        public var confirmButtonCornerRadius : CGFloat = 20
        
        public var thumbnailSliderCornerRadius : CGFloat = 8
        public var thumbnailSliderThumbViewBorderColor : UIColor = .white
        
        public var cameraRollButtonBackgroundColor : UIColor = .white
        public var cameraRollButtonTextColor : UIColor = .black
        public var cameraRollButtonCornerRadius : CGFloat = 22
        
    }
}

