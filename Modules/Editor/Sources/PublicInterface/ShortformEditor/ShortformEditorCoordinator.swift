//
//  ShortformEditorCoordinator.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/7/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon


class ShopliveShortformCoordinator : NSObject {
    typealias ShortformEditor = ShopLiveShortformEditor
    
   
    private weak var permissionHandler : ShopLivePermissionHandler?
    private weak var editorDelegate : ShopLiveShortformEditorDelegate?
    private var ffmpegValidator = FFmpegVideoValidator()
    private var convertedVideoPath : String?
    private var parentVc : UIViewController?
    
    private var navigationController : SLPickerNavigationController?
    
    func showPhotoPicker(vc : UIViewController, permissionHandler : ShopLivePermissionHandler?, editorDelegate : ShopLiveShortformEditorDelegate?) {
        self.permissionHandler = permissionHandler
        self.editorDelegate = editorDelegate
        
        let photoPicker = SLPhotosPickerViewController(mediaType: .video, permissionDelegate: permissionHandler)
        photoPicker.delegate = self
        
        self.callFilterListAPI()
        
        self.navigationController = SLPickerNavigationController(rootViewController: photoPicker)
        navigationController?.isNavigationBarHidden = true
        navigationController?.modalPresentationCapturesStatusBarAppearance = true
        navigationController?.modalPresentationStyle = .overFullScreen
        self.parentVc = vc
        vc.present(navigationController!, animated: true)
    }
    
    
    private func callFilterListAPI() {
        DispatchQueue.global(qos: .background).async {
            ShopLiveShortformEditorFilterListManager.shared.shortformEditorDelegate = self.editorDelegate
            ShopLiveShortformEditorFilterListManager.shared.callFilterListAPI { }
        }
    }
    
    func close() {
        SLFileManager.deleteEditorDirectoryFiles()
        self.editorDelegate = nil
        self.permissionHandler = nil
        self.navigationController?.viewControllers.first?.dismiss(animated: true)
        self.navigationController?.dismiss(animated: true)
        self.navigationController = nil
    }
    
    func getPermissionHandler() -> ShopLivePermissionHandler? {
        return self.permissionHandler
    }
}

extension ShopliveShortformCoordinator : SLPhotosPickerViewControllerDelegate  {
    func photoPicker(picker: UIViewController, didSelectVideo absoluteUrl: URL, relativeUrl: URL) {
        ffmpegValidator.checkValidCodec(videoUrl: relativeUrl) { [weak self] isValidCodec in
            guard let self = self else { return }
            if isValidCodec {
                self.showSLVideoEditorViewController(video: ShortsVideo(localAbsoluteUrl: absoluteUrl, localRelativeUrl: relativeUrl))
            }
        }
    }
    
    func photoPicker(picker: UIViewController, didSelectImage url: URL) {
    }
    
    func photoPickerOnEvent(picker: UIViewController, name: EventTrace, payload: [String : Any]?) {
        editorDelegate?.onShopLiveShortformEditorOnEvent?(name: name.rawValue, payload: payload)

    }
    func photoPiker(onClose picker: UIViewController) {
        picker.dismiss(animated: true)
        self.close()
    }
}
extension ShopliveShortformCoordinator : SLVideoEditorViewControllerDelegate {
    func videoEditorError(editor: UIViewController?, error: ShopliveSDKCommon.ShopLiveCommonError) {
        editorDelegate?.onShopLiveShortformEditorError?(error: error)
    }
    
    func videoEditorOnEvent(editor: UIViewController?, name: EventTrace, payload: [String : Any]?) {
        editorDelegate?.onShopLiveShortformEditorOnEvent?(name: name.rawValue, payload: payload)
    }
    
    func videoEditorDidCancelConvertVideo(editor: UIViewController?) {
        let bundle = Bundle(for: type(of: self))
        editor?.showToast(message: "toast.cancel.encoding.title".localizedString(bundle: bundle), duration: .long)
    }
    
    func videoEditorDidFinishConvertVideo(editor: UIViewController?, videoPath: String) {
        self.convertedVideoPath = videoPath
    }
    
    func videoEditorRequestPopView(editor: UIViewController?) {
        if let nav = editor?.navigationController {
            nav.popViewController(animated: true)
        }
    }
    
    func videoEditorDidFinishUpload(editor: UIViewController?, result: ShopLiveEditorResultInternalData?) {
        guard let shortsId = result?.shortsId else {
            let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .UnexpectedError, error: nil, message: "there is no shortsId")
            editorDelegate?.onShopLiveShortformEditorError?(error: commonError)
            return
        }
        self.showCoverPicker(shortsId: shortsId,result: result)
    }
    
    func videoEditorRequestPopView() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func showSLVideoEditorViewController(video : ShortsVideo) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.navigationController?.viewControllers.filter({ $0.isKind(of: SLVideoEditorMainViewController.self) }).count == 0 else {
                return
            }
            let editor = SLVideoEditorMainViewController(video: video )
            editor.delegate = self
            self.navigationController?.pushViewController(editor, animated: true)
        }
    }
}
extension ShopliveShortformCoordinator  {
    private func showCoverPicker(shortsId : String,result : ShopLiveEditorResultInternalData?) {
        guard let videoPath = self.convertedVideoPath else { return }
        let videoUrl = URL(fileURLWithPath: videoPath)
        let pickerVc = ShopLiveCoverPickerViewController()
        let data = ShopLiveCoverPickerData(videoUrl: videoUrl, shortsId: shortsId)
        pickerVc.action( .setShopLiveCoverPickerData(data) )
        pickerVc.action( .setEditorResultData(result))
        pickerVc.action( .setPlayer )
        pickerVc.action(. initializeSliderView )
        self.bindCoverPickerViewController(pickerController: pickerVc)
        self.navigationController?.pushViewController(pickerVc, animated: true)
    }
    
    private func bindCoverPickerViewController(pickerController : ShopLiveCoverPickerViewController) {
        pickerController.resultHandler = { [weak self] result in
            switch result {
            case .backBtnTapped:
                self?.onPickerBackBtnTapped()
            case .onFinished:
                self?.onPickerControllerFinished()
            case .onError(let error):
                self?.onPickerControllerError(error: error)
            case .onSuccessImage(let image):
                self?.onPickerControllerOnSuccessImage(image: image)
            case .onSuccessUpload(result: let result):
                self?.onPickerControllerOnSuccessUpload(result: result)
            case .onEvent(name: let name, payload: let payload):
                self?.onPickerControllerOnEvent(name : name , payload : payload)
            }
        }
    }
    
    private func onPickerBackBtnTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func onPickerControllerFinished() {
        self.close()
    }
    
    private func onPickerControllerError(error : ShopLiveCommonError) {
        editorDelegate?.onShopLiveShortformEditorError?(error: error)
    }
    
    private func onPickerControllerOnSuccessImage(image : UIImage?) {
        editorDelegate?.onShopLiveShortformEditorCoverImageSuccess?(image: image)
    }
    
    private func onPickerControllerOnSuccessUpload(result : ShopLiveEditorResultInternalData? ) {
        editorDelegate?.onShopLiveShortformEditorUploadSuccess?(result: result?.convertToClass() )
    }
    
    private func onPickerControllerOnEvent(name : EventTrace , payload : [String : Any]?) {
        editorDelegate?.onShopLiveShortformEditorOnEvent?(name: name.rawValue, payload: payload)
    }
}
