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

class SLVideoEditorMainViewController : UIViewController {
    let design = EditorMainConfig.global
    
    private var naviBar : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    lazy private var backBtn : SlBlurBGButton = {
        let btn = SlBlurBGButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(design.backButtonIcon, for: .normal)
        btn.imageView?.tintColor = design.backButtonIconTintColor
        btn.imageLayoutMargin = design.backButtonIconPadding
        btn.imageView?.contentMode = .scaleAspectFit
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        return btn
    }()
    
    lazy private var editingCloseBtn : SlBlurBGButton = {
        let btn = SlBlurBGButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(design.editingCloseButtonIcon, for: .normal)
        btn.imageView?.tintColor = design.editingCloseButtonIconTintColor
        btn.imageLayoutMargin = design.editingCloseButtonIconPadding
        btn.imageView?.contentMode = .scaleAspectFit
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        btn.isHidden = true
        return btn
    }()
    
    lazy private var pageTitleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.text = ShopLiveShortformEditorSDKStrings.Editor.Main.Page.title
        return label
    }()
    
    
    private lazy var nextButton: SlBlurBGButton = {
        let view = SlBlurBGButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        view.setTitle(ShopLiveShortformEditorSDKStrings.Editor.Main.Btn.Next.title, for: .normal)
        view.layer.cornerRadius = design.nextButtonCornerRadius
        view.clipsToBounds = true
        return view
    }()
    
    lazy private var videoSpeedBtn : SlBlurBGButton = {
        let btn = SlBlurBGButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(design.videoSpeedButtonIcon, for: .normal)
        btn.imageView?.tintColor = design.videoSpeedButtonIconTintColor
        btn.imageLayoutMargin = design.videoSpeedButtonIconPadding
        btn.imageView?.contentMode = .scaleAspectFit
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    lazy private var videoSoundBtn : SlBlurBGButton = {
        let btn = SlBlurBGButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(design.videoSoundButtonIcon, for: .normal)
        btn.imageView?.tintColor = design.videoSoundButtonIconTintColor
        btn.imageLayoutMargin = design.videoSoundButtonIconPadding
        btn.imageView?.contentMode = .scaleAspectFit
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    lazy private var videoCropBtn : SlBlurBGButton = {
        let btn = SlBlurBGButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(design.videoCropButtonIcon, for: .normal)
        btn.imageView?.tintColor = design.videoCropButtonIconTintColor
        btn.imageLayoutMargin = design.videoCropButtonIconPadding
        btn.imageView?.contentMode = .scaleAspectFit
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    lazy private var filterAddBtn : SlBlurBGButton = {
        let btn = SlBlurBGButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(design.videoFilterButtonIcon, for: .normal)
        btn.imageView?.tintColor = design.videofilterButtonIconTintColor
        btn.imageLayoutMargin = design.videoFilterButtonIconPadding
        btn.imageView?.contentMode = .scaleAspectFit
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 20
        return btn
    }()
    
    lazy private var filterPlayerView : ShopLiveFilterPlayer = {
        let view = ShopLiveFilterPlayer()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layerCornerRadius = design.videoPlayerCornerRadius
        return view
    }()
    
    lazy private var playerBoxMainModeTopAnc : NSLayoutConstraint = {
        return filterPlayerView.topAnchor.constraint(equalTo: self.view.topAnchor)
    }()
    
    lazy private var playerBoxEditModeTopAnc : NSLayoutConstraint = {
        return filterPlayerView.topAnchor.constraint(equalTo: naviBar.bottomAnchor)
    }()
        
    lazy private var playerBoxBottonAnc : [ControlBoxType: NSLayoutConstraint] = {
        return [.main : filterPlayerView.bottomAnchor.constraint(equalTo: timeTrimSliderView.topAnchor,constant: -30),
                .speed : filterPlayerView.bottomAnchor.constraint(equalTo: speedRateControlBox.topAnchor,constant: -30),
                .volume : filterPlayerView.bottomAnchor.constraint(equalTo: volumeControlBox.topAnchor,constant: -30),
                .filter : filterPlayerView.bottomAnchor.constraint(equalTo: filterControlBox.topAnchor, constant: -30),
                .crop : filterPlayerView.bottomAnchor.constraint(equalTo: cropControlBox.topAnchor,constant: -30)]
    }()
    
    private lazy var timeTrimSliderView : SLTimeTrimSliderView = {
        let view = SLTimeTrimSliderView(videoUrl: reactor.getVideoUrl(), timeIndicatorCornerRadius: design.sliderIndicatorCornerRadius)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var speedRateControlBox : SLVideoMainSpeedSubView = {
        let view = SLVideoMainSpeedSubView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private var volumeControlBox : SLVideoMainVolumeSubView = {
        let view = SLVideoMainVolumeSubView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private var filterControlBox : SLVideoMainFilterSubView = {
        let view = SLVideoMainFilterSubView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private var cropControlBox : SLVideoMainCropSubView = {
        let view = SLVideoMainCropSubView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
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
    
    private var reactor : SLVideoEditorMainViewReactor
    weak var delegate : SLVideoEditorViewControllerDelegate?
    weak var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
    weak var videoEditorDelegate : ShopLiveVideoEditorDelegate?
    
    lazy private var currentOrientation : UIInterfaceOrientationMask = didChangeOrientation_SL()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    init(video : ShortsVideo,isRoot : Bool ){
        self.reactor = SLVideoEditorMainViewReactor(shortsVideo: video)
        self.reactor.action( .setIsRootViewController(isRoot) )
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
        //subComponents binding
        bindSpeedControlBox()
        bindVolumeControlBox()
        bindFilterControlBox()
        bindCropControlBox()
        
        reactor.action( .viewDidLoad )
        
        
        speedRateControlBox.action( .setVideoEditInfoDTO(reactor.getVideoEditInfoDto()) )
        volumeControlBox.action( .setVideoEditInfoDTO(reactor.getVideoEditInfoDto()) )
        filterControlBox.action( .setVideoEditInfoDto(reactor.getVideoEditInfoDto()) )
        
        
        backBtn.addTarget(self, action: #selector(backBtnTapped(sender: )), for: .touchUpInside)
        editingCloseBtn.addTarget(self, action: #selector(editingCloseBtnTapped(sender: )), for: .touchUpInside)
        filterAddBtn.addTarget(self, action: #selector(filterAddBtnTapped(sender: )), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextBtnTapped(sender: )), for: .touchUpInside)
        videoCropBtn.addTarget(self, action: #selector(cropBtnTapped(sender: )), for: .touchUpInside)
        videoSoundBtn.addTarget(self, action: #selector(videoSoundBtnTapped(sender: )), for: .touchUpInside)
        videoSpeedBtn.addTarget(self, action: #selector(videoSpeedRateBtnTapped(sender: )), for: .touchUpInside)
        
        filterPlayerView.action( .hideCropView(true) )
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reactor.action( .viewDidLayOutSubView )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor.action( .setShortformEditorDelegate(self.shortformEditorDelegate) )
        reactor.action( .setVideoEditorDelegate(self.videoEditorDelegate) )
        filterPlayerView.action( .playVideo )
        
        speedRateControlBox.action( .initialize )
        volumeControlBox.action( .initialize )
        filterControlBox.action( .initialize )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        filterPlayerView.action( .pauseVideo )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        filterPlayerView.action( .pauseVideo )
    }
    
    deinit {
        ShopLiveLogger.memoryLog("SLVideoEditorMainViewController deinited")
    } 
    
    @objc func backBtnTapped(sender : UIButton) {
        reactor.action( .backBtnTapped )
    }
    
    @objc func editingCloseBtnTapped(sender : UIButton) {
        if reactor.getCurrentEditingMode() == .crop {
            filterPlayerView.action( .revertCropChange )
        }
        else if reactor.getCurrentEditingMode() == .speed {
            speedRateControlBox.action( .revertChanges )
        }
        else if reactor.getCurrentEditingMode() == .volume {
            volumeControlBox.action( .revertChange )
        }
        animateControlBox(to : .main)
    }
    
    
    @objc func nextBtnTapped(sender : UIButton) {
        reactor.action( .processConvertVideo )
    }
    
    @objc func filterAddBtnTapped(sender : UIButton) {
        filterControlBox.action( .setThumbnail(self.timeTrimSliderView.getFirstThumbnailImage()) )
        animateControlBox(to: .filter) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.filterControlBox.action( .initializeCells )
            }
        }
    }
    
    @objc func cropBtnTapped(sender : UIButton) {
        animateControlBox(to: .crop)
        filterPlayerView.action( .hideCropView(false) )
        filterPlayerView.action( .saveStartCropRect )
    }
    
    @objc func videoSoundBtnTapped(sender : UIButton) {
        animateControlBox(to : .volume)
        volumeControlBox.action( .saveEditingStartValue)
    }
    
    @objc func videoSpeedRateBtnTapped(sender : UIButton) {
        animateControlBox(to : .speed)
        speedRateControlBox.action( .saveEditingStartSpeedValue )
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
                case .setFilterConfigResult(let filterConfig):
                    self.onSetFilterConfig(filterConfig: filterConfig)
                case .setFilterIntensityResult(let filterIntensity):
                    self.onSetFilterIntensityResult(value: filterIntensity)
                case .setSpeedRateResult(let rate):
                    self.onSetSpeedRateResult(value: rate)
                case .presentViewController(let vc):
                    self.onPresentViewController(vc: vc)
                case .setCropBtnIsSelected(isSelected: let isSelected):
                    self.onSetCropBtnIsSelected(isSelected : isSelected)
                case .setVideoSoundBtnIsSelected(isSelected: let isSelected):
                    self.onSetVideoSoundBtnIsSelected(isSelected: isSelected)
                case .setVideoSpeedBtnIsSelected(isSelected: let isSelected):
                    self.onSetSpeedBtnIsSelected(isSelected: isSelected)
                case .setFilterBtnIsSelected(isSelected: let isSelected):
                    self.onSetFilterBtnIsSelected(isSelected: isSelected)
                case .showThumbnailViewController:
                    self.onShowThumbnailViewController()
                case .showCancelToast:
                    self.onReactorShowCancelToast()
                case .showPopUp(let popup):
                    self.onReactorShowPopUp(popUp: popup)
                case .showLoadingView:
                    self.onReactorShowLoadingView()
                case .cancelLoading:
                    self.onReactorCancelLoading()
                case .didFinishLoading:
                    self.onReactorDidFinishLoading()
                case .updateLoadingPercent(let value):
                    self.onReactorUpdateLoadingPercent(value: value)
                case .requestPopView:
                    self.onReactorRequestPopView()
                default:
                    break
                }
            }
        }
    }
    
    private func setShortsVideoToPlayer(video : ShortsVideo){
        let fileName = (video.localAbsoluteUrl.absoluteString as NSString).lastPathComponent
        let videoUrl = video.localAbsoluteUrl
        let videoSize = video.getVideoSize() ?? .zero
        
        self.filterPlayerView.action( .setUpFilterPlayer(fileName, videoUrl , videoSize,centerCrop : false, isCropMode: true, isCropAvailable: false) )
        
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
        speedRateControlBox.action( .changePlayOrPauseBtnState(isPlaying: true) )
        volumeControlBox.action( .changePlayOrPauseBtnState(isPlaying: true) )
        filterControlBox.action( .changePlayOrPauseBtnState(isPlaying: true) )
        cropControlBox.action( .changePlayOrPauseBtnState(isPlaying: true) )
    }
    
    private func onPauseVideo() {
        filterPlayerView.action( .pauseVideo )
        speedRateControlBox.action( .changePlayOrPauseBtnState(isPlaying: false) )
        volumeControlBox.action( .changePlayOrPauseBtnState(isPlaying: false) )
        filterControlBox.action( .changePlayOrPauseBtnState(isPlaying: false) )
        cropControlBox.action( .changePlayOrPauseBtnState(isPlaying: false) )
    }
    
    private func onSetFilterConfig(filterConfig : String) {
        filterPlayerView.action( .setFilterConfig(filterConfig) )
    }
    
    private func onSetFilterIntensityResult(value : Float) {
        filterPlayerView.action( .setFilterIntensity(value) )
    }
    
    private func onSetSpeedRateResult(value : CGFloat) {
        filterPlayerView.action( .setSpeedRate(value) )
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
    
    private func onSetSpeedBtnIsSelected(isSelected : Bool) {
        self.videoSpeedBtn.isSelected = isSelected
    }
    
    private func onSetFilterBtnIsSelected(isSelected : Bool) {
        self.filterAddBtn.isSelected = isSelected
    }
    
    private func onShowThumbnailViewController() {
        let view = SLVideoThumbnailViewController(videoEditInfo: reactor.getVideoEditInfoDto(), shortformEditorDelegate: shortformEditorDelegate, videoEditorDelegate: videoEditorDelegate)
        self.navigationController?.pushViewController(view, animated: true)
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
    
    private func onReactorShowPopUp(popUp: UIView) {
        popUp.frame = self.view.frame
        self.view.addSubview(popUp)
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
    
    private func onReactorRequestPopView() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true)
        }
    }
}
//MARK: - FilterPlayerView binding
extension SLVideoEditorMainViewController {
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
extension SLVideoEditorMainViewController {
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
//MARK: - bindSpeedControlBox
extension SLVideoEditorMainViewController {
    private func bindSpeedControlBox() {
        speedRateControlBox.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .closeBtn:
                break
            case .confirm:
                self.onSpeedControlBoxConfirm()
            case .togglePlayPause:
                self.reactor.action( .requestToggleVideoPlayOrPause )
            case .onValueChanged:
                self.onSpeedControlBoxOnValueChanged()
            }
        }
    }
    
    private func onSpeedControlBoxOnValueChanged() {
        reactor.action(.applyVideoConfiChange(.speed) )
    }
    
    private func onSpeedControlBoxConfirm() {
        reactor.action( .applyVideoConfiChange(.all) )
        animateControlBox(to : .main)
    }
    
}
//MARK: - bindVolumeControlBox
extension SLVideoEditorMainViewController {
    private func bindVolumeControlBox() {
        volumeControlBox.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .closeBtn:
                break
            case .confirm:
                self.onVolumeControlBoxConfirm()
            case .togglePlayPause:
                self.reactor.action( .requestToggleVideoPlayOrPause )
            default:
                break
            }
        }
    }
    
    private func onVolumeControlBoxConfirm() {
        reactor.action( .applyVideoConfiChange(.all) )
        animateControlBox(to: .main)
    }
}
//MARK: -bindFilterControlBox
extension SLVideoEditorMainViewController {
    private func bindFilterControlBox() {
        filterControlBox.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .confirm:
                self.onFilterControlBoxConfirm()
            case .onValueChanged:
                self.onFilterControlBoxOnValueChanged()
            case .togglePlayPause:
                self.reactor.action( .requestToggleVideoPlayOrPause )
            default:
                break
            }
        }
    }
    
    private func onFilterControlBoxConfirm() {
        self.reactor.action( .applyVideoConfiChange(.all) )
        animateControlBox(to : .main)
    }
    
    private func onFilterControlBoxOnValueChanged() {
        reactor.action( .applyVideoConfiChange(.filter) )
    }
    
}
extension SLVideoEditorMainViewController {
    private func bindCropControlBox() {
        cropControlBox.resultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .confirm:
                    self.onCropControlBoxConfirm()
                case .togglePlayPause:
                    self.reactor.action( .requestToggleVideoPlayOrPause )
                }
            }
        }
    }
    
    private func onCropControlBoxConfirm() {
        animateControlBox(to: .main )
    }
}
extension SLVideoEditorMainViewController {
    private func setLayout() {
        self.view.addSubview(filterPlayerView)
        
        self.view.addSubview(naviBar)
        self.view.addSubview(backBtn)
        self.view.addSubview(editingCloseBtn)
        self.view.addSubview(pageTitleLabel)
        self.view.addSubview(nextButton)
        
        let optionBtnStack = UIStackView(arrangedSubviews: [videoSpeedBtn, videoSoundBtn, videoCropBtn, filterAddBtn])
        optionBtnStack.translatesAutoresizingMaskIntoConstraints = false
        optionBtnStack.axis = .vertical
        optionBtnStack.spacing = 8
        self.view.addSubview(optionBtnStack)
        
        self.view.addSubview(timeTrimSliderView)
        self.view.addSubview(speedRateControlBox)
        self.view.addSubview(volumeControlBox)
        self.view.addSubview(filterControlBox)
        self.view.addSubview(cropControlBox)
        self.view.addSubview(cancelConfirmToast)
        
        NSLayoutConstraint.activate([
            naviBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            naviBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            naviBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            naviBar.heightAnchor.constraint(equalToConstant: 60),
            
            backBtn.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
            backBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20),
            backBtn.widthAnchor.constraint(equalToConstant: 40),
            backBtn.heightAnchor.constraint(equalToConstant: 40),
            
            editingCloseBtn.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
            editingCloseBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20),
            editingCloseBtn.widthAnchor.constraint(equalToConstant: 40),
            editingCloseBtn.heightAnchor.constraint(equalToConstant: 40),
            
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
            
//            filterPlayerView.topAnchor.constraint(equalTo: self.view.topAnchor),
//            filterPlayerView.topAnchor.constraint(equalTo: naviBar.bottomAnchor),
            playerBoxMainModeTopAnc,
//            playerBoxEditModeTopAnc,
            filterPlayerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            filterPlayerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            timeTrimSliderView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: -4),
            timeTrimSliderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            timeTrimSliderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            timeTrimSliderView.heightAnchor.constraint(equalToConstant: 60),
            
            playerBoxBottonAnc[.main]!,
            
            
            speedRateControlBox.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: -4),
            speedRateControlBox.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            speedRateControlBox.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            volumeControlBox.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: -4),
            volumeControlBox.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            volumeControlBox.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            filterControlBox.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: -4),
            filterControlBox.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            filterControlBox.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            cropControlBox.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: -4),
            cropControlBox.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            cropControlBox.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            cancelConfirmToast.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            cancelConfirmToast.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            cancelConfirmToast.widthAnchor.constraint(lessThanOrEqualToConstant: 400),
            cancelConfirmToast.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    
}
extension SLVideoEditorMainViewController {
    enum ControlBoxType {
        case speed
        case volume
        case filter
        case crop
        case main
    }
    
