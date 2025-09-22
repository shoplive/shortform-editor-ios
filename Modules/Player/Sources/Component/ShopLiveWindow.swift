//
//  ShopLiveWindow.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 2023/06/15.
//

import Foundation
import UIKit

public class ShopliveWindow: SLWindow {
    
    private var blockAddSubView: Bool = false
    private var timer: Timer?
    private var dispatchSource: DispatchSourceTimer?
    
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
    
    
    private var blackLists: Set<UIView> = []
    
    public override func addSubview(_ view: UIView) {
        
        //최초 preview 혹은 play시 liveStreamViewController 넣기 위해서
        if self.subviews.count == 0 && String(describing: view).contains("UITransitionView") {
            super.addSubview(view)
            return
        }
        //stopPictureInPicture 함수 불리면서 blockAddSubView 타이머 돌림
        // 이변수 true인 동안에 ShopLiveViewComponent가 아닌것이 들어오면 blackList처리
        if self.blockAddSubView == true {
            self.detectIfShopLiveViewisBeingAdded(view: view)
            return
        }
        //pip상태의 경우 모든 뷰 전부 블락킹
        if self.frame.size != UIScreen.main.bounds.size {
            return
        }
        //블랙리스트 뷰는 ShopLiveWindow 초기화 될때까지 모두 블락킹
        if blackLists.contains(where: { $0 === view }) {
            return
        }
        super.addSubview(view)
    }
    
    private func findShopLiveTagView(view: UIView) -> [UIView]  {
        var subviews: [UIView] = view.subviews
        for subview in view.subviews {
            subviews.append(contentsOf: findShopLiveTagView(view: subview))
        }
        return subviews
    }
    
    private func detectIfShopLiveViewisBeingAdded(view: UIView){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let subViews = self.findShopLiveTagView(view: view)
            if subViews.map({ $0.tag }).contains(where: { $0 == shopLiveViewTag }) {
                self.blockAddSubView = false
                self.forceAddSubView(view)
                return
            }
            else {
                self.blackLists.insert(view)
            }
        }
    }
    
    public func forceAddSubView(_ view: UIView){
        super.addSubview(view)
    }
    
}
