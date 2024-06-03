//
//  SLCustomUISLider.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/7/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon



class SLTimeTrimTimeIndicator : UIView, SLReactor {
    
    enum Action {
        case initializeThumbView
        case setMinValue(CGFloat)
        case setMaxValue(CGFloat)
        case setCurrentValue(CGFloat,pixelPerTime : CGFloat)
        case setCurrentValueToStart(pixelPerTime : CGFloat)
    }
    
    enum Result {
        case didFinishDragging
        case didStartDragging
        case thumbViewOffset(CGFloat)
    }
    
    
    private var thumbView : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.alpha = 0.2
        return view
    }()
    
    lazy private var lineView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = timeIndicatorCornerRadius
        return view
    }()
    
    private var minValue : CGFloat = -1
    private var maxValue : CGFloat = -1
    private var currentValue : CGFloat = 0
    private var thumbViewBeganPosition : CGRect = .zero
    private var isDragging : Bool = false
    private var timeIndicatorCornerRadius : CGFloat = 0
    
    
    var resultHandler: ((Result) -> ())?
    
    private var animator : UIViewPropertyAnimator?
    
    init(frame : CGRect,timeIndicatorCornerRadius : CGFloat) {
        self.timeIndicatorCornerRadius = timeIndicatorCornerRadius
        super.init(frame: frame)
        setLayout()
        addPangesture()
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in self.subviews {
            if subview.hitTest(self.convert(point, to: subview), with: event) != nil {
                return true
            }
        }
        return false
    }
    
    
    func action(_ action: Action) {
        switch action {
        case .initializeThumbView:
            self.onInitializeThumbView()
        case .setCurrentValue(let value,let pixelPerTime):
            self.onSetCurrentValue(value: value,pixelPerTime: pixelPerTime)
        case .setMaxValue(let value):
            self.onSetMaxValue(value: value)
        case .setMinValue(let value):
            self.onSetMinValue(value: value)
        case .setCurrentValueToStart(let pixelPerTime):
            self.onSetCurrentValueToStart(pixelPerTime: pixelPerTime)
        }
    }
    
    
    private func onInitializeThumbView() {
        thumbView.frame = CGRect(x: -10, y: 0, width: 20, height: self.frame.height)
    }
    
    private func onSetCurrentValue(value : CGFloat,pixelPerTime : CGFloat) {
        guard self.isDragging == false else { return } //self.maxValue != -1, self.minValue != -1
        self.currentValue = value
        if self.frame.width > 0 {
            let targetXpos = max((pixelPerTime * (value - self.minValue)) - 10, -10)
            if animator == nil {
                animator = UIViewPropertyAnimator(duration: 0.01, curve: .linear) { [weak self] in
                    guard let self = self else { return }
                    self.thumbView.frame.origin.x = targetXpos
                }
            }
            else {
                animator?.addAnimations { [weak self] in
                    guard let self = self else { return }
                    self.thumbView.frame.origin.x = targetXpos
                }
            }
            animator?.startAnimation()
        }
        else {
            self.onInitializeThumbView()
        }
        
    }
    
    private func onSetMaxValue(value : CGFloat) {
        self.maxValue = value
    }
    
    private func onSetMinValue(value : CGFloat) {
        self.minValue = value
    }
    
    private func onSetCurrentValueToStart(pixelPerTime : CGFloat) {
        guard self.isDragging == false else { return }
        self.onSetCurrentValue(value: self.minValue, pixelPerTime: pixelPerTime)
    }
    
    
    
}
extension SLTimeTrimTimeIndicator {
    private func setLayout() {
        self.addSubview(lineView)
        self.addSubview(thumbView)
        
        NSLayoutConstraint.activate([
            lineView.centerXAnchor.constraint(equalTo: thumbView.centerXAnchor),
            lineView.heightAnchor.constraint(equalTo: thumbView.heightAnchor, multiplier: 1),
            lineView.widthAnchor.constraint(equalToConstant: 4),
            lineView.centerYAnchor.constraint(equalTo: thumbView.centerYAnchor)
        ])
    }
    
}
extension SLTimeTrimTimeIndicator : UIGestureRecognizerDelegate {
    private func addPangesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(sender: )))
        panGesture.delegate = self
        panGesture.isEnabled = true
        thumbView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(sender : UIPanGestureRecognizer) {
        guard let handler = sender.view else { return }
        let translation = sender.translation(in: handler)
        switch sender.state {
        case .began:
            thumbViewBeganPosition = handler.frame
            self.isDragging = true
            resultHandler?( .didStartDragging )
            break
        case .changed:
            let nextPos = thumbViewBeganPosition.midX + translation.x
            if nextPos < -10 || nextPos > self.safeAreaLayoutGuide.layoutFrame.size.width - 10 {
                return
            }
            handler.frame.origin.x = nextPos
            resultHandler?( .thumbViewOffset(handler.frame.midX) )
            break
        case .ended:
            self.isDragging = false
            resultHandler?( .thumbViewOffset(handler.frame.midX) )
            resultHandler?( .didFinishDragging )
            break
        default:
            break
        }
    }
    
    
}
