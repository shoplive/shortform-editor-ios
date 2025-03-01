//
//  MainRouting.swift
//  PlayerDemo2Tests
//
//  Created by Tabber on 1/31/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

protocol MainRouting: NSObjectProtocol {
    
    // 사이드메뉴
    func showSideMenuViewController()
    
    /// --- 홈화면
    // 방송 선택
    func showCampaigns()
    // 재생
    func showVideoPlayer()
    
    func showUserInfo()
}
