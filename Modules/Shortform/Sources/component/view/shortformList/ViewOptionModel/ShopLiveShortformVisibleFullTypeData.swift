//
//  ShopLiveShortformDetailViewHideOptionModel.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/08/21.
//

import Foundation


public struct ShopLiveShortformVisibleFullTypeData {
    public var isBookMarkVisible : Bool = true
    public var isShareButtonVisible : Bool = true
    public var isCommentButtonVisible : Bool = true
    public var isLikeButtonVisible : Bool = true
    
    public init(isBookMarkVisible: Bool = true, isShareButtonVisible: Bool = true, isCommentButtonVisible: Bool = true, isLikeButtonVisible: Bool = true) {
        self.isBookMarkVisible = isBookMarkVisible
        self.isShareButtonVisible = isShareButtonVisible
        self.isCommentButtonVisible = isCommentButtonVisible
        self.isLikeButtonVisible = isLikeButtonVisible
    }
    
    
    internal func toDict(forceBookMarkVisible : Bool? = nil, forceShareVisible : Bool? = nil, forceCommentVisible : Bool? = nil, forceLikeVisible : Bool? = nil, forceBackBtnVisible : Bool? = nil ) -> [String : Bool] {
        return ["bookmark" : forceBookMarkVisible != nil ? forceBookMarkVisible! : isBookMarkVisible,
                "shareButton" : forceShareVisible != nil ? forceShareVisible! : isShareButtonVisible,
                "commentButton" : forceCommentVisible != nil ? forceCommentVisible! : isCommentButtonVisible,
                "likeButton" : forceLikeVisible != nil ? forceLikeVisible! : isLikeButtonVisible,
                "backButton" : forceBackBtnVisible != nil ? forceBackBtnVisible! : true]
    }
}
