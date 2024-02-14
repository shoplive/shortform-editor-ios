//
//  ListViewHideOptionModel.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/08/02.
//

import Foundation


/**
 기본 리스트 뷰 빌더에서 이거를 객체로 갖고 있고, 이 객체안의 값을 바꾸는 것으로 로직 변경했음
 따라서 public으로 고객사에게 보여줄 이유가 없음
 */
class ShopLiveListCellViewHideOptionModel {
    var isViewCountVisible : Bool = true
    var isBrandVisible : Bool = true
    var isTitleVisible : Bool = true
    var isProductCountVisible : Bool = true
    var isDescriptionVisible : Bool = true
}

