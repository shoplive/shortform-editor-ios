//
//  SLVideoEditorViewController.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 4/12/23.
//

import UIKit
import AVKit
import ShopliveSDKCommon

protocol SLVideoEditorViewControllerDelegate: AnyObject {
    func cancelConvertVideo()
}

class SLVideoEditorViewController: UIViewController {
    private var temporaryUploadInfo: SLUploadAttachmentInfo?
    
    private var shortsPlayer: VideoPlayer?
    
    weak var delegate: SLVideoEditorViewControllerDelegate?
    
    private weak var video: ShortsVideo?
    
    private var cropTime: (start: CMTime, end: CMTime) = (.zero, .zero)
    private var cropRect: CGRect = .zero
    private var isPlaying: Bool = false
    private var updatedCropTime: Bool = false
    private var sliderInitialized: Bool = false
    
    private var isCanceled: Bool = false
    
    private lazy var videoConverter: SLVideoConverter? = {
        let converter = SLVideoConverter()
        converter.delegate = self
        return converter
    }()
    
    init(video: ShortsVideo?) {
        self.video = video
        self.video?.seekNotificationEnabled = false
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        teardownEditor()
    }
    
    private func teardownEditor() {
        self.videoConverter = nil
        self.shortsPlayer = nil
        self.video = nil
    }
    
