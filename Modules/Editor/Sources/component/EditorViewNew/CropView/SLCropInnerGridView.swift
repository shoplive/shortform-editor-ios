//
//  SLCropInnerGridView.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 2023/06/02.
//

import Foundation
import UIKit
import ShopLiveSDKCommon

class SLCropInnerGridView : UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawGridLines(rect)
    }
    
    deinit {
        ShopLiveLogger.debugLog("[ShopliveShortformEditor] SLCropInnerGridView deinited")
    }
    
    private let lineWidth : CGFloat = 1
    private let lineColor : UIColor = .init(white: 1, alpha: 0.5)
    private func drawGridLines(_ rect : CGRect){
        let context = UIGraphicsGetCurrentContext()
        
        //vertical left
        context?.setStrokeColor(lineColor.cgColor)
        context?.setLineWidth(lineWidth)
        context?.move(to: CGPoint(x: rect.maxX * ( 1 / 3) , y: rect.minY))
        context?.addLine(to: CGPoint(x: rect.maxX * ( 1 / 3) , y: rect.maxY ))
        context?.strokePath()
        
        //vertical right
        context?.setStrokeColor(lineColor.cgColor)
        context?.setLineWidth(lineWidth)
        context?.move(to: CGPoint(x: rect.maxX * ( 2 / 3) , y: rect.minY))
        context?.addLine(to: CGPoint(x: rect.maxX * ( 2 / 3) , y: rect.maxY ))
        context?.strokePath()
        
        //horizontal top
        context?.setStrokeColor(lineColor.cgColor)
        context?.setLineWidth(lineWidth)
        context?.move(to: CGPoint(x: rect.origin.x , y: rect.maxY * ( 1 / 3)))
        context?.addLine(to: CGPoint(x: rect.maxX , y: rect.maxY * ( 1 / 3)))
        context?.strokePath()
        
        //horizontal down
        context?.setStrokeColor(lineColor.cgColor)
        context?.setLineWidth(lineWidth)
        context?.move(to: CGPoint(x: rect.origin.x , y: rect.maxY * ( 2 / 3)))
        context?.addLine(to: CGPoint(x: rect.maxX , y: rect.maxY * ( 2 / 3) ))
        context?.strokePath()
        
        context?.setBlendMode(.clear)
        
        self.setNeedsDisplay()
    }
}
