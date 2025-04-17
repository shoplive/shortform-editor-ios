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
    
    private var coverPickerBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("CoverPicker", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        return btn
    }()
    
    
    private var mediaPickerVideo : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("MediaPickerVideo", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        return btn
    }()
    
    private var mediaPickerImage : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("MediaPickerImage", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        return btn
    }()
    
    enum Mode {
        case galleryAndEditor
        case editorOnly
        case coverPicker
        case mediaPickerVideo
        case mediaPickerImage
    }
    
    private var currentMode : Mode = .galleryAndEditor
    
    weak var vc : ViewController?
    let picker = UIImagePickerController()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        
        dimBtn.addTarget(self, action: #selector(dimBtnTapped(sender: )), for: .touchUpInside)
        shortformEditorBtn.addTarget(self, action: #selector(shortformBtnTapped(sender: )), for: .touchUpInside)
        onlyEditorBtn.addTarget(self, action: #selector(editorBtnTapped(sender: )), for: .touchUpInside)
//        bytePlusBtn.addTarget(self, action: #selector(bytePlusBtnTapped(sender: )), for: .touchUpInside)
        coverPickerBtn.addTarget(self, action: #selector(coverPickerBtnTapped(sender: )), for: .touchUpInside)
        mediaPickerVideo.addTarget(self, action: #selector(mediaPickerVideotapped(sender: )), for: .touchUpInside)
        mediaPickerImage.addTarget(self, action: #selector(mediaPickerImagetapped(sender: )), for: .touchUpInside)
        picker.delegate = self
        
        let mediConfig = ShopLiveShortformEditor.MediaPickerConfig.global
        mediConfig.cellCornerRadius = 0
        let mainConfig = ShopLiveShortformEditor.EditorMainConfig.global
        mainConfig.titleTextFont = OptionSettingModel.specificFont
        mainConfig.nextButtonTitleFont = OptionSettingModel.specificFont
        mainConfig.popupCloseButtonTextFont = OptionSettingModel.specificFont
        mainConfig.popupConfirmButtonTextFont = OptionSettingModel.specificFont
        mainConfig.nextButtonBackgroundColor = .white
        mainConfig.nextButtonCornerRadius = 4
        mainConfig.nextButtonTitleColor = .black
        mainConfig.popupCornerRadius = 4
        mainConfig.popupButtonCornerRadius = 4
        mainConfig.videoPlayerCornerRadius = 0
        mainConfig.backButtonBackgroundColor = .blue
        mainConfig.videoSoundButtonBackgroundColor = .blue
        mainConfig.videoSpeedButtonBackgroundColor = .blue
        mainConfig.videoCropButtonBackgroundColor = .blue
        mainConfig.videofilterButtonBackgroundColor = .blue
        mainConfig.sliderHandleCornerRadius = 8
        

        let volumeConfig = ShopLiveShortformEditor.EditorVolumeConfig.global
        volumeConfig.confirmButtonBackgroundColor = .white
        volumeConfig.confirmButtonCornerRadius = 4
        volumeConfig.sliderCornerRadius = 4
        volumeConfig.sliderBackgroundColor = .white
        volumeConfig.sliderThumbViewColor = .black
        
        let coverPickerConfig = ShopLiveShortformEditor.EditorCoverPickerConfig.global
        coverPickerConfig.confirmButtonTitleFont = OptionSettingModel.specificFont
        coverPickerConfig.cropColor = .blue
        coverPickerConfig.sliderThumbColor = .blue
        coverPickerConfig.sliderCornerRadius = 4
        coverPickerConfig.sliderThumbCornerRadius = 4
        
        coverPickerConfig.confirmButtonCornerRadius = 4
        coverPickerConfig.confirmButtonBackgroundColor = .white
        coverPickerConfig.cameraRollButtonCornerRadius = 4
        coverPickerConfig.videoPlayerCornerRadius = 0
        coverPickerConfig.backButtonBackgroundColor = .blue
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    @objc func dimBtnTapped(sender : UIButton) {
        self.alpha = 0
    }
    
    
    @objc func shortformBtnTapped(sender : UIButton) {
        guard let vc = self.vc else { return }
        setSpecificFont()
        ShopLiveMediaPicker
            .shared
            .setDelegate(self)
            .build(type: .video) { [weak self] mediaPicker in
                guard let self = self else { return }
                guard let vc = self.vc else { return }
                let view = UINavigationController(rootViewController: mediaPicker)
                view.modalPresentationStyle = .fullScreen
                self.vc?.present(view, animated: true)
            }
    }
    
    @objc func editorBtnTapped(sender : UIButton) {
        self.currentMode = .editorOnly
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeMovie as String]
        vc?.present(picker, animated: true)
    }
    
    @objc func bytePlusBtnTapped(sender : UIButton) {
//        guard let vc = self.vc else { return }
//        ShopLiveBytePlus.shared
//            .start(vc: vc,delegate: self)
    }
    
    @objc func coverPickerBtnTapped(sender : UIButton) {
        self.currentMode = .coverPicker
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeMovie as String]
        vc?.present(picker, animated: true)
    }
    
    @objc func mediaPickerVideotapped(sender : UIButton) {
        guard let vc = vc else { return }
        self.currentMode = .mediaPickerVideo
        ShopLiveMediaPicker.shared
            .setDelegate(vc)
            .setConfiguration(.init(videoDurationOption: .init(minVideoDuration: 3,maxVideoDuration: 90,invalidDurationToastMessage: "custom_toast_message_for_test")))
            .setPermissionHandler(nil)
            .build(type: .video, completion: { [weak self] mediaPickerViewController in
                guard let self = self else { return }
                let nav = UINavigationController(rootViewController: mediaPickerViewController)
                self.vc?.mediaPickerViewController = mediaPickerViewController
                self.vc?.present(nav, animated: true)
            })
    }
    
    @objc func mediaPickerImagetapped(sender : UIButton) {
        guard let vc = vc else { return }
        self.currentMode = .mediaPickerImage
        ShopLiveMediaPicker.shared
            .setDelegate(vc)
            .setPermissionHandler(nil)
            .build(type: .image, completion: { [weak self] mediaPickerViewController in
                guard let self = self else { return }
                let nav = UINavigationController(rootViewController: mediaPickerViewController)
                self.vc?.mediaPickerViewController = mediaPickerViewController
                self.vc?.present(nav, animated: true)
            })
    }
    
}
extension EditorOptionPopUp {
    private func setLayout() {
        self.addSubview(dimBtn)
        self.addSubview(boxView)
        self.addSubview(stack)
        stack.addArrangedSubview(shortformEditorBtn)
        stack.addArrangedSubview(onlyEditorBtn)
        stack.addArrangedSubview(coverPickerBtn)
        stack.addArrangedSubview(mediaPickerVideo)
        stack.addArrangedSubview(mediaPickerImage)
        
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
            onlyEditorBtn.heightAnchor.constraint(equalToConstant: 40),
            coverPickerBtn.heightAnchor.constraint(equalToConstant: 40),
            mediaPickerVideo.heightAnchor.constraint(equalToConstant: 40),
            mediaPickerImage.heightAnchor.constraint(equalToConstant: 40),
            
            boxView.topAnchor.constraint(equalTo: stack.topAnchor,constant: -20),
            boxView.leadingAnchor.constraint(equalTo: stack.leadingAnchor,constant: -20),
            boxView.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: 20),
            boxView.bottomAnchor.constraint(equalTo: stack.bottomAnchor,constant: 20),
        ])
    }
    
    private func setSpecificFont() {
        let mainConfig = ShopLiveShortformEditor.EditorMainConfig.global
        mainConfig.titleTextFont = OptionSettingModel.specificFont
        mainConfig.nextButtonTitleFont = OptionSettingModel.specificFont
        mainConfig.popupCloseButtonTextFont = OptionSettingModel.specificFont
        mainConfig.popupConfirmButtonTextFont = OptionSettingModel.specificFont
        
        let coverPickerConfig = ShopLiveShortformEditor.EditorCoverPickerConfig.global
        coverPickerConfig.confirmButtonTitleFont = OptionSettingModel.specificFont
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
        if self.currentMode == .editorOnly {
            self.openShopLiveEditorOnly(localUrl: videoUrl)
        }
        else if self.currentMode == .coverPicker {
            self.openCoverPicker(videoUrl: videoUrl)
        }
    }
    
    private func openShopLiveEditorOnly(localUrl : URL) {
        guard let vc = self.vc else { return }
       
        
        
        let cropOption = ShopliveVideoEditorAspectRatio(width: OptionSettingModel.editorWidth,
                                                        height: OptionSettingModel.editorheight,
                                                        isFixed: OptionSettingModel.editorIsFixed)

        let trimOption = ShopliveVideoEditorTrimOption(minVideoDuration: OptionSettingModel.editorMinVideoDuration,
                                                       maxVideoDuration: OptionSettingModel.editorMaxVideoDuration)
        
        let videoOutPutOption = ShopLiveShortformEditorVideoOuputOption(videoOutputQuality: .max,
                                                                        videoOutputResoltuion: ._1080)
        
        
        let visibleContents = ShopLiveShortFormEditorVisibleContent(isDescriptionVisible: OptionSettingModel.editorShowDescription,
                                                                    isTagsVisible: OptionSettingModel.editorShowTags,
                                                                    editOptions: [.crop,.filter,.playBackSpeed,.volume])
        
        
        ShopliveVideoEditor.shared
            .setPermissionHandler(nil)
            .setConfiguration(.init(videoCropOption: cropOption,
                                    videoOutputOption: videoOutPutOption,
                                    videoTrimOption: trimOption,
                                    visibleContents: visibleContents))
            .setDelegate(vc)
            .build(data: .init(videoUrl: localUrl,isCreatedShortform: true), completion: { [weak self] editorViewController in
                guard let self = self else { return }
                let nav = UINavigationController(rootViewController: editorViewController)
                nav.navigationBar.isHidden = true
                nav.modalPresentationStyle = .fullScreen
                self.vc?.editorViewController = editorViewController
                self.vc?.present(nav, animated: true)
            })
    }
    
    private func openCoverPicker(videoUrl : URL) {
        guard let vc = self.vc else { return }
        
        let cropOption = ShopLiveShortFormEditorAspectRatio(width: OptionSettingModel.editorWidth,
                                                        height: OptionSettingModel.editorheight,
                                                        isFixed: OptionSettingModel.editorIsFixed)
        
        let visibleActionButton = ShopLiveCoverPickerVisibleActionButton(editOptions: [.crop])
        
        ShopLiveCoverPicker.shared
            .setConfiguration(.init(cropOption: cropOption,
                                    visibleActionButton: visibleActionButton))
            .setDelegate(vc)
            .build(data: .init(videoUrl: videoUrl,shortsId: nil), completion: { [weak self] coverPickerViewController in
                guard let self = self else { return }
                let nav = UINavigationController(rootViewController: coverPickerViewController)
                nav.navigationBar.isHidden = true
                nav.modalPresentationStyle = .fullScreen
                self.vc?.coverPickerViewController = nav
                self.vc?.present(nav, animated: true)
            })
    }
}

