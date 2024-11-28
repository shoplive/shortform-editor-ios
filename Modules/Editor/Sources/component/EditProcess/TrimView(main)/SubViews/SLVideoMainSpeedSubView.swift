//
//  SLVideoMainSpeedSubView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/23/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon


class SLVideoMainSpeedSubView : UIView, SLReactor {
    private let design = ShopLiveShortformEditor.EditorSpeedConfig.global
    
    private var durationLabelBackgroundView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(white: 51 / 255, alpha: 1)
        view.layer.cornerRadius = (23 / 2)
        return view
    }()
    
    private var durationlabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .set(size: 10, weight: ._500)
        label.textColor = .white
        return label
    }()
    
    
    lazy private var sliderView : SlCustomUISlider = {
        let view = SlCustomUISlider(frame: .zero,thumbViewColor: design.sliderThumbViewColor, sliderCornerRadius: design.sliderCornerRaidus)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.action( .setMinValue(0.5) )
        view.action( .setMaxValue(2.5) )
        view.action( .setZeroUnAvailable )
        view.action( .setCurrentValue(1.0) )
        view.action( .setValueLabel("1.0x") )
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
        btn.titleLabel?.font = .set(size: 16, weight: ._600)
        btn.setTitle(ShopLiveShortformEditorSDKStrings.Editor.PlaybackSpeed.Btn.Confirm.shoplive, for: .normal)
        btn.layer.cornerRadius = design.confirmButtonCornerRadius
        btn.clipsToBounds = true
        return btn
    }()
    
    enum Action {
        case initialize
        case setVideoEditInfoDTO(SLVideoEditInfoDTO)
        case changePlayOrPauseBtnState(isPlaying : Bool)
        case saveEditingStartSpeedValue
        case revertChanges
        case setToOrigin
    }
    
    enum Result {
        case confirmWithChange
        case confirmWithOrigin
        case togglePlayPause
        case closeBtn
        case onValueChanged
        case showToast(String)
    }
    
    
    var resultHandler: ((Result) -> ())?
    
    private let reactor = SLVideoMainSpeedSubReactor()
    
    
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
        reactor.action( .checkVideoDuration )
    }
    
    @objc func onPlayPauseBtnTapped(sender : UIButton) {
        resultHandler?( .togglePlayPause )
    }
}
//MARK: - bind view action
extension SLVideoMainSpeedSubView {
    func action(_ action: Action) {
        switch action {
        case .initialize:
            self.onInitialized()
        case .setVideoEditInfoDTO(let value):
            self.onSetVideoEditoInfoDTO(dto: value)
        case .changePlayOrPauseBtnState(isPlaying: let isPlaying):
            self.onChangePlayOrPauseBtnState(isPlaying: isPlaying)
        case .saveEditingStartSpeedValue:
            self.onSaveEditingStartSpeedValue()
        case .revertChanges:
            self.onRevertChanges()
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
    
    private func onSaveEditingStartSpeedValue() {
        reactor.action( .saveEditingStartSpeedValue )
    }
    
    private func onRevertChanges() {
        reactor.action( .revertChanges )
    }
    
    private func onSetToOrigin() {
        reactor.action( .setToOrigin )
    }
}
//MARK: - reactor
extension SLVideoMainSpeedSubView {
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .setInitialValue(let value):
                    self.onReactorSetInitialValue(value: value)
                case .setVideoDuration(let duration):
                    self.onReactorSetVideoDuration(duration: duration)
                case .onValueChanged:
                    self.onReactorOnValueChanged()
                case .setSliderValue(let value):
                    self.onReactorSetSliderValue(value : value)
                case .confirmWithChange:
                    self.onReactorConfirmWithChange()
                case .confirmWithOrigin:
                    self.onReactorConfirmWithOrigin()
                case .showToast(let toastMessage):
                    self.onReactorShowtoast(message : toastMessage)
                }
            }
        }
    }
    
    private func onReactorSetVideoDuration(duration : String) {
        self.durationlabel.text = duration
    }
    
    private func onReactorSetInitialValue(value : CGFloat) {
        self.sliderView.action( .setCurrentValue(value) )
    }
    
    private func onReactorOnValueChanged() {
        resultHandler?( .onValueChanged )
    }
    
    private func onReactorSetSliderValue(value : CGFloat) {
        self.sliderView.action( .setCurrentValue(value) )
        self.sliderView.action( .setValueLabel(String(format: "%.1f", value) + "x"))
    }
    
    private func onReactorConfirmWithChange() {
        resultHandler?( .confirmWithChange )
    }
    
    private func onReactorConfirmWithOrigin() {
        resultHandler?( .confirmWithOrigin )
    }
    
    private func onReactorShowtoast(message : String) {
        resultHandler?( .showToast(message) )
    }
}
//MARK: - bindSlider
extension SLVideoMainSpeedSubView {
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
        reactor.action( .setSpeed( (value * 10).rounded() / 10 ) )
        sliderView.action( .setValueLabel(String(format: "%.1f", value) + "x"))
    }
}
extension SLVideoMainSpeedSubView {
    private func setLayout() {
        self.addSubview(durationLabelBackgroundView)
        self.addSubview(durationlabel)
        self.addSubview(sliderView)
        self.addSubview(bottomBar)
        self.addSubview(playPauseBtn)
        self.addSubview(confirmBtn)
        
        NSLayoutConstraint.activate([
            durationlabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            durationlabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            durationlabel.heightAnchor.constraint(equalToConstant: 15),
            durationlabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            
            durationLabelBackgroundView.topAnchor.constraint(equalTo: durationlabel.topAnchor, constant: -4),
            durationLabelBackgroundView.leadingAnchor.constraint(equalTo: durationlabel.leadingAnchor, constant: -8),
            durationLabelBackgroundView.trailingAnchor.constraint(equalTo: durationlabel.trailingAnchor, constant: 8),
            durationLabelBackgroundView.bottomAnchor.constraint(equalTo: durationlabel.bottomAnchor, constant: 4),
            
            sliderView.topAnchor.constraint(equalTo: durationLabelBackgroundView.bottomAnchor, constant: 10),
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
