//
//  ShopLiveCoverPickerViewController.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/5/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import ShopliveSDKCommon



class ShopLiveCoverPickerViewController : UIViewController,SLReactor {
    private let design = EditorThumbnailConfig.global
    
    private var naviBar : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    lazy private var closeBtn : SLPaddingImageButton = {
        let btn = SLPaddingImageButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .init(red: 255, green: 255, blue: 255,aa: 0.2)
        btn.layer.cornerRadius = 20
        btn.setImage(design.closeButtonIcon, for: .normal)
        btn.imageView?.tintColor = design.closeButtonIconTintColor
        btn.imageLayoutMargin = design.closeButtonIconPadding
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    private var pageTitle : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .set(size: 16, weight: ._600)
        label.text = ShopLiveShortformEditorSDKStrings.Editor.Thumbnail.Page.title
        return label
    }()
    
    lazy private var confirmBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = design.confirmButtonBackgroundColor
        btn.setTitleColor(design.confirmButtonTextColor, for: .normal)
        btn.titleLabel?.font = .set(size: 16, weight: ._600)
        btn.setTitle(ShopLiveShortformEditorSDKStrings.Editor.Thumbnail.Btn.Confirm.title, for: .normal)
        btn.layer.cornerRadius = design.confirmButtonCornerRadius
        btn.clipsToBounds = true
        return btn
    }()
    
    lazy private var cameraBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = design.cameraRollButtonBackgroundColor
        btn.setTitleColor(design.cameraRollButtonTextColor, for: .normal)
        btn.titleLabel?.font = .set(size: 16, weight: ._600)
        btn.setTitle(ShopLiveShortformEditorSDKStrings.Editor.Thumbnail.Btn.CameraRoll.title, for: .normal)
        btn.layer.cornerRadius = design.cameraRollButtonCornerRadius
        btn.clipsToBounds = true
        return btn
    }()
    
    private let playerHolder : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let playerContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var playerLayer : AVPlayerLayer?
    
    lazy private var pickerSelectedThumbnailImageView : SLCropableUIImageView = {
        let imageView = SLCropableUIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.action( .setClipsToBound(true) )
        imageView.action( .setCornerRadius(design.videoPlayerCornerRadius))
        imageView.action( .setImageViewContentMode(.scaleAspectFit))
        imageView.backgroundColor = .clear
        imageView.isHidden = true
        return imageView
    }()
    
    lazy private var photoPickerModeCloseBtn : SlBlurBGButton = {
        let btn = SlBlurBGButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(ShopLiveShortformEditorSDKAsset.slClosebutton.image.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.imageView?.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
        btn.isHidden = true
        btn.layer.cornerRadius = 14
        btn.imageLayoutMargin = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        btn.clipsToBounds = true
        return btn
    }()
    
    private lazy var thumbnailSliderView: SLThumbnailSliderView = {
        let view = SLThumbnailSliderView(containerCornerRadius: design.thumbnailSliderCornerRadius,
                                         thumbViewBorderColor: design.thumbnailSliderThumbViewBorderColor)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var loadingProgress: SLLoadingAlertController = {
        let vc = SLLoadingAlertController()
        vc.useProgress = false
        vc.setLoadingText("loading...")
//        vc.delegate = reactor
        return vc
    }()
    
    private var cancelConfirmToast : SlBlurBGLabel = {
        let view = SlBlurBGLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.label.textColor = .white
        view.label.font = .set(size: 15, weight: ._600)
        view.label.text = ShopLiveShortformEditorSDKStrings.Toast.Cancel.Uploading.title
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view._layoutMargin = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.alpha = 0
        return view
    }()
    
    enum Action {
        case setVideoUrl(URL)
        case setPlayer
        case initializeSliderView
    }
    
    enum Result {
        case onError(ShopLiveCommonError)
        case onClosed
        case onSuccessImage(UIImage?)
    }
    
    var resultHandler : ((Result) -> ())?
    
    private var picker :  SLPhotosPickerViewController?
    
    private let reactor : ShopLiveCoverPickerReactor = ShopLiveCoverPickerReactor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reactor.action( .viewDidLoad )
        self.view.backgroundColor = .black
        self.setLayout()
        self.bindReactor()
        self.bindThumbnailSliderView()
        self.bindCroppableImageView()
        
        
        cameraBtn.addTarget(self, action: #selector(cameraBtnTapped(sender: )), for: .touchUpInside)
        confirmBtn.addTarget(self, action: #selector(confirmBtnTapped(sender: )), for: .touchUpInside)
        photoPickerModeCloseBtn.addTarget(self, action: #selector(photoPickerModelCloseButtonTapped), for: .touchUpInside)
        closeBtn.addTarget(self, action: #selector(closeBtnTapped(sender: )), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated : Bool) {
        super.viewDidAppear(animated)
        reactor.action( .viewDidAppear )
        thumbnailSliderView.action( .initializeThumbView )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reactor.action( .viewDidLayoutSubView )
        self.playerLayer?.frame = playerContainerView.bounds
    }
    
    @objc func closeBtnTapped(sender : UIButton) {
        ShopLiveCoverPicker.shared.close()
    }
   
    @objc func confirmBtnTapped(sender : UIButton) {
        reactor.action( .requestOnConfirm )
    }
    
    @objc func cameraBtnTapped(sender : UIButton) {
        picker = nil
        picker = SLPhotosPickerViewController(mediaType: .image, permissionDelegate: ShopLiveShortformEditor.shared.getShoplivePermissionHandler())
        picker!.delegate = reactor
        picker!.modalPresentationStyle = .overFullScreen
        self.present(picker!, animated: true)
    }
    
    @objc func photoPickerModelCloseButtonTapped() {
        self.pickerSelectedThumbnailImageView.isHidden = true
        self.photoPickerModeCloseBtn.isHidden = true
        self.playerContainerView.isHidden = false
        self.reactor.action( .setCurrentMode(.video) )
        self.thumbnailSliderView.action( .changeThumbnailFrameToPickerImage(nil) )
    }
}
extension ShopLiveCoverPickerViewController {
    func action(_ action : Action) {
        switch action {
        case .setVideoUrl(let url):
            self.onSetVideoUrl(url: url)
        case .setPlayer:
            self.onSetPlayer()
        case .initializeSliderView:
            self.onInitializeSliderView()
        }
    }
    
    private func onSetVideoUrl(url : URL) {
        reactor.action( .setVideoUrl(url) )
    }
    
    private func onSetPlayer() {
        self.setPlayerLayer()
    }
    
    private func onInitializeSliderView() {
        guard let url = self.reactor.getVideoUrl() else { return }
        thumbnailSliderView.action( .setVideoUrl(url) )
        thumbnailSliderView.action( .initializeSliderView )
    }
    
}
extension ShopLiveCoverPickerViewController {
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .dismissPhotoPicker:
                self.onReactorDismissPhotoPicker()
            case .canceLoading:
                self.onReactorCancelLoading()
            case .didFinishLoading:
                self.onReactorDidFinishLoading()
            case .setThumbnail(let image):
                self.onReactorSetThumbnailImage(image: image)
            case .requestCropImageForCropableImageView:
                self.onReactorRequestCropImageForCropableImageView()
            }
        }
    }
    
    private func onReactorDismissPhotoPicker() {
        guard let picker = picker else { return }
        picker.dismiss(animated: true)
    }
    
    private func onReactorCancelLoading() {
        self.loadingProgress.cancelLoading = false
    }
    
    private func onReactorDidFinishLoading() {
        self.loadingProgress.finishLoading()
    }
    
    private func onReactorSetThumbnailImage(image : UIImage) {
        self.photoPickerModeCloseBtn.isHidden = false
        pickerSelectedThumbnailImageView.action( .setCropViewSize(playerContainerView.frame.size) )
        pickerSelectedThumbnailImageView.action( .setImage(image) )
        thumbnailSliderView.action( .changeThumbnailFrameToPickerImage(image) )
        pickerSelectedThumbnailImageView.isHidden = false
        playerContainerView.isHidden = true
    }
    
    private func onReactorRequestCropImageForCropableImageView() {
        pickerSelectedThumbnailImageView.action( .requestCroppedImageResult )
    }
}
extension ShopLiveCoverPickerViewController {
    private func bindThumbnailSliderView() {
        thumbnailSliderView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .seekTo(let time):
                self.onThumbnailSliderSeekTo(time: time)
            }
        }
    }
    
    private func onThumbnailSliderSeekTo(time : CMTime) {
        reactor.action( .seekTo(time) )
    }
}
extension ShopLiveCoverPickerViewController {
    private func bindCroppableImageView() {
        pickerSelectedThumbnailImageView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .croppedImageResult(let image):
                self.onCroppableImageViewCroppedImageResult(image: image)
            }
        }
    }
    
    private func onCroppableImageViewCroppedImageResult(image : UIImage?) {
        self.resultHandler?( .onSuccessImage(image) )
        ShopLiveCoverPicker.shared.close()
    }
}
extension ShopLiveCoverPickerViewController {
    private func setLayout() {
        self.view.addSubview(naviBar)
        self.view.addSubview(closeBtn)
        self.view.addSubview(pageTitle)
        self.view.addSubview(confirmBtn)
        
        self.view.addSubview(cameraBtn)
        self.view.addSubview(thumbnailSliderView)
        self.view.addSubview(playerHolder)
        self.view.addSubview(playerContainerView)
        
        self.view.addSubview(pickerSelectedThumbnailImageView)
        self.view.addSubview(photoPickerModeCloseBtn)
        self.view.addSubview(cancelConfirmToast)
        
        
        NSLayoutConstraint.activate([
            naviBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 0),
            naviBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            naviBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            naviBar.heightAnchor.constraint(equalToConstant: 60),
            
            closeBtn.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
            closeBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 16),
            closeBtn.widthAnchor.constraint(equalToConstant: 40),
            closeBtn.heightAnchor.constraint(equalToConstant: 40),
            
            pageTitle.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
            pageTitle.centerXAnchor.constraint(equalTo: naviBar.centerXAnchor),
            pageTitle.heightAnchor.constraint(equalToConstant: 18),
            pageTitle.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            
            confirmBtn.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
            confirmBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -16),
            confirmBtn.widthAnchor.constraint(equalToConstant: 70),
            confirmBtn.heightAnchor.constraint(equalToConstant: 40),
            
            
            cameraBtn.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            cameraBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 16),
            cameraBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            cameraBtn.heightAnchor.constraint(equalToConstant: 44),
            
            
            thumbnailSliderView.bottomAnchor.constraint(equalTo: cameraBtn.topAnchor,constant: -30),
            thumbnailSliderView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            thumbnailSliderView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            thumbnailSliderView.heightAnchor.constraint(equalToConstant: 60),
        
            
            playerHolder.topAnchor.constraint(equalTo: naviBar.bottomAnchor),
            playerHolder.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            playerHolder.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            playerHolder.bottomAnchor.constraint(equalTo: thumbnailSliderView.topAnchor,constant: -20),
            
            playerContainerView.centerYAnchor.constraint(equalTo: playerHolder.centerYAnchor),
            playerContainerView.centerXAnchor.constraint(equalTo: playerHolder.centerXAnchor),
            playerContainerView.widthAnchor.constraint(equalTo: playerHolder.widthAnchor,multiplier: 1 / 2),
            playerContainerView.heightAnchor.constraint(equalTo: playerContainerView.widthAnchor,multiplier: 16 / 9),
            
            pickerSelectedThumbnailImageView.centerYAnchor.constraint(equalTo: playerHolder.centerYAnchor),
            pickerSelectedThumbnailImageView.centerXAnchor.constraint(equalTo: playerHolder.centerXAnchor),
            pickerSelectedThumbnailImageView.widthAnchor.constraint(equalTo: playerContainerView.widthAnchor),
            pickerSelectedThumbnailImageView.heightAnchor.constraint(equalTo: playerContainerView.heightAnchor),
            
            photoPickerModeCloseBtn.topAnchor.constraint(equalTo: pickerSelectedThumbnailImageView.topAnchor,constant: 8 ),
            photoPickerModeCloseBtn.trailingAnchor.constraint(equalTo: pickerSelectedThumbnailImageView.trailingAnchor,constant: -8),
            photoPickerModeCloseBtn.widthAnchor.constraint(equalToConstant: 28),
            photoPickerModeCloseBtn.heightAnchor.constraint(equalToConstant: 28),
            
            cancelConfirmToast.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            cancelConfirmToast.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            cancelConfirmToast.widthAnchor.constraint(lessThanOrEqualToConstant: 400),
            cancelConfirmToast.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setPlayerLayer() {
        playerLayer = AVPlayerLayer(player: reactor.getAVPlayer())
        self.playerLayer?.frame = playerContainerView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        if let playerLayer = playerLayer {
            playerContainerView.layer.addSublayer(playerLayer)
        }
    }
}
