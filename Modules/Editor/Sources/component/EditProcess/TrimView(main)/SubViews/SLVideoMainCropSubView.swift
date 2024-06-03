//
//  SLVideoMainCropSubView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/24/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon



class SLVideoMainCropSubView : UIView, SLReactor {
    private let design = EditorSpeedConfig.global
    
    private var bottomBar : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    lazy private var playPauseBtn : SLPaddingImageButton = {
        let btn = SLPaddingImageButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .init(red: 255, green: 255, blue: 255,aa: 0.2)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        btn.setImage(design.pauseButtonIcon, for: .normal)
        btn.imageView?.tintColor = design.pauseButtonIconTintColor
        btn.imageLayoutMargin = design.pauseButtonIconPadding
        btn.imageView?.contentMode = .scaleAspectFit
    
        return btn
    }()
    
    lazy private var confirmBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = design.confirmButtonBackgroundColor
        btn.setTitleColor(design.confirmButtonTextColor, for: .normal)
        btn.titleLabel?.font = .set(size: 16, weight: ._600)
        btn.setTitle(ShopLiveShortformEditorSDKStrings.Editor.Volume.Btn.Confirm.title, for: .normal)
        btn.layer.cornerRadius = design.confirmButtonCornerRadius
        btn.clipsToBounds = true
        return btn
    }()
    
    
    enum Action{
        case changePlayOrPauseBtnState(isPlaying : Bool)
    }
    
    enum Result {
        case confirm
        case togglePlayPause
    }
    
    var resultHandler: ((Result) -> ())?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        
        confirmBtn.addTarget(self, action: #selector(onConfirmBtnTapped(sender: )), for: .touchUpInside)
        playPauseBtn.addTarget(self, action: #selector(onPlayPauseBtnTapped(sender: )), for: .touchUpInside)
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    
    @objc func onConfirmBtnTapped(sender : UIButton) {
        resultHandler?( .confirm )
    }
    
    @objc func onPlayPauseBtnTapped(sender : UIButton) {
        resultHandler?( .togglePlayPause )
    }
    
    
    func action(_ action: Action) {
        switch action {
        case .changePlayOrPauseBtnState(let isPlaying):
            self.onChangePlayOrPauseBtnState(isPlaying: isPlaying)
        }
    }
    
    private func onChangePlayOrPauseBtnState(isPlaying : Bool) {
        if isPlaying {
            playPauseBtn.setImage(design.pauseButtonIcon, for: .normal)
            playPauseBtn.imageView?.tintColor = design.pauseButtonIconTintColor
            playPauseBtn.imageLayoutMargin = design.pauseButtonIconPadding
        }
        else {
            playPauseBtn.setImage(design.playButtonIcon, for: .normal)
            playPauseBtn.imageView?.tintColor = design.playButtonIconTintColor
            playPauseBtn.imageLayoutMargin = design.playButtonIconPadding
        }
    }
}
extension SLVideoMainCropSubView {
    private func setLayout() {
        self.addSubview(bottomBar)
        self.addSubview(playPauseBtn)
        self.addSubview(confirmBtn)
        
        NSLayoutConstraint.activate([
            bottomBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            bottomBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 60),
            
            playPauseBtn.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            playPauseBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 16),
            playPauseBtn.widthAnchor.constraint(equalToConstant: 40),
            playPauseBtn.heightAnchor.constraint(equalToConstant: 40),
            
            confirmBtn.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            confirmBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -16),
            confirmBtn.widthAnchor.constraint(equalToConstant: 80),
            confirmBtn.heightAnchor.constraint(equalToConstant: 40),
            
            self.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor)
        ])
    }
}
