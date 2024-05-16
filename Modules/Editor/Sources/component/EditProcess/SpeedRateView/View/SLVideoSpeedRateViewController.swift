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
    func speedRateViewController(didFinish didChange : Bool)
}

class SLVideoSpeedRateViewController : UIViewController {
    private var naviBar : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var closeBtn : SLPaddingImageButton = {
        let btn = SLPaddingImageButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .init(red: 255, green: 255, blue: 255,aa: 0.2)
        btn.layer.cornerRadius = 20
        btn.setImage(ShopLiveShortformEditorSDKAsset.slCloseButton.image.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.imageView?.tintColor = .white
        btn.imageLayoutMargin = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    private var pageTitle : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .set(size: 16, weight: ._600)
        label.text = "자르기"
        return label
    }()
    
    private var bottomBar : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var playPauseBtn : SLPaddingImageButton = {
        let btn = SLPaddingImageButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .init(red: 255, green: 255, blue: 255,aa: 0.2)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        btn.setImage(ShopLiveShortformEditorSDKAsset.slIcPlay.image.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.imageView?.tintColor = .white
        btn.imageLayoutMargin = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        btn.imageView?.contentMode = .scaleAspectFit
    
        return btn
    }()
    
    private var confirmBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .white
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .set(size: 16, weight: ._600)
        btn.setTitle("완료", for: .normal)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        return btn
    }()
    
    
    private var playerHolder : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var playerView : ShopLiveFilterPlayer = {
        let player = ShopLiveFilterPlayer()
        player.translatesAutoresizingMaskIntoConstraints = false
        
        return player
    }()
    
    
    private var sliderView : SlCustomUISlider = {
        let view = SlCustomUISlider()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.action( .setMinValue(0) )
        view.action( .setMaxValue(2) )
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
        ShopLiveLogger.debugLog("SLVideoSpeedRateViewController Deinit")
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
            }
        }
    }
    
    private func onReactorSetShortsVideo(video : ShortsVideo) {
        let fileName = (video.videoUrl.absoluteString as NSString).lastPathComponent
        let videoUrl = video.videoUrl
        let videoSize = video.getVideoSize() ?? .zero
        self.playerView.action( .setUpFilterPlayer(fileName, videoUrl , videoSize, false, false) )
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
    }
    
    private func onReactorPlayVideo() {
        playerView.action( .playVideo )
    }
    
    private func onReactorRequestOnConfirm(didChange : Bool) {
        self.delegate?.speedRateViewController(didFinish: didChange)
    }

    private func onReactorSetInitialSpeed(value : CGFloat) {
        sliderView.action( .setCurrentValue(value) )
        sliderView.action( .setValueLabel(String(format: "%.1f", value) + "x") )
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
            playerView.heightAnchor.constraint(equalTo: playerHolder.heightAnchor)
        ])
    }
}
