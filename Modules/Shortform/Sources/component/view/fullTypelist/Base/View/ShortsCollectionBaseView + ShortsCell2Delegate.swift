//
//  ShortsCollectionBaseView + ShortsCell2Delegate.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2/4/24.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon


extension ShortsCollectionBaseView : ShortsCellDelegate {
    
    func onExternalEmitEvent(name: String, payload: [String : Any]?) {
        ShopLiveShortform.ShortsReceiveInterface.receiveHandler.handleOnEvents(command: name, payLoad: payload)
    }
    
    func didFinishPlayingShorts(cell: ShortsCell, data: ShopLiveShortform.ShortsModel?) {
        guard let data = data, viewModel.shortsMode == .preview else { return }
        
        if let nextIndex = viewModel.getNextShortItemIndex(data) {
            if let latestCell = viewModel.latestCell.latestCell {
                latestCell.stop()
            }
            if let srn = self.viewModel.shortsListData[safe : nextIndex]?.srn {
                viewModel.postActivePageNotification(srn: srn, index: nextIndex)
            }
            viewModel.postPreviewShowNotification()
            playPage(nextIndex)
        }
        else if let latestCell = viewModel.latestCell.latestCell {
            latestCell.replay()
        }
    }
    
    func didFinishLoadinWebView(indexPath: IndexPath) {
        if viewModel.fromPreview == false { return }
        if viewModel.isOnRotation { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let index = self.getCenterItemIndexPath()?.row, let srn = self.viewModel.shortsListData[safe: index]?.srn else { return }
            viewModel.postActivePageNotification(srn: srn, index: index)
        }
    }
    
    func requestJSRequestForExternalWebView(request: (ShopLiveShortform.ShortsWebInterface.SdkToWeb, [String : Any]?)) {
        ShopLiveShortform.BridgeInterface.sendShortsEvent(event: request.0.rawValue, parameter: request.1)
    }
    
    func requestCloseShortsDetailForHybrid(srn: String) {
        //이전에 날리던 노티피케이션
        //NotificationCenter.default.post(Notification(name: Notification.Name("closeShortsDetail"), userInfo: ["srn" : viewModel.shorts.srn]))
        //종착지는 BridgeInterface 쪽에 있음
        ShopLiveShortform.BridgeInterface.closeShortsDetail(srn: srn)
        
    }
    
    func requestShowShortsDetailForHybrid(srn: String) {
        //이전에 날리던 노티피케이션
        //NotificationCenter.default.post(Notification(name: Notification.Name("showShortsDetail"), userInfo: ["srn" : viewModel.shorts.srn]))
        //종착지는 BridgeInterface 쪽에 있음
        ShopLiveShortform.BridgeInterface.showShortsDetail(srn: srn)
    }
    
    func requestShowNewShortformFullScreen(bridgeModel: ShopLiveShortform.ShortsBridgeModel) {
        //이전 ShortsView에 있던 로직 가져와서 쓰면 됨
        let shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        if ShortFormConfigurationInfosManager.shared.shortsConfiguration.detailCollectionListAll {
            let requestModel = InternalShortformCollectionData()
            if let collectionQuery = bridgeModel.collectionQuery {
                requestModel.tags = collectionQuery.tags
                requestModel.tagSearchOperator = collectionQuery.tagSearchOperator
                requestModel.brands = collectionQuery.brands
                requestModel.shuffle = collectionQuery.shuffle
            }
            else {
                requestModel.tags = bridgeModel.relatedQuery?.tags
                requestModel.tagSearchOperator = bridgeModel.relatedQuery?.tagSearchOperator
                requestModel.brands = bridgeModel.relatedQuery?.brands
                requestModel.shuffle = bridgeModel.relatedQuery?.shuffle
            }
            ShopLiveShortform.playNormalFullScreen(shortsId: bridgeModel.shorts?.shortsId, shortsSrn: bridgeModel.shorts?.srn, requestModel: requestModel,shopliveSessionId: shopliveSessionId)
        }
        else {
            let requestModel = InternalShortformRelatedData()
            requestModel.tags = bridgeModel.relatedQuery?.tags
            requestModel.tagSearchOperator = bridgeModel.relatedQuery?.tagSearchOperator
            requestModel.brands = bridgeModel.relatedQuery?.brands
            requestModel.productId = bridgeModel.relatedQuery?.productId
            requestModel.name = bridgeModel.relatedQuery?.name
            requestModel.sku = bridgeModel.relatedQuery?.sku
            requestModel.url = bridgeModel.relatedQuery?.url
            requestModel.shuffle = bridgeModel.relatedQuery?.shuffle
            
            
            ShopLiveShortform.playRelatedFullScreen(shortsId: bridgeModel.shorts?.shortsId, shortsSrn: bridgeModel.shorts?.srn, requestModel: requestModel,shopliveSessionId: shopliveSessionId)
        }
    }
    
    func requestCloseShortform() {
        ShopLiveShortform.close()
    }
    
