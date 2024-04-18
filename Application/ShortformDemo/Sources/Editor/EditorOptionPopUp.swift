//
//  EditorOptionPopUp.swift
//  ShortformDemo
//
//  Created by sangmin han on 3/26/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import ShopLiveShortformEditorSDK
import UniformTypeIdentifiers
import MobileCoreServices
import Photos
//import EffectOneKit
import Toast


class EditorOptionPopUp : UIView {
    
    private var dimBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .init(white: 0, alpha: 0.5)
        return btn
    }()
    
    private var boxView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy private var stack : UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    private var shortformEditorBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("ShortformEditor", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        return btn
    }()
    
    private var galleryAndEditorBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("GalleryAndEditor", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        return btn
    }()
    
    private var onlyEditorBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("EditorOnly", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        return btn
    }()
    
    
    weak var vc : ViewController?
    let picker = UIImagePickerController()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        
        dimBtn.addTarget(self, action: #selector(dimBtnTapped(sender: )), for: .touchUpInside)
        shortformEditorBtn.addTarget(self, action: #selector(shortformBtnTapped(sender: )), for: .touchUpInside)
        galleryAndEditorBtn.addTarget(self, action: #selector(galleryAndEditorBtnTapped(sender: )), for: .touchUpInside)
        onlyEditorBtn.addTarget(self, action: #selector(editorBtnTapped(sender: )), for: .touchUpInside)
//        bytePlusBtn.addTarget(self, action: #selector(bytePlusBtnTapped(sender: )), for: .touchUpInside)
        picker.delegate = self
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    @objc func dimBtnTapped(sender : UIButton) {
        self.alpha = 0
    }
    
    
    @objc func shortformBtnTapped(sender : UIButton) {
        guard let vc = self.vc else { return }
        let cropOption = ShopLiveShortFormEditorAspectRatio(width: OptionSettingModel.editorWidth,
                                                            height: OptionSettingModel.editorheight,
                                                            isFixed: OptionSettingModel.editorIsFixed)
        
        let visibleContents = ShopLiveShortFormEditorVisibleContent(isDescriptionVisible: OptionSettingModel.editorShowDescription,
                                                                    isTagsVisible: OptionSettingModel.editorShowTags)
        
        ShopLiveShortformEditor.shared
            .setPermissionHandler(nil)
            .setConfiguration(ShopLiveShortformEditorConfiguration(videoCropOption: cropOption ,
                                                                   visibleContents: visibleContents,
                                                                   minVideoDuration: OptionSettingModel.editorMinVideoDuration,
                                                                   maxVideoDuration: OptionSettingModel.editorMaxVideoDuration))
            .setDelegate(delegate: vc)
            .start(vc)
        
    }
    
    @objc func galleryAndEditorBtnTapped(sender : UIButton) {
        guard let vc = self.vc else { return }
        let cropOption = ShopliveVideoEditorAspectRatio(width: OptionSettingModel.editorWidth,
                                                        height: OptionSettingModel.editorheight,
                                                        isFixed: OptionSettingModel.editorIsFixed)
        
        ShopliveVideoEditor.shared
            .setPermissionHandler(nil)
            .setConfiguration(.init(videoCropOption: cropOption))
            .setDelegate(vc)
            .start(vc)
        
    }
    
    @objc func editorBtnTapped(sender : UIButton) {
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeMovie as String]
        vc?.present(picker, animated: true)
    }
    
    @objc func bytePlusBtnTapped(sender : UIButton) {
        guard let vc = self.vc else { return }
//        ShopLiveBytePlus.shared
//            .start(vc: vc,delegate: self)
    }
    
}
extension EditorOptionPopUp {
    private func setLayout() {
        self.addSubview(dimBtn)
        self.addSubview(boxView)
        self.addSubview(stack)
        stack.addArrangedSubview(shortformEditorBtn)
        stack.addArrangedSubview(galleryAndEditorBtn)
        stack.addArrangedSubview(onlyEditorBtn)
//        stack.addArrangedSubview(bytePlusBtn)
        
        NSLayoutConstraint.activate([
            dimBtn.topAnchor.constraint(equalTo: self.topAnchor),
            dimBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dimBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            dimBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            
            stack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: 200),
            stack.heightAnchor.constraint(lessThanOrEqualToConstant: 500),
            
            shortformEditorBtn.heightAnchor.constraint(equalToConstant: 40),
            galleryAndEditorBtn.heightAnchor.constraint(equalToConstant: 40),
            onlyEditorBtn.heightAnchor.constraint(equalToConstant: 40),
//            bytePlusBtn.heightAnchor.constraint(equalToConstant: 40),
        
            boxView.topAnchor.constraint(equalTo: stack.topAnchor,constant: -20),
            boxView.leadingAnchor.constraint(equalTo: stack.leadingAnchor,constant: -20),
            boxView.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: 20),
            boxView.bottomAnchor.constraint(equalTo: stack.bottomAnchor,constant: 20),
        ])
    }
}
extension EditorOptionPopUp : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            self.getPHAsset(videoUrl : videoUrl)
        }
    }
    
    private func getPHAsset(videoUrl : URL) {
        var placeHolderAsset : PHObjectPlaceholder? = nil
        PHPhotoLibrary.shared().performChanges { [weak self] in
            guard let self = self else { return }
            let newAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoUrl)
            placeHolderAsset = newAssetRequest?.placeholderForCreatedAsset
            
        } completionHandler: { [weak self] isSuccess, error in
            guard let self = self else { return }
            guard let identifier = placeHolderAsset?.localIdentifier else { return }
            let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
            
            asset.firstObject?.getURL_SL(completionHandler: { [weak self] responseURL in
                guard let self = self,
                      let url = responseURL else { return }
                self.openShopLiveEditorOnly(videoURl : url)
            })
        }
        
    }
    
    
    private func openShopLiveEditorOnly(videoURl : URL) {
        guard let vc = self.vc else { return }
        let cropOption = ShopliveVideoEditorAspectRatio(width: OptionSettingModel.editorWidth,
                                                        height: OptionSettingModel.editorheight,
                                                        isFixed: OptionSettingModel.editorIsFixed)
        
        ShopliveVideoEditor.shared
            .setPermissionHandler(nil)
            .setConfiguration(.init(videoCropOption: cropOption))
            .setDelegate(vc)
            .start(vc, videoPath: videoURl.path)
    }
    
    
    
}
//extension EditorOptionPopUp : ShopLiveBytePlusDelegate {
//    func videoEditorViewControllerTapNext(_ exportModel: EOExportModel, presentVC viewController: UIViewController) {
//        EOExportViewController.startExport(with: exportModel, presentVC: viewController, delegate: self)
//    }
//}
//extension EditorOptionPopUp : EOExportViewControllerDelegate {
//    func exportVideoPath(_ videoPath: String, videoImage videoImg: UIImage) {
//        guard let vc = self.vc else { return }
//        vc.view.makeToast("VideoPath \(videoPath)")
//        ShopLiveLogger.debugLog("[HASSAN LOG] bytePlusExportVideoPath \(videoPath)")
//    }
//}
