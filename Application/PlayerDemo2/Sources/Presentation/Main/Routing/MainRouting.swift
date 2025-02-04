//
//  MainRouting.swift
//  PlayerDemo2Tests
//
//  Created by Tabber on 1/31/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

protocol MainRouting: NSObjectProtocol {
    /// --- 사이드 메뉴
    // 옵션 선택
    func showOptionSetting()
    // 쿠폰 적용
    func showCouponResponseSetting()
    
    /// --- 홈화면
    // 방송 선택
    func showCampaigns()
    // 재생
    func showVideoPlayer()
    
    func showUserInfo()
}
