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
        
        if let mediaPickerOption = configuration?.videoDurationOption {
            ShopLiveEditorConfigurationManager.shared.mediaPickerVideoDurationOption = mediaPickerOption
        }
        
        if let visibleContents = configuration?.visibleContents {
            ShopLiveEditorConfigurationManager.shared.visibleContents = visibleContents
        }
        
        if let videoOutputOption = configuration?.videoOutputOption {
            ShopLiveEditorConfigurationManager.shared.videoOutputOption = videoOutputOption
        }
        
        if let videoUploadOption = configuration?.videoUploadOption {
            ShopLiveEditorConfigurationManager.shared.videoUploadOption = videoUploadOption
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
        public var confirmButtonTextWeight: UIFont.Weight = .bold
        public var confirmButtonTextSize: CGFloat = 16
        
        public var sliderThumbViewColor : UIColor = .white
        public var sliderCornerRadius : CGFloat = 24
        public var sliderBackgroundColor : UIColor = .init(white: 1, alpha: 0.2)
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
        public var confirmButtonTextWeight: UIFont.Weight = .bold
        public var confirmButtonTextSize: CGFloat = 16
        
        public var sliderThumbViewColor : UIColor = .white
        public var sliderCornerRadius : CGFloat = 24
        public var sliderBackgroundColor : UIColor = .init(white: 1, alpha: 0.2)
    }
    
    public class EditorMainConfig {
        public static let global = EditorMainConfig()
        
        public var videoPlayerCornerRadius : CGFloat = 24
        
        public var titleTextFont: UIFont? = nil
        public var titleTextColor : UIColor = .white
        public var titleTextWeight : UIFont.Weight = .medium
        public var titleTextSize : CGFloat = 16
        
        public var bottomTitleTextColor: UIColor = .white
        public var bottomTitleTextWeight: UIFont.Weight = .medium
        public var bottomTitleTextSize: CGFloat = 16
        
        public var backButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slBackArrow.image.withRenderingMode(.alwaysTemplate)
        public var backButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        public var backButtonIconTintColor : UIColor =  .white
        public var backButtonBackgroundColor : UIColor? = nil
        
        public var cropColor : UIColor = .white
        
        public var editingCloseButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slCloseButton.image.withRenderingMode(.alwaysTemplate)
        public var editingCloseButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        public var editingCloseButtonIconTintColor : UIColor = .white
        
        public var nextButtonTitleFont: UIFont? = nil
        public var nextButtonTitle : String = ShopLiveShortformEditorSDKStrings.Editor.Main.Btn.Next.shoplive
        public var nextButtonCornerRadius : CGFloat = 20
        public var nextButtonBackgroundColor : UIColor = .clear
        public var nextButtonTitleColor : UIColor = .white
        public var nextButtonTitleWeight: UIFont.Weight = .regular
        public var nextButtonTitleSize: CGFloat = 14
        
        
        public var videoSpeedButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcSpeedometer.image.withRenderingMode(.alwaysTemplate)
        public var videoSpeedButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 13, right: 10)
        public var videoSpeedButtonIconTintColor : UIColor = .white
        public var videoSpeedButtonBackgroundColor : UIColor?
        
        public var videoSoundButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcEditUnmute.image.withRenderingMode(.alwaysTemplate)
        public var videoSoundButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        public var videoSoundButtonIconTintColor : UIColor = .white
        public var videoSoundButtonBackgroundColor : UIColor?
        
        public var videoCropButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcCrop.image.withRenderingMode(.alwaysTemplate)
        public var videoCropButtonIconPadding : UIEdgeInsets =  UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        public var videoCropButtonIconTintColor : UIColor = .white
        public var videoCropButtonBackgroundColor : UIColor?
        
        public var videoFilterButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slIcFilter.image.withRenderingMode(.alwaysTemplate)
        public var videoFilterButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        public var videofilterButtonIconTintColor : UIColor = .white
        public var videofilterButtonBackgroundColor : UIColor?
        
        public var sliderIndicatorCornerRadius : CGFloat = 2
        public var sliderIndicatorColor : UIColor = .white
        public var sliderHandleCornerRadius : CGFloat = 4
        public var sliderHandleBackgroundColor : UIColor = .white
        public var sliderHandleBarColor : UIColor = .black
        
        
        public var popupCornerRadius : CGFloat = 16
        public var popupButtonCornerRadius : CGFloat = 10
        public var popupCloseButtonTextFont: UIFont? = nil
        public var popupCloseButtonBackgroundColor : UIColor = .white
        public var popupCloseButtonTextColor : UIColor = .black
        public var popupCloseButtonTextWeight: UIFont.Weight = .bold
        public var popupCloseButtonTextSize: CGFloat = 15
        
        public var popupConfirmButtonTextFont: UIFont? = nil
        public var popupConfirmButtonBackgroundColor : UIColor = .init(red: 51, green: 51, blue: 51)
        public var popupConfirmButtonTextColor : UIColor = .white
        public var popupConfirmButtonTextWeight: UIFont.Weight = .bold
        public var popupConfirmButtonTextSize: CGFloat = 15
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
        public var confirmButtonTextWeight: UIFont.Weight = .bold
        public var confirmButtonTextSize: CGFloat = 16
        
        public var sliderThumbViewColor : UIColor = .white
        public var sliderCornerRadius : CGFloat = 24
        public var sliderBackgroundColor : UIColor = .init(white: 1, alpha: 0.2)
        
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
        public var confirmButtonTextWeight: UIFont.Weight = .bold
        public var confirmButtonTextSize: CGFloat = 16
    }
    
    public class EditorCoverPickerConfig {
        public static let global = EditorCoverPickerConfig()
        
        public var videoPlayerCornerRadius : CGFloat = 20
        
        public var backButtonIcon : UIImage = ShopLiveShortformEditorSDKAsset.slBackArrow.image.withRenderingMode(.alwaysTemplate)
        public var backButtonIconPadding : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        public var backButtonIconTintColor : UIColor = .white
        public var backButtonBackgroundColor : UIColor? = nil
        
        public var confirmButtonTitleFont: UIFont? = nil
        public var confirmButtonTitle : String = ShopLiveShortformEditorSDKStrings.Editor.Cover.Picker.Btn.Confirm.shoplive
        public var confirmButtonBackgroundColor : UIColor = .white
        public var confirmButtonTextColor : UIColor = .black
        public var confirmButtonCornerRadius : CGFloat = 20
        public var confirmButtonTitleWeight: UIFont.Weight = .medium
        public var confirmButtonTitleSize: CGFloat = 14
        
        public var sliderCornerRadius : CGFloat = 8
        public var sliderThumbCornerRadius : CGFloat = 8
        public var sliderThumbColor : UIColor = .white
        
        
        public var cropColor : UIColor = .white
        
        public var cameraRollButtonBackgroundColor : UIColor = .white
        public var cameraRollButtonTextColor : UIColor = .black
        public var cameraRollButtonCornerRadius : CGFloat = 22
        public var cameraRollButtonTitle : String = ShopLiveShortformEditorSDKStrings.Editor.Select.Gallery.shoplive
        
    }
}

