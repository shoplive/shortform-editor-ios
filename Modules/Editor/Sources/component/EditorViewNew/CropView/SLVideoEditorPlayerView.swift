//
//  SLVideoEditorPlayerView.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 4/24/23.
//

import UIKit
import ShopliveSDKCommon

protocol SLVideoEditorPlayerViewDelegate: AnyObject {
    func didTapPlayerView()
    func updateCropRect(frame: CGRect)
}

class SLVideoEditorPlayerView: UIView, UIGestureRecognizerDelegate, SLVideoEditorPlayerCropViewDelegate {
    weak var delegate: SLVideoEditorPlayerViewDelegate?
    
    private lazy var cropView: SLVideoEditorPlayerCropView = {
        let view = SLVideoEditorPlayerCropView()
        view.delegate = self
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var playButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        let bundle = Bundle(for: type(of: self))
        let closebuttonImage = UIImage(named: "sl_editor_play_button", in: bundle, compatibleWith: nil)
        view.setImage(closebuttonImage, for: .normal)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        layout()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        self.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        tapGesture.isEnabled = true
        
        let cropviewTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        cropView.addGestureRecognizer(cropviewTapGesture)
        cropviewTapGesture.delegate = self
        cropviewTapGesture.isEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ShopLiveLogger.debugLog("[ShopliveShortformEditor] SLVideoEditorPlayerView deinited")
    }
    
    @objc func tapHandler(_ recognizer: UITapGestureRecognizer) {
        delegate?.didTapPlayerView()
    }
    
    private func layout() {
        self.addSubview(cropView)
        self.addSubview(playButton)
        
        let playButtonConstraints = [
            playButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            playButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            playButton.widthAnchor.constraint(equalToConstant: 72),
            playButton.heightAnchor.constraint(equalToConstant: 72)
        ]
        
        NSLayoutConstraint.activate(playButtonConstraints)
        
        
    }
    
    func setCropResolution(_ resolution: CGSize) {
        
    }
    
    var videoResolution: CGSize = .zero
    
    
    //실제 크롭 되는 에리어가 아니라 cropView를 들고 있는 컨테이너뷰의 크기를 정하는 작업
    func updateCropview(videoSize: CGSize?) {
        guard let videoSize = videoSize else { return }
        videoResolution = videoSize
        cropView.videoResolution = videoSize
        let frameRatio = self.frame.width / self.frame.height
        let videoRatio = videoSize.width / videoSize.height
        
        if frameRatio == videoRatio {
            cropView.frame = self.frame
        } else {
            if frameRatio < videoRatio {
                let letterSpacing = (self.frame.height - (self.frame.width * (videoSize.height / videoSize.width))) / 2
                cropView.frame = CGRect(x: 0, y: letterSpacing, width: self.frame.width, height: self.frame.height - (letterSpacing * 2))
            } else {
                let letterSpacing = (self.frame.width - (self.frame.height * (videoSize.width / videoSize.height))) / 2
                cropView.frame = CGRect(x: letterSpacing, y: 0, width: self.frame.width - (letterSpacing * 2), height: self.frame.height)
            }
        }
        
        self.bringSubviewToFront(self.cropView)
        self.bringSubviewToFront(playButton)
        self.cropView.updateCropArea(self.cropView.frame)
        self.cropView.setNeedsDisplay()
        self.delegate?.updateCropRect(frame: self.cropView.getCropRect())
    }
    
    func updatePlayState(isPlaying: Bool) {
        playButton.isHidden = isPlaying
    }
    
    func hidePlayBtn(){
        playButton.isHidden = true
    }
    
    func showPlayBtn(){
        playButton.isHidden = false
    }
    
    func updateCropRect(frame: CGRect) {
        delegate?.updateCropRect(frame: frame)
    }
}
