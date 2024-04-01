//
//  SLVideoEditorSliderHandleView2.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/8/23.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon

protocol SLVideoEditorSliderHandleDelegate: AnyObject {
    func updatedCurrentHandlePosition(offset: CGFloat, handleType: SLVideoEditorSliderHandleType)
}

enum SLVideoEditorSliderHandleType {
    case left
    case right
}

class SLVideoEditorSliderHandleView2 : UIView {
    typealias globalConfig = ShopLiveEditorConfigurationManager
    
    private var bundle : Bundle {
        return  Bundle(for: type(of: self))
    }
    
    private var dimView : SLDimView = {
        let dimView = SLDimView()
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = .clear
        dimView.isUserInteractionEnabled = false
        return dimView
    }()
    
    private var trimDurationLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.backgroundColor = .white
        label.cornerRadiusV_SL = 4
        label.clipsToBounds = true
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private var trimDurationLabelPaddingView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.cornerRadiusV_SL = 4
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy private var timeIndicatorView : UISlider = {
        let view = UISlider()
        view.translatesAutoresizingMaskIntoConstraints = false
//        let playbar = UIImage(named: "sl_playbar", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        view.setThumbImage(ShopLiveShortformEditorSDKAsset.slPlaybar.image, for: .normal)
        view.backgroundColor = .clear
        view.minimumTrackTintColor = .clear
        view.maximumTrackTintColor = .clear
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    
    private var betweenHandleContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var leftHandle: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = true
//        let image = UIImage(named: "sl_editor_handle_left", in: bundle, compatibleWith: nil)
        view.image = ShopLiveShortformEditorSDKAsset.slEditorHandleLeft.image
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var rightHandle: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = true
//        let image = UIImage(named: "sl_editor_handle_right", in: bundle, compatibleWith: nil)
        view.image = ShopLiveShortformEditorSDKAsset.slEditorHandleRight.image
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var leftHandleTouchAreaView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var rightHandleTouchAreaView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var leftHandleRightAnchorConstraint: NSLayoutConstraint {
        return leftHandleTouchAreaView.rightAnchor.constraint(equalTo: leftHandle.rightAnchor, constant: 30)
    }
    private var rightHandleLeftAnchorConstraint: NSLayoutConstraint {
        return rightHandleTouchAreaView.leftAnchor.constraint(equalTo: rightHandle.leftAnchor, constant: -30)
    }
    private let handleMargin: CGFloat = 8
    private let handleWidth: CGFloat = 20
    private var timePerPixel : CGFloat = 0
    private var videoDuration : CGFloat = 0
    private var minimumTrimTime : CGFloat {
        return globalConfig.shared.videoTrimOption.minVideoDuration
    }
    
    var minimumTrimTimeGap : CGFloat {
        return ceil(minimumTrimTime / timePerPixel)
    }
    
    var timebarLoaded: Bool = false
    
    
    private var handleInitializePosition: CGPoint = .zero
    
    weak var delegate: SLVideoEditorSliderHandleDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setLayout()
        addGesture()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ShopLiveLogger.debugLog("[ShopliveShortformEditor] SLVideoEditorSliderHandleView2 deinited")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dimView.updateMaskDim(CGRect(x: leftHandle.frame.maxX, y: 0, width: rightHandle.frame.minX - leftHandle.frame.maxX, height: self.frame.height))
        calculateTrimTimeDuration()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.resetHandlePosition()
    }
    
    

    func resetAndRedraw() {
        self.resetHandlePosition()
        self.calculateTrimTimeDuration()
        self.blockHandleWhenVideoDurationIsShorterThenMinTrimTime()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in self.subviews {
            if subview.hitTest(self.convert(point, to: subview), with: event) != nil {
                return true
            }
        }
        return false
    }
    
    func setTimePerPixel(timePerPixel : CGFloat) {
        self.timePerPixel = timePerPixel
    }
    
    func setVideoDuration(videoDuration : CGFloat) {
        self.videoDuration = videoDuration
        self.blockHandleWhenVideoDurationIsShorterThenMinTrimTime()
    }
    
    private func calculateTrimTimeDuration() {
        let gapWidth = betweenHandleContainerView.bounds.width
        let gapSecond = Int(gapWidth * timePerPixel)
        if gapSecond > 60 {
            let min = Int(gapSecond / 60)
            let sec = gapSecond % 60
            trimDurationLabel.text = "editor.time.gap.min.sec.label".localizedString(with: [min,sec], bundle: bundle)
        }
        else {
            trimDurationLabel.text = "editor.time.gap.sec.label".localizedString(with: [gapSecond], bundle: bundle)
        }
        
    }
    
