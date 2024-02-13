//
//  SLUploadVideoPreviewController.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 4/30/23.
//

import Foundation
import AVKit
import UIKit
import AVKit
import ShopLiveSDKCommon

class SLUploadVideoPreviewController: UIViewController, UIGestureRecognizerDelegate {
    
    private var shortsPlayer: VideoPlayer?
    private var video: ShortsVideo?
    
    private var videoUrl: String?
    
    private var isPlaying: Bool = false
    private var inSeeking: Bool = false
    
    private var uploadInfo: SLUploadAttachmentInfo
    
    private var latestPlayTime: Float = .zero
    
    private lazy var playerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let dim = UIView()
        dim.backgroundColor = .black
        dim.alpha = 0.2
        view.addSubview(dim)
        dim.fit_SL()
        
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        let bundle = Bundle(for: type(of: self))
        let closeImage = UIImage(named: "sl_closebutton", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        view.setImage(closeImage, for: .normal)
        view.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        view.imageView?.tintColor = .white
        return view
    }()
    
    private lazy var playBtnImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let bundle = Bundle(for: type(of: self))
        let playImage = UIImage(named: "sl_editor_play_button", in: bundle, compatibleWith: nil)
        imageView.image = playImage
        imageView.isHidden = true
        imageView.backgroundColor = .clear
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textColor = .white
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        return view
    }()
    
    private lazy var videoTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textColor = .white
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        return view
    }()
    
    private lazy var videoDescriptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 13, weight: .regular)
        view.textColor = .white
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        return view
    }()
    
    private lazy var tagField: SLWSTagsField = {
        let view = SLWSTagsField(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        view.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        view.textColor = .white
        view.cornerRadius = 3.0
        view.spaceBetweenLines = 10
        view.spaceBetweenTags = 10
        view.placeholderAlwaysVisible = false
        view.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        view.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.placeholder = ""
        view.placeholderColor = UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1.0)
        view.textField.returnKeyType = .continue
        view.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0)
        view.useCloseButton = false
        view.isDisplayMode = true
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var timeSlider: UISlider = {
        let view = UISlider()
        view.translatesAutoresizingMaskIntoConstraints = false
        let bundle = Bundle(for: type(of: self))
        let timeSliderThumb = UIImage(named: "sl_timeSliderThumb", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        view.setThumbImage(timeSliderThumb, for: .normal)
        view.minimumTrackTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        view.maximumTrackTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        return view
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    init(uploadInfo: SLUploadAttachmentInfo) {
        self.uploadInfo = uploadInfo
        super.init(nibName: nil, bundle: nil)
        
        if let videoUrl = URL(string: uploadInfo.videoUrl) {
            self.video = ShortsVideo(videoUrl: videoUrl)
            self.video?.seekNotificationEnabled = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shortsPlayer = VideoPlayer()
        shortsPlayer?.timeUpdateInterval = 0.01
        layout()
        attributes()
        bindData()
        
        shortsPlayer?.play()
    }
    
    deinit {
        shortsPlayer?.detach()
        shortsPlayer?.stop()
        shortsPlayer = nil
        self.video = nil
    }
    
    private func layout() {
        self.view.backgroundColor = .black
        
        self.view.addSubview(playerView)
        self.view.addSubview(overlayView)
        
        self.overlayView.addSubview(closeButton)
        self.overlayView.addSubview(titleLabel)
        self.overlayView.addSubview(videoTitleLabel)
        self.overlayView.addSubview(videoDescriptionLabel)
        self.overlayView.addSubview(timeSlider)
        self.overlayView.addSubview(tagField)
        self.overlayView.addSubview(playBtnImageView)
        
        let closeButtonConstraint = [
            closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
        ]
        
        let titleLabelConstraint = [
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            titleLabel.rightAnchor.constraint(lessThanOrEqualTo: closeButton.leftAnchor, constant: 0)
        ]
        
        let videoTitleLabelConstraint = [
            videoTitleLabel.bottomAnchor.constraint(equalTo: self.videoDescriptionLabel.topAnchor, constant: -4),
            videoTitleLabel.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            videoTitleLabel.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -16)
        ]
        
        let videoDescriptionLabelConstraint = [
            videoDescriptionLabel.bottomAnchor.constraint(equalTo: self.tagField.topAnchor, constant: -6),
            videoDescriptionLabel.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 16),
            videoDescriptionLabel.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -16)
        ]
        
        let timeSliderConstraint = [
            timeSlider.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            timeSlider.leftAnchor.constraint(equalTo: overlayView.leftAnchor, constant: 20),
            timeSlider.rightAnchor.constraint(equalTo: overlayView.rightAnchor, constant: -20),
        ]
        
        let tagFieldConstraint = [
            tagField.bottomAnchor.constraint(equalTo: self.timeSlider.topAnchor, constant: -10),
            tagField.leftAnchor.constraint(equalTo: overlayView.leftAnchor, constant: 10),
            tagField.rightAnchor.constraint(equalTo: overlayView.rightAnchor, constant: -10),
        ]
        
        let playBtnImageViewConstraint = [
            playBtnImageView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            playBtnImageView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            playBtnImageView.widthAnchor.constraint(equalToConstant: 72),
            playBtnImageView.heightAnchor.constraint(equalToConstant: 72)
        ]
        
        let playerViewConstraint = [
            playerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            playerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            playerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ]
        
        let overlayViewConstraint = [
            overlayView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(closeButtonConstraint)
        NSLayoutConstraint.activate(titleLabelConstraint)
        NSLayoutConstraint.activate(timeSliderConstraint)
        NSLayoutConstraint.activate(tagFieldConstraint)
        NSLayoutConstraint.activate(videoDescriptionLabelConstraint)
        NSLayoutConstraint.activate(videoTitleLabelConstraint)
        NSLayoutConstraint.activate(playBtnImageViewConstraint)
        NSLayoutConstraint.activate(playerViewConstraint)
        NSLayoutConstraint.activate(overlayViewConstraint)
        
        shortsPlayer?.attach(parent: playerView)
        self.view.bringSubviewToFront(overlayView)
    }
    
    private func attributes() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        self.view.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        tapGesture.isEnabled = true
        
        shortsPlayer?.playerDelegate = self
        
        let sliderTapGesture = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(gestureRecognizer:)))
        self.timeSlider.addGestureRecognizer(sliderTapGesture)
        
        self.timeSlider.addTarget(self, action: #selector(sliderValueChanged), for: UIControl.Event.valueChanged)
    }
    
    private func bindData() {
        if let video = video {
            shortsPlayer?.setShortsVideo(video: video)
            shortsPlayer?.setVideoGravity(.resizeAspect)
        }
        
        videoTitleLabel.text = uploadInfo.title
        videoDescriptionLabel.text = uploadInfo.description
        
        tagField.addTags(uploadInfo.tags ?? [])
        tagField.textField.text = ""
        
        titleLabel.text = "Preview"
    }
    
    @objc private func didTapClose() {
        self.dismiss(animated: true)
    }
    
    @objc private func sliderValueChanged(_ slider: UISlider) {
        inSeeking = true
        let time = CMTime(seconds: Double(slider.value), preferredTimescale: 44100)
        latestPlayTime = slider.value
        self.video?.player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] isFinished in
            guard isFinished else { return }
            self?.inSeeking = false
        }
    }
    
    @objc func tapHandler(_ recognizer: UITapGestureRecognizer) {
        isPlaying ? shortsPlayer?.pause() : shortsPlayer?.play()
        if isPlaying == false {
            playBtnImageView.isHidden = false
        }
    }
    
    @objc func sliderTapped(gestureRecognizer : UITapGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.view)
        
        let positionOfSlider: CGPoint = timeSlider.frame.origin
        let widthOfSlider: CGFloat = timeSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(timeSlider.maximumValue) / widthOfSlider)
        
        timeSlider.setValue(Float(newValue), animated: false)
        
        inSeeking = true
        let time = CMTime(seconds: Double(timeSlider.value), preferredTimescale: 44100)
        latestPlayTime = timeSlider.value
        self.video?.player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] isFinished in
            guard isFinished else { return }
            self?.inSeeking = false
        }
    }
    
}
extension SLUploadVideoPreviewController : SLShortsVideoPlayerDelegate {
    func handlePlayerItemStatus(_ status: AVPlayerItem.Status) {
        switch status {
        case .unknown:
            break
        case .readyToPlay:
            if let duration = video?.player?.currentItem?.duration {
                timeSlider.minimumValue = 0
                let seconds = CMTimeGetSeconds(duration)
                timeSlider.maximumValue = Float(seconds)
            }
            
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
            playBtnImageView.isHidden = true
            break
        case .waitingToPlayAtSpecifiedRate:
            break
        @unknown default:
            break
        }
    }
    
    func handleDidPlayToEndTime(video: ShortsVideo?) {
        guard let shortsPlayer = shortsPlayer else { return }
        latestPlayTime = 0.0
        shortsPlayer.replay()
    }
    
    func onVideoTimeUpdated(time: Float64) {
        let currentTime = Float(time)
        guard isPlaying else { return }
        guard !inSeeking else { return }
        guard latestPlayTime >= 0.0 && currentTime >= latestPlayTime else { return }
        
        latestPlayTime = currentTime < 0 ? 0 : currentTime
        
        timeSlider.value = currentTime
    }
}
