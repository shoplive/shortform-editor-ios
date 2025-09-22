//
//  ShopLivePlayerShareDelegate.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 1/30/24.
//

import Foundation

/// 공유하기 버튼, 커스텀 팝업을 만들기 위한 데이터를 받는 델리게이트
@objc public protocol ShopLivePlayerShareDelegate: AnyObject {
    @objc func handleShare(data: ShopLivePlayerShareData)
}


