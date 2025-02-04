//
//  SLVideoSpeedRateViewController.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/10/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit



protocol SLVideoSpeedRateViewControllerDelegate {
    func speedRateViewController(didFinish didChange : Bool?)
}

class SLVideoSpeedRateViewController : UIViewController {
    private let design = ShopLiveShortformEditor.EditorSpeedConfig.global
    
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
        label.text = ShopLiveShortformEditorSDKStrings.Editor.Title.PlaybackSpeed.shoplive
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
        btn.setTitle(ShopLiveShortformEditorSDKStrings.Editor.PlaybackSpeed.Btn.Confirm.shoplive, for: .normal)
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
        let player = ShopLiveFilterPlayer(frame: .zero, cropGridViewColor: .white)
        player.translatesAutoresizingMaskIntoConstraints = false
        player.layer.cornerRadius = design.videoPlayerCornerRadius
        player.clipsToBounds = true
        return player
    }()
    
    private var durationLabelBackgroundView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(white: 51 / 255, alpha: 1)
        view.layer.cornerRadius = (23 / 2)
        return view
    }()
    
    private var durationlabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .set(size: 10, weight: ._500)
        label.textColor = .white
        return label
    }()
    
    
    lazy private var sliderView : SlCustomUISlider = {
        let view = SlCustomUISlider(frame: .zero,thumbViewColor: design.sliderThumbViewColor,
                                    sliderCornerRadius: design.sliderCornerRadius,
                                    backgroundColor: design.sliderBackgroundColor)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.action( .setMinValue(0.1) )
        view.action( .setMaxValue(2.1) )
        view.action( .setZeroUnAvailable )
        return view
    }()
    
    private let reactor : SlVideoSpeedRateReactor
    
    var delegate : SLVideoSpeedRateViewControllerDelegate?
    
    
    required init(videoEditInfoDto : SLVideoEditInfoDTO){
        self.reactor = SlVideoSpeedRateReactor(videoEditInfoDto: videoEditInfoDto)
        super.init(nibName: nil, bundle: nil)
        bindReactor()
        bindPlayerView()
        bindSlider()
        
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
        playPauseBtn.addTarget(self, action: #selector(playPauseBtnTapped(sender: )), for: .touchUpInside)
        confirmBtn.addTarget(self, action: #selector(confirmBtnTapped(sender: )), for: .touchUpInside)
    }
    
    deinit {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reactor.action( .viewDidLayoutSubView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor.action( .viewDidAppear )
    }
    
    @objc func closeBtnTapped(sender : UIButton) {
        delegate?.speedRateViewController(didFinish: nil)
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
    
    @objc func confirmBtnTapped(sender : UIButton) {
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
    
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
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
            case .requestOnConfirm(let didChange):
                self.onReactorRequestOnConfirm(didChange: didChange)
            case .setInitialSpeed(let value):
                self.onReactorSetInitialSpeed(value: value)
            case .setVideoDuration(let duration):
                self.onReactorSetVideoDuration(duration: duration)
            }
        }
    }
    
    private func onReactorSetShortsVideo(video : ShortsVideo) {
        let fileName = (video.localAbsoluteUrl.absoluteString as NSString).lastPathComponent
        let videoUrl = video.localAbsoluteUrl
        let videoSize = video.getVideoSize() ?? .zero
        self.playerView.action( .setUpFilterPlayer(fileName, videoUrl , videoSize,centerCrop: false, isCropMode: false, isCropAvailable: false, mode: .videoEditing) )
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
    
    private func onReactorRequestOnConfirm(didChange : Bool) {
        self.delegate?.speedRateViewController(didFinish: didChange)
    }

    private func onReactorSetInitialSpeed(value : CGFloat) {
        sliderView.action( .setCurrentValue(value) )
        sliderView.action( .setValueLabel(String(format: "%.1f", value) + "x") )
        playerView.action( .setSpeedRate(value) )
    }
    
    private func onReactorSetVideoDuration(duration : String) {
        self.durationlabel.text = duration
    }
    
}
//MARK: - speedRate Slider
extension SLVideoSpeedRateViewController {
    private func bindSlider() {
        sliderView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .currentValue(let value):
                self.onSliderCurrentValue(value: value)
                break
            default:
                break
            }
        }
    }
    
    
    private func onSliderCurrentValue(value : CGFloat) {
        reactor.action( .setSpeed(value) )
        sliderView.action( .setValueLabel(String(format: "%.1f", value) + "x") )
        playerView.action( .setSpeedRate(value) )
    }
    
}
extension SLVideoSpeedRateViewController {
    private func bindPlayerView() {
        playerView.resultHandler = {[weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .didPlaytoEndTime:
                    self.onPlayerViewDidPlayToEndTime()
                case .didTapPlayBtn:
                    self.onPlayerViewDidTapPlayBtn()
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
    
    private func onPlayerViewTimeControlStatusUpdated(status : AVPlayer.TimeControlStatus) {
        reactor.action( .timeControlStatusUpdated(status) )
    }
}
extension SLVideoSpeedRateViewController {
    private func setLayout() {
        self.view.addSubview(naviBar)
        self.view.addSubview(closeBtn)
        self.view.addSubview(pageTitle)
        
        self.view.addSubview(bottomBar)
        self.view.addSubview(playPauseBtn)
        self.view.addSubview(confirmBtn)
        
        self.view.addSubview(playerHolder)
        self.view.addSubview(playerView)
        self.view.addSubview(sliderView)
        
        let durationlabelHolder = UIView()
        durationlabelHolder.backgroundColor = .clear
        durationlabelHolder.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(durationlabelHolder)
        self.view.addSubview(durationLabelBackgroundView)
        self.view.addSubview(durationlabel)
        
        
        
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
            
            
            sliderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 16),
            sliderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            sliderView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor,constant:  -20),
            sliderView.heightAnchor.constraint(equalToConstant: 48),
            
            
            playerHolder.topAnchor.constraint(equalTo: naviBar.bottomAnchor, constant: 40),
            playerHolder.bottomAnchor.constraint(equalTo: sliderView.topAnchor,constant: -40),
            playerHolder.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            playerHolder.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            
            playerView.centerYAnchor.constraint(equalTo: playerHolder.centerYAnchor),
            playerView.centerXAnchor.constraint(equalTo: playerHolder.centerXAnchor),
            playerView.widthAnchor.constraint(equalTo: playerHolder.widthAnchor),
            playerView.heightAnchor.constraint(equalTo: playerHolder.heightAnchor),
            
            durationlabelHolder.topAnchor.constraint(equalTo: playerHolder.bottomAnchor),
            durationlabelHolder.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            durationlabelHolder.bottomAnchor.constraint(equalTo: sliderView.topAnchor),
            durationlabelHolder.widthAnchor.constraint(equalToConstant: 1),
            
            durationlabel.centerYAnchor.constraint(equalTo: durationlabelHolder.centerYAnchor),
            durationlabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            durationlabel.heightAnchor.constraint(equalToConstant: 15),
            durationlabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            
            durationLabelBackgroundView.topAnchor.constraint(equalTo: durationlabel.topAnchor, constant: -4),
            durationLabelBackgroundView.leadingAnchor.constraint(equalTo: durationlabel.leadingAnchor, constant: -8),
            durationLabelBackgroundView.trailingAnchor.constraint(equalTo: durationlabel.trailingAnchor, constant: 8),
            durationLabelBackgroundView.bottomAnchor.constraint(equalTo: durationlabel.bottomAnchor, constant: 4),
        ])
    }
}
