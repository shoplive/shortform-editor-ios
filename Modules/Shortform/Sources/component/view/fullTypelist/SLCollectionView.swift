//
//  SLCollectionView.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/26/23.
//

import UIKit
import ShopliveSDKCommon

final class SLCollectionView: UICollectionView {
    
    var maskRect: CGRect = .zero
    
    deinit {
        // print("SLCollectionView deinit")
    }
    
    override var contentSize:CGSize {
      didSet {
        invalidateIntrinsicContentSize()
      }
    }
    
    override var intrinsicContentSize: CGSize {
      layoutIfNeeded()
      return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
    
    private var reloadDataCompletionBlock: (() -> Void)?
        
    func reloadDataWithCompletion(items: [IndexPath], _ complete: @escaping () -> Void) {
        reloadDataCompletionBlock = complete
        
        if items.count > 3 {
            super.reloadItems(at: items)
        } else {
            super.reloadData()
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let block = reloadDataCompletionBlock {
            block()
            self.reloadDataCompletionBlock = nil
        }
        
    }
}

extension SLCollectionView {
    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        let context = UIGraphicsGetCurrentContext()
//
//        context?.setFillColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
//        context?.fill([CGRect(origin: .zero, size: self.contentSize)])
//
//        context?.setBlendMode(.clear)
//        context?.fill([self.maskRect])
//    }
//
//    func dimMasK(_ maskRect: CGRect) {
//        self.maskRect = maskRect
//
//        let context = UIGraphicsGetCurrentContext()
//        
//        context?.setFillColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
//        context?.fill([CGRect(origin: .zero, size: self.contentSize)])
//
//        context?.setBlendMode(.clear)
//        context?.fill([maskRect])
//        self.setNeedsLayout()
//    }
}