    private func blockHandleWhenVideoDurationIsShorterThenMinTrimTime() {
        if videoDuration <= minimumTrimTime {
            leftHandleTouchAreaView.isUserInteractionEnabled = false
            rightHandleTouchAreaView.isUserInteractionEnabled = false
        }
        else {
            leftHandleTouchAreaView.isUserInteractionEnabled = true
            rightHandleTouchAreaView.isUserInteractionEnabled = true
        }
    }
    
    
    
}
extension SLVideoEditorSliderHandleView2 {
    private func setLayout() {
        self.addSubview(dimView)
        self.addSubview(betweenHandleContainerView)
        self.addSubview(trimDurationLabelPaddingView)
        self.addSubview(trimDurationLabel)
        self.addSubview(timeIndicatorView)
        
        self.addSubview(leftHandle)
        self.addSubview(rightHandle)
        self.addSubview(leftHandleTouchAreaView)
        self.addSubview(rightHandleTouchAreaView)
        
        
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: self.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            
            betweenHandleContainerView.leftAnchor.constraint(equalTo: self.leftHandle.rightAnchor, constant: 0),
            betweenHandleContainerView.rightAnchor.constraint(equalTo: self.rightHandle.leftAnchor, constant: 0),
            betweenHandleContainerView.heightAnchor.constraint(equalTo: self.heightAnchor),
            betweenHandleContainerView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            
            trimDurationLabelPaddingView.centerXAnchor.constraint(equalTo: betweenHandleContainerView.centerXAnchor, constant: 0),
            trimDurationLabelPaddingView.centerYAnchor.constraint(equalTo: betweenHandleContainerView.centerYAnchor, constant: 0),
            trimDurationLabelPaddingView.heightAnchor.constraint(equalToConstant: 20),
            trimDurationLabelPaddingView.widthAnchor.constraint(equalTo: trimDurationLabel.widthAnchor, constant: 4),
            
            trimDurationLabel.centerXAnchor.constraint(equalTo: betweenHandleContainerView.centerXAnchor),
            trimDurationLabel.centerYAnchor.constraint(equalTo: betweenHandleContainerView.centerYAnchor),
            trimDurationLabel.heightAnchor.constraint(equalToConstant: 20),
            trimDurationLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            
            
            timeIndicatorView.topAnchor.constraint(equalTo: betweenHandleContainerView.topAnchor),
            timeIndicatorView.leadingAnchor.constraint(equalTo: betweenHandleContainerView.leadingAnchor),
            timeIndicatorView.trailingAnchor.constraint(equalTo: betweenHandleContainerView.trailingAnchor),
            timeIndicatorView.bottomAnchor.constraint(equalTo: betweenHandleContainerView.bottomAnchor),
            
            leftHandleTouchAreaView.leftAnchor.constraint(equalTo: leftHandle.leftAnchor, constant: -30),
            leftHandleTouchAreaView.heightAnchor.constraint(equalTo: leftHandle.heightAnchor, multiplier: 1.0),
            leftHandleTouchAreaView.centerYAnchor.constraint(equalTo: leftHandle.centerYAnchor),
            
            rightHandleTouchAreaView.rightAnchor.constraint(equalTo: rightHandle.rightAnchor, constant: 30),
            rightHandleTouchAreaView.heightAnchor.constraint(equalTo: rightHandle.heightAnchor, multiplier: 1.0),
            rightHandleTouchAreaView.centerYAnchor.constraint(equalTo: rightHandle.centerYAnchor),
            
            leftHandleRightAnchorConstraint,
            rightHandleLeftAnchorConstraint
        ])
    }
   
    
    private func resetHandlePosition() {
        leftHandle.frame = CGRect(x: handleMargin, y: 0, width: 20, height: 60)
        rightHandle.frame = CGRect(x: self.safeAreaLayoutGuide.layoutFrame.size.width - 20 - handleMargin, y: 0, width: 20, height: 60)
    }
    
    
}
extension SLVideoEditorSliderHandleView2 : UIGestureRecognizerDelegate {
    private func addGesture() {
        let leftHandleTouchViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(leftHandlerAct))
        leftHandleTouchAreaView.addGestureRecognizer(leftHandleTouchViewPanGesture)
        leftHandleTouchViewPanGesture.delegate = self
        leftHandleTouchViewPanGesture.isEnabled = true

