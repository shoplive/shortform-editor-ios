//
//  ShopLiveShortformUploaderPreviewController.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 4/30/23.
//

import Foundation
import AVKit
import UIKit
import AVKit
import ShopliveSDKCommon

class ShopLiveShortformUploaderPreviewController: UIViewController, UIGestureRecognizerDelegate {
    
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
        dim.backgroundColor = .clear
        view.addSubview(dim)
        dim.fit_SL()
        return view
    }()
    
    private var topDimmedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var bottomDimmedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var topGradient: CAGradientLayer?
    private var bottomGradient: CAGradientLayer?
    
    private lazy var backButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(ShopLiveShortformEditorSDKAsset.slBackArrow.image, for: .normal)
        view.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
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
        view.setFont(font: .init(size: 16, weight: .bold))
        view.textColor = .white
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.text = ShopLiveShortformEditorSDKStrings.Editor.Ugc.Preview.title
        return view
    }()
    
    private lazy var timeSlider: UISlider = {
        let view = UISlider()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setThumbImage(ShopLiveShortformEditorSDKAsset.slTimeSliderThumb.image, for: .normal)
        view.minimumTrackTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        view.maximumTrackTintColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        return view
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let reactor = SLUploadVideoPreviewReactor()
    
    init(url: String) {
        super.init(nibName: nil, bundle: nil)
        reactor.action( .setUrl(url) )
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        playerLayer.videoGravity = .resizeAspectFill
        
        topGradient?.frame = topDimmedView.bounds
        bottomGradient?.frame = bottomDimmedView.bounds
    }
    
    deinit {
        ShopLiveLogger.memoryLog("SLUploadVideoPreviewController deinited")
    }
    
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .setAVplayer(let player):
                self.onSetAVplayer(player: player)
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
extension ShopLiveShortformUploaderPreviewController {
    @objc private func didTapBack() {
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

extension ShopLiveShortformUploaderPreviewController {
    private func layout() {
        self.view.backgroundColor = .black
        
        self.view.addSubview(playerView)
        self.view.addSubview(topDimmedView)
        self.view.addSubview(bottomDimmedView)
        self.view.addSubview(overlayView)
        
        let topGradientLayer = CAGradientLayer()
        let bottomGradientLayer = CAGradientLayer()
        
        topGradient = topGradientLayer
        bottomGradient = bottomGradientLayer
        
        if #available(iOS 13.0, *) {
            let colors: [CGColor] = [
                UIColor.black.withAlphaComponent(0.5).cgColor,
                UIColor.clear.cgColor
            ]
            
            topGradientLayer.colors = colors
            topGradientLayer.startPoint = .init(x: 0.5, y: 0.0)
            topGradientLayer.endPoint = .init(x: 0.5, y: 1.0)
            
            topDimmedView.layer.addSublayer(topGradientLayer)
            
            bottomGradientLayer.colors = colors.reversed()
            
            bottomGradientLayer.startPoint = .init(x: 0.5, y: 0.0)
            bottomGradientLayer.endPoint = .init(x: 0.5, y: 1.0)
            
            bottomDimmedView.layer.addSublayer(bottomGradientLayer)
        }
        
        self.overlayView.addSubview(backButton)
        self.overlayView.addSubview(titleLabel)
        self.overlayView.addSubview(timeSlider)
        self.overlayView.addSubview(playBtnImageView)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12),
            backButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            
            timeSlider.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            timeSlider.leftAnchor.constraint(equalTo: overlayView.leftAnchor, constant: 20),
            timeSlider.rightAnchor.constraint(equalTo: overlayView.rightAnchor, constant: -20),
            
            playBtnImageView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            playBtnImageView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            playBtnImageView.widthAnchor.constraint(equalToConstant: 72),
            playBtnImageView.heightAnchor.constraint(equalToConstant: 72),
            
            playerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            playerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            playerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            overlayView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            topDimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            topDimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topDimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topDimmedView.heightAnchor.constraint(equalToConstant: UIScreen.topSafeArea_SL + 80),
            
            bottomDimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomDimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomDimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomDimmedView.heightAnchor.constraint(equalToConstant: UIScreen.bottomSafeArea_SL + 80)
        ])
        
        self.view.bringSubviewToFront(overlayView)
    }
}

