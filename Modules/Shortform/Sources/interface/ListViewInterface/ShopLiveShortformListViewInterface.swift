//
//  ShopLiveShortformListViewInterface.swift
//  matrix-shortform-ios
//
//  Created by sangmin han on 2023/04/28.
//

import Foundation
import UIKit
import AVKit

public protocol ShopLiveShortformListViewDelegate : NSObject {
    func onListViewError(error : Error)
}


extension ShopLiveShortform {
    
    public enum CardViewType { 
        case type0
        case type1
        case type2
    }
    
    public enum ListViewType {
        case vertical
        case horizontal
    }
    
    public enum PlayableType {
        case FIRST
        case CENTER
        case ALL
    }
    
    
    /**
     1 단 세로 리스트 뷰 빌더
        타입 세팅후 .getView() -> UIView 사용
     - parameters:
       - cardViewType : ShopLiveShortform.CardViewTypw
       - enableSnap : Bool
       - enablePlayVideo : Bool
       - playOnlyOnWifi : Bool
       - cellSpacing : CGFloat (default : 20)
       - viewCountVisibility : Bool (default : true )
     */
    public class CardTypeViewBuilder : ListViewBaseBuilder {
        private var currentListViewType : ShopLiveShortform.ListViewType = .vertical
       
       @discardableResult
        public func build(cardViewType : ShopLiveShortform.CardViewType = .type1,
                          listViewDelegate : ShopLiveShortformListViewDelegate? = nil,
                          enableSnap : Bool = false,
                          enablePlayVideo : Bool = true,
                          playOnlyOnWifi : Bool = false,
                          cellSpacing : CGFloat = 8,
                          cellRadius : CGFloat = 16,
                          viewCountVisibility : Bool = true,
                          avAudioSessionCategoryOptions : AVAudioSession.CategoryOptions? = nil) -> Self {
            
            view = ShopLiveShortformCardTypeView(cardViewType: cardViewType,
                                                 listViewDelegate: listViewDelegate,
                                                 tagsAndBrandsRequestParameterModel: makeApiRequestModel(), avAudioSessionCategoryOptions: avAudioSessionCategoryOptions)
            self.setCardViewType(type: cardViewType)
            self.setVisibleViewCount(isVisible: viewCountVisibility)
            if enableSnap {
                self.enableSnap()
            }
            else {
                self.disableSnap()
            }
            
            if enablePlayVideo {
                self.enablePlayVideos()
            }
            else {
                self.disablePlayVideos()
            }
            self.setPlayOnlyWifi(isEnabled: playOnlyOnWifi)
            self.setCellSpacing(spacing: cellSpacing)
            self.setCellCornerRadius(radius: cellRadius)
            return self
        }
        
        public func getView() -> UIView {
            guard let view = view else {
                fatalError("[ShopLiveShortformSDK] view is nil, must build view first")
            }
            return view
        }
    
    }
    
    /**
        타입 세팅후 .getView() -> UIView 사용
     - parameters:
       - cardViewType : ShopLiveShortform.CardViewType
       - listViewType : ShopLiveShortform.ListViewType (.vertical, .horizontal)
       - playableType : ShopLiveShortform.PlayableType (onlyFor .horizontal type )
       - enableSnap : Bool
       - enablePlayVideo : Bool
       - playOnlyOnWifi : Bool
       - cellSpacing : CGFloat (default : 20)
       - viewCountVisibility ; Bool (default : true )
     */
    public class ListViewBuilder : ListViewBaseBuilder {
        private var currentListViewType : ShopLiveShortform.ListViewType = .vertical
        
       @discardableResult
        public func build(cardViewType : ShopLiveShortform.CardViewType = .type1,
                          listViewType : ShopLiveShortform.ListViewType,
                          playableType : ShopLiveShortform.PlayableType = .FIRST,
                          listViewDelegate : ShopLiveShortformListViewDelegate? = nil,
                          enableSnap : Bool = false,
                          enablePlayVideo : Bool = true,
                          playOnlyOnWifi : Bool = false,
                          cellSpacing : CGFloat = 8,
                          cellRadius : CGFloat = 12,
                          viewCountVisibility : Bool = true,
                          avAudioSessionCategoryOptions : AVAudioSession.CategoryOptions? = nil) -> Self {
            
            if listViewType == .vertical {
                view = ShopLiveShortformVerticalTypeView(cardViewType: cardViewType, listViewDelegate: listViewDelegate,
                                                         tagsAndBrandsRequestParameterModel: makeApiRequestModel(), avAudioSessionCategoryOptions: avAudioSessionCategoryOptions)
            }
            else {
                view = ShopLiveShortformHorizontalTypeView(cardViewType: cardViewType, listViewDelegate: listViewDelegate,
                                                           tagsAndBrandsRequestParameterModel: makeApiRequestModel(), avAudioSessionCategoryOptions: avAudioSessionCategoryOptions)
            }
            
            self.setCardViewType(type: cardViewType)
            self.setPlayableType(type: playableType)
            self.setVisibleViewCount(isVisible: viewCountVisibility)
            
            if enableSnap {
                self.enableSnap()
            }
            else {
                self.disableSnap()
            }
            
            if enablePlayVideo {
                self.enablePlayVideos()
            }
            else {
                self.disablePlayVideos()
            }
            self.setPlayOnlyWifi(isEnabled: playOnlyOnWifi)
            self.setCellSpacing(spacing: cellSpacing)
            self.setCellCornerRadius(radius: cellRadius)
            return self
        }
        
        public func getView() -> UIView {
            guard let view = view else {
                fatalError("[ShopLiveShortformSDK] view is nil, must build view first")
            }
            return view
        }
        
    }
}
