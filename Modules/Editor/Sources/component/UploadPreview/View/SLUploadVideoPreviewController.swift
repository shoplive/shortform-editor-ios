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
import ShopliveSDKCommon

class SLUploadVideoPreviewController: UIViewController, UIGestureRecognizerDelegate {
    
    private lazy var playerLayer = AVPlayerLayer()
    
    private lazy var playerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.addSublayer(playerLayer)
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
        view.setImage(ShopLiveShortformEditorSDKAsset.slClosebutton.image.withRenderingMode(.alwaysOriginal), for: .normal)
        view.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        view.imageView?.tintColor = .white
        return view
    }()
    
    private lazy var playBtnImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = ShopLiveShortformEditorSDKAsset.slEditorPlayButton.image
        imageView.isHidden = true
        imageView.backgroundColor = .clear
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    private lazy var titleLabel: SLLabel = {
        let view = SLLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setFont(font: .init(size: 16, weight: .medium))
        view.textColor = .white
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.text = "Preview"
        return view
    }()
    
    private lazy var videoTitleLabel: SLLabel = {
        let view = SLLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setFont(font: .init(size: 16, weight: .medium))
        view.textColor = .white
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        return view
    }()
    
    private lazy var videoDescriptionLabel: SLLabel = {
        let view = SLLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setFont(font: .init(size: 13, weight: .regular))
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
        view.setThumbImage(ShopLiveShortformEditorSDKAsset.slTimeSliderThumb.image.withRenderingMode(.alwaysOriginal), for: .normal)
        view.minimumTrackTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        view.maximumTrackTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        return view
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let reactor = SLUploadVideoPreviewReactor()
    
    init(uploadInfo: SLUploadAttachmentInfo) {
        super.init(nibName: nil, bundle: nil)
        reactor.action( .setUploadInfo(uploadInfo) )
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        bindReactor()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        self.view.addGestureRecognizer(tapGesture)
        tapGesture.isEnabled = true
        
        let sliderTapGesture = UITapGestureRecognizer(target: self, action: #selector(sliderTapped(gestureRecognizer:)))
        self.timeSlider.addGestureRecognizer(sliderTapGesture)
        
        self.timeSlider.addTarget(self, action: #selector(sliderValueChanged), for: UIControl.Event.valueChanged)
        
        reactor.action( .viewDidLoad )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = playerView.frame
        playerLayer.videoGravity = .resizeAspect
    }
    
    deinit {
        
    }
    
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .setAVplayer(let player):
                self.onSetAVplayer(player: player)
            case .setTitle(let title):
                self.onSetTitle(title: title)
            case .setDescription(let description):
                self.onSetDescription(description: description)
            case .setTags(let tags):
                self.onSetTags(tags: tags)
            
            case .setPlayBtnIsHidden(let isHidden):
                self.onSetPlayBtnIsHidden(isHidden: isHidden)
            case .setSliderMaximumValue(let value):
                self.onSetSliderMaximumValue(value: value)
            case .updateSliderCurrentValue(let value):
                self.onUpdateSliderCurrentValue(value: Float(value))
            case .setSLiderMinimumValue(let value):
                self.onSetSliderMinimumValue(value: value)
            }
        }
    }
    
    private func onSetAVplayer(player : AVPlayer) {
        self.playerLayer.player = player
    }
    
    private func onSetTitle(title : String) {
        videoTitleLabel.text = title
    }
    
    private func onSetDescription(description : String) {
        videoDescriptionLabel.text = description
    }
    
    private func onSetTags(tags : [String]) {
        tagField.addTags(tags)
        tagField.textField.text = ""
    }
    
    private func onSetPlayBtnIsHidden(isHidden : Bool) {
        self.playBtnImageView.isHidden = isHidden
    }
    
    private func onSetSliderMaximumValue(value : Float) {
        self.timeSlider.maximumValue = value
    }
    
    private func onSetSliderMinimumValue(value : Float) {
        self.timeSlider.minimumValue = value
    }
    
    private func onUpdateSliderCurrentValue(value : Float){
        self.timeSlider.value = value
    }
}
extension SLUploadVideoPreviewController {
    @objc private func didTapClose() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true)
        }
    }
    
    @objc private func sliderValueChanged(_ slider: UISlider) {
        let time = CMTime(seconds: Double(slider.value), preferredTimescale: 44100)
        reactor.action( .seekTo(time) )
    }
    
    @objc func tapHandler(_ recognizer: UITapGestureRecognizer) {
        reactor.action( .toggleVideoPlayOrPause )
    }
    
    @objc func sliderTapped(gestureRecognizer : UITapGestureRecognizer) {
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.view)
        
        let positionOfSlider: CGPoint = timeSlider.frame.origin
        let widthOfSlider: CGFloat = timeSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(timeSlider.maximumValue) / widthOfSlider)
        
        timeSlider.setValue(Float(newValue), animated: false)
        let time = CMTime(seconds: Double(timeSlider.value), preferredTimescale: 44100)
        reactor.action( .seekTo(time) )
    }
}

extension SLUploadVideoPreviewController {
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
        
        
        self.view.bringSubviewToFront(overlayView)
    }
}

