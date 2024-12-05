//
//  SLVideoMainVolumeSubView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/24/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon

class SLVideoMainVolumeSubView : UIView, SLReactor {
    private let design = ShopLiveShortformEditor.EditorVolumeConfig.global
    
    lazy private var sliderView : SlCustomUISlider = {
        let view = SlCustomUISlider(frame: .zero,
                                    thumbViewColor: design.sliderThumbViewColor,
                                    sliderCornerRadius: design.sliderCornerRaidus,
                                    backgroundColor: design.sliderBackgroundColor)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.action( .setMinValue(0) )
        view.action( .setMaxValue(100) )
        view.action( .setCurrentValue(100) )
        view.action( .setValueLabel("100") )
        return view
    }()
    
    
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
        btn.titleLabel?.font = design.confirmButtonTextFont
        btn.setTitle(ShopLiveShortformEditorSDKStrings.Editor.Volume.Btn.Confirm.shoplive, for: .normal)
        btn.layer.cornerRadius = design.confirmButtonCornerRadius
        btn.clipsToBounds = true
        return btn
    }()
    
    enum Action {
        case initialize
        case setVideoEditInfoDTO(SLVideoEditInfoDTO)
        case changePlayOrPauseBtnState(isPlaying : Bool)
        case saveEditingStartValue
        case revertChange
        case setToOrigin
    }
    
    enum Result {
        case confirmWithChange
        case confirmWithOrigin
        case togglePlayPause
        case closeBtn
        case onValueChanged(CGFloat)
    }
    
    
    var resultHandler: ((Result) -> ())?
    
    private let reactor = SLVideoMainVolumeSubReactor()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        bindReactor()
        bindSlider()
        
        confirmBtn.addTarget(self, action: #selector(onConfirmBtnTapped(sender: )), for: .touchUpInside)
        playPauseBtn.addTarget(self, action: #selector(onPlayPauseBtnTapped(sender: )), for: .touchUpInside)
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    @objc func onConfirmBtnTapped(sender : UIButton) {
        reactor.action( .onConfirm )
    }
    
    @objc func onPlayPauseBtnTapped(sender : UIButton) {
        resultHandler?( .togglePlayPause )
    }
}
//MARK: - bind view action
extension SLVideoMainVolumeSubView {
    func action(_ action: Action) {
        switch action {
        case .initialize:
            self.onInitialized()
        case .setVideoEditInfoDTO(let value):
            self.onSetVideoEditoInfoDTO(dto: value)
        case .changePlayOrPauseBtnState(isPlaying: let isPlaying):
            self.onChangePlayOrPauseBtnState(isPlaying: isPlaying)
        case .saveEditingStartValue:
            self.onSaveEditingStartValue()
        case .revertChange:
            self.onRevertChange()
        case .setToOrigin:
            self.onSetToOrigin()
        }
    }
    
    private func onInitialized() {
        reactor.action( .initialize )
    }
    
    private func onSetVideoEditoInfoDTO(dto : SLVideoEditInfoDTO) {
        reactor.action( .videoEditInfoDto(dto) )
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
    
    private func onSaveEditingStartValue() {
        reactor.action( .saveEditingStartValue )
    }
    
    private func onRevertChange() {
        reactor.action( .revertChange )
    }
    
    private func onSetToOrigin() {
        reactor.action( .setToOrigin )
    }
}
//MARK: - reactor
extension SLVideoMainVolumeSubView {
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .setInitialValue(let value):
                    self.onReactorSetInitialValue(value: value)
                case .setSliderValue(let value):
                    self.onReactorSetSliderValue(value : value)
                case .confirmWithChange:
                    self.onReactorConfirmWithChange()
                case .confirmWithOrigin:
                    self.onReactorConfirmWithOrigin()
                }
            }
        }
    }
    
    private func onReactorSetInitialValue(value : CGFloat) {
        self.sliderView.action( .setCurrentValue(value) )
    }
    
    private func onReactorSetSliderValue(value : Int) {
        sliderView.action( .setCurrentValue(CGFloat(value)) )
        sliderView.action( .setValueLabel(String(Int(value))) )
        resultHandler?( .onValueChanged(CGFloat(value)) )
    }
    
    private func onReactorConfirmWithChange() {
        resultHandler?( .confirmWithChange )
    }
    
    private func onReactorConfirmWithOrigin() {
        resultHandler?( .confirmWithOrigin )
    }
    
}
//MARK: - bindSlider
extension SLVideoMainVolumeSubView {
    private func bindSlider() {
        sliderView.resultHandler = { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .currentValue(let value):
                    self?.onSliderCurrentValue(value: value)
                default:
                    break
                }
            }
        }
    }
    
    private func onSliderCurrentValue(value : CGFloat) {
        reactor.action( .setVolume(value) )
        sliderView.action( .setValueLabel(String(Int(value))) )
        resultHandler?( .onValueChanged(value) )
    }
}
extension SLVideoMainVolumeSubView {
    private func setLayout() {
        self.addSubview(sliderView)
        self.addSubview(bottomBar)
        self.addSubview(playPauseBtn)
        self.addSubview(confirmBtn)
        
        NSLayoutConstraint.activate([
            sliderView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            sliderView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 16),
            sliderView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            sliderView.heightAnchor.constraint(equalToConstant: 48),
            
            
            bottomBar.topAnchor.constraint(equalTo: sliderView.bottomAnchor, constant: 20),
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