extension EditorOptionPopUp : ShopLiveMediaPickerDelegate {
    func onShopLiveMediaPickerCancelled(picker: UIViewController?) {
        if let nav = picker?.navigationController {
            nav.dismiss(animated: true)
        }
    }
    
    func onShopLiveMediaPickerDidPickVideo(picker: UIViewController?, absoluteUrl: URL, relativeUrl: URL) {
        let cropOption = ShopliveVideoEditorAspectRatio(width: OptionSettingModel.editorWidth,
                                                        height: OptionSettingModel.editorheight,
                                                        isFixed: OptionSettingModel.editorIsFixed)

        let trimOption = ShopliveVideoEditorTrimOption(minVideoDuration: OptionSettingModel.editorMinVideoDuration,
                                                       maxVideoDuration: OptionSettingModel.editorMaxVideoDuration)
        
        let videoOutPutOption = ShopLiveShortformEditorVideoOuputOption(videoOutputQuality: .max,
                                                                        videoOutputResoltuion: ._1080)
        
        
        let visibleContents = ShopLiveShortFormEditorVisibleContent(isDescriptionVisible: OptionSettingModel.editorShowDescription,
                                                                    isTagsVisible: OptionSettingModel.editorShowTags,
                                                                    editOptions: [.crop,.filter,.playBackSpeed,.volume])
        
        
        ShopliveVideoEditor.shared
            .setPermissionHandler(nil)
            .setConfiguration(.init(videoCropOption: cropOption,
                                    videoOutputOption: videoOutPutOption,
                                    videoTrimOption: trimOption,
                                    visibleContents: visibleContents))
            .setDelegate(self)
            .build(data: .init(videoUrl: absoluteUrl,isCreatedShortform: true), completion: { [weak self] editorViewController in
                guard let self = self else { return }
                picker?.navigationController?.pushViewController(editorViewController, animated: true)
            })
    }
    
}
extension EditorOptionPopUp : ShopLiveVideoEditorDelegate {
    func onShopLiveVideoEditorCancelled(editor: UIViewController?) {
        editor?.navigationController?.popViewController(animated: true)
    }
    
