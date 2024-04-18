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
    
    lazy private var backBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(ShopLiveShortformEditorSDKAsset.slBackArrow.image.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.imageView?.tintColor = .white
        return btn
    }()
    
    lazy private var filterAddBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        let bundle = Bundle(for: type(of: self))
        btn.setImage(ShopLiveShortformEditorSDKAsset.slIcFilter.image.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.imageView?.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    lazy private var textAddBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("AddText", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
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
    
    lazy private var filterPlayerView : ShopLiveFilterPlayer = {
        let view = ShopLiveFilterPlayer()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private var optionBtnContainer : OptionBtnContainer = {
        let view = OptionBtnContainer()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var editSliderView: SLVideoEditorSliderView2 = {
        let view = SLVideoEditorSliderView2(videoUrl: reactor.getVideoUrl())
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = reactor
        return view
    }()
    
    private lazy var seperateLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        return view
    }()
    
    private lazy var nextButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        view.setTitle("editor.next.title".localizedString(bundle: bundle), for: .normal)
        view.setTitle("editor.next.title".localizedString(bundle: bundle), for: .disabled)
        view.setBackgroundColor_SL(.white, for: .normal)
        view.setBackgroundColor_SL(.darkGray, for: .disabled)
        view.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), for: .normal)
        view.setTitleColor(.gray, for: .disabled)
        view.cornerRadiusV_SL = 10
        return view
    }()
    
    private lazy var loadingProgress: SLLoadingAlertController = {
        let vc = SLLoadingAlertController()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.useProgress = false
        vc.view.isHidden = true
        vc.setLoadingText("0%")
        return vc
    }()
    
    private lazy var filterSelectionView : SLVideoFilterSelectionView = {
        let view = SLVideoFilterSelectionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    private var reactor : SLVideoEditorViewReactor
    weak var delegate : SLVideoEditorViewControllerDelegate?
    weak var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
    weak var videoEditorDelegate : ShopLiveVideoEditorDelegate?
    private var layoutForInitalLoad : Bool = true
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
        bindFilterSelectionView()
        bindOptionBtnContainer()
        reactor.action( .viewDidLoad )
        
        backBtn.addTarget(self, action: #selector(backBtnTapped(sender: )), for: .touchUpInside)
        textAddBtn.addTarget(self, action: #selector(addTextBtnTapped(sender: )), for: .touchUpInside)
        filterAddBtn.addTarget(self, action: #selector(filterAddBtnTapped(sender: )), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextBtnTapped(sender: )), for: .touchUpInside)
        
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
        reactor.action( .requestViewPop )
    }
    
    @objc func addTextBtnTapped(sender : UIButton) {
        reactor.action( .requestShowCreateTextView )
//        self.filterSelectionView.alpha = 1
    }
    
    @objc func filterAddBtnTapped(sender : UIButton) {
        self.onOptionBtnContainerFilterBtnTapped()
    }
    
    @objc func nextBtnTapped(sender : UIButton) {
        if let filterConfig = filterPlayerView.getFilterConfig() {
            let filterIntensity = filterPlayerView.getFilterIntensity()
            reactor.action( .setFilterConfig(.init(filterConfig: filterConfig, filterIntensity: filterIntensity)) )
        }
        
        reactor.action( .requestVideoConvert )
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
                case .updateConvertPercentage(let percent):
                    self.updateConvertPercentage(percent: percent)
                case .seekTo(let time):
                    self.seekTo(time: time)
                case .setFilterBtnVisible(let isVisible):
                    self.setFilterBtnVisible(isVisible: isVisible)
                case .setPlayBtnVisible(let isVisible):
                    self.setPlayBtnVisible(isVisible: isVisible)
                case .setLoadingVisible(let isVisible):
                    self.setLoadingVisible(isVisible: isVisible)
                case .resetLoadingProgress:
                    self.resetLoadingProgress()
                case .setNextButtnEnable(let isEnabled):
                    self.setNextButtonEnabled(isEnabled: isEnabled)
                case .showUploadInfoViewController(let vc):
                    self.showUPloadInfoViewController(vc: vc)
                case .setTimeIndicatorLineVisible(let isVisible):
                    self.setTimeIndicatorLineVisible(isVisible: isVisible)
                case .setTimeIndicatorLineTime(let time):
                    self.setTimeIndicatorLineTime(time: time)
                case .resetTimeIndicatorLine:
                    self.resetTimeIndicatorLine()
                case .popView:
                    self.popView()
                case .popViewWithMessage:
                    self.popViewWithMessage()
                case .showAlert(let alertController):
                    self.showAlertController(alertVc: alertController)
                    
                case .playVideo:
                    self.onPlayVideo()
                case .pauseVideo:
                    self.onPauseVideo()
                    
                case .setFilterConfig(let filterConfig):
                    self.onSetFilterConfig(filterConfig: filterConfig)
                
                case .presentViewController(let vc):
                    self.onPresentViewController(vc: vc)
                    
                case .addFFmpegTextBox(let textBox):
                    self.onAddFFmpegTextBox(textBox: textBox)
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
        
        self.filterPlayerView.action( .setUpFilterPlayer(fileName, videoUrl , videoSize) )
        
    }
    
    private func setPlayerEndBoundaryTime(time : CMTime){
        filterPlayerView.action( .setPlayerEndBoundaryTime(time) )
    }
    
    private func updateConvertPercentage(percent : Int){
        loadingProgress.setLoadingText("\(percent)%")
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
    
    private func setLoadingVisible(isVisible : Bool) {
        loadingProgress.view.isHidden = !isVisible
    }
    
    private func resetLoadingProgress(){
        loadingProgress.resetProgress()
    }
    
    private func setNextButtonEnabled(isEnabled : Bool) {
        nextButton.isEnabled = isEnabled
    }
    
    private func showUPloadInfoViewController(vc : UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true )
    }
    
    private func setTimeIndicatorLineVisible(isVisible : Bool) {
        editSliderView.setTimeIndicatorLineVisible(isVisible: isVisible)
    }
    
    private func setTimeIndicatorLineTime(time : Float) {
        editSliderView.updateTimeIndicatorTime(time: time)
    }
    
    private func resetTimeIndicatorLine() {
        editSliderView.updateTimeIndicatorTimeToStartPos()
    }
    
    private func popView(){
        self.navigationController?.popViewController(animated: true)
    }
    
    private func popViewWithMessage(){
        self.navigationController?.popViewController(animated: true)
        self.delegate?.cancelConvertVideo()
    }
    
    private func showAlertController(alertVc : UIAlertController) {
        self.present(alertVc, animated: true)
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
    
    private func onAddFFmpegTextBox(textBox : ShopLiveFFmpegTextBox) {
        filterPlayerView.action( .setFFmpegTextBox(textBox) )
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
//MARK: -FilterSelectionView Binding
extension SLVideoEditorViewController2 {
    private func bindFilterSelectionView() {
        
        filterSelectionView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .filterConfigChanged(let filterConfig):
                self.onFilterSelectionViewFilterConfigChanged(filterConfig: filterConfig)
            case .filterIntensityChanged(let intensity):
                self.onFilterSelectionViewFilterIntensityChanged(intensity: intensity)
            case .filterSelectionEnded:
                self.onFilterSelectionViewFilterSelectionEnded()
                break
            }
        }
    }

    
    private func onFilterSelectionViewFilterConfigChanged(filterConfig : String) {
        filterPlayerView.action( .setFilterConfig(filterConfig) )
        filterPlayerView.action( .tingleVideo )
    }
    
    private func onFilterSelectionViewFilterIntensityChanged(intensity : Float) {
        filterPlayerView.action( .setFilterIntensity(intensity) )
        filterPlayerView.action( .tingleVideo )
    }
    
    private func onFilterSelectionViewFilterSelectionEnded() {
        self.filterPlayerView.action( .seekToTingleStartedTime )
    }
}
//MARK: -OptionBtnContainer
extension SLVideoEditorViewController2 {
    private func bindOptionBtnContainer() {
        optionBtnContainer.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .filterBtnTapped:
                self.onOptionBtnContainerFilterBtnTapped()
            }
        }
    }
    
    private func onOptionBtnContainerFilterBtnTapped() {
        filterPlayerView.action( .pauseVideo )
        filterPlayerView.action( .setThumbnailGLKView )
        self.filterSelectionView.animateOpen()
    }
    
}
extension SLVideoEditorViewController2 {
    private func setLayout() {
        self.view.addSubview(naviBar)
        self.view.addSubview(backBtn)
        
        
        let topBarRightBtnStack = UIStackView(arrangedSubviews: [textAddBtn, filterAddBtn])
        topBarRightBtnStack.translatesAutoresizingMaskIntoConstraints = false
        filterAddBtn.translatesAutoresizingMaskIntoConstraints = false
        textAddBtn.translatesAutoresizingMaskIntoConstraints = false
        topBarRightBtnStack.axis = .horizontal
        topBarRightBtnStack.spacing = 10
        self.view.addSubview(topBarRightBtnStack)
//
//        self.view.addSubview(filterAddBtn)
//        self.view.addSubview(textAddBtn)
        self.view.addSubview(pageTitleLabel)
        
        self.view.addSubview(filterPlayerView)
//        self.view.addSubview(optionBtnContainer)
        
        self.view.addSubview(editSliderView)
        self.view.addSubview(seperateLine)
        self.view.addSubview(nextButton)
        self.view.addSubview(loadingProgress.view)
        self.view.addSubview(filterSelectionView)
        
        NSLayoutConstraint.activate([
            naviBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            naviBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            naviBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            naviBar.heightAnchor.constraint(equalToConstant: 44),
            
            backBtn.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
            backBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20),
            backBtn.widthAnchor.constraint(equalToConstant: 30),
            backBtn.heightAnchor.constraint(equalToConstant: 30),
            
//            filterAddBtn.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
//            filterAddBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -20),
//            filterAddBtn.widthAnchor.constraint(equalToConstant: 30),
//            filterAddBtn.heightAnchor.constraint(equalToConstant: 25),
//
//
//            textAddBtn.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
//            textAddBtn.trailingAnchor.constraint(equalTo: filterAddBtn.leadingAnchor,constant: -10),
//            textAddBtn.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
//            textAddBtn.heightAnchor.constraint(equalToConstant: 30),
            
            topBarRightBtnStack.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
            topBarRightBtnStack.trailingAnchor.constraint(equalTo: naviBar.trailingAnchor,constant: -20),
            topBarRightBtnStack.heightAnchor.constraint(equalToConstant: 30),
            topBarRightBtnStack.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            
            filterAddBtn.widthAnchor.constraint(equalToConstant: 30),
            textAddBtn.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            
            
            pageTitleLabel.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
            pageTitleLabel.centerXAnchor.constraint(equalTo: naviBar.centerXAnchor),
            pageTitleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            pageTitleLabel.heightAnchor.constraint(equalToConstant: 18),
            
            
            filterPlayerView.topAnchor.constraint(equalTo: self.naviBar.bottomAnchor),
            filterPlayerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 0),
            filterPlayerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: 0),
            filterPlayerView.bottomAnchor.constraint(equalTo: editSliderView.topAnchor,constant: -30),
            
            
//            optionBtnContainer.centerYAnchor.constraint(equalTo: filterPlayerView.centerYAnchor, constant: 0),
//            optionBtnContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
//            optionBtnContainer.widthAnchor.constraint(equalToConstant: 30),
            
            
            
            editSliderView.bottomAnchor.constraint(equalTo: seperateLine.topAnchor,constant: -16),
            editSliderView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            editSliderView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            editSliderView.heightAnchor.constraint(equalToConstant: 60),
        
            seperateLine.bottomAnchor.constraint(equalTo: nextButton.topAnchor,constant: -12),
            seperateLine.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            seperateLine.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            seperateLine.heightAnchor.constraint(equalToConstant: 1),
            
            nextButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: -12),
            nextButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,constant:  20),
            nextButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            
            
            loadingProgress.view.topAnchor.constraint(equalTo: naviBar.bottomAnchor),
            loadingProgress.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            loadingProgress.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            loadingProgress.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            
            filterSelectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            filterSelectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            filterSelectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            filterSelectionView.topAnchor.constraint(equalTo: self.view.topAnchor)
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
            self.editSliderView.resetAndRedraw()
        }
        
    }
}
