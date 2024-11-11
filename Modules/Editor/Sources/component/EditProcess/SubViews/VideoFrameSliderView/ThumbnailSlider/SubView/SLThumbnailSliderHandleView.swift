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



class SLThumbnailSliderHandleView : UIView, SLReactor {
    
    enum Action {
        case initializeThumbView
        case setTimePerPixel(CGFloat)
        case moveHandleTo(CGFloat)
    }
    
    enum Result {
        case thumbViewOffset(CGFloat)
        case thumbViewOffsetForDimViewOnly(CGFloat)
        
    }
    
    private var thumbView : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    lazy private var lineView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.borderColor = borderColor.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let handleMargin: CGFloat = 28
    private var timePerPixel : CGFloat = 0
    private var handleBeganPosition : CGRect = .zero
    
    
    var resultHandler: ((Result) -> ())?
    private var borderColor : UIColor = .white
    
    init(frame : CGRect,borderColor : UIColor) {
        self.borderColor = borderColor
        super.init(frame: frame)
        setLayout()
        addPanGesture()
        lineView.isHidden = true
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
        case .moveHandleTo(let offset):
            self.onMoveHandleTo(offset: offset)
        }
    }
    
    private func onInitializeThumbView() {
        thumbView.frame = CGRect(x: handleMargin, y: 0, width: 60 * ( 9 / 16), height: 60)
        lineView.isHidden = false
    }
    
    private func onSetTimePerPixel(timePerPixel : CGFloat) {
        self.timePerPixel = timePerPixel
    }
    
    private func onMoveHandleTo(offset : CGFloat) {
        thumbView.frame.origin.x = offset
        resultHandler?( .thumbViewOffsetForDimViewOnly(thumbView.frame.minX) )
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
extension SLThumbnailSliderHandleView {
    private func setLayout() {
        self.addSubview(lineView)
        self.addSubview(thumbView)
        
        NSLayoutConstraint.activate([
            lineView.centerXAnchor.constraint(equalTo: thumbView.centerXAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 64),
            lineView.widthAnchor.constraint(equalTo: lineView.heightAnchor, multiplier: 9 / 16),
            lineView.centerYAnchor.constraint(equalTo: thumbView.centerYAnchor,constant: 2)
        ])
    }
}
extension SLThumbnailSliderHandleView : UIGestureRecognizerDelegate {
    private func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(sender: )))
        panGesture.delegate = self
        panGesture.isEnabled = true
        thumbView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(sender : UIPanGestureRecognizer) {
        guard let handler = sender.view else { return }
        let translation = sender.translation(in: handler)
        let handleWidth =  (self.frame.height) * (9 / 16)
        switch sender.state {
        case .began:
            handleBeganPosition = handler.frame
            break
        case .changed:
            let nextXpos = handleBeganPosition.minX + translation.x
            if nextXpos <= handleMargin {
                handler.frame.origin.x = handleMargin
                resultHandler?( .thumbViewOffset(handleMargin) )
            }
            else if nextXpos > self.safeAreaLayoutGuide.layoutFrame.size.width - handleMargin - handleWidth + 2 {
                handler.frame.origin.x = self.safeAreaLayoutGuide.layoutFrame.size.width - handleMargin - handleWidth + 2
                resultHandler?( .thumbViewOffset(self.safeAreaLayoutGuide.layoutFrame.size.width - handleMargin - handleWidth + 2) )
            }
            else {
                handler.frame.origin.x = nextXpos
                resultHandler?( .thumbViewOffset(handler.frame.minX) )
            }
            break
        case .ended:
            let nextXpos = handleBeganPosition.minX + translation.x
            if nextXpos <= handleMargin {
                handler.frame.origin.x = handleMargin
                resultHandler?( .thumbViewOffset(handleMargin) )
            }
            else if nextXpos > self.safeAreaLayoutGuide.layoutFrame.size.width - handleMargin - handleWidth + 2 {
                handler.frame.origin.x = self.safeAreaLayoutGuide.layoutFrame.size.width - handleMargin - handleWidth + 2
                resultHandler?( .thumbViewOffset(self.safeAreaLayoutGuide.layoutFrame.size.width - handleMargin - handleWidth + 2) )
            }
            else {
                handler.frame.origin.x = nextXpos
                resultHandler?( .thumbViewOffset(handler.frame.minX) )
            }
            break
        default:
            break
        }
    }
    
    
}
extension SLThumbnailSliderHandleView {
    func getHandleMargin() -> CGFloat {
        return handleMargin
    }
}
