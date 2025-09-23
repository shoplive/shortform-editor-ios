//
//  ShortFormConfigurationInfoModel.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/05/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon


struct ShortFormUploadConfigurationInfoModel {
    var baseUrl : String = ""
    var shortformApiEndpoint : String = ""
    var detailUrl : String = ""
    var previewEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    let previewFloatingOffset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    let resolution = CGSize(width: 9, height: 16)
    private var _previewMaxsSize : CGFloat?
    var previewMaxSize : CGFloat {
        get {
            if let _previewMaxsSize = _previewMaxsSize {
                return _previewMaxsSize
            }
            else {
                return 180.0 * (resolution.width / resolution.height)
            }
        }
    }
    var previewScale: CGFloat {
        return previewMaxSize / (UIScreen.isLandscape_SL ? UIScreen.main.bounds.height : UIScreen.main.bounds.width)
    }
//    var previewPosition : ShopLiveShortform.PreviewPosition = .bottomRight
    var detailApiInitializeCount: Int = 3
    var detailApiPaginationCount: Int = 10
    var listApiInitializeCount: Int = 10
    var listApiPaginationCount: Int = 10
    var previewUseCloseButton: Bool = true
    var enabledSwipeOut: Bool = true
    var mutedWhenStart : Bool = false
    var mixWithOthers : Bool = true
    var detailCollectionListAll : Bool = true
    var eventTraceEndpoint : String = ""
    var ugcUrl: String = ""
    
    
    
    init(shortformApiEndPoint : String?, datas : ShortsSettingConfigSDK?){
        self.init(detailUrl: datas?.detailUrl,
                  shortformApiEndPoint: shortformApiEndPoint,
                  previewEdgeInsets: (left: datas?.previewMargin?.left, top: datas?.previewMargin?.top, right: datas?.previewMargin?.right, bottom: datas?.previewMargin?.bottom),
                  previewPosition: datas?.previewPosition,
                  detailApiInitializeCount: datas?.detailApiInitializeCount,
                  detailApiPaginationCount: datas?.detailApiPaginationCount,
                  listApiInitializeCount: datas?.listApiInitializeCount,
                  listApiPaginationCount: datas?.listApiPaginationCount,
                  previewUseCloseButton: datas?.previewUseCloseButton,
                  enabledSwipeOut: datas?.enabledSwipeOut,
                  mutedWhenStart: datas?.mutedWhenStart,
                  mixWithOthers: datas?.mixWithOthers,
                  previewMaxSize: datas?.previewMaxSize,
                  ugcUrl: datas?.ugcUrl)
    }
    
    init(detailUrl: String?, shortformApiEndPoint : String?, previewEdgeInsets: (left : CGFloat?, top : CGFloat?, right : CGFloat?, bottom :CGFloat?),
        previewPosition: String?, detailApiInitializeCount: Int?, detailApiPaginationCount: Int?,
         listApiInitializeCount: Int?, listApiPaginationCount: Int?, previewUseCloseButton: Bool?, enabledSwipeOut: Bool?,
         mutedWhenStart: Bool?, mixWithOthers: Bool?, previewMaxSize : CGFloat?, ugcUrl: String?) {
        
        if let detailUrl = detailUrl {
            self.detailUrl = detailUrl
        }
        
        if let shortformApiEndPoint = shortformApiEndPoint {
            self.shortformApiEndpoint = shortformApiEndPoint
        }
        
        var _previewEdgeInset = self.previewEdgeInsets
        
        if let top = previewEdgeInsets.top {
            _previewEdgeInset.top = top
        }
        if let left = previewEdgeInsets.left {
            _previewEdgeInset.left = left
        }
        if let right = previewEdgeInsets.right {
            _previewEdgeInset.right = right
        }
        if let bottom = previewEdgeInsets.bottom {
            _previewEdgeInset.bottom = bottom
        }
        self.previewEdgeInsets = _previewEdgeInset
        
        if let previewMaxSize = previewMaxSize {
            self._previewMaxsSize = previewMaxSize * (resolution.width / resolution.height)
        }
        if let detailApiInitializeCount = detailApiInitializeCount {
            self.detailApiInitializeCount = detailApiInitializeCount
        }
        if let detailApiPaginationCount = detailApiPaginationCount {
            self.detailApiPaginationCount = detailApiPaginationCount
        }
        if let listApiInitializeCount = listApiInitializeCount {
            self.listApiInitializeCount = listApiInitializeCount
        }
        if let listApiPaginationCount = listApiPaginationCount {
            self.listApiPaginationCount = listApiPaginationCount
        }
        if let previewUseCloseButton = previewUseCloseButton {
            self.previewUseCloseButton = previewUseCloseButton
        }
        if let enabledSwipeOut = enabledSwipeOut {
            self.enabledSwipeOut = enabledSwipeOut
        }
        if let mutedWhenStart = mutedWhenStart {
            self.mutedWhenStart = mutedWhenStart
        }
        if let mixWithOthers = mixWithOthers {
            self.mixWithOthers = mixWithOthers
        }
        if let ugcUrl = ugcUrl {
            self.ugcUrl = ugcUrl
        }
        
    }
    
}
