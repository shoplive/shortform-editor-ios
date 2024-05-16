//
//  SLColorPickerView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/27/23.
//

import Foundation
import UIKit

protocol SLColorPickerDelegate: AnyObject {
    func slColorPicker(_ view : SLColorPickerView, didSelect color: UIColor, rgb : [CGFloat])
}



class SLColorPickerView : UIView {
    
    
    let gradientLayer = CAGradientLayer()
    
    weak var delegate: SLColorPickerDelegate?
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(onTap)))
    }
    
    required init(coder : NSCoder) {
        fatalError()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        setUpGradientLayerIfNeeded()
    }
    
    private func setUpGradientLayerIfNeeded() {
        guard gradientLayer.superlayer == nil else { return }
        gradientLayer.colors = [
            UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor,
            UIColor(red: 1, green: 1, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 1, blue: 0, alpha: 1).cgColor,
            UIColor(red: 0, green: 1, blue: 1, alpha: 1).cgColor,
            UIColor(red: 0, green: 0, blue: 1, alpha: 1).cgColor,
            UIColor(red: 1, green: 0, blue: 1, alpha: 1).cgColor,
            UIColor(red: 1, green: 0, blue: 0, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = bounds
        gradientLayer.name = "colorPicker"
        layer.addSublayer(gradientLayer)
    }
    
    
    @objc func onTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let color = gradientLayer.colorOfPoint(point: gestureRecognizer.location(in: self)) else { return }
        delegate?.slColorPicker(self, didSelect: color.0,rgb: color.1)
    }
    
    
}
fileprivate extension CALayer {
    func colorOfPoint(point: CGPoint) -> (UIColor,[CGFloat])? {
        var pixel: [UInt8] = [0, 0, 0, 0]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(
            rawValue: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        guard let context = CGContext(
            data: &pixel,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ) else { return nil }
        context.translateBy(x: -point.x, y: -point.y)
        
        render(in: context)
        /// Get every value from the array
        let red = CGFloat(pixel[0]) / 255.0
        let green = CGFloat(pixel[1]) / 255.0
        let blue = CGFloat(pixel[2]) / 255.0
        let alpha = CGFloat(pixel[3]) / 255.0
        
        /// Create the color from the values
        return (UIColor(red: red, green: green, blue: blue, alpha: alpha), [red,green,blue] )
    }
    
}




