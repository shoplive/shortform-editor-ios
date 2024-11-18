//
//  SLVideoThumbnailViewController.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/13/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon


class SLVideoThumbnailViewController : UIViewController {
    private let design = ShopLiveShortformEditor.EditorCoverPickerConfig.global
    
    
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
    
    private var playerHolder : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    lazy private var playerView : ShopLiveFilterPlayer = {
        let player = ShopLiveFilterPlayer()
        player.translatesAutoresizingMaskIntoConstraints = false
        player.layerCornerRadius = design.videoPlayerCornerRadius
        return player
    }()
    
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
    
    private lazy var pickerSelectedThumbnailWidthAnc : NSLayoutConstraint = {
        return pickerSelectedThumbnailImageView.widthAnchor.constraint(equalToConstant: 100)
    }()
    
    private lazy var pickerSelectedThumbnailHeightAnc : NSLayoutConstraint = {
        return pickerSelectedThumbnailImageView.heightAnchor.constraint(equalToConstant: 100)
    }()
    
    private lazy var thumbnailSliderView: SLThumbnailSliderView = {
        let view = SLThumbnailSliderView(containerCornerRadius: design.thumbnailSliderCornerRadius,thumbViewBorderColor: design.thumbnailSliderThumbViewBorderColor) //videoUrl: reactor.getVideoUrl(),
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
        view.label.text = ShopLiveShortformEditorSDKStrings.Toast.Cancel.Uploading.title
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view._layoutMargin = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.alpha = 0
        return view
    }()
    
    private var picker :  SLPhotosPickerViewController?
    
    private let reactor : SLVideoThumbnailReactor
    
    
    required init(videoEditInfo : SLVideoEditInfoDTO,shortformEditorDelegate : ShopLiveShortformEditorDelegate?, videoEditorDelegate : ShopLiveVideoEditorDelegate? ) {
        self.reactor = SLVideoThumbnailReactor(videoEditInfo: videoEditInfo)
        reactor.action( .setShortformEditorDelegate(shortformEditorDelegate) )
        reactor.action( .setVideoEditorDelegate(videoEditorDelegate) )
        super.init(nibName: nil, bundle: nil)
        bindReactor()
        bindPlayerView()
        bindSliderView()
        thumbnailSliderView.action( .setVideoUrl(reactor.getVideoUrl()) )
        thumbnailSliderView.action( .initializeSliderView )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.setLayout()
        reactor.action( .viewDidLoad )
        
        closeBtn.addTarget(self, action: #selector(backBtnTapped(sender: )), for: .touchUpInside)
        cameraBtn.addTarget(self, action: #selector(cameraBtnTapped(sender: )), for: .touchUpInside)
        confirmBtn.addTarget(self, action: #selector(confirmBtnTapped(sender: )), for: .touchUpInside)
    }
    
    deinit {
        ShopLiveLogger.memoryLog("SLVideoThumbnailViewController deinit")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reactor.action( .viewDidLayoutSubView )
        playerView.action( .setPlayBtnisHidden(true) )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        thumbnailSliderView.action( .initializeThumbView )
        reactor.action( .viewDidAppear )
        playerView.action( .setPlayBtnisHidden(true) )
    }
    
    @objc func backBtnTapped(sender : UIButton) {
        reactor.action( .cancelConverting )
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true)
        }
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
}
//MARK: - bind reactor
extension SLVideoThumbnailViewController {
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .setThumbnail(let image):
                    self.onReactorSetThumbnailImage(image: image)
                case .setShortsVideo(let shortsVideo):
                    self.onReactorSetShortsVideo(video: shortsVideo)
                case .pauseVideo:
                    self.onReactorPauseVideo()
                case .dismissPhotoPicker:
                    self.onReactorDismissPhotoPicker()
                case .showLoadingView:
                    self.onReactorShowLoadingView()
                case .cancelLoading:
                    self.onReactorCancelLoading()
                case .didFinishLoading:
                    self.onReactorDidFinishLoading()
                case .updateLoadingPercent(let value):
                    self.onReactorUpdateLoadingPercent(value: value)
                case .showPopUp(let popup):
                    self.onReactorShowPopUp(popUp: popup)
                case .showCancelToast:
                    self.onReactorShowCancelToast()
                case .seekTo(let time):
                    self.onReactorSeekTo(time: time)
                case .seekThumbailSliderTo(let time):
                    self.onReactorSeekThumbnailSliderTo(time: time)
                case .setinitailCropRect(let rect):
                    self.onReactorSetInitialCropRect(crop: rect)
                case .pushViewController(let vc):
                    self.onReactorPushViewController(vc: vc)
                default:
                    break
                }
            }
        }
    }
    
    private func onReactorSetThumbnailImage(image : UIImage) {
        let glkViewSize = playerView.getGLKViewSize()
        pickerSelectedThumbnailWidthAnc.constant = glkViewSize.width
        pickerSelectedThumbnailHeightAnc.constant = glkViewSize.height
        view.layoutIfNeeded()
        pickerSelectedThumbnailImageView.action( .setCropViewSize(glkViewSize) )
        pickerSelectedThumbnailImageView.action( .setImage(image) )
        pickerSelectedThumbnailImageView.isHidden = false
    }
    
    private func onReactorSetShortsVideo(video : ShortsVideo) {
        pickerSelectedThumbnailImageView.isHidden = true
        let fileName = (video.localAbsoluteUrl.absoluteString as NSString).lastPathComponent
        let videoUrl = video.localAbsoluteUrl
        let videoSize = video.getVideoSize() ?? .zero
        self.playerView.action( .setUpFilterPlayer(fileName, videoUrl , videoSize,centerCrop: false, isCropMode: true, isCropAvailable: false, mode: .coverPicker) )
    }
    
    private func onReactorPauseVideo() {
        self.playerView.action( .pauseVideo )
    }
    
    private func onReactorDismissPhotoPicker() {
        guard let picker = picker else { return }
        picker.dismiss(animated: true)
    }
    
    private func onReactorShowLoadingView() {
        self.loadingProgress.modalPresentationStyle = .overFullScreen
        self.loadingProgress.setLoadingText("Loading...")
        
        guard self.loadingProgress.isBeingPresented == false else { return }
        self.present(self.loadingProgress, animated: false)
    }
    
    private func onReactorCancelLoading() {
        self.loadingProgress.cancelLoading = false
    }
    
    private func onReactorDidFinishLoading() {
        self.loadingProgress.finishLoading()
    }
    
    private func onReactorUpdateLoadingPercent(value : String) {
        self.loadingProgress.setLoadingText(value)
    }
    
    private func onReactorShowPopUp(popUp: UIView) {
        popUp.frame = self.view.frame
        self.view.addSubview(popUp)
    }
    
    private func onReactorShowCancelToast() {
        UIView.animateKeyframes(withDuration: 2, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2) {
                self.cancelConfirmToast.alpha = 1
            }

            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
                self.cancelConfirmToast.alpha = 0
            }
        })
    }
    
    private func onReactorSeekTo(time : CMTime) {
        playerView.action( .seekTo(time) )
    }
    
    private func onReactorSeekThumbnailSliderTo(time : CMTime) {
        thumbnailSliderView.action( .seekToHandleViewTo(time) )
    }
    
    private func onReactorSetInitialCropRect(crop : CGRect) {
        DispatchQueue.main.async { [weak self] in
            self?.playerView.action( .hideCropView(crop == .zero) )
            self?.playerView.action( .setInitialCropRectByRatio(crop) )
        }
    }
    
    private func onReactorPushViewController(vc : UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK: - bind playerview
extension SLVideoThumbnailViewController {
    private func bindPlayerView() {
        playerView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .timeControlStatusUpdated(let status):
                self.onPlayerViewTimeControlStatusUpdated(status: status)
            default:
                break
            }
        }
    }
    
    private func onPlayerViewTimeControlStatusUpdated(status : AVPlayer.TimeControlStatus) {
        reactor.action( .timeControlStatusUpdated(status) )
    }
}
//MARK: - bind SliderView
extension SLVideoThumbnailViewController {
    private func bindSliderView() {
        thumbnailSliderView.resultHandler = { [weak self] result in
            switch result {
            case .seekTo(let time):
                self?.onSliderViewSeekTo(time: time)
            }
        }
    }
    
