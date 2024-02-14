//
//  SLVideoEditorScrollView.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 4/22/23.
//

import UIKit
import ShopliveSDKCommon

class SLDimView: UIView {
    
    private var maskRect: CGRect = .zero
    
    override func draw(_ rect: CGRect) {
        let rBounds = self.bounds
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        context?.fill([rBounds])
        
        context?.setStrokeColor(UIColor.white.cgColor)
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

class SLVideoEditorScrollView: UIScrollView {
    
    private var itemSize: CGSize = .zero
    private(set) var itemCount: CGFloat = 0
    
    private var handleInset: UIEdgeInsets = .zero
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let cropDimView: SLDimView = {
        let view = SLDimView()
        view.backgroundColor = .clear
//        view.alpha = 0.5
        view.isHidden = true
        
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        layout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ShopLiveLogger.debugLog("[ShopliveShortformEditor] SLVideoEidtorSCrollView deinited")
    }
    
    private func layout() {
        self.bounces = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.addSubview(contentView)
        contentView.fit_SL()
        
//        self.contentView.addSubview(cropDimView)
//        self.contentView.bringSubviewToFront(cropDimView)
    }
    
    func setItemSize(_ size: CGSize) {
        itemSize = size
    }
    
    func setItemInset(_ inset: UIEdgeInsets) {
        self.contentInset = inset
    }
    
    func addItem(_ item: UIImage, newSize: CGSize? = nil) {
        guard itemSize != .zero else { return }
        
        var addtemSize: CGSize = itemSize
        if let newSize = newSize {
            addtemSize = newSize
        }
        
        let itemView = UIImageView(image: item)
        
        self.contentView.addSubview(itemView)
        itemView.frame = CGRect(origin: CGPoint(x: itemCount * itemSize.width, y: 0), size: addtemSize)
        self.itemCount += 1
        updateContentSize()
    }
    
    func removeAllItems() {
        self.contentView.subviews.filter({$0.isKind(of: UIImageView.self)}).forEach { view in
            view.removeFromSuperview()
        }
        self.itemCount = 0
        updateContentSize()
    }
    
    func updateMaskDim(_ rect: CGRect = .zero) {
        let xpos = self.contentOffset.x + 28
        let updateDimRect = CGRect(origin: CGPoint(x: rect.origin.x + xpos, y: rect.origin.y), size: CGSize(width: rect.width, height: rect.height))
        cropDimView.updateMaskDim(updateDimRect)
        self.contentView.bringSubviewToFront(cropDimView)
        self.setNeedsDisplay()
    }
    
    private func updateContentSize() {
        let itemTotalWidth = self.contentView.subviews.filter({$0.isKind(of: UIImageView.self)}).map { $0.frame.width }.reduce(0, +)
        let updateSize = CGSize(width: itemTotalWidth, height: itemSize.height)
        self.contentSize = updateSize
        self.cropDimView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: updateSize)
        self.setNeedsDisplay()
    }
}
