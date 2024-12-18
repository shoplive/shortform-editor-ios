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
    private let design = ShopLiveShortformEditor.EditorCoverPickerConfig.global
    private let config = ShopLiveEditorConfigurationManager.shared
    
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
        btn.setImage(design.backButtonIcon, for: .normal)
        btn.imageView?.tintColor = design.backButtonIconTintColor
        btn.imageLayoutMargin = design.backButtonIconPadding
        if let backgroundColor = design.backButtonBackgroundColor {
            btn.backgroundColor = backgroundColor
        }
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    private var pageTitle : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .set(size: 16, weight: ._600)
        label.text = ShopLiveShortformEditorSDKStrings.Editor.Title.Cover.Picker.shoplive
        return label
    }()
    
    lazy private var confirmBtn : SLLabelButton = {
        let btn = SLLabelButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = design.confirmButtonBackgroundColor
        btn.titleTextLabel.textColor = design.confirmButtonTextColor
        btn.titleTextLabel.font = .set(size: 16, weight: ._600)
        btn.titleTextLabel.text = design.confirmButtonTitle
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
        btn.setTitle(design.cameraRollButtonTitle, for: .normal)
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
    
    lazy private var playerContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = design.videoPlayerCornerRadius
        return view
    }()
    
    lazy private var playerCropView : SLVideoEditorPlayerCropView = {
        let view = SLVideoEditorPlayerCropView(cropGridViewColor: design.cropColor)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = reactor
        view.backgroundColor = .clear
        if config.coverPickerVisibleActionButton.editOptions.contains(where: { $0 == .crop }) == false {
            view.setIsCropAvailable(isAvailable: false)
            view.isHidden = true
        }
        else {
            view.setIsCropAvailable(isAvailable: true)
            view.isHidden = false
        }
        return view
    }()
    
    private var playerLayer : AVPlayerLayer?
    
    lazy private var pickerSelectedThumbnailImageView : SLCropableUIImageView = {
        let imageView = SLCropableUIImageView(cropGridViewColor: design.cropColor)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.action( .setClipsToBound(true) )
        imageView.action( .setCornerRadius(design.videoPlayerCornerRadius))
        imageView.action( .setImageViewContentMode(.scaleAspectFit))
        imageView.backgroundColor = .clear
        imageView.isHidden = true
        if config.coverPickerVisibleActionButton.editOptions.contains(where: { $0 == .crop }) == false {
            imageView.action( .setCropViewIsAvailable(false) )
        }
        else {
            imageView.action( .setCropViewIsAvailable(true) )
        }
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
        let view = SLThumbnailSliderView(containerCornerRadius: design.sliderCornerRadius,
                                         thumbViewBorderColor: design.sliderThumbColor, thumbviewCornerRadius: design.sliderThumbCornerRadius)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var loadingProgress: SLLoadingAlertController = {
        let vc = SLLoadingAlertController()
        vc.useProgress = false
        vc.setLoadingText("loading...")
        vc.delegate = reactor
        return vc
    }()
    
    private var cancelConfirmToast : SlBlurBGLabel = {
        let view = SlBlurBGLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.label.textColor = .white
        view.label.font = .set(size: 15, weight: ._600)
        view.label.text = ShopLiveShortformEditorSDKStrings.Editor.Toast.Upload.cancelled
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view._layoutMargin = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.alpha = 0
        return view
    }()
    
    enum Action {
//        case setVideoUrl(URL)
        case setShopLiveCoverPickerData(ShopLiveCoverPickerData?)
        case setEditorResultData(ShopLiveEditorResultInternalData?)
        case setPlayer
        case initializeSliderView
    }
    
    enum Result {
        case onError(ShopLiveCommonError)
        case onFinished
        case backBtnTapped
        case onSuccessImage(UIImage?)
        case onSuccessUpload(result : ShopLiveEditorResultInternalData?)
        case onEvent(name : EventTrace, payload : [String : Any]?)
    }
    
    var resultHandler : ((Result) -> ())?
    
    private var picker :  SLPhotosPickerViewController?
    
    private let reactor : ShopLiveCoverPickerReactor = ShopLiveCoverPickerReactor()
    
    private var isLaunched : Bool = false
    
    
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
        if isLaunched == false {
            reactor.action( .viewDidAppear )
            thumbnailSliderView.action( .initializeThumbView )
            if let videoSize = self.reactor.getVideoSize() {
                playerCropView.videoResolution = videoSize
            }
            playerCropView.updateCropArea()
            isLaunched = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reactor.action( .viewDidLayoutSubView )
        reactor.action( .setPlayerContainerBound(playerContainerView.bounds))
        self.playerLayer?.frame = playerContainerView.bounds
        self.playerLayer?.cornerRadius = design.videoPlayerCornerRadius
        self.playerLayer?.masksToBounds = true
    }
    
    deinit {
        ShopLiveLogger.memoryLog("SLCoverPickerViewController deinit")
    }
    
    @objc func closeBtnTapped(sender : UIButton) {
        resultHandler?( .onEvent(name: .COVER_PICKER_CLICK_CLOSE, payload: nil))
        resultHandler?( .backBtnTapped )
    }
   
    @objc func confirmBtnTapped(sender : UIButton) {
        let state = reactor.getCurrentMode() == .video ? "VIDEO" : "CAMERA_ROLL"
        resultHandler?( .onEvent(name: .COVER_PICKER_CLICK_CONFIRM, payload: ["state" : state]))
        reactor.action( .requestOnConfirm )
    }
    
    @objc func cameraBtnTapped(sender : UIButton) {
        resultHandler?( .onEvent(name: .COVER_PICKER_CLICK_CAMERA_ROLL, payload: nil))
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
        case .setShopLiveCoverPickerData(let data):
            self.onSetShopLiveCoverPickerData(data: data)
        case .setEditorResultData(let result):
            self.onSetEditorResultData(result : result)
        case .setPlayer:
            self.onSetPlayer()
        case .initializeSliderView:
            self.onInitializeSliderView()
        }
    }
    
    private func onSetShopLiveCoverPickerData(data : ShopLiveCoverPickerData?) {
        reactor.action( .setShopLiveCoverPickerData(data) )
        guard let data = data else { return }
        reactor.action( .setVideoUrl(data.videoUrl) )
    }
    
    private func onSetEditorResultData(result : ShopLiveEditorResultInternalData?) {
        reactor.action( .setEditorResultData(result) )
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
            case .requestNormalImageForCropableImageView:
                self.onReactorRequestNormalImageForCropableImageView()
            case .videoThumbnailResult(let image):
                self.onReactorVideoThumbnailResult(image : image)
            case .requestFinishCoverPicker:
                self.onReactorRequestFinishCoverPicker()
            case .onError(let error):
                self.onReactorOnError(error : error)
            case .requestShowLoading:
                self.onReactorShowLoading()
            case .uploadSuccess(result: let result):
                self.onReactorUploadSuccess(result: result)
            case .onEvent(name: let name , payload: let payload):
                self.onReactorOnEvent(name : name, payload : payload)
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
        pickerSelectedThumbnailImageView.isHidden = false
        playerContainerView.isHidden = true
    }
    
    private func onReactorRequestCropImageForCropableImageView() {
        pickerSelectedThumbnailImageView.action( .requestCroppedImageResult )
    }
    
    private func onReactorRequestNormalImageForCropableImageView() {
        pickerSelectedThumbnailImageView.action( .requestNormalImageResult )
    }
    
    private func onReactorVideoThumbnailResult(image : UIImage?) {
        self.resultHandler?( .onSuccessImage(image) )
    }
    
    private func onReactorRequestFinishCoverPicker() {
        self.resultHandler?( .onFinished )
    }
    
    private func onReactorOnError(error : ShopLiveCommonError) {
        self.resultHandler?( .onError(error) )
    }
    
    private func onReactorShowLoading() {
        self.loadingProgress.modalPresentationStyle = .overFullScreen
        self.loadingProgress.setLoadingText("Loading...")
        
        guard self.loadingProgress.isBeingPresented == false else { return }
        self.present(self.loadingProgress, animated: false)
    }
    
    private func onReactorUploadSuccess(result : ShopLiveEditorResultInternalData?) {
        self.resultHandler?( .onSuccessUpload(result: result) )
    }
    
    private func onReactorOnEvent(name : EventTrace, payload : [String : Any]?) {
        self.resultHandler?( .onEvent(name: name, payload: payload) )
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
        if pickerSelectedThumbnailImageView.isHidden == false {
            pickerSelectedThumbnailImageView.isHidden = true
            self.photoPickerModeCloseBtn.isHidden = true
        }
        if playerContainerView.isHidden == true {
            playerContainerView.isHidden = false
            reactor.action( .setCurrentMode(.video) )
        }
        
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
            case .normalImageResult(let image):
                self.onCroppableImageviewNormalImageResult(image : image)
            }
        }
    }
    
    private func onCroppableImageViewCroppedImageResult(image : UIImage?) {
        self.reactor.action( .setCropImageResultFromCropableImageView(image) )
        self.resultHandler?( .onSuccessImage(image) )
    }
    
    private func onCroppableImageviewNormalImageResult(image : UIImage?) {
        self.reactor.action( .setCropImageResultFromCropableImageView(image) )
        self.resultHandler?( .onSuccessImage(image) )
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
        
        playerContainerView.addSubview(playerCropView)
        
       
        
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
            confirmBtn.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
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
            playerHolder.bottomAnchor.constraint(equalTo: thumbnailSliderView.topAnchor,constant: -20)]  +
                                    self.getLayoutForPlayerContainerView() +
            [playerCropView.topAnchor.constraint(equalTo: playerContainerView.topAnchor),
            playerCropView.leadingAnchor.constraint(equalTo: playerContainerView.leadingAnchor),
            playerCropView.trailingAnchor.constraint(equalTo: playerContainerView.trailingAnchor),
            playerCropView.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor),
            
            pickerSelectedThumbnailImageView.centerYAnchor.constraint(equalTo: playerHolder.centerYAnchor),
            pickerSelectedThumbnailImageView.centerXAnchor.constraint(equalTo: playerHolder.centerXAnchor),
            pickerSelectedThumbnailImageView.widthAnchor.constraint(equalTo: playerHolder.widthAnchor,multiplier: 1 / 2),
            pickerSelectedThumbnailImageView.heightAnchor.constraint(equalTo: pickerSelectedThumbnailImageView.widthAnchor,multiplier: 16 / 9),
            
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
    
    
    private func getLayoutForPlayerContainerView() -> [NSLayoutConstraint] {
        var videoRatio : CGFloat = 16 / 9
        
        var isVerticalVideo : Bool = true
        if let videoSize = reactor.getVideoSize() {
            isVerticalVideo = videoSize.height >= videoSize.width
            if videoSize.height >= videoSize.width {
                videoRatio = videoSize.height / videoSize.width
            }
            else {
                videoRatio = videoSize.height / videoSize.width
            }
        }
        
        if isVerticalVideo {
            return [
                playerContainerView.centerYAnchor.constraint(equalTo: playerHolder.centerYAnchor),
                playerContainerView.centerXAnchor.constraint(equalTo: playerHolder.centerXAnchor),
                playerContainerView.widthAnchor.constraint(equalTo: playerHolder.widthAnchor,multiplier: 1 / 2),
                playerContainerView.heightAnchor.constraint(equalTo: playerContainerView.widthAnchor,multiplier: videoRatio)
            ]
        }
        else {
            return [
                playerContainerView.centerYAnchor.constraint(equalTo: playerHolder.centerYAnchor),
                playerContainerView.centerXAnchor.constraint(equalTo: playerHolder.centerXAnchor),
                playerContainerView.widthAnchor.constraint(equalTo: playerHolder.widthAnchor),
                playerContainerView.heightAnchor.constraint(equalTo: playerContainerView.widthAnchor, multiplier: videoRatio)
            ]
        }
    }
    
    private func setPlayerLayer() {
        playerLayer = AVPlayerLayer(player: reactor.getAVPlayer())
        self.playerLayer?.frame = playerContainerView.bounds
        playerLayer?.videoGravity = .resizeAspect
        if let playerLayer = playerLayer {
            playerContainerView.layer.addSublayer(playerLayer)
        }
    }
}
