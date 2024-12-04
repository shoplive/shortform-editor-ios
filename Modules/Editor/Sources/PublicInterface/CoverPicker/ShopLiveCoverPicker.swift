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
    
    private weak var delegate : ShopLiveCoverPickerDelegate?
    private weak var permissionHandler : ShopLivePermissionHandler?
    
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
    
    public func build(data : ShopLiveCoverPickerData, completion : @escaping(UIViewController) -> ()) {
        self.callConfigAPI {
            let vc = Self.shared.showPickerViewController( data: data)
            completion(vc)
        }
    }
    
    private func showPickerViewController( data : ShopLiveCoverPickerData) -> UIViewController {
        let pickerVc = ShopLiveCoverPickerViewController()
        pickerVc.action( .setShopLiveCoverPickerData(data) )
        pickerVc.action( .setPlayer )
        pickerVc.action(. initializeSliderView )
        Self.shared.bindCoverPickerViewController(pickerController: pickerVc)
        return pickerVc
    }
    
    private func callConfigAPI(completion : @escaping () -> ()) {
        ShortFormUploadConfigurationInfosManager.shared.callShortsConfigurationAPI { result in
            switch result {
            case .success():
                DispatchQueue.main.async{
                    completion()
                }
            case .failure(let error):
                Self.shared.delegate?.onShopLiveCoverPickerError?(picker: nil, error: error)
            }
        }
    }
    
    public func cleanUpMemory() {
        SLFileManager.deleteEditorDirectoryFiles()
        Self.shared.permissionHandler = nil
        Self.shared.delegate = nil
    }
}
extension ShopLiveCoverPicker {
    private func bindCoverPickerViewController(pickerController : ShopLiveCoverPickerViewController) {
        pickerController.resultHandler = { result in
            switch result {
            case .backBtnTapped:
                Self.shared.onPickerControllerBackBtnTapped(picker: pickerController)
            case .onFinished:
                Self.shared.onPickerControllerFinished(picker: pickerController)
            case .onError(let error):
                Self.shared.onPickerControllerError(picker: pickerController, error: error)
            case .onSuccessImage(let image):
                Self.shared.onPickerControllerOnSuccessImage(picker: pickerController, image: image)
            case .onSuccessUpload(result: let result):
                Self.shared.onPickerControllerOnSuccessUpload(picker: pickerController, result: result)
            case .onEvent(name: let name, payload: let payload):
                Self.shared.onPickerControllerOnEvent(picker: pickerController, name: name, payload: payload)
            }
        }
    }
    
    private func onPickerControllerBackBtnTapped(picker: UIViewController) {
        Self.shared.delegate?.onShopLiveCoverPickerCancelled?(picker: picker)
    }
    
    private func onPickerControllerFinished(picker: UIViewController) {
        /* 고객사가 그냥 핸들링 하는 쪽으로 해야함 */
    }
    
    private func onPickerControllerError(picker: UIViewController,error : ShopLiveCommonError) {
        Self.shared.delegate?.onShopLiveCoverPickerError?(picker: picker, error: error)
    }
    
    private func onPickerControllerOnSuccessImage(picker: UIViewController,image : UIImage?) {
        Self.shared.delegate?.onShopLiveCoverPickerCoverImageSuccess?(picker: picker, image: image)
    }
    
    private func onPickerControllerOnSuccessUpload(picker: UIViewController,result : ShopLiveEditorResultInternalData?) {
        Self.shared.delegate?.onShopLiveCoverPickerUploadSuccess?(picker: picker, result: result?.convertToClass())
    }
    
    private func onPickerControllerOnEvent(picker: UIViewController,name : EventTrace, payload : [String : Any]?) {
        Self.shared.delegate?.onShopLiveCoverPickerOnEvent?(picker: picker, name: name.rawValue, payload: payload)
    }
}