    func setSnapShotForWindow(image: UIImage?) {
        snapShotView.image = image
        snapShotView.isHidden = false
    }
    
    func getShortsListDataForV2ActivePage() -> [ShopLiveShortform.ShortsModel]? {
        return viewModel.getShortsListDataForV2ActivePage()
    }
    
}

extension ShortsCollectionBaseView {
    func shortsCommand(name: String, payload: [String : Any]?) {
        
        guard let webInterface = ShopLiveShortform.ShortsWebInterface.WebToSdk(rawValue: name) else { return }
        
        switch webInterface {
        case .ENABLE_SWIPE_DOWN:
            self.handleWebViewEnableSwipeDown()
        case .DISABLE_SWIPE_DOWN:
            self.handleWebviewDisableSwipeDown()
        case .ON_CLICK_PRODUCT_ITEM:
            self.handleWebViewOnClickProductItem(payload: payload)
        case .ON_CLICK_PRODUCT_BANNER:
            self.handleWebViewOnClickProductBanner(payload: payload)
        case .SET_VIDEO_MUTE:
            self.handleWebViewSetVideoMute(payload: payload)
        case .ON_CLICK_SHARE_BUTTON:
            self.handleWebViewOnClickShareBtn(payload: payload)
        case .ON_SHORTFORM_DETAIL_INITIALIZED:
            self.handleWebViewOnShortformDetailInitialized(payload: payload)
        case .CLOSE_SHORTFORM_DETAIL:
            self.handleWebViewCloseShortformDetail(payload: payload)
        default:
            break
        }
    }
    
    private func handleWebViewEnableSwipeDown() {
        guard viewModel.shortsMode == .detail else { return }
        shortsListView.isScrollEnabled = true
    }
    
    private func handleWebviewDisableSwipeDown() {
        shortsListView.isScrollEnabled = false
    }
    
    private func handleWebViewOnClickProductItem(payload : [String : Any]? ) {
        guard let shorts = payload?["shorts"] as? [String:Any],
              let product = payload?["product"] as? [String:Any] else { return }
        
        do {
            let srn = shorts["srn"] as? String
            let shortsId = shorts["shortsId"] as? String
            let productModel : Product = try Product.decode_SL(dictionary: product)
            viewModel.postMoveToProductPageNotification(shortsId: shortsId, srn: srn, productModel: productModel)
        }
        catch { }
    }
    
    private func handleWebViewOnClickProductBanner(payload : [String : Any]?) {
        guard let shorts = payload?["shorts"] as? [String : Any],
              let shortsDetailDict = shorts["shortsDetail"] as? [String : Any] else { return }
        do {
            let srn = shorts["srn"] as? String
            let shortsId = shorts["shortsId"] as? String
            let scheme = payload?["scheme"] as? String
            let shortsDetailModel : ShortsDetail = try ShortsDetail.decode_SL(dictionary: shortsDetailDict)
            viewModel.postMoveToProductBannerPageNotification(scheme: scheme, srn: srn, shortsId: shortsId, shortsDetailModel: shortsDetailModel)
        }
        catch {
            return
        }
    }
    
    private func handleWebViewSetVideoMute(payload : [String : Any]?) {
        guard let isMuted = payload?["mute"] as? Bool else { return }
        viewModel.isMuted = isMuted
        ShortFormConfigurationInfosManager.shared.setWhenMutedStart(isMuted: isMuted)
    }
    
    private func handleWebViewOnClickShareBtn(payload : [String : Any]?) {
        viewModel.postHandleShareNotification(payload: payload)
    }
    
    private func handleWebViewOnShortformDetailInitialized(payload : [String : Any]?) {
        if let srn = self.viewModel.currentShortsSrn, let index = self.viewModel.latestCell.indexPath?.row, self.viewModel.latestActivePageIndex != index {
            self.viewModel.latestActivePageIndex = index
            viewModel.postActivePageNotification(srn: srn, index: index)
        }
    }
    
    private func handleWebViewCloseShortformDetail(payload : [String : Any]?) {
        if self.viewModel.fromPreview {
            viewModel.postRequestShortsPreview(url: viewModel.currentOverlayUrl, srn: viewModel.currentShortsSrn)
        } else {
            viewModel.postCloseShortsDetail(srn: viewModel.currentShortsSrn)
            viewModel.latestCell.setLatest(latestCell: nil,indexPath: nil)
            ShopLiveShortform.close()
        }
    }
}

extension ShortsCollectionBaseView {
    func playPageTo(_ page: Int = 0) {
        let indexPath = IndexPath(row: page, section: 0)
        shortsListView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: false)
    }
    
    @objc func playPage(_ page: Int = 0) {
        let pageTo = CGPoint(x: 0, y: CGFloat(page) * self.frame.height)
        if viewModel.isViewAppeared {
            self.shortsListView.setContentOffset(pageTo, animated: false)
        } else {
            viewModel.scrollToPage = page
            if viewModel.shortsMode == .preview {
                shortsListView.setContentOffset(pageTo, animated: false)
            }
        }
    }
}
