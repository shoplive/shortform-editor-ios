//
//  SLCollectionView.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/26/23.
//

import UIKit
import ShopliveSDKCommon

final class SLCollectionView: UICollectionView {
    
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
    
    
    private var isContentViewDrawed : Bool = false
    var didRenderContentView : (() -> ())?
        
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
        
        if isContentViewDrawed == false && self.contentSize != .zero {
            isContentViewDrawed = true
            self.didRenderContentView?()
        }
        
        if let block = reloadDataCompletionBlock {
            block()
            self.reloadDataCompletionBlock = nil
        }
        
    }
}

