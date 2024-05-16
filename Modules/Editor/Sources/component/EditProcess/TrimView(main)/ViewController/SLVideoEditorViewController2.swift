//
//  SLVideoEditorViewController2.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/7/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit

protocol SLVideoEditorViewControllerDelegate: AnyObject {
    func cancelConvertVideo()
}

class SLVideoEditorViewController2 : UIViewController {
    private var bundle : Bundle {
        return Bundle(for: type(of: self))
    }
    
    private var naviBar : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    lazy private var backBtn : SlBlurBGButton = {
        let btn = SlBlurBGButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(ShopLiveShortformEditorSDKAsset.slBackArrow.image.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.imageView?.tintColor = .white
        btn.imageLayoutMargin = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    
    lazy private var pageTitleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.text = "editor.page.title".localizedString(bundle: bundle)
        return label
    }()
    
    
    private lazy var nextButton: SlBlurBGButton = {
        let view = SlBlurBGButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        view.setTitle("editor.next.title".localizedString(bundle: bundle), for: .normal)
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    lazy private var videoSpeedBtn : SlBlurBGButton = {
        let btn = SlBlurBGButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(ShopLiveShortformEditorSDKAsset.slIcSpeedometer.image.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.imageView?.tintColor = .white
        btn.imageLayoutMargin = UIEdgeInsets(top: 7, left: 10, bottom: 13, right: 10)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    lazy private var videoSoundBtn : SlBlurBGButton = {
        let btn = SlBlurBGButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(ShopLiveShortformEditorSDKAsset.slIcEditUnmute.image.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.imageView?.tintColor = .white
        btn.imageLayoutMargin = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    lazy private var videoCropBtn : SlBlurBGButton = {
        let btn = SlBlurBGButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(ShopLiveShortformEditorSDKAsset.slIcCrop.image.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.imageView?.tintColor = .white
        btn.imageLayoutMargin = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    lazy private var filterAddBtn : SlBlurBGButton = {
        let btn = SlBlurBGButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(ShopLiveShortformEditorSDKAsset.slIcFilter.image.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.imageView?.tintColor = .white
        btn.imageLayoutMargin = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    lazy private var filterPlayerView : ShopLiveFilterPlayer = {
        let view = ShopLiveFilterPlayer()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var timeTrimSliderView : SLTimeTrimSliderView = {
        let view = SLTimeTrimSliderView(videoUrl: reactor.getVideoUrl())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var seperateLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        return view
    }()
    
    private var reactor : SLVideoEditorViewReactor
    weak var delegate : SLVideoEditorViewControllerDelegate?
    weak var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
    weak var videoEditorDelegate : ShopLiveVideoEditorDelegate?
    
    lazy private var currentOrientation : UIInterfaceOrientationMask = didChangeOrientation_SL()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    init(video : ShortsVideo){
        self.reactor = SLVideoEditorViewReactor(shortsVideo: video)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = .black
        setLayout()
        bindReactor()
        bindFilterPlayerView()
        bindTimeTrimSliderView()
        reactor.action( .viewDidLoad )
        
        backBtn.addTarget(self, action: #selector(backBtnTapped(sender: )), for: .touchUpInside)
        filterAddBtn.addTarget(self, action: #selector(filterAddBtnTapped(sender: )), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextBtnTapped(sender: )), for: .touchUpInside)
        videoCropBtn.addTarget(self, action: #selector(cropBtnTapped(sender: )), for: .touchUpInside)
        videoSoundBtn.addTarget(self, action: #selector(videoSoundBtnTapped(sender: )), for: .touchUpInside)
        videoSpeedBtn.addTarget(self, action: #selector(videoSpeedRateBtnTapped(sender: )), for: .touchUpInside)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reactor.action( .viewDidLayOutSubView )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor.action( .setShortformEditorDelegate(self.shortformEditorDelegate) )
        reactor.action( .setVideoEditorDelegate(self.videoEditorDelegate) )
        
    }
    
    deinit {
        ShopLiveLogger.debugLog("[ShopliveShortformEditor] SLVideoEditorViewController2 deinited")
    }
    
    @objc func backBtnTapped(sender : UIButton) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true)
        }
    }
    
    @objc func filterAddBtnTapped(sender : UIButton) {
        filterPlayerView.action( .pauseVideo )
        let view = SLVideoFilterViewController(videoEditInfo: reactor.getVideoEditInfoDto(), thumbnailImage: timeTrimSliderView.getFirstThumbnailImage())
        view.delegate = reactor
        view.modalPresentationStyle = .overFullScreen
        self.present(view, animated: true)
    }
    
    @objc func nextBtnTapped(sender : UIButton) {
        let view = SLVideoThumbnailViewController(videoEditInfo: reactor.getVideoEditInfoDto(), shortformEditorDelegate: shortformEditorDelegate, videoEditorDelegate: videoEditorDelegate)
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    @objc func cropBtnTapped(sender : UIButton) {
        filterPlayerView.action( .pauseVideo )
        let view = SLVideoCropViewController(delegate: reactor, videoInfo: reactor.getVideoEditInfoDto())
        view.modalPresentationStyle = .overFullScreen
        view.delegate = reactor
        self.present(view, animated: true)
    }
    
    @objc func videoSoundBtnTapped(sender : UIButton) {
        filterPlayerView.action( .pauseVideo )
        let view = SLVideoVolumeViewController(videoEditInfoDto: reactor.getVideoEditInfoDto())
        view.modalPresentationStyle = .overFullScreen
        view.delegate = reactor
        self.present(view, animated: true)
    }
    
    @objc func videoSpeedRateBtnTapped(sender : UIButton) {
        filterPlayerView.action( .pauseVideo )
        let view = SLVideoSpeedRateViewController(videoEditInfoDto: reactor.getVideoEditInfoDto())
        view.modalPresentationStyle = .overFullScreen
        view.delegate = reactor
        self.present(view, animated: true)
    }
    
    
    private func bindReactor(){
        
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .setShortsVideo(let video):
                self.setShortsVideoToPlayer(video: video)
            case .setPlayerEndBoundaryTime(let time):
                self.setPlayerEndBoundaryTime(time: time)
                break
            default:
                break
            }
            
        }
        
        reactor.onMainQueueResultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .seekTo(let time):
                    self.seekTo(time: time)
                case .setFilterBtnVisible(let isVisible):
                    self.setFilterBtnVisible(isVisible: isVisible)
                case .setPlayBtnVisible(let isVisible):
                    self.setPlayBtnVisible(isVisible: isVisible)
                case .setTimeIndicatorLineTime(let time):
                    self.setTimeIndicatorLineTime(time: time)
                case .resetTimeIndicatorLine:
                    self.resetTimeIndicatorLine()
                case .playVideo:
                    self.onPlayVideo()
                case .pauseVideo:
                    self.onPauseVideo()
                case .setFilterConfig(let filterConfig):
                    self.onSetFilterConfig(filterConfig: filterConfig)
                case .presentViewController(let vc):
                    self.onPresentViewController(vc: vc)
                case .setCropBtnIsSelected(isSelected: let isSelected):
                    self.onSetCropBtnIsSelected(isSelected : isSelected)
                case .setVideoSoundBtnIsSelected(isSelected: let isSelected):
                    self.onSetVideoSoundBtnIsSelected(isSelected: isSelected)
                default:
                    break
                }
            }
        }
    }
    
    private func setShortsVideoToPlayer(video : ShortsVideo){
        let fileName = (video.videoUrl.absoluteString as NSString).lastPathComponent
        let videoUrl = video.videoUrl
        let videoSize = video.getVideoSize() ?? .zero
        
        self.filterPlayerView.action( .setUpFilterPlayer(fileName, videoUrl , videoSize, true, false) )
        
    }
    
    private func setPlayerEndBoundaryTime(time : CMTime){
        filterPlayerView.action( .setPlayerEndBoundaryTime(time) )
    }
    
    private func seekTo(time : CMTime) {
        self.filterPlayerView.action( .seekTo(time) )
    }
    
    private func setFilterBtnVisible(isVisible : Bool) {
        self.filterAddBtn.isHidden = !isVisible
    }
    
    private func setPlayBtnVisible(isVisible : Bool) {
        filterPlayerView.action( .setPlayBtnisHidden(isVisible ? false : true ))
    }
    
    private func setTimeIndicatorLineTime(time : Float) {
        timeTrimSliderView.action( .updateTimeIndicatorTime(time) )
    }
    
    private func resetTimeIndicatorLine() {
        timeTrimSliderView.action( .updateTimeIndicatorTimeToStartPos )
    }
    
    private func onPlayVideo() {
        filterPlayerView.action( .playVideo )
    }
    
    private func onPauseVideo() {
        filterPlayerView.action( .pauseVideo )
    }
    
    private func onSetFilterConfig(filterConfig : String) {
        filterPlayerView.action( .setFilterConfig(filterConfig) )
    }
    
    private func onPresentViewController(vc : UIViewController) {
        self.present(vc, animated: true)
    }
    
    private func onSetCropBtnIsSelected(isSelected : Bool) {
        self.videoCropBtn.isSelected = isSelected
    }
    
    private func onSetVideoSoundBtnIsSelected(isSelected : Bool) {
        self.videoSoundBtn.isSelected = isSelected
    }
}
//MARK: - FilterPlayerView binding
extension SLVideoEditorViewController2 {
    private func bindFilterPlayerView() {
        filterPlayerView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .didPlaytoEndTime:
                self.onFilterPlayerViewDidPlayToEndTime()
            case .didTapPlayBtn:
                self.onFilterPlayerDidTapPlayBtn()
            case .didUpdateCropRect(let cropRect):
                self.onFilterPlayerDidUpdateCropRect(rect: cropRect)
            case .videoTimeUpdated(let time):
                self.onFilterPlayerVideoTimeUpdated(time: time)
            case .timeControlStatusUpdated(let status):
                self.onFilterTimeControlStatusUpdated(timeControlStatus: status)
            default:
                break
            }
        }
    }
    
    private func onFilterPlayerViewDidPlayToEndTime() {
        reactor.action( .didPlayToEndTime )
    }
    
    private func onFilterPlayerDidTapPlayBtn() {
        reactor.action( .requestToggleVideoPlayOrPause )
    }
    
    private func onFilterPlayerDidUpdateCropRect(rect : CGRect) {
        reactor.action( .setCropRect(rect) )
    }
    
    private func onFilterPlayerVideoTimeUpdated(time : Double) {
        reactor.action( .videoTimeUpdated(time) )
    }
    
    private func onFilterTimeControlStatusUpdated(timeControlStatus : AVPlayer.TimeControlStatus) {
        reactor.action( .timeControlStatusUpdated(timeControlStatus) )
    }
}
extension SLVideoEditorViewController2 {
    private func bindTimeTrimSliderView() {
        timeTrimSliderView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result { 
            case .toggleViewPlayOrPause:
                self.onTimeTrimSliderTogglePlayerOrPause()
            case .seekTo(let time):
                self.onTimeTrimSliderSeekTo(time: time)
            case .updateCropTime(start: let startTime, end: let endTime):
                self.onTimeTrimSliderUpdateCropTime(startTime: startTime, endTime: endTime)
            }
        }
    }
    
    private func onTimeTrimSliderTogglePlayerOrPause() {
        reactor.action( .requestToggleVideoPlayOrPause )
    }
    
    private func onTimeTrimSliderSeekTo(time : CMTime) {
        filterPlayerView.action( .seekTo(time) )
    }
    
    private func onTimeTrimSliderUpdateCropTime(startTime : CMTime, endTime : CMTime) {
        reactor.action( .setCropStartTime(startTime) )
        reactor.action( .setCropEndTime(endTime) )
    }
}
extension SLVideoEditorViewController2 {
    private func setLayout() {
        self.view.addSubview(filterPlayerView)
        
        self.view.addSubview(naviBar)
        self.view.addSubview(backBtn)
        self.view.addSubview(pageTitleLabel)
        self.view.addSubview(nextButton)
        
        let optionBtnStack = UIStackView(arrangedSubviews: [videoSpeedBtn, videoSoundBtn, videoCropBtn, filterAddBtn])
        optionBtnStack.translatesAutoresizingMaskIntoConstraints = false
        optionBtnStack.axis = .vertical
        optionBtnStack.spacing = 8
        self.view.addSubview(optionBtnStack)
        
        self.view.addSubview(timeTrimSliderView)
        
        NSLayoutConstraint.activate([
            naviBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            naviBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            naviBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            naviBar.heightAnchor.constraint(equalToConstant: 60),
            
            backBtn.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
            backBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20),
            backBtn.widthAnchor.constraint(equalToConstant: 40),
            backBtn.heightAnchor.constraint(equalToConstant: 40),
            
            nextButton.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: naviBar.trailingAnchor,constant: -20),
            nextButton.widthAnchor.constraint(equalToConstant: 70),
            nextButton.heightAnchor.constraint(equalToConstant: 40),
            
            
            pageTitleLabel.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
            pageTitleLabel.centerXAnchor.constraint(equalTo: naviBar.centerXAnchor),
            pageTitleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            pageTitleLabel.heightAnchor.constraint(equalToConstant: 18),
            
            optionBtnStack.centerYAnchor.constraint(equalTo: filterPlayerView.centerYAnchor),
            optionBtnStack.trailingAnchor.constraint(equalTo: filterPlayerView.trailingAnchor,constant: -16),
            optionBtnStack.widthAnchor.constraint(equalToConstant: 40),
            optionBtnStack.heightAnchor.constraint(lessThanOrEqualToConstant: 400),
            
            videoSpeedBtn.heightAnchor.constraint(equalToConstant: 40),
            videoSoundBtn.heightAnchor.constraint(equalToConstant: 40),
            videoCropBtn.heightAnchor.constraint(equalToConstant: 40),
            filterAddBtn.heightAnchor.constraint(equalToConstant: 40),
            
            filterPlayerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            filterPlayerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            filterPlayerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            filterPlayerView.bottomAnchor.constraint(equalTo: timeTrimSliderView.topAnchor,constant: -14),
            
            timeTrimSliderView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: -4),
            timeTrimSliderView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            timeTrimSliderView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            timeTrimSliderView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
extension SLVideoEditorViewController2 {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self, let videoSize = self.reactor.getVideoSize() else { return }
            self.filterPlayerView.action( .updateGLKViewOnRotation(videoSize) )
            self.filterPlayerView.action( .updateCropViewOnRotation(videoSize) )
        }) { [weak self] context in
            guard let self = self else { return }
            self.timeTrimSliderView.action( .resetAndRedraw )
//            self.editSliderView.resetAndRedraw()
        }
        
    }
}
