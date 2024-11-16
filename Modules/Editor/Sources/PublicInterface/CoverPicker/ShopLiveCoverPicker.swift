//
//  ShopLiveCoverPicker.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/7/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon


public class ShopLiveCoverPicker {
    public static let shared = ShopLiveCoverPicker()
    private init() { }
    
    
    private var delegate : ShopLiveCoverPickerDelegate?
    private var permissionHandler : ShopLivePermissionHandler?
    private var navigationController : SLPickerNavigationController?
    
    @discardableResult
    public func setPermissionHandler(_ permissionHandler : ShopLivePermissionHandler) -> Self {
        Self.shared.permissionHandler = permissionHandler
        return self
    }
    
    @discardableResult
    public func setDelegate(_ delegate : ShopLiveCoverPickerDelegate?) -> Self {
        Self.shared.delegate = delegate
        return self
    }
    
    @discardableResult
    public func setConfiguration(_ configuration : ShopLiveCoverPickerConfiguration?) -> Self {
        if let videoCropOption = configuration?.cropOption {
            ShopLiveEditorConfigurationManager.shared.videoCropOption = videoCropOption
        }
        if let visibleActionButton = configuration?.visibleActionButton {
            ShopLiveEditorConfigurationManager.shared.coverPickerVisibleActionButton = visibleActionButton
        }
        return self
    }
    
    public func start(_ vc : UIViewController, data : ShopLiveCoverPickerData) {
        self.callConfigAPI {
            let pickerVc = ShopLiveCoverPickerViewController()
            pickerVc.action( .setShopLiveCoverPickerData(data) )
            pickerVc.action( .setPlayer )
            pickerVc.action(. initializeSliderView )
            Self.shared.bindCoverPickerViewController(pickerController: pickerVc)
            let navigationController = SLPickerNavigationController(rootViewController: pickerVc)
            Self.shared.navigationController = navigationController
            navigationController.isNavigationBarHidden = true
            navigationController.modalPresentationCapturesStatusBarAppearance = true
            navigationController.modalPresentationStyle = .overFullScreen
            vc.present(navigationController, animated: true)
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
                DispatchQueue.main.async{
                    completion()
                }
            case .failure(let error):
                Self.shared.delegate?.onShopLiveCoverPickerError?(error: error)
            }
        }
    }
}
extension ShopLiveCoverPicker {
    private func bindCoverPickerViewController(pickerController : ShopLiveCoverPickerViewController) {
        pickerController.resultHandler = { result in
            switch result {
            case .backBtnTapped:
                Self.shared.onPickerControllerBackBtnTapped()
            case .onFinished:
                Self.shared.onPickerControllerFinished()
            case .onError(let error):
                Self.shared.onPickerControllerError(error: error)
            case .onSuccessImage(let image):
                Self.shared.onPickerControllerOnSuccessImage(image: image)
            case .onSuccessUpload(shortsId: let shortsId):
                Self.shared.onPickerControllerOnSuccessUpload(shortsId: shortsId)
            }
        }
    }
    
    private func onPickerControllerBackBtnTapped() {
        Self.shared.close()
        Self.shared.delegate?.onShopLiveCoverPickerCancelled?()
    }
    
    private func onPickerControllerFinished() {
        Self.shared.close()
    }
    
    private func onPickerControllerError(error : ShopLiveCommonError) {
        Self.shared.delegate?.onShopLiveCoverPickerError?(error: error)
    }
    
    private func onPickerControllerOnSuccessImage(image : UIImage?) {
        Self.shared.delegate?.onShopLiveCoverPickerCoverImageSuccess?(image: image)
    }
    
    private func onPickerControllerOnSuccessUpload(shortsId : String) {
        Self.shared.delegate?.onShopLiveCoverPickerUploadSuccess?(shortsId: shortsId)
    }
}
