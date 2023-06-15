//
//  ShopLiveWindow.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 2023/06/15.
//

import Foundation
import UIKit

class ShopliveWindow: UIWindow {
    
    private var blockAddSubView : Bool = false
    private var timer : Timer?
    private var dispatchSource : DispatchSourceTimer?
    
    func startBlockAddSubViewTimer(){
        blockAddSubView = true
        dispatchSource?.cancel()
        dispatchSource = nil
        dispatchSource = DispatchSource.makeTimerSource()
        dispatchSource?.schedule(deadline: .now() + 30)
        dispatchSource?.setEventHandler{ [weak self] in
            guard let self = self else { return }
            self.blockAddSubView = false
        }
        dispatchSource?.activate()
    }
    
    func invalidateBlockAddSubViewTimer(){
        self.dispatchSource?.cancel()
        self.dispatchSource = nil
        self.blockAddSubView = false
    }
    
    override func addSubview(_ view: UIView) {
        if self.subviews.count == 0 && String(describing: view).contains("UITransitionView") {
            super.addSubview(view)
            return
        }
        if self.blockAddSubView == true {
            return
        }
        if self.frame.size != UIScreen.main.bounds.size {
            return
        }
        super.addSubview(view)
    }
}

