////
////  SLVideoEditorScrollView.swift
////  matrix-shortform-ios
////
////  Created by 김우현 on 4/22/23.
////
//
import UIKit
import ShopliveSDKCommon
//
class SLDimView: UIView {
    
    private var maskRect: CGRect = .zero
    
    private var borderColor : UIColor = .white
    init(borderColor : UIColor ) {
        super.init(frame: .zero)
        self.borderColor = borderColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let rBounds = self.bounds
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        context?.fill([rBounds])
        
        context?.setStrokeColor(borderColor.cgColor)
        context?.setLineWidth(4)
        context?.move(to: CGPoint(x: maskRect.origin.x, y: maskRect.origin.y))
        context?.addLine(to: CGPoint(x: maskRect.origin.x + maskRect.size.width, y: maskRect.origin.y))
        context?.strokePath()
        
        context?.move(to: CGPoint(x: maskRect.origin.x, y: maskRect.origin.y + maskRect.size.height))
        context?.addLine(to: CGPoint(x: maskRect.origin.x + maskRect.size.width, y: maskRect.origin.y + maskRect.size.height))
        context?.strokePath()

        context?.setBlendMode(.clear)
        context?.fill([CGRect(x: maskRect.origin.x, y: maskRect.origin.y + 2, width: maskRect.width, height: maskRect.size.height - 4)])
    }
    
    func updateMaskDim(_ rect: CGRect = .zero) {
        self.maskRect = rect
        
        let rBounds = self.bounds
                    
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        context?.fill([rBounds])
        
        context?.setBlendMode(.clear)
        context?.fill([self.maskRect])
        self.setNeedsDisplay()
    }
}
