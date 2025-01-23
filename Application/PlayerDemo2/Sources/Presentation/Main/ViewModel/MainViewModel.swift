//
//  MainViewModel.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

struct MainViewModelActions {
    /// --- 사이드 메뉴
    // 옵션 선택
    let showOptionSetting: () -> Void
    // 쿠폰 적용
    let showCouponResponseSetting: () -> Void
    
    /// --- 홈화면
    // 방송 선택
    let showBroadCastList: () -> Void
    // 재생
    let showVideoPlayer: () -> Void
    
    let showUserInfo: () -> Void
}


class MainViewModel {
    
    private let useCase: MainUseCase
    private let actions: MainViewModelActions?
    
    private(set) var keyset: ShopLiveKeySet?
    private(set) var items: [String] = ["CampaignInfoCell", "UserInfoCell"]
    
    init(useCase: MainUseCase, actions: MainViewModelActions? = nil) {
        self.useCase = useCase
        self.actions = actions
    }
    
    func controlItems(action: ItemAction, value: String, at: Int?) {
        switch action {
        case .insert:
            if let at {
                items.insert(value, at: at)
                return
            }
            
            items.append(value)
            break
        case .delete:
            if let at, items.count-1 >= at {
                items.remove(at: at)
                return
            }
        }
    }
    
    func settingShopLiveKeySet(keySet: ShopLiveKeySet) {
        self.keyset = keySet
    }
    
    func showUserInfoViewController() {
        actions?.showUserInfo()
    }
}
