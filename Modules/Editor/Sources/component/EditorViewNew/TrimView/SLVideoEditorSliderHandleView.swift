//
//  SLVideoEditorSliderHandleView.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 4/20/23.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon





class SLVideoEditorSliderHandleView: SLBaseView, UIGestureRecognizerDelegate {

    weak var delegate: SLVideoEditorSliderHandleDelegate?
    
    private var dimView : SLDimView = {
        let dimView = SLDimView()
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = .clear
        return dimView
    }()
    
    private let handleMargin: CGFloat = 8
    private let handleWidth: CGFloat = 20
    
    var timeGapSpacing: CGFloat = 0
    
    var timebarLoaded: Bool = false
    
    private lazy var timeGapLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        view.font = .systemFont(ofSize: 12, weight: .semibold)
        view.backgroundColor = .white
        view.cornerRadiusV_SL = 4
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var timeGapLabelBounderyView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeGapLabel)
        timeGapLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        timeGapLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        timeGapLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        view.backgroundColor = .white
        view.cornerRadiusV_SL = 4
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var displayTimeGapView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.addSubview(timeSlider)
        timeSlider.fit_SL()
        return view
    }()
    
    private lazy var leftHandle: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = true
        let bundle = Bundle(for: type(of: self))
        let image = UIImage(named: "sl_editor_handle_left", in: bundle, compatibleWith: nil)
        view.image = image
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
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
    
    private lazy var rightHandle: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = true
        let bundle = Bundle(for: type(of: self))
        let image = UIImage(named: "sl_editor_handle_right", in: bundle, compatibleWith: nil)
        view.image = image
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var timeSlider: UISlider = {
        let view = UISlider()
        view.translatesAutoresizingMaskIntoConstraints = false
        let bundle = Bundle(for: type(of: self))
        let playbar = UIImage(named: "sl_playbar", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        view.setThumbImage(playbar, for: .normal)
        view.addTarget(self, action: #selector(timeSliderValueChanged), for: UIControl.Event.valueChanged)
        view.backgroundColor = .clear
        view.minimumTrackTintColor = .clear
        view.maximumTrackTintColor = .clear
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private var leftHandleRightAnchorConstraint: NSLayoutConstraint?
    private var rightHandleLeftAnchorConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func layout() {
        self.addSubview(dimView)
        
        self.addSubview(leftHandle)
        self.addSubview(rightHandle)
        
        self.addSubview(leftHandleTouchAreaView)
        self.addSubview(rightHandleTouchAreaView)
        
        self.addSubview(displayTimeGapView)
        self.addSubview(timeGapLabelBounderyView)
        
        
 
        leftHandleRightAnchorConstraint = leftHandleTouchAreaView.rightAnchor.constraint(equalTo: leftHandle.rightAnchor, constant: 30)
        rightHandleLeftAnchorConstraint = rightHandleTouchAreaView.leftAnchor.constraint(equalTo: rightHandle.leftAnchor, constant: -30)
        
        let dimViewContraints = [
            dimView.topAnchor.constraint(equalTo: self.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        
        let leftHandleTouchAreaViewConstraint = [
            leftHandleTouchAreaView.leftAnchor.constraint(equalTo: leftHandle.leftAnchor, constant: -30),
            leftHandleTouchAreaView.heightAnchor.constraint(equalTo: leftHandle.heightAnchor, multiplier: 1.0),
            leftHandleTouchAreaView.centerYAnchor.constraint(equalTo: leftHandle.centerYAnchor)
        ]
        
        let rightHandleTouchAreaViewConstraint = [
            rightHandleTouchAreaView.rightAnchor.constraint(equalTo: rightHandle.rightAnchor, constant: 30),
            rightHandleTouchAreaView.heightAnchor.constraint(equalTo: rightHandle.heightAnchor, multiplier: 1.0),
            rightHandleTouchAreaView.centerYAnchor.constraint(equalTo: rightHandle.centerYAnchor)
        ]
        
        let timegapViewConstraint = [
            displayTimeGapView.leftAnchor.constraint(equalTo: self.leftHandle.rightAnchor, constant: 0),
            displayTimeGapView.rightAnchor.constraint(equalTo: self.rightHandle.leftAnchor, constant: 0),
            displayTimeGapView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0),
            displayTimeGapView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
        ]
        
        let gapLabelBounderyConstraint = [
            timeGapLabelBounderyView.centerXAnchor.constraint(equalTo: displayTimeGapView.centerXAnchor, constant: 0),
            timeGapLabelBounderyView.heightAnchor.constraint(equalToConstant: 20),
            timeGapLabelBounderyView.centerYAnchor.constraint(equalTo: displayTimeGapView.centerYAnchor, constant: 0),
            timeGapLabelBounderyView.widthAnchor.constraint(equalTo: self.timeGapLabel.widthAnchor, constant: 4)
        ]
        
        self.addBorder_SL(toSide: .Top, withColor: UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor, andThickness: 3)
        self.addBorder_SL(toSide: .Bottom, withColor: UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor, andThickness: 3)
        
        NSLayoutConstraint.activate(dimViewContraints)
        NSLayoutConstraint.activate(leftHandleTouchAreaViewConstraint)
        NSLayoutConstraint.activate(rightHandleTouchAreaViewConstraint)
        leftHandleRightAnchorConstraint?.isActive = true
        rightHandleLeftAnchorConstraint?.isActive = true
        
        NSLayoutConstraint.activate(gapLabelBounderyConstraint)
        NSLayoutConstraint.activate(timegapViewConstraint)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        for subview in self.subviews {
            if subview.hitTest(self.convert(point, to: subview), with: event) != nil {
                return true
            }
        }
        return false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard needResetHandle else { return }
        resetHandle()
        needResetHandle = false
        dimView.updateMaskDim(CGRect(x: leftHandle.frame.maxX, y: 0, width: rightHandle.frame.minX - leftHandle.frame.maxX, height: self.frame.height))
    }
    
    private lazy var leftHandleTouchViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(leftHandlerAct))
    private lazy var rightHandleTouchViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(rightHandlerAct))
    
    private var needResetHandle: Bool = true
    
    private func resetHandle() {
        leftHandle.frame = CGRect(x: handleMargin, y: 0, width: 20, height: 60)
        rightHandle.frame = CGRect(x: self.safeAreaLayoutGuide.layoutFrame.size.width - 20 - handleMargin, y: 0, width: 20, height: 60)
    }
    
    func onOrientationChange() {
        self.needResetHandle = true
        self.layoutIfNeeded()
    }
    
    override func attributes() {
        leftHandleTouchAreaView.addGestureRecognizer(leftHandleTouchViewPanGesture)
        leftHandleTouchViewPanGesture.delegate = self
        leftHandleTouchViewPanGesture.isEnabled = true

        rightHandleTouchAreaView.addGestureRecognizer(rightHandleTouchViewPanGesture)
        rightHandleTouchViewPanGesture.delegate = self
        rightHandleTouchViewPanGesture.isEnabled = true
    }
    
    var betweenHandleGap: CGFloat = .zero
    private var handleInitializePosition: CGPoint = .zero
    
    private func updateTouchGapWidth() {
        let handleGap = rightHandle.frame.origin.x - leftHandle.frame.maxX
        let touchGap = handleGap >= 30 ? 30 : (handleGap >= betweenHandleGap ? (handleGap - betweenHandleGap) : (betweenHandleGap / 2))
        self.leftHandleRightAnchorConstraint?.constant = touchGap
        self.rightHandleLeftAnchorConstraint?.constant = -touchGap
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
            guard handleInitializePosition.x + handleWidth + betweenHandleGap <= rightHandle.frame.origin.x else {
                return
            }
                    
            let xChange = handleInitializePosition.x + translation.x
            guard xChange >= handleMargin else {
                leftHandle.frame.origin = CGPoint(x: handleMargin, y: self.leftHandle.frame.origin.y)
                delegate?.updatedCurrentHandlePosition(offset: handleMargin + handleWidth, handleType: .left)
                dimView.updateMaskDim(CGRect(x: leftHandle.frame.maxX, y: 0, width: rightHandle.frame.minX - leftHandle.frame.maxX, height: self.frame.height))
                return
            }
            
            guard xChange + handleWidth + betweenHandleGap < rightHandle.frame.origin.x else {
                leftHandle.frame.origin = CGPoint(x: rightHandle.frame.origin.x - betweenHandleGap - handleWidth, y: self.leftHandle.frame.origin.y)
                delegate?.updatedCurrentHandlePosition(offset: leftHandle.frame.origin.x + handleWidth, handleType: .left)
                
                dimView.updateMaskDim(CGRect(x: leftHandle.frame.maxX, y: 0, width: rightHandle.frame.minX - leftHandle.frame.maxX, height: self.frame.height))
                return
            }
            
            leftHandle.frame.origin = CGPoint(x: xChange, y: self.leftHandle.frame.origin.y)
            
            delegate?.updatedCurrentHandlePosition(offset: leftHandle.frame.origin.x + handleWidth, handleType: .left)
            
            dimView.updateMaskDim(CGRect(x: leftHandle.frame.maxX, y: 0, width: rightHandle.frame.minX - leftHandle.frame.maxX, height: self.frame.height))
            
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
            guard handleInitializePosition.x >= leftHandle.frame.origin.x + handleWidth + betweenHandleGap else {
                return
            }
            
            let xChange = handleInitializePosition.x + translation.x
            guard xChange < self.safeAreaLayoutGuide.layoutFrame.size.width - handleWidth - handleMargin - timeGapSpacing else {
                rightHandle.frame.origin = CGPoint(x: self.safeAreaLayoutGuide.layoutFrame.size.width - handleWidth - handleMargin - timeGapSpacing, y: self.leftHandle.frame.origin.y)
                delegate?.updatedCurrentHandlePosition(offset: rightHandle.frame.origin.x, handleType: .right)
                dimView.updateMaskDim(CGRect(x: leftHandle.frame.maxX, y: 0, width: rightHandle.frame.minX - leftHandle.frame.maxX, height: self.frame.height))
                return
            }
            
            guard xChange >= leftHandle.frame.origin.x + handleWidth + betweenHandleGap else {
                rightHandle.frame.origin = CGPoint(x: leftHandle.frame.origin.x + handleWidth + betweenHandleGap, y: self.leftHandle.frame.origin.y)
                delegate?.updatedCurrentHandlePosition(offset: rightHandle.frame.origin.x, handleType: .right)
                dimView.updateMaskDim(CGRect(x: leftHandle.frame.maxX, y: 0, width: rightHandle.frame.minX - leftHandle.frame.maxX, height: self.frame.height))
                return
            }
            
            rightHandle.frame.origin = CGPoint(x: xChange, y: self.leftHandle.frame.origin.y)
            dimView.updateMaskDim(CGRect(x: leftHandle.frame.maxX, y: 0, width: rightHandle.frame.minX - leftHandle.frame.maxX, height: self.frame.height))
            delegate?.updatedCurrentHandlePosition(offset: rightHandle.frame.origin.x, handleType: .right)
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
    
    @objc private func timeSliderValueChanged(_ slider: UISlider) {
        
    }
    
    func updateTimeGap(start: CMTime, end: CMTime) {
        let startSecond = CMTimeGetSeconds(start)
        let endSecond = CMTimeGetSeconds(end)
        
        guard !endSecond.isNaN && !endSecond.isInfinite else {
            return
        }
        guard !startSecond.isNaN && !startSecond.isInfinite else {
            return
        }
        
        let endSec = endSecond.seconds_SL
        let startSec = startSecond.seconds_SL
        let gapSecond = startSec == endSec ? 1 : Int((endSec - startSec) / 1000000)
        updateTimeSlider(start: startSecond, end: endSecond)
        
        let bundle = Bundle(for: type(of: self))
        if gapSecond > 60 {
            let min = Int(gapSecond / 60)
            let sec = gapSecond % 60
            timeGapLabel.text = "editor.time.gap.min.sec.label".localizedString(with: [min,sec], bundle: bundle)
        }
        else {
            timeGapLabel.text = "editor.time.gap.sec.label".localizedString(with: [gapSecond], bundle: bundle)
        }
        
//        timeGapLabel.text = "\(gapSecond >= 60 ? 60 : gapSecond)초"
    }
    
    private func updateTimeSlider(start: Float64, end: Float64) {
        timeSlider.minimumValue = Float(start)
        timeSlider.maximumValue = Float(end)
        
        updateTime(time: Float(start))
    }
    
    func updateTime(time: Float) {
        timeSlider.value = time
    }
    
    func updateTimeToStart() {
        timeSlider.value = timeSlider.minimumValue
    }
    
    func setSliderVisible(_ visible: Bool) {
        timeSlider.isHidden = !visible
    }
    
    
    
    
}