        let rightHandleTouchViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(rightHandlerAct))
        rightHandleTouchAreaView.addGestureRecognizer(rightHandleTouchViewPanGesture)
        rightHandleTouchViewPanGesture.delegate = self
        rightHandleTouchViewPanGesture.isEnabled = true
    }
    
    @objc private func leftHandlerAct(_ recognizer: UIPanGestureRecognizer) {
        guard timebarLoaded else { return }
        
        guard let handle = recognizer.view else { return }
        
        let translation = recognizer.translation(in: handle)
      
        switch recognizer.state {
        case .began:
            handleInitializePosition = leftHandle.frame.origin
            break
        case .changed:
            guard handleInitializePosition.x + handleWidth + minimumTrimTimeGap <= rightHandle.frame.origin.x else {
                return
            }
                    
            let xChange = handleInitializePosition.x + translation.x
            guard xChange >= handleMargin else {
                leftHandle.frame.origin = CGPoint(x: handleMargin, y: self.leftHandle.frame.origin.y)
                delegate?.updatedCurrentHandlePosition(offset: leftHandle.frame.maxX - handleWidth - handleMargin, handleType: .left)
                return
            }
            
            guard xChange + handleWidth + minimumTrimTimeGap < rightHandle.frame.origin.x else {
                leftHandle.frame.origin = CGPoint(x: rightHandle.frame.origin.x - minimumTrimTimeGap - handleWidth, y: self.leftHandle.frame.origin.y)
                delegate?.updatedCurrentHandlePosition(offset: leftHandle.frame.maxX - handleWidth - handleMargin, handleType: .left)
                return
            }
            
            leftHandle.frame.origin = CGPoint(x: xChange, y: self.leftHandle.frame.origin.y)
            
            delegate?.updatedCurrentHandlePosition(offset: leftHandle.frame.maxX - handleWidth - handleMargin, handleType: .left)
            break
        case .ended:
            updateTouchGapWidth()
            break
        default:
            break
        }
    }
    
    @objc private func rightHandlerAct(_ recognizer: UIPanGestureRecognizer) {
        guard timebarLoaded else { return }
        
        guard let handle = recognizer.view else { return }
        
        let translation = recognizer.translation(in: handle)
      
        switch recognizer.state {
        case .began:
            handleInitializePosition = rightHandle.frame.origin
            break
        case .changed:
            guard handleInitializePosition.x >= leftHandle.frame.origin.x + handleWidth + minimumTrimTimeGap else {
                return
            }
            
            let xChange = handleInitializePosition.x + translation.x
            guard xChange < self.safeAreaLayoutGuide.layoutFrame.size.width - handleWidth - handleMargin else {
                rightHandle.frame.origin = CGPoint(x: self.safeAreaLayoutGuide.layoutFrame.size.width - handleWidth - handleMargin, y: self.leftHandle.frame.origin.y)
                delegate?.updatedCurrentHandlePosition(offset: rightHandle.frame.origin.x - handleWidth - handleMargin, handleType: .right)
                return
            }
            
            guard xChange >= leftHandle.frame.origin.x + handleWidth + minimumTrimTimeGap else {
                rightHandle.frame.origin = CGPoint(x: leftHandle.frame.origin.x + handleWidth + minimumTrimTimeGap, y: self.leftHandle.frame.origin.y)
                delegate?.updatedCurrentHandlePosition(offset: rightHandle.frame.origin.x - handleWidth - handleMargin, handleType: .right)
                return
            }
            
            rightHandle.frame.origin = CGPoint(x: xChange, y: self.leftHandle.frame.origin.y)
            delegate?.updatedCurrentHandlePosition(offset: rightHandle.frame.origin.x - handleWidth - handleMargin, handleType: .right)
            break
        case .ended:
            updateTouchGapWidth()
            break
        default:
            break
        }
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func updateTouchGapWidth() {
        let handleGap = rightHandle.frame.origin.x - leftHandle.frame.maxX
        let touchGap = handleGap >= 30 ? 30 : (handleGap >= minimumTrimTimeGap ? (handleGap - minimumTrimTimeGap) : (minimumTrimTimeGap / 2))
        self.leftHandleRightAnchorConstraint.constant = touchGap
        self.rightHandleLeftAnchorConstraint.constant = -touchGap
    }
    
}
extension SLVideoEditorSliderHandleView2 {
    func updateTimeIndicatorSliderTime(start: CMTime, end: CMTime) {
        let startSecond = CMTimeGetSeconds(start)
        let endSecond = CMTimeGetSeconds(end)
        
        guard !endSecond.isNaN && !endSecond.isInfinite else {
            return
        }
        guard !startSecond.isNaN && !startSecond.isInfinite else {
            return
        }
        
        updateTimeIndicatorSlider(start: startSecond, end: endSecond)

    }

    private func updateTimeIndicatorSlider(start: Float64, end: Float64) {
        timeIndicatorView.minimumValue = Float(start)
        timeIndicatorView.maximumValue = Float(end)
        
        updateTimeIndicatorTime(time: Float(start))
    }

    func updateTimeIndicatorTime(time : Float) {
        timeIndicatorView.value = time
    }
    
    func updateTimeIndicatorTimeToStartPos() {
        timeIndicatorView.value = timeIndicatorView.minimumValue
    }
    
    func setTimeIndicatorVisible(isVisible : Bool) {
        timeIndicatorView.isHidden = !isVisible
    }
}