    private func animateControlBox(to : ControlBoxType,completion : (() -> ())? = nil) {
        filterPlayerView.action( .setCropIsAvailable(to == .crop) )
        editingCloseBtn.isHidden = to == .main ? true : false
        backBtn.isHidden = to == .main ? false : true
        
        UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: []) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.playerBoxEditModeTopAnc.isActive = to == .main ? false : true
                self.playerBoxMainModeTopAnc.isActive = to == .main ? true : false
                
                self.timeTrimSliderView.isHidden = to == .main ? false : true
                self.playerBoxBottonAnc[.main]!.isActive = to == .main
                self.timeTrimSliderView.alpha = to == .main ? 1 : 0
                
                self.speedRateControlBox.isHidden  = to == .speed ? false : true
                self.playerBoxBottonAnc[.speed]!.isActive = to == .speed
                self.speedRateControlBox.alpha = to == .speed ? 1 : 0
                
                
                self.volumeControlBox.isHidden = to == .volume ? false : true
                self.playerBoxBottonAnc[.volume]!.isActive = to == .volume
                self.volumeControlBox.alpha = to == .volume ? 1 : 0
                
                self.filterControlBox.isHidden = to == .filter ? false : true
                self.playerBoxBottonAnc[.filter]!.isActive = to == .filter
                self.filterControlBox.alpha = to == .filter ? 1 : 0
                
