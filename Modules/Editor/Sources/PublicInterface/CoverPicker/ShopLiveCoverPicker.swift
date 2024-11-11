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
    private var navigationController : UINavigationController?
    
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
    
    public func start(_ vc : UIViewController, videoUrl : URL) {
        self.callConfigAPI {
            let pickerVc = ShopLiveCoverPickerViewController()
            pickerVc.action( .setVideoUrl(videoUrl) )
            pickerVc.action( .setPlayer )
            pickerVc.action(. initializeSliderView )
            Self.shared.bindCoverPickerViewController(pickerController: pickerVc)
            let navigationController = UINavigationController(rootViewController: pickerVc)
            Self.shared.navigationController = navigationController
            navigationController.isNavigationBarHidden = true
            navigationController.modalPresentationCapturesStatusBarAppearance = true
            navigationController.modalPresentationStyle = .overFullScreen
            vc.present(navigationController, animated: true)
        }
    }
    
    public func close() {
        self.navigationController?.dismiss(animated: true)
        self.navigationController = nil
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
                delegate?.onShopLiveCoverPickerError?(error: error)
            }
        }
    }
}
extension ShopLiveCoverPicker {
    private func bindCoverPickerViewController(pickerController : ShopLiveCoverPickerViewController) {
        pickerController.resultHandler = { [weak self] result in
            switch result {
            case .onClosed:
                self?.onPickerControllerClosed()
            case .onError(let error):
                self?.onPickerControllerError(error: error)
            case .onSuccessImage(let image):
                self?.onPickerControllerOnSuccessImage(image: image)
            }
        }
    }
    
    private func onPickerControllerClosed() {
        Self.shared.delegate?.onShopLiveCoverPickerClosed?()
    }
    
    private func onPickerControllerError(error : ShopLiveCommonError) {
        Self.shared.delegate?.onShopLiveCoverPickerError?(error: error)
    }
    
    private func onPickerControllerOnSuccessImage(image : UIImage?) {
        Self.shared.delegate?.onShopLiveCoverPickerSuccess?(image: image)
    }
}
