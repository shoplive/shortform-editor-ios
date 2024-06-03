//
//  SLthumbnailSliderDimView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/14/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon



class SLThumbnailSliderDimView : UIView {
    
    private var maskRect : CGRect = CGRect(x: 28, y: 0, width: 60 * (CGFloat(9) / CGFloat(16)), height: 60)
    
    private var cornerRadius : CGFloat = 0
    
    init(frame : CGRect, cornerRadius : CGFloat) {
        self.cornerRadius = cornerRadius
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
    
    
    override func draw(_ rect: CGRect) {
        let rBounds = self.bounds
        // 배경을 검은색으로 설정
        UIColor.init(white: 0, alpha: 0.4).setFill()
        UIRectFill(rBounds)
        
        
        let outerRect = CGRect(x: 0, y: 0, width: rBounds.width, height: rBounds.height)
        let outerPath = UIBezierPath(rect: outerRect)
        
        let innerRect = CGRect(x: 28, y: 0, width: rBounds.width - 56, height: rBounds.height)
        let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: cornerRadius)
        
        outerPath.append(innerPath)
        outerPath.usesEvenOddFillRule = true
        
        UIColor.black.setFill()
        outerPath.fill()

        let context = UIGraphicsGetCurrentContext()
        let handleRect = maskRect
        let handlePath = UIBezierPath(roundedRect: handleRect, cornerRadius: cornerRadius).cgPath
        
        context?.addPath(handlePath)
        context?.setBlendMode(.clear)
        context?.fillPath()
//        context?.fill([handleRect])
    }
    
    
    func makeHandleViewAreaClear(rect : CGRect) {
        self.maskRect = rect
        let rBounds = self.bounds
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        context?.fill([rBounds])
        
        context?.setBlendMode(.clear)
        context?.fill([rect])
        self.setNeedsDisplay()
    }

}
