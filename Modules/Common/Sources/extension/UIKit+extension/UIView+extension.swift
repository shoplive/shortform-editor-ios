//
//  UIView+extension.swift
//  CopyWidget
//
//  Created by james on 2020/06/13.
//  Copyright © 2020 James Kim. All rights reserved.
//

import UIKit

public extension UIView {
    func fit_SL() {
        guard let superview = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
    
    func fitTop30_SL() {
        guard let superview = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
    
    func animateSizeChange_SL(from: CGSize, to: CGSize, duration: Double) {
        let halfDuration: TimeInterval = duration / 2
        UIView.animate(withDuration: halfDuration, delay: 0, options: []) {
            self.transform = CGAffineTransform(scaleX: from.width, y: from.height)
        }
        
        UIView.animate(withDuration: halfDuration, delay: halfDuration, options: []) {
            self.transform = CGAffineTransform(scaleX: to.width, y: to.height)
        }
    }
    
    func changeScale_SL(to: CGFloat) {
        self.transform = CGAffineTransform(scaleX: to, y: to)
    }
    
    @IBInspectable var cornerRadiusV_SL: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidthV_SL: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColorV_SL: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    var ratio_SL: CGFloat {
        let s = frame.size
        return s.height/s.width
    }
    
    var showsUp_SL: Bool {
        return !isHidden
    }
    
    var parentViewController_SL: UIViewController? {
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
    
    func addAndFitToParent_SL(view: UIView, belowSubview: UIView) {
        insertSubview(view, belowSubview: belowSubview)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    }
    
    func fitToParent_SL() {
        guard let p = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: p.topAnchor).isActive = true
        rightAnchor.constraint(equalTo: p.rightAnchor).isActive = true
        bottomAnchor.constraint(equalTo: p.bottomAnchor).isActive = true
        leftAnchor.constraint(equalTo: p.leftAnchor).isActive = true
    }
        
    func clearConstraints_SL() {
        for subview in self.subviews {
            subview.clearConstraints_SL()
        }
        self.removeConstraints(self.constraints)
    }
    
    func roundCorners_SL(corners: UIRectCorner, radius: CGFloat) {
        var arr = CACornerMask()
        
        if corners.contains(.topLeft) {
            arr.insert(.layerMinXMinYCorner)
        }
        
        if corners.contains(.topRight) {
            arr.insert(.layerMaxXMinYCorner)
        }
        
        if corners.contains(.bottomLeft) {
            arr.insert(.layerMinXMaxYCorner)
        }
        
        if corners.contains(.bottomRight) {
            arr.insert(.layerMaxXMaxYCorner)
        }
        
        layer.cornerRadius = radius
        layer.maskedCorners = arr
    }
    
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage_SL() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    
    class func fromNib_SL<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    func makeDashedBorderLine_SL(lineDashWidth: CGFloat, pattern: [NSNumber]) {
        let path = CGMutablePath()
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = lineDashWidth
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineDashPattern = pattern
        path.addLines(between: [CGPoint(x: bounds.minX, y: bounds.height/2),
                                CGPoint(x: bounds.maxX, y: bounds.height/2)])
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
    
    @discardableResult
    func setGradientBackground_SL(bottom: UIColor = UIColor.black.withAlphaComponent(0.5), top: UIColor = UIColor.clear) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [top.cgColor, bottom.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        let size = bounds.size
        gradientLayer.frame = CGRect(origin: bounds.origin, size: CGSize(width: size.width*3, height: size.height*3))
        
        layer.insertSublayer(gradientLayer, at: 0)
        return gradientLayer
    }
    
    func removeGradientBackground_SL() {
        guard let layers = layer.sublayers else { return }
        let b = layers.compactMap { $0 as? CAGradientLayer }
        b.forEach { $0.removeFromSuperlayer() }
    }
    
    func constrainCentered_SL(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let verticalContraint = NSLayoutConstraint(
            item: subview,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0)
        
        let horizontalContraint = NSLayoutConstraint(
            item: subview,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0)
        
        let heightContraint = NSLayoutConstraint(
            item: subview,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: subview.frame.height)
        
        let widthContraint = NSLayoutConstraint(
            item: subview,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: subview.frame.width)
        
        addConstraints([
                        horizontalContraint,
                        verticalContraint,
                        heightContraint,
                        widthContraint])
        
    }
    
    func constrainToEdges_SL(_ subview: UIView) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let topContraint = NSLayoutConstraint(
            item: subview,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 0)
        
        let bottomConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0)
        
        let leadingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0)
        
        let trailingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0)
        
        addConstraints([topContraint,
                        bottomConstraint,
                        leadingContraint,
                        trailingContraint])
    }
    
    func addBlurEffect_SL() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        insertSubview(blurEffectView, at: 0)
        blurEffectView.fitToParent_SL()
    }
    
    func addSubviews_SL(_ views: UIView...) {
        views.forEach { view in
            self.addSubview(view)
        }
    }
    
    var globalPoint_SL :CGPoint? {
        return self.superview?.convert(self.frame.origin, to: nil)
    }
    
    var globalFrame_SL :CGRect? {
        return self.superview?.convert(self.frame, to: nil)
    }
    
    func snapshot_SL(afterScreenUpdates: Bool = false, completion: @escaping (UIImage?) -> Void) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: afterScreenUpdates)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {
            completion(nil)
            return
        }
        UIGraphicsEndImageContext()
        completion(img)
        
    }
    
    func fitToSuperView_SL() {
        guard let superview = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
    
    enum ViewSide {
        case Left, Right, Top, Bottom
    }
    
    func addBorder_SL(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {
        
        let border = CALayer()
        border.backgroundColor = color
        
        switch side {
        case .Left: border.frame = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height); break
        case .Right: border.frame = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height); break
        case .Top: border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: thickness); break
        case .Bottom: border.frame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: thickness); break
        }
        
        layer.addSublayer(border)
    }
}
