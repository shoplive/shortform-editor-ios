//
//  SlCustomUIPicker.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/10/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon

class SlCustomUISlider : UIView, SLReactor {
    
    
    enum Action {
        case setMinValue(CGFloat)
        case setMaxValue(CGFloat)
        case setCurrentValue(CGFloat)
        case setValueLabel(String)
        case setDeActive(Bool)
    }
    
    enum Result {
        case didFinishDragging
        case didStartDragging
        case currentValue(CGFloat)
    }
    
    
    
    private var thumbView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    lazy private var thumViewCentXAnc : NSLayoutConstraint = {
        return thumbView.centerXAnchor.constraint(equalTo: self.lineView.leadingAnchor)
    }()
    
    
    private var lineView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(white: 1, alpha: 0.4)
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        return view
    }()
    
    private var valueLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.font = .set(size: 16, weight: ._600)
        label.textAlignment = .right
        return label
    }()
    
    private var inActiveStateBlockView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(white: 0, alpha: 0.3)
        return view
    }()
    
    
    
    var resultHandler: ((Result) -> ())?
    private var touchBeganXpos : CGFloat = 0
    private var latestOutPutValue : CGFloat = 0
    private var maxValue : CGFloat = 0
    private var minValue : CGFloat = 0
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor =  .init(white: 1, alpha: 0.2)
        self.layer.cornerRadius = 24
        self.clipsToBounds = true
        
        self.setLayout()
        self.addPangesture()
        
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    
    func action(_ action: Action) {
        switch action {
        case .setMinValue(let value):
            self.onSetMinValue(minVal: value)
        case .setMaxValue(let value):
            self.onSetMaxValue(maxVal: value)
        case .setCurrentValue(let value):
            self.onSetCurrentValue(val: value)
        case .setValueLabel(let text):
            self.onSetValueLabel(text: text)
        case .setDeActive(let deActive):
            self.onSetDeActive(deActive: deActive)
        }
    }
    
    private func onSetMinValue(minVal : CGFloat) {
        self.minValue = minVal
    }
    
    private func onSetMaxValue(maxVal : CGFloat) {
        self.maxValue = maxVal
    }

    private func onSetCurrentValue(val : CGFloat) {
        let lineFrame = self.lineView.frame.width
        let percent = val / (self.maxValue - self.minValue )
        self.thumViewCentXAnc.constant = lineFrame * percent
    }
    
    private func onSetValueLabel(text : String) {
        self.valueLabel.text = text
    }
    
    private func onSetDeActive(deActive : Bool) {
        self.inActiveStateBlockView.isHidden = deActive ? false : true
    }
    
}
extension SlCustomUISlider {
    private func setLayout() {
        self.addSubview(lineView)
        self.addSubview(thumbView)
        self.addSubview(valueLabel)
        self.addSubview(inActiveStateBlockView)
        inActiveStateBlockView.isHidden = true
        
        
        NSLayoutConstraint.activate([
            lineView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 16),
            lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -60),
            lineView.heightAnchor.constraint(equalToConstant: 4),
            
            
            valueLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: lineView.trailingAnchor, constant: 5),
            valueLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            valueLabel.heightAnchor.constraint(equalToConstant: 20),
            
            thumbView.centerYAnchor.constraint(equalTo: lineView.centerYAnchor),
            thumbView.widthAnchor.constraint(equalToConstant: 20),
            thumbView.heightAnchor.constraint(equalToConstant: 20),
            thumViewCentXAnc,
            
            
            inActiveStateBlockView.topAnchor.constraint(equalTo: self.topAnchor),
            inActiveStateBlockView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            inActiveStateBlockView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            inActiveStateBlockView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
}
extension SlCustomUISlider : UIGestureRecognizerDelegate {
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
            touchBeganXpos = handler.frame.minX
            resultHandler?( .didStartDragging )
            break
        case .changed:
            var nextPos = touchBeganXpos + translation.x
            if nextPos < 0 {
                nextPos = 0
                self.thumViewCentXAnc.constant = 0
            }
            else if nextPos > self.lineView.frame.width {
                nextPos = lineView.frame.width
            }
            
            self.thumViewCentXAnc.constant = nextPos
            
            
            let percent = nextPos / self.lineView.frame.width
            let result = (self.maxValue - self.minValue) * percent
            
            if result == self.latestOutPutValue {
                return
            }
            self.latestOutPutValue = result
            resultHandler?( .currentValue( result ) )
            break
        case .ended:
            resultHandler?( .didFinishDragging )
            break
        default:
            break
        }
    }
    
}