                self.cropControlBox.isHidden = to == .crop ? false : true
                self.playerBoxBottonAnc[.crop]!.isActive = to == .crop
                self.cropControlBox.alpha = to == .crop ? 1 : 0
                self.view.layoutIfNeeded()
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                guard let videoSize = self.reactor.getVideoSize() else { return }
                if to == .main {
                    self.filterPlayerView.action( .updatePlayerViewHeightToMain(videoSize) )
                }
                else {
                    self.filterPlayerView.action( .updatePlayerViewHeight(self.filterPlayerView.frame.height, videoSize) )
                }
                self.view.layoutIfNeeded()
            }
        } completion: { [weak self] _ in
            guard let self = self else { return }
            //cropView랑 이런게 제대로 렌더링이 안되는 현상이 있어서 다시 한번 세팅해주는 용도
            self.filterPlayerView.action( .checkIfCropRectExceedsBounds )
            self.filterPlayerView.layoutIfNeeded()
            completion?()
        }
    }
    
}
extension SLVideoEditorMainViewController {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self, let videoSize = self.reactor.getVideoSize() else { return }
            self.filterPlayerView.action( .updateGLKViewOnRotation(videoSize) )
            self.filterPlayerView.action( .updateCropViewOnRotation(videoSize) )
        }) { [weak self] context in
            guard let self = self else { return }
            self.timeTrimSliderView.action( .resetAndRedraw )
        }
        
    }
}
