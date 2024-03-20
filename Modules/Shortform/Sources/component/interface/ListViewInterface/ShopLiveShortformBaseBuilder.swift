//
//  ShopLiveShortformBaseBuilder.swift
//  matrix-shortform-ios
//
//  Created by sangmin han on 2023/04/30.
//

import Foundation
import UIKit


public enum ShopLiveTagSearchOperator : String {
    case AND
    case OR
}

protocol ShopLiveShortformListViewSettings {
    func setCardViewType(type : ShopLiveShortform.CardViewType)
    func enableSnap()
    func disableSnap()
    func enablePlayVideos()
    func disablePlayVideos()
    func scrollToTop()
    func setPlayOnlyWifi(isEnabled : Bool)
    func setCellSpacing(spacing : CGFloat)
    func setScrollContentOffset(offset : CGFloat)
    func getScrollContentOffset() -> CGPoint
    func setPlayableType(type : ShopLiveShortform.PlayableType)
    func setAPIRequestParamToModel(model : InternalShortformCollectionData?)
    func reloadItems()
    func setVisibleViewCount(isVisible : Bool)
    func setVisibleBrand(isVisible : Bool)
    func setVisibleTitle(isVisisble : Bool)
    func setVisibleProductCount(isVisible : Bool)
    func setVisibleDescription(isVisible : Bool)
    func setCellCornerRadius(radius : CGFloat)
    func setCellBackgroundColor(color : UIColor)
    func notifyViewRotated()
    func submit()
    
    
    func enableShuffle()
    func disableShuffle()
    func setHashTags(tags : [String]?, tagSearchOperator : ShopLiveTagSearchOperator?)
    func setBrands(brands : [String]?)
    func setSkus(skus : [String]?)
    func setShortsCollectionId(shortsCollectionId : String?)
}

public class ListViewBaseBuilder : ShopLiveShortformListViewSettings {
    
    internal var view : ShopLiveShortformBaseTypeView?
    private var tagsAndBrandsRequestParameterModel : InternalShortformCollectionData?
    private var cellViewHideOptionModel : ShopLiveListCellViewHideOptionModel = ShopLiveListCellViewHideOptionModel()
    
    public init(){
        
    }
    
    public final func setCardViewType(type: ShopLiveShortform.CardViewType) {
        view?.action(.setCardViewType(type))
    }
    public final func enableSnap() {
        view?.action(.enableSnap)
    }
    public final func disableSnap() {
        view?.action(.disableSnap)
    }
    public final func enablePlayVideos() {
        view?.action(.enablePlayVideos)
    }
    public final func disablePlayVideos() {
        view?.action(.disablePlayVideos)
    }
    public final func scrollToTop() {
        view?.action(.scrollToTop)
    }
    public final func setPlayOnlyWifi(isEnabled: Bool) {
        view?.action(.setPlayOnlyWifi(isEnabled))
    }
    public final func setCellSpacing(spacing: CGFloat) {
        view?.action(.setCellSpacing(spacing))
    }
    public final func setScrollContentOffset(offset : CGFloat) {
        view?.action(.setScrollContentOffset(offset))
    }
    public final func getScrollContentOffset() -> CGPoint {
        return view?.getScrollContentOffset() ?? .zero
    }
    public final func setPlayableType(type: ShopLiveShortform.PlayableType) {
        view?.action(.setPlayableType(type))
    }
    public final func reloadItems() {
        view?.action(.setTagsAndBrandsRequestParameterModel(makeApiRequestModel()))
        view?.action(.reloadItems)
    }
    
    public final func setCellBackgroundColor(color: UIColor) {
        view?.action(.setCellBackgroundColor(color))
    }
    
    public final func notifyViewRotated() {
        view?.action(.notifyViewRotated)
    }
    
    public final func submit() {
        guard let view = view else {
            fatalError("[ShopLiveShortformSDK] view is nil, must build view first")
        }
        view.action(.notifyViewRotated)
        view.action(.setCellViewHideOptionModel(cellViewHideOptionModel))
        view.action(.initialLizeShortsSetting)
    }
    
    //MARK: - CellViewHideOptions
    public final func setVisibleViewCount(isVisible: Bool) {
        self.cellViewHideOptionModel.isViewCountVisible = isVisible
        view?.action(.setCellViewHideOptionModel(cellViewHideOptionModel))
    }
    public final func setVisibleBrand(isVisible: Bool) {
        self.cellViewHideOptionModel.isBrandVisible = isVisible
        view?.action(.setCellViewHideOptionModel(cellViewHideOptionModel))
    }
    
    public final func setVisibleTitle(isVisisble: Bool) {
        self.cellViewHideOptionModel.isTitleVisible = isVisisble
        view?.action(.setCellViewHideOptionModel(cellViewHideOptionModel))
    }
    
    public final func setVisibleProductCount(isVisible: Bool) {
        self.cellViewHideOptionModel.isProductCountVisible = isVisible
        view?.action(.setCellViewHideOptionModel(cellViewHideOptionModel))
    }
    
    public final func setVisibleDescription(isVisible: Bool) {
        self.cellViewHideOptionModel.isDescriptionVisible = isVisible
        view?.action(.setCellViewHideOptionModel(cellViewHideOptionModel))
    }
    
    public final func setCellCornerRadius(radius: CGFloat) {
        view?.action(.setCellRadius(radius))
    }
}

//MARK: -APIRequestParameter setter functions
extension ListViewBaseBuilder {
    internal func makeApiRequestModel() -> InternalShortformCollectionData{
        if tagsAndBrandsRequestParameterModel == nil {
            self.tagsAndBrandsRequestParameterModel = InternalShortformCollectionData()
        }
        return self.tagsAndBrandsRequestParameterModel!
    }
    
    public final func enableShuffle() {
        let model = makeApiRequestModel()
        model.shuffle = true
        self.setAPIRequestParamToModel(model: model)
    }
    
    public final func disableShuffle(){
        let model = makeApiRequestModel()
        model.shuffle = false
        self.setAPIRequestParamToModel(model: model)
    }

    public final func setHashTags(tags: [String]?, tagSearchOperator: ShopLiveTagSearchOperator?) {
        let model = makeApiRequestModel()
        model.tags = tags
        model.tagSearchOperator = tagSearchOperator?.rawValue
        self.setAPIRequestParamToModel(model: model)
    }
    
    public final func setBrands(brands: [String]?) {
        let model = makeApiRequestModel()
        model.brands = brands
        self.setAPIRequestParamToModel(model: model)
    }
    
    public final func setSkus(skus: [String]?) {
        let model = makeApiRequestModel()
        model.skus = skus
        self.setAPIRequestParamToModel(model: model)
    }
    
    public final func setShortsCollectionId(shortsCollectionId : String?) {
        let model = makeApiRequestModel()
        model.shortsCollectionId = shortsCollectionId
        self.setAPIRequestParamToModel(model: model)
    }
    
    internal func setAPIRequestParamToModel(model : InternalShortformCollectionData?){
        view?.action(.setTagsAndBrandsRequestParameterModel(model))
    }
    
}
