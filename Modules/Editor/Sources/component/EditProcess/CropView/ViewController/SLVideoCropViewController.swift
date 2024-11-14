//
//  SLVideoCropViewController.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/8/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit


protocol SLVideoCropViewControllerDelegate : NSObjectProtocol {
    func videoCropViewController(didFinish didCrop : Bool?)
    
}

class SLVideoCropViewController : UIViewController {
    let design = EditorCropConfig.global
    
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
        label.text = ShopLiveShortformEditorSDKStrings.Editor.Crop.Page.title
        return label
    }()
    
    private var bottomBar : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    lazy private var playPauseBtn : SLPaddingImageButton = {
        let btn = SLPaddingImageButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .init(red: 255, green: 255, blue: 255,aa: 0.2)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        btn.setImage(design.pauseButtonIcon, for: .normal)
        btn.imageView?.tintColor = design.pauseButtonIconTintColor
        btn.imageLayoutMargin = design.pauseButtonIconPadding
        
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    lazy private var confirmBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = design.confirmButtonBackgroundColor
        btn.setTitleColor(design.confirmButtonTextColor, for: .normal)
        btn.titleLabel?.font = .set(size: 16, weight: ._600)
        btn.setTitle(ShopLiveShortformEditorSDKStrings.Editor.Crop.Btn.Confirm.title, for: .normal)
        btn.layer.cornerRadius = design.confirmButtonCornerRadius
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
        player.layer.cornerRadius = design.videoPlayerCornerRadius
        player.clipsToBounds = true
        return player
    }()
    
    
    weak var delegate : SLVideoCropViewControllerDelegate?
    
    private var reactor : SLVideoCropReactor
    
    required init(delegate : SLVideoCropViewControllerDelegate?, videoInfo : SLVideoEditInfoDTO) {
        self.reactor = SLVideoCropReactor(videoInfo: videoInfo)
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        bindReactor()
        bindPlayerView()
        reactor.action( .initialize )
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.setLayout()
        reactor.action( .viewDidLoad )
        closeBtn.addTarget(self, action: #selector(closeBtnTapped(sender: )), for: .touchUpInside)
        playPauseBtn.addTarget(self, action: #selector(playPauseBtnTapped(sender:)), for: .touchUpInside)
        confirmBtn.addTarget(self, action: #selector(confirmBtn(sender: )), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor.action( .viewWillAppear )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reactor.action( .viewDidLayOutSubView )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor.action( .setGlkViewSize(playerView.getGLKViewSize()) )
        reactor.action( .viewDidAppeared )
    }
    
    deinit {
        ShopLiveLogger.debugLog("SLVideoCropViewController deinited")
    }
    
    @objc func closeBtnTapped(sender : UIButton) {
        delegate?.videoCropViewController(didFinish: nil)
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true)
        }
    }
    
    @objc func playPauseBtnTapped(sender : UIButton) {
        reactor.action( .requestToggleVideoPlayOrPause )
    }
    
    @objc func confirmBtn(sender : UIButton) {
        reactor.action( .requestOnConfirm )
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true)
        }
    }
    
    private func changePlayOrPauseBtnState(isSelected : Bool ) {
        if isSelected {
            playPauseBtn.setImage(design.pauseButtonIcon, for: .normal)
            playPauseBtn.imageView?.tintColor = design.pauseButtonIconTintColor
            playPauseBtn.imageLayoutMargin = design.pauseButtonIconPadding
        }
        else {
            playPauseBtn.setImage(design.playButtonIcon, for: .normal)
            playPauseBtn.imageView?.tintColor = design.playButtonIconTintColor
            playPauseBtn.imageLayoutMargin = design.playButtonIconPadding
        }
      
    }
}
extension SLVideoCropViewController {
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .setShortsVideo(let shortsVideo):
                    self.onReactorSetShortsVideo(video: shortsVideo)
                case .setPlayerEndBoundaryTime(let endTime):
                    self.onReactorSetEndBoundaryTime(time: endTime)
                case .setFilterConfig(let filterConfig):
                    self.onReactorSetFilterConfig(filter: filterConfig)
                case .seekTo(let time):
                    self.onReactorSeekTo(time: time)
                case .pauseVideo:
                    self.onReactorPauseVideo()
                case .playVideo:
                    self.onReactorPlayVideo()
                case .requestOnConfirm(let didCrop):
                    self.onReactorRequestOnConfirm(didCrop: didCrop)
                case .setinitailCropRect(let rect):
                    self.onReactorSetInitialCropRect(crop: rect)
                }
            }
        }
    }
    
    private func onReactorSetShortsVideo(video : ShortsVideo) {
        let fileName = (video.localAbsoluteUrl.absoluteString as NSString).lastPathComponent
        let videoUrl = video.localAbsoluteUrl
        let videoSize = video.getVideoSize() ?? .zero
        self.playerView.action( .setUpFilterPlayer(fileName, videoUrl , videoSize,centerCrop: false, isCropMode: true, isCropAvailable: true) )
    }
    
    private func onReactorSetEndBoundaryTime(time : CMTime) {
        playerView.action( .setPlayerEndBoundaryTime(time) )
    }
    
    private func onReactorSetFilterConfig(filter : String?) {
        playerView.action( .setFilterConfig(filter ?? "") )
    }
    
    private func onReactorSeekTo(time : CMTime) {
        playerView.action( .seekTo(time) )
    }
    
    private func onReactorPauseVideo() {
        playerView.action( .pauseVideo )
        changePlayOrPauseBtnState(isSelected : false )
    }
    
    private func onReactorPlayVideo() {
        playerView.action( .playVideo )
        changePlayOrPauseBtnState(isSelected : true )
    }
    
    private func onReactorRequestOnConfirm(didCrop : Bool) {
        self.delegate?.videoCropViewController(didFinish: didCrop)
    }
    
    private func onReactorSetInitialCropRect(crop : CGRect) {
        DispatchQueue.main.async { [weak self] in
            self?.playerView.action( .setInitialCropRect(crop) )
        }
        
    }
}
//MARK: - bind playerView
extension SLVideoCropViewController {
    private func bindPlayerView() {
        playerView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .didPlaytoEndTime:
                    self.onPlayerViewDidPlayToEndTime()
                case .didTapPlayBtn:
                    self.onPlayerViewDidTapPlayBtn()
                case .didUpdateCropRect(let rect):
                    self.onPlayerViewDidUpdateCropRect(rect: rect)
                case .didUpdateCropViewRect(let rect):
                    self.onPlayerViewDidUpdateCropViewRect(rect: rect)
                case .timeControlStatusUpdated(let timeControlStatus):
                    self.onPlayerViewTimeControlStatusUpdated(status: timeControlStatus)

                default:
                    break
                }
            }
        }
    }
    
    private func onPlayerViewDidPlayToEndTime() {
        reactor.action( .didPlayToEndTime )
    }
    
    private func onPlayerViewDidTapPlayBtn() {
        reactor.action( .requestToggleVideoPlayOrPause )
    }
    
    private func onPlayerViewDidUpdateCropRect(rect : CGRect) {
        reactor.action( .setCropRect(rect) )
    }
    
    private func onPlayerViewDidUpdateCropViewRect(rect : CGRect) {
        reactor.action( .setCropViewRect(rect) )
    }
    
    private func onPlayerViewTimeControlStatusUpdated(status : AVPlayer.TimeControlStatus) {
        reactor.action( .timeControlStatusUpdated(status) )
    }
}
extension SLVideoCropViewController {
    private func setLayout() {
        self.view.addSubview(naviBar)
        self.view.addSubview(closeBtn)
        self.view.addSubview(pageTitle)
        
        self.view.addSubview(bottomBar)
        self.view.addSubview(playPauseBtn)
        self.view.addSubview(confirmBtn)
        
        self.view.addSubview(playerHolder)
        self.view.addSubview(playerView)
        
        
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
            
            bottomBar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: -20),
            bottomBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 60),
            
            playPauseBtn.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            playPauseBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 16),
            playPauseBtn.widthAnchor.constraint(equalToConstant: 40),
            playPauseBtn.heightAnchor.constraint(equalToConstant: 40),
            
            confirmBtn.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            confirmBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -16),
            confirmBtn.widthAnchor.constraint(equalToConstant: 80),
            confirmBtn.heightAnchor.constraint(equalToConstant: 40),
            
            
            playerHolder.topAnchor.constraint(equalTo: naviBar.bottomAnchor, constant: 40),
            playerHolder.bottomAnchor.constraint(equalTo: bottomBar.topAnchor,constant: -40),
            playerHolder.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            playerHolder.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            playerView.centerYAnchor.constraint(equalTo: playerHolder.centerYAnchor),
            playerView.centerXAnchor.constraint(equalTo: playerHolder.centerXAnchor),
            playerView.widthAnchor.constraint(equalTo: playerHolder.widthAnchor),
            playerView.heightAnchor.constraint(equalTo: playerHolder.heightAnchor)
        ])
    }
    
}
