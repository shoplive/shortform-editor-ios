//
//  SLVideoVideoMainFilterSubView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/24/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit


class SLVideoMainFilterSubView : UIView, SLReactor {
    private let design = EditorFilterConfig.global
    
    
    
    lazy private var sliderView : SlCustomUISlider = {
        let view = SlCustomUISlider(frame: .zero,thumbViewColor: design.sliderThumbViewColor, sliderCornerRadius: design.sliderCornerRaidus)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.action( .setMinValue(0) )
        view.action( .setMaxValue(1) )
        return view
    }()
    
    lazy private var filterCv : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        reactor.action(.registerCv(cv))
        return cv
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
        btn.setTitle(ShopLiveShortformEditorSDKStrings.Editor.Volume.Btn.Confirm.title, for: .normal)
        btn.layer.cornerRadius = design.confirmButtonCornerRadius
        btn.clipsToBounds = true
        return btn
    }()
    
    
    enum Action {
        case initialize
        case initializeCells
        case setVideoEditInfoDto(SLVideoEditInfoDTO)
        case setThumbnail(UIImage)
        case changePlayOrPauseBtnState(isPlaying : Bool)
        
    }
    
    enum Result {
        case confirm
        case togglePlayPause
        case closeBtn
        case onValueChanged
    }
    
    
    var resultHandler: ((Result) -> ())?
    private let reactor = SLVideoMainFilterSubReactor()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        bindReactor()
        bindSliderView()
        
        playPauseBtn.addTarget(self, action: #selector(playPauseBtnTapped(sender:)), for: .touchUpInside)
        confirmBtn.addTarget(self, action: #selector(confirmBtnTapped(sender: )), for: .touchUpInside)
        
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    @objc func playPauseBtnTapped(sender : UIButton) {
        resultHandler?( .togglePlayPause )
    }
    
    @objc func confirmBtnTapped(sender : UIButton) {
        resultHandler?( .confirm)
    }
    
}
extension SLVideoMainFilterSubView {
    func action(_ action: Action) {
        switch action {
        case .initialize:
            self.onInitialize()
        case .initializeCells:
            self.onInitializeCells()
        case .setThumbnail(let image):
            self.onSetThumbnail(image: image)
        case .setVideoEditInfoDto(let dto):
            self.onSetVideoEditInfoDto(dto: dto)
        case .changePlayOrPauseBtnState(isPlaying: let isPlaying):
            self.onChangePlayOrPauseBtnState(isPlaying: isPlaying)
        }
    }
    
    private func onInitialize() {
        reactor.action( .initialize )
    }
    
    private func onInitializeCells() {
        reactor.action( .initializeCells )
    }
    
    private func onSetThumbnail(image : UIImage) {
        reactor.action( .setThumbnailImage(image) )
    }
    
    private func onSetVideoEditInfoDto(dto : SLVideoEditInfoDTO) {
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
}
//MARK: - bind Reactor
extension SLVideoMainFilterSubView {
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .activateSlider(let activate):
                    self.onReactorActivateSliderView(activate: activate)
                case .setFilterConfig(_):
                    self.onReactorSetFilterConfig()
                case .setInitialIntensity(let intensity):
                    self.onReactorSetInitialIntensity(value: intensity )
                }
            }
        }
    }
    
    private func onReactorActivateSliderView(activate : Bool) {
        sliderView.action( .setDeActive(!activate))
    }
    
    private func onReactorSetFilterConfig(){
        resultHandler?( .onValueChanged )
    }
    
    private func onReactorSetInitialIntensity(value : CGFloat) {
        sliderView.action( .setCurrentValue(value) )
        sliderView.action( .setValueLabel(String(format: "%.1f", value)) )
    }
}
//MARK: - bind SliderView
extension SLVideoMainFilterSubView {
    private func bindSliderView() {
        sliderView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .currentValue(let value):
                    self.onSliderViewCurrentValue(value: value)
                default:
                    break
                }
            }
        }
    }
    
    private func onSliderViewCurrentValue(value : CGFloat) {
        sliderView.action( .setValueLabel(String(format: ".1f", value)) )
        reactor.action( .setIntensity(value) )
    }
}
extension SLVideoMainFilterSubView {
    private func setLayout() {
        self.addSubview(sliderView)
        self.addSubview(filterCv)
        self.addSubview(bottomBar)
        self.addSubview(playPauseBtn)
        self.addSubview(confirmBtn)
        
        NSLayoutConstraint.activate([
            sliderView.topAnchor.constraint(equalTo: self.topAnchor),
            sliderView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 16),
            sliderView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -16),
            sliderView.heightAnchor.constraint(equalToConstant: 48),
            
            filterCv.topAnchor.constraint(equalTo: sliderView.bottomAnchor, constant: 14),
            filterCv.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 16),
            filterCv.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -16),
            filterCv.heightAnchor.constraint(equalToConstant: 100),
            
            bottomBar.topAnchor.constraint(equalTo: filterCv.bottomAnchor, constant: 28),
            bottomBar.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 0),
            bottomBar.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: 0),
            bottomBar.heightAnchor.constraint(equalToConstant: 60),
            
        
            playPauseBtn.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            playPauseBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 16),
            playPauseBtn.widthAnchor.constraint(equalToConstant: 40),
            playPauseBtn.heightAnchor.constraint(equalToConstant: 40),
            
            confirmBtn.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            confirmBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -16),
            confirmBtn.widthAnchor.constraint(equalToConstant: 80),
            confirmBtn.heightAnchor.constraint(equalToConstant: 40),
            
            self.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor),
        ])
    }
}
