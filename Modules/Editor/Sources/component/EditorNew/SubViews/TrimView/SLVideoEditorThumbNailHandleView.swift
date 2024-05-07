//
//  SLVideoEditorThumbNailHandleView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 4/26/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon



class SLVideoEditorThumbNailHandleView : UIView, SLReactor {
    
    
    
    enum Action {
        case initializeThumbView
        case setTimePerPixel(CGFloat)
        
    }
    
    enum Result {
        case thumbViewOffset(CGFloat)
        
    }
    
    private var thumbView : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var lineView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }()
    
    private let handleMargin: CGFloat = 8
    private var timePerPixel : CGFloat = 0
    private var handleBeganPosition : CGRect = .zero
    
    
    var resultHandler: ((Result) -> ())?
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        setLayout()
        addPanGesture()
    }
    
    
    required init(coder : NSCoder) {
        fatalError()
    }
    
    func action(_ action: Action) {
        switch action {
        case .initializeThumbView:
            self.onInitializeThumbView()
        case .setTimePerPixel(let timePerPixel):
            self.onSetTimePerPixel(timePerPixel: timePerPixel)
        }
    }
    
    private func onInitializeThumbView() {
        thumbView.frame = CGRect(x: handleMargin + 9, y: 0, width: 20, height: 60)
    }
    
    private func onSetTimePerPixel(timePerPixel : CGFloat) {
        self.timePerPixel = timePerPixel
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in self.subviews {
            if subview.hitTest(self.convert(point, to: subview), with: event) != nil {
                return true
            }
        }
        return false
    }
}
extension SLVideoEditorThumbNailHandleView {
    private func setLayout() {
        self.addSubview(lineView)
        self.addSubview(thumbView)
        
        NSLayoutConstraint.activate([
            lineView.centerXAnchor.constraint(equalTo: thumbView.centerXAnchor),
            lineView.heightAnchor.constraint(equalTo: thumbView.heightAnchor, multiplier: 1),
            lineView.widthAnchor.constraint(equalToConstant: 1),
            lineView.centerYAnchor.constraint(equalTo: thumbView.centerYAnchor)
        ])
    }
}
extension SLVideoEditorThumbNailHandleView : UIGestureRecognizerDelegate {
    private func addPanGesture() {
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
            handleBeganPosition = handler.frame
            break
        case .changed:
            let nextXpos = handleBeganPosition.midX + translation.x
            if nextXpos < handleMargin + 9 || nextXpos > self.safeAreaLayoutGuide.layoutFrame.size.width - handleMargin - 20 - 9 {
                return
            }
            handler.frame.origin.x = nextXpos
            
            resultHandler?( .thumbViewOffset(handler.frame.midX) )
            break
        case .ended:
            resultHandler?( .thumbViewOffset(handler.frame.midX) )
            break
        default:
            break
        }
    }
    
    
}
