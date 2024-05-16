//
//  SLFFmpegTextSizeVerticalSlider.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 1/29/24.
//

import Foundation
import UIKit
import ShopliveSDKCommon



class SLFFmpegTextSizeVerticalSlider : UIView, UIGestureRecognizerDelegate, SLReactor {

    
    enum Action {
        
    }
    
    enum Result {
        case fontSizeChanged(CGFloat)
    }
    
    private var baseLineView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    
    private var thumbView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var thumbViewbottomAnc : NSLayoutConstraint = {
        return thumbView.bottomAnchor.constraint(equalTo: baseLineView.bottomAnchor)
    }()
    
    
    private var thumbPanGesture : UIPanGestureRecognizer?
    
    private var lastThumbYPos : CGFloat = 0
    
    private var maskLayer = CAShapeLayer()
    
    var resultHandler: ((Result) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        setUpPanGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        maskLayer.frame = baseLineView.bounds
        setColorMask()
    }
    
    func action(_ action: Action) {
        
    }
    
    private func setUpPanGesture() {
        thumbPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture: )))
        thumbPanGesture?.delegate = self
        thumbView.addGestureRecognizer(thumbPanGesture!)
    }
    
   
    @objc private func handlePanGesture(gesture : UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        switch gesture.state {
        case .began:
            lastThumbYPos = thumbViewbottomAnc.constant
            break
        case .changed:
            let targetYPos = lastThumbYPos + translation.y
            if targetYPos >= 0 || targetYPos <= -(baseLineView.frame.height) {
                return
            }
            thumbViewbottomAnc.constant = lastThumbYPos + translation.y
            break
        case .ended:
            break
        default:
            break
        }
        
        
    }
    
    private func setColorMask() {
        var coloredRect = baseLineView.bounds
        coloredRect.size.height = abs(baseLineView.frame.height) - abs(thumbViewbottomAnc.constant)
        let path = UIBezierPath(rect: coloredRect)
        maskLayer.path = path.cgPath
    }
    
    // font size 15 ~ 50
    // slider value 0 ~ 100
    private func changeFontSize() {
        let fullHeight = baseLineView.frame.height
        let currentHeight = fullHeight - abs(thumbViewbottomAnc.constant)
        
        let currentValue = (currentHeight / fullHeight) * 100
        
        
        
    }
}
extension SLFFmpegTextSizeVerticalSlider {
    private func setLayout() {
        self.addSubview(baseLineView)
        self.addSubview(thumbView)
        baseLineView.layer.addSublayer(maskLayer)
        maskLayer.fillColor = UIColor.lightGray.cgColor
        
        
        NSLayoutConstraint.activate([
            baseLineView.topAnchor.constraint(equalTo: self.topAnchor),
            baseLineView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            baseLineView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            baseLineView.widthAnchor.constraint(equalToConstant: 1),
            
            thumbViewbottomAnc,
            thumbView.centerXAnchor.constraint(equalTo: baseLineView.centerXAnchor),
            thumbView.widthAnchor.constraint(equalToConstant: 20),
            thumbView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
}