    func onShopLiveVideoEditorUploadSuccess(editor: UIViewController?, result: ShopliveEditorResultData?) {
        let cropOption = ShopLiveShortFormEditorAspectRatio(width: OptionSettingModel.editorWidth,
                                                        height: OptionSettingModel.editorheight,
                                                        isFixed: OptionSettingModel.editorIsFixed)
        
        let visibleActionButton = ShopLiveCoverPickerVisibleActionButton(editOptions: [.crop])
        guard let result = result,
              let localVideoUrlString = result.localVideoUrl else { return }
        let videoUrl = URL(fileURLWithPath: localVideoUrlString)
        
        ShopLiveCoverPicker.shared
            .setConfiguration(.init(cropOption: cropOption,
                                    visibleActionButton: visibleActionButton))
            .setDelegate(self)
            .build(data: .init(videoUrl: videoUrl,shortsId: result.shortsId), completion: { [weak self] coverPickerViewController in
                guard let self = self else { return }
                editor?.navigationController?.pushViewController(coverPickerViewController, animated: true)
            })
    }
    
}
extension EditorOptionPopUp : ShopLiveCoverPickerDelegate {
    
    
    func onShopLiveCoverPickerCancelled(picker: UIViewController?) {
        picker?.navigationController?.popViewController(animated: true)
    }
    
    func onShopLiveCoverPickerCoverImageSuccess(picker: UIViewController?, image: UIImage?) {
        picker?.navigationController?.dismiss(animated: true)
        
    }
    
    func onShopLiveCoverPickerUploadSuccess(picker: UIViewController?, result: ShopliveEditorResultData?) {
        if let nav = picker?.navigationController {
            nav.dismiss(animated: true)
        }
    }
    
}