    private func onSliderViewSeekTo(time : CMTime) {
        playerView.action( .seekTo(time) )
        reactor.action( .setThumbnailTime(time) )
        
        if pickerSelectedThumbnailImageView.isHidden == false {
            pickerSelectedThumbnailImageView.isHidden = true
        }
    }
}
extension SLVideoThumbnailViewController {
    
    private func setLayout() {
        self.view.addSubview(naviBar)
        self.view.addSubview(closeBtn)
        self.view.addSubview(pageTitle)
        self.view.addSubview(confirmBtn)
        
        self.view.addSubview(cameraBtn)
        self.view.addSubview(thumbnailSliderView)
        self.view.addSubview(playerHolder)
        self.view.addSubview(playerView)
        
        self.view.addSubview(pickerSelectedThumbnailImageView)
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
            
            playerView.centerYAnchor.constraint(equalTo: playerHolder.centerYAnchor),
            playerView.centerXAnchor.constraint(equalTo: playerHolder.centerXAnchor),
            playerView.widthAnchor.constraint(equalTo: playerHolder.widthAnchor),
            playerView.heightAnchor.constraint(equalTo: playerHolder.heightAnchor),
            
            
            pickerSelectedThumbnailImageView.centerYAnchor.constraint(equalTo: playerHolder.centerYAnchor),
            pickerSelectedThumbnailImageView.centerXAnchor.constraint(equalTo: playerHolder.centerXAnchor),
            pickerSelectedThumbnailWidthAnc,
            pickerSelectedThumbnailHeightAnc,
            
            
            cancelConfirmToast.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            cancelConfirmToast.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            cancelConfirmToast.widthAnchor.constraint(lessThanOrEqualToConstant: 400),
            cancelConfirmToast.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