    private lazy var playerView: SLVideoEditorPlayerView = {
        let view = SLVideoEditorPlayerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var videoEditSliderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nextButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        let bundle = Bundle(for: type(of: self))
        view.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        view.setTitle("editor.next.title".localizedString(bundle: bundle), for: .normal)
        view.setTitle("editor.next.title".localizedString(bundle: bundle), for: .disabled)
        view.setBackgroundColor_SL(.white, for: .normal)
        view.setBackgroundColor_SL(.darkGray, for: .disabled)
        view.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), for: .normal)
        view.setTitleColor(.gray, for: .disabled)
        view.cornerRadiusV_SL = 10
        view.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        return view
    }()
    
    private lazy var bottomLayoutView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)
        nextButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 12).isActive = true
        nextButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return view
    }()
    
    private lazy var seperateLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        return view
    }()
    
    private lazy var loadingProgress: SLLoadingAlertController = {
        let vc = SLLoadingAlertController()
        vc.delegate = self
        vc.useProgress = false
        vc.view.isHidden = true
        let bundle = Bundle(for: type(of: self))
        vc.setLoadingText("0%")
        return vc
    }()

    
    private var layoutForInitalLoad : Bool = true
    lazy private var currentOrientation : UIInterfaceOrientationMask = didChangeOrientation_SL()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        shortsPlayer = VideoPlayer()
        shortsPlayer?.timeUpdateInterval = 0.001
        layout()
        attributes()
        bindView()
        bindData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if layoutForInitalLoad || (currentOrientation != didChangeOrientation_SL()) {
            if layoutForInitalLoad == false {
                editSliderView.onOrientationChange()
            }
            playerView.updateCropview(videoSize: video?.getVideoSize())
            self.currentOrientation = didChangeOrientation_SL()
            layoutForInitalLoad = false
        }
    }
    
    private lazy var navibarConstraint = [
        self.navibar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        self.navibar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        self.navibar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        self.navibar.heightAnchor.constraint(equalToConstant: 44)
    ]
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func layout() {
        self.view.backgroundColor = .black
        self.view.addSubview(navibar)
        self.view.addSubview(playerView)
        self.view.addSubview(videoEditSliderView)
        self.view.addSubview(seperateLine)
        self.view.addSubview(bottomLayoutView)
        self.view.addSubview(loadingProgress.view)
        let bottomLayoutContraint = [
            bottomLayoutView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            bottomLayoutView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            bottomLayoutView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            bottomLayoutView.heightAnchor.constraint(equalToConstant: 64)
        ]
        
        let videoEditSliderConstraint = [
            videoEditSliderView.bottomAnchor.constraint(equalTo: bottomLayoutView.topAnchor, constant: -16),
            videoEditSliderView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            videoEditSliderView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            videoEditSliderView.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        let playerViewConstraint = [
            playerView.bottomAnchor.constraint(equalTo: videoEditSliderView.topAnchor, constant: -30),
            playerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            playerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            playerView.topAnchor.constraint(equalTo: self.navibar.bottomAnchor, constant: 0)
        ]
        
        let seperateLineConstraint = [
            seperateLine.bottomAnchor.constraint(equalTo: bottomLayoutView.topAnchor, constant: 0),
            seperateLine.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            seperateLine.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            seperateLine.heightAnchor.constraint(equalToConstant: 1)
        ]
        
        loadingProgress.view.fit_SL()
        self.view.bringSubviewToFront(seperateLine)
        self.view.bringSubviewToFront(self.loadingProgress.view)
        self.view.bringSubviewToFront(self.navibar)
        
        NSLayoutConstraint.activate(navibarConstraint)
        NSLayoutConstraint.activate(bottomLayoutContraint)
        NSLayoutConstraint.activate(videoEditSliderConstraint)
        NSLayoutConstraint.activate(playerViewConstraint)
        NSLayoutConstraint.activate(seperateLineConstraint)
        
        shortsPlayer?.attach(parent: playerView)
        
        self.setNavigationBar()
        DispatchQueue.main.async {
            self.videoEditSliderView.addSubview(self.editSliderView)
            let editSliderViewConstraint = [
                self.editSliderView.leadingAnchor.constraint(equalTo: self.videoEditSliderView.leadingAnchor, constant: 0),
                self.editSliderView.trailingAnchor.constraint(equalTo: self.videoEditSliderView.trailingAnchor, constant: 0),
                self.editSliderView.centerYAnchor.constraint(equalTo: self.videoEditSliderView.centerYAnchor, constant: 0),
                self.editSliderView.heightAnchor.constraint(equalToConstant: 60)
            ]
            
            NSLayoutConstraint.activate(editSliderViewConstraint)
        }
        
    }
    
    private lazy var editSliderView: SLVideoEditorSliderView = {
        let view = SLVideoEditorSliderView(videoUrl: video?.videoUrl)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    
    private lazy var navibar: UINavigationBar = {
        let view = UINavigationBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.tintColor = .black
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .black
            view.standardAppearance = appearance
            view.scrollEdgeAppearance = appearance
            
        } else {
            // Fallback on earlier versions
        }
        return view
    }()
    
    private lazy var naviItem: UINavigationItem = {
        let item = UINavigationItem()
        item.titleView?.backgroundColor = .black
        return item
    }()
    
    private lazy var titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        let titleLabel = UILabel()
        titleLabel.textColor = .white
        var paragraphStyle = NSMutableParagraphStyle()
        titleLabel.textAlignment = .center
        let bundle = Bundle(for: type(of: self))
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.attributedText = NSMutableAttributedString(string: "editor.page.title".localizedString(bundle: bundle), attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle, .font: font])
        view.addSubview(titleLabel)
        titleLabel.fit_SL()
        return view
    }()
    
    private func setNavigationBar(){
        configureNavigationButton()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        updateConstraint()
    }
    
    private func updateConstraint() {
        NSLayoutConstraint.activate(navibarConstraint)
    }
       
    private func configureNavigationButton(){
        let bundle = Bundle(for: type(of: self))
        let backImage = UIImage(named: "back_arrow", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        naviItem.titleView = titleView
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(self.back))
        naviItem.leftBarButtonItem = backButton
        self.navibar.setItems([naviItem], animated: false)
    }
    
    @objc func back() {
        let bundle = Bundle(for: type(of: self))
        if let inConvert = self.videoConverter?.inConvert, inConvert {
            let cancelAlert = UIAlertController(title: "editor.encoding.cancel.alert.title".localizedString(bundle: bundle), message: nil, preferredStyle: .alert)
            cancelAlert.addAction(.init(title: "alert.no".localizedString(bundle: bundle), style: .cancel))
            cancelAlert.addAction(.init(title: "alert.yes".localizedString(bundle: bundle), style: .default, handler: { [weak self] action in
                self?.isCanceled = true
                self?.videoConverter?.cancelConvert()
                self?.navigationController?.popViewController(animated: true)
                self?.delegate?.cancelConvertVideo()
            }))
            self.present(cancelAlert, animated: true)
        } else {
            stop()
            teardownEditor()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func attributes() {
        shortsPlayer?.playerDelegate = self
    }
    
    private func bindView() {
        
    }
    
    private func bindData() {
        
        if let video = video, let duration = video.player?.currentItem?.duration {
            shortsPlayer?.setShortsVideo(video: video)
            shortsPlayer?.setVideoGravity(.resizeAspect)
            
            let seconds = CMTimeGetSeconds(duration)
            var initialEndTime : CGFloat = 0
            if let maxVideoTrimTime = ShopLiveShortformEditorConfigurationManager.shared.shortformUploadConfiguration?.videoTrimOption.maxVideoDuration {
                initialEndTime = seconds >= maxVideoTrimTime ? maxVideoTrimTime : seconds
            }
            else {
                initialEndTime = seconds >= 60 ? 60 : seconds
            }
            
            cropTime.end = CMTime(seconds: initialEndTime , preferredTimescale: 44100)
        }
    }
    
    @objc private func didTapNextButton() {
        guard let videoUrl = video?.videoUrl.absoluteString,
        let startTime = cropTime.start.timeSeconds_SL,
        let endTime = cropTime.end.timeSeconds_SL else { return }
        
        stop()
        
        self.playerView.hidePlayBtn()
        
        let videoInfo = SLVideoInfo(videoPath: videoUrl, cropRect: cropRect, videoSize: self.playerView.videoResolution, timeRange: (startTime, endTime), fileName: (videoUrl as NSString).lastPathComponent)
        
        DispatchQueue.main.async { [weak self] in
            self?.loadingProgress.view.isHidden = false
            self?.nextButton.isEnabled = false
        }
        videoConverter?.convertVideo(videoInfo: videoInfo) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                self?.nextButton.isEnabled = true
                self?.loadingProgress.view.isHidden = true
            }
            switch result {
            case .Success(let videoPath):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    guard !self.isCanceled else {
                        self.isCanceled = false
                        return
                    }
                    if let uploadInfo = self.temporaryUploadInfo {
                        self.temporaryUploadInfo?.videoUrl = videoPath
                        let vc = SLUploadInfoController2(uploadInfo: uploadInfo)
                        vc.delegate = self
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        let vc = SLUploadInfoController2(videoUrl: videoPath )
                        vc.delegate = self
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                break
            case .Failed(let error):
                guard let videoConverterError = error as? SLVideoConvertError else {
                    return
                }
                switch videoConverterError {
                case .cancel:
//                    print("video cancel")
                    break
                case .error:
//                    print("video error \(error.localizedDescription)")
                    break
                }
                break
            }
            DispatchQueue.main.async {
                self.playerView.showPlayBtn()
            }
        }
    }
}


