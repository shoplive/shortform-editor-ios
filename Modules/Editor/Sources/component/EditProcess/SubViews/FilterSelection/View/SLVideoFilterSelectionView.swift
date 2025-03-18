//
//  SLVideoFilterSelectionView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/28/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import ShopliveFilterSDK




class SLVideoFilterSelectionView : UIView, SLReactor {
    
    enum Action {
        
    }
    
    enum Result {
        case filterIntensityChanged(Float)
        case filterConfigChanged(String)
        case filterSelectionEnded
    }
    
    var resultHandler: ((Result) -> ())?
    
    
    private var blankBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .clear
        return btn
    }()
    
    private var intensitySliderView : UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.value = 0.5
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.isHidden = true
        return slider
    }()
    
    private var bottomSheetbackgroundView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .darkGray
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var bottomSheetBackgroundViewBottomAnc : NSLayoutConstraint = {
        return bottomSheetbackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: 300)
    }()
    
    private  var bottomSheetbackgroundViewHeightAnc : NSLayoutConstraint?
    
    private var panGestureHandlerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var filterTitleLabel : SLLabel = {
        let label = SLLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.setFont(font: .init(size: 15, weight: .bold))
        label.text = "Filter"
        return label
    }()
    
    private var cancelBtn : SLButton = {
        let btn = SLButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("cancel", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setFont(font: .init(size: 13, weight: .regular))
        btn.isHidden = true
        return btn
    }()
    
    private var doneBtn : SLButton = {
        let btn = SLButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("done", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setFont(font: .init(size: 13, weight: .regular))
        return btn
    }()
    
    private var filterCv : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .darkGray
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private let reactor = SLVideoFilterSelectionReactor()
    private var lastPangestureYPos : CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        self.bindReactor()
        self.addPanGestureRecognizerToPangGestuerHandlerView()
        self.backgroundColor = .clear
        
        blankBtn.addTarget(self, action: #selector(blankBtnTapped(sender: )), for: .touchUpInside)
        doneBtn.addTarget(self, action: #selector(doneBtnTapped(sender: )), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(cancelBtnTapped(sender: )), for: .touchUpInside)
        intensitySliderView.addTarget(self, action: #selector(intensitySliderChanged(sender: )), for: .valueChanged)
        reactor.action( .registerCollectionView(filterCv) )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func blankBtnTapped(sender : UIButton) {
        self.animateClose()
    }
    
    @objc func doneBtnTapped(sender : UIButton) {
        self.animateClose()
    }
    
    @objc func cancelBtnTapped(sender : UIButton) {
        reactor.action( .cancelCurrentFilter )
    }
    
    @objc func intensitySliderChanged(sender : UISlider) {
        reactor.action( .setCurrentFilterIntensity(sender.value) )
        resultHandler?( .filterIntensityChanged(sender.value) )
    }
    
    func action(_ action: Action) { /*no - op*/ }

}
//MARK: - reactor functions
extension SLVideoFilterSelectionView {
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .filterConfigSelected(let filterConfig):
                self.onReactorFilterConfigSelected(filterConfig: filterConfig)
            case .setFilterIntensity(let filterIntensity):
                self.onReactorSetFilterIntensity(filterIntensity: filterIntensity)
            default:
                break
            }
        }
        
        reactor.mainQueueResultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .showCancelBtn(let show):
                    self.onReactorShowCancelBtn(isShow: show)
                case .showIntensitySlider(let show):
                    self.onReactorShowIntensitySlider(isShow : show)
                default:
                    break
                }
            }
        }
    }
    
    private func onReactorFilterConfigSelected(filterConfig : String) {
        resultHandler?( .filterConfigChanged(filterConfig))
    }
    
    private func onReactorSetFilterIntensity(filterIntensity : Float) {
        resultHandler?( .filterIntensityChanged(filterIntensity) )
    }
    
    private func onReactorShowCancelBtn(isShow : Bool) {
        cancelBtn.isHidden = isShow ? false : true
    }
    
    private func onReactorShowIntensitySlider(isShow : Bool) {
        intensitySliderView.isHidden = isShow ? false : true
    }
}
//MARK: -animation
extension SLVideoFilterSelectionView {
    func animateOpen() {
        self.bottomSheetBackgroundViewBottomAnc.constant = 0
        self.alpha = 1
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.reactor.action( .initializeCells )
            self.layoutIfNeeded()
        }
    }
    
    func animateClose() {
        self.bottomSheetBackgroundViewBottomAnc.constant = 300
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.resultHandler?( .filterSelectionEnded )
            self.layoutIfNeeded()
        } completion: { [weak self] done in
            guard done, let self = self else { return }
            self.alpha = 0
        }
    }
    
    
    private func addPanGestureRecognizerToPangGestuerHandlerView() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognzier(sender: )))
        panGestureHandlerView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handlePanGestureRecognzier(sender : UIPanGestureRecognizer) {
        let translation = sender.translation(in: bottomSheetbackgroundView)
        
        guard let heightAnc = self.bottomSheetbackgroundViewHeightAnc else { return }
        switch sender.state {
        case .began:
            lastPangestureYPos = translation.y
            break
        case .changed:
            heightAnc.constant += lastPangestureYPos - translation.y
            lastPangestureYPos = translation.y
            break
        case .ended:
            if heightAnc.constant <= 50 {
                heightAnc.constant = 170
                self.animateClose()
            }
            else {
                heightAnc.constant = 170
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseIn) { [weak self] in
                    guard let self = self else { return }
                    self.layoutIfNeeded()
                }
            }
            break
        default:
            break
        }
    }
}
extension SLVideoFilterSelectionView {
    private func setLayout() {
        self.addSubview(blankBtn)
        self.addSubview(intensitySliderView)
        self.addSubview(bottomSheetbackgroundView)
        let filterCvHolder = UIView()
        filterCvHolder.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(filterCvHolder)
        self.addSubview(filterCv)
        
        let bottomSheetNaviRightBtnStack = UIStackView(arrangedSubviews: [cancelBtn, doneBtn])
        bottomSheetNaviRightBtnStack.axis = .horizontal
        bottomSheetNaviRightBtnStack.spacing = 10
        
        let bottomSheetNaviStack = UIStackView(arrangedSubviews: [ filterTitleLabel, bottomSheetNaviRightBtnStack ])
        bottomSheetNaviStack.translatesAutoresizingMaskIntoConstraints = false
        bottomSheetNaviStack.axis = .horizontal
        bottomSheetNaviStack.distribution = .equalSpacing
        bottomSheetNaviStack.isLayoutMarginsRelativeArrangement = true
        bottomSheetNaviStack.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let bottomSheetContentHolder = UIStackView(arrangedSubviews: [bottomSheetNaviStack])//,filterCv
        bottomSheetContentHolder.translatesAutoresizingMaskIntoConstraints = false
        bottomSheetContentHolder.axis = .vertical
        
        self.addSubview(bottomSheetContentHolder)
        self.addSubview(panGestureHandlerView)
        
//        bottomSheetbackgroundViewHeightAnc = bottomSheetbackgroundView.heightAnchor.constraint(greaterThanOrEqualTo: bottomSheetContentHolder.heightAnchor,constant: 30)
        
        let bottomSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        bottomSheetbackgroundViewHeightAnc = bottomSheetbackgroundView.heightAnchor.constraint(greaterThanOrEqualToConstant: 170 + bottomSafeArea)
        
        NSLayoutConstraint.activate([
            blankBtn.topAnchor.constraint(equalTo: self.topAnchor),
            blankBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blankBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            blankBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            intensitySliderView.bottomAnchor.constraint(equalTo: bottomSheetbackgroundView.topAnchor, constant: -10),
            intensitySliderView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 20),
            intensitySliderView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -20),
            
            bottomSheetContentHolder.topAnchor.constraint(equalTo: bottomSheetbackgroundView.topAnchor, constant: 10),
            bottomSheetContentHolder.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            bottomSheetContentHolder.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            bottomSheetContentHolder.heightAnchor.constraint(lessThanOrEqualToConstant: 300),
            
            bottomSheetNaviStack.heightAnchor.constraint(equalToConstant: 30),
            
            
            filterCvHolder.topAnchor.constraint(equalTo: bottomSheetContentHolder.bottomAnchor, constant: 0),
            filterCvHolder.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            filterCvHolder.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            filterCvHolder.bottomAnchor.constraint(equalTo: self.bottomSheetbackgroundView.bottomAnchor),
            
            filterCv.leadingAnchor.constraint(equalTo: self.bottomSheetbackgroundView.leadingAnchor),
            filterCv.trailingAnchor.constraint(equalTo: self.bottomSheetbackgroundView.trailingAnchor),
            filterCv.centerYAnchor.constraint(equalTo: filterCvHolder.centerYAnchor,constant:  -bottomSafeArea),
            filterCv.heightAnchor.constraint(equalToConstant: 60),
            
            panGestureHandlerView.centerYAnchor.constraint(equalTo: bottomSheetNaviStack.centerYAnchor,constant: 0),
            panGestureHandlerView.heightAnchor.constraint(equalToConstant: 30),
            panGestureHandlerView.leadingAnchor.constraint(equalTo: filterTitleLabel.trailingAnchor),
            panGestureHandlerView.trailingAnchor.constraint(equalTo: bottomSheetNaviRightBtnStack.leadingAnchor),
            
            bottomSheetbackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomSheetbackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomSheetbackgroundViewHeightAnc!,
            bottomSheetBackgroundViewBottomAnc,
        ])
    }
    
    
}
