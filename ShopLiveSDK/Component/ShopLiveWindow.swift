//
//  ShopLiveWindow.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 2023/06/15.
//

import Foundation
import UIKit

class ShopliveWindow: SLWindow {
    
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
            self.detectIfShopLiveViewisBeingAdded(view: view)
            return
        }
        if self.frame.size != UIScreen.main.bounds.size {
            return
        }
        super.addSubview(view)
    }
    
    private func findShopLiveTagView(view : UIView) -> [UIView]  {
        var subviews : [UIView] = view.subviews
        for subview in view.subviews {
            subviews.append(contentsOf: findShopLiveTagView(view: subview))
        }
        return subviews
    }
    
    private func detectIfShopLiveViewisBeingAdded(view : UIView){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let subViews = self.findShopLiveTagView(view: view)
            if subViews.map({ $0.tag }).contains(where: { $0 == shopLiveViewTag }) {
                self.blockAddSubView = false
                self.forceAddSubView(view)
            }
        }
    }
    
    private func forceAddSubView(_ view : UIView){
        super.addSubview(view)
    }
    
    
}
