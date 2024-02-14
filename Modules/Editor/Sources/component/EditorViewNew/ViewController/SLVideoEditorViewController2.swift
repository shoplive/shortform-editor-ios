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
//        UIImage(named: "sl_back_arrow", in: bundle, compatibleWith: nil)
        btn.setImage(ShopLiveShortformEditorSDKAsset.slBackArrow.image.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.imageView?.tintColor = .white
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
    
    private var shortsPlayer : VideoPlayer?
    
    lazy private var playerView : SLVideoEditorPlayerView = {
        let view = SLVideoEditorPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = reactor
        view.backgroundColor = .black
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
    
    
    private var reactor : SLVideoEditorViewReactor
    weak var delegate : SLVideoEditorViewControllerDelegate?
    weak var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
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
        shortsPlayer = VideoPlayer()
        shortsPlayer?.timeUpdateInterval = 0.001
        shortsPlayer?.attach(parent: playerView)
        shortsPlayer?.playerDelegate = reactor
        setLayout()
        bindReactor()
        reactor.action( .viewDidLoad )
        
        backBtn.addTarget(self, action: #selector(backBtnTapped(sender: )), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextBtnTapped(sender: )), for: .touchUpInside)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reactor.action( .viewDidLayOutSubView )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor.action( .setShortformEditorDelegate(self.shortformEditorDelegate) )
    }
    
    deinit {
        ShopLiveLogger.debugLog("[ShopliveShortformEditor] SLVideoEditorViewController2 deinited")
    }
    
    @objc func backBtnTapped(sender : UIButton) {
        reactor.action( .requestViewPop )
    }
    
    @objc func nextBtnTapped(sender : UIButton) {
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
            default:
                break
            }
            
        }
        
        reactor.onMainQueueResultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .initCropView:
                    self.initCropView()
                case .updateConvertPercentage(let percent):
                    self.updateConvertPercentage(percent: percent)
                case .seekTo(let time):
                    self.seekTo(time: time)
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
                case .setPlayerViewPlayState(let isPlaying):
                    self.setPlayerViewPlayState(isPlaying: isPlaying)
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
                    break
                default:
                    break
                }
            }
        }
    }
    
    private func initCropView() {
        playerView.updateCropview(videoSize: reactor.getVideoSize())
    }
    
    private func setShortsVideoToPlayer(video : ShortsVideo){
        shortsPlayer?.setShortsVideo(video: video)
        shortsPlayer?.setVideoGravity(.resizeAspect)
    }
    
    private func setPlayerEndBoundaryTime(time : CMTime){
        shortsPlayer?.setStopTime(time: time)
    }
    
    private func updateConvertPercentage(percent : Int){
        loadingProgress.setLoadingText("\(percent)%")
    }
    
    private func seekTo(time : CMTime) {
        self.shortsPlayer?.seekTo(time: time)
    }
    
    private func setPlayBtnVisible(isVisible : Bool) {
        if isVisible {
            self.playerView.showPlayBtn()
        }
        else {
            self.playerView.hidePlayBtn()
        }
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
    
    private func setPlayerViewPlayState(isPlaying : Bool){
        playerView.updatePlayState(isPlaying: isPlaying)
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
    
}
extension SLVideoEditorViewController2 {
    private func setLayout() {
        self.view.addSubview(naviBar)
        self.view.addSubview(backBtn)
        self.view.addSubview(pageTitleLabel)
        self.view.addSubview(playerView)
        self.view.addSubview(editSliderView)
        self.view.addSubview(seperateLine)
        self.view.addSubview(nextButton)
        self.view.addSubview(loadingProgress.view)
        
        NSLayoutConstraint.activate([
            naviBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            naviBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            naviBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            naviBar.heightAnchor.constraint(equalToConstant: 44),
            
            backBtn.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
            backBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20),
            backBtn.widthAnchor.constraint(equalToConstant: 30),
            backBtn.heightAnchor.constraint(equalToConstant: 30),
            
            pageTitleLabel.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
            pageTitleLabel.centerXAnchor.constraint(equalTo: naviBar.centerXAnchor),
            pageTitleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            pageTitleLabel.heightAnchor.constraint(equalToConstant: 18),
            
            
            playerView.topAnchor.constraint(equalTo: self.naviBar.bottomAnchor),
            playerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: editSliderView.topAnchor,constant: -30),
            
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
            loadingProgress.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}
extension SLVideoEditorViewController2 {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.playerView.updateCropview(videoSize: reactor.getVideoSize())
        }) { [weak self] context in
            guard let self = self else { return }
            self.editSliderView.resetAndRedraw()
        }
        
    }
}