extension SLVideoEditorViewController: SLShortsVideoPlayerDelegate {
    
    func onVideoTimeUpdated(time: Float64) {
        let timeString = String(String(describing: time))
        editSliderView.updateTime(time: Float(time))
    }
    
    func handlePlayerItemStatus(_ status: AVPlayerItem.Status) {
        switch status {
        case .unknown:
            break
        case .readyToPlay:
            break
        case .failed:
            break
        @unknown default:
            break
        }
    }
    
    func handleTimeControlStatus(_ status: AVPlayer.TimeControlStatus) {
        switch status {
        case .paused:
            isPlaying = false
            break
        case .playing:
            isPlaying = true
            break
        case .waitingToPlayAtSpecifiedRate:
            break
        @unknown default:
            break
        }
        
        playerView.updatePlayState(isPlaying: !isPlaying)
    }
    
    func handleDidPlayToEndTime(video: ShortsVideo?) {
        editSliderView.setSliderVisible(false)
        shortsPlayer?.seekTo(time: cropTime.start)
        editSliderView.updateTimeToStart()
    }
}

extension SLVideoEditorViewController: SLVideoEditorSliderViewDelegate {
    func sliderInitialize() {
        sliderInitialized = true
    }
    
    func updateCropTime(start: CMTime, end: CMTime) {
        updatedCropTime = true
        
        cropTime.start = start
        cropTime.end = end
        
        shortsPlayer?.setStopTime(time: cropTime.end)
    }
    
    private func play() {
        editSliderView.setSliderVisible(true)
        shortsPlayer?.play()
    }
    
    private func pause() {
        editSliderView.setSliderVisible(false)
        shortsPlayer?.pause()
    }
    
    private func stop() {
        editSliderView.setSliderVisible(false)
        shortsPlayer?.pause()
        shortsPlayer?.seekTo(time: cropTime.start)
        editSliderView.updateTimeToStart()
    }
    
    func seekTo(time: CMTime, handleType: SLVideoEditorSliderHandleType) {
        pause()
        guard let timeSeconds = time.timeSeconds_SL else { return }
        
//        switch handleType {
//        case .left:
//            videoPlayTimeView.setCurrentTime(timeSeconds)
//            break
//        case .right:
//            videoPlayTimeView.setTotalTime(timeSeconds)
//            break
//        }
        video?.seekTo(time: time)
    }
}

extension SLVideoEditorViewController: SLVideoEditorPlayerViewDelegate {
    func updateCropRect(frame: CGRect) {
        cropRect = frame
    }
    
    func didTapPlayerView() {
        if updatedCropTime {
            shortsPlayer?.seekTo(time: cropTime.start)
            updatedCropTime = false
        }
        guard sliderInitialized else { return }
        isPlaying ? pause() : play()
        
    }
}

extension SLVideoEditorViewController: SLUploadInfoControllerDelegate {
    func temporaryUploadInfo(uploadInfo: SLUploadAttachmentInfo) {
        temporaryUploadInfo = uploadInfo
        loadingProgress.resetProgress()
    }
}

extension SLVideoEditorViewController: SLVideoConverterDelegate {
    func updateConvertPercent(percent: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.loadingProgress.setLoadingText("\(percent)%")
//            self?.loadingProgress.setProgress(CGFloat(percent) / 100)
        }
    }
}

extension SLVideoEditorViewController: SLLoadingAlertControllerDelegate {
    func didCancelLoading() {
        //필터 관련 브랜치 머지하면서 구체화 될 예정 그전까지는 no - op으로 설정
    }
    
    func didFinishLoading() {
        //필터 관련 브랜치 머지하면서 구체화 될 예정 그전까지는 no - op으로 설정
    }
    
    func cancelLoading() {
        
    }
    
    func finishLoading() {
        
    }
}

