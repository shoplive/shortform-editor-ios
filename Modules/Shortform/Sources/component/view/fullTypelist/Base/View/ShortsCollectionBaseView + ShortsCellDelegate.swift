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
    
    func onExternalEmitEvent(webView : ShortsWebView?, name: String, payload: [String : Any]?) {
        var jsonString : String?
        if let payload = payload {
            jsonString = payload.toJSONString_SL()
        }
        if let webView = webView {
            let webViewWrapper = ShopLiveWebViewWrapper(webView: webView)
            shortformDelegate?.onEvent?(messenger: webViewWrapper, command: name, payload: jsonString)
        }
        else {
            shortformDelegate?.onEvent?(messenger: nil, command: name, payload: jsonString)
        }
    }
    
    func didFinishPlayingShorts(cell: ShortsCell, data: SLShortsModel?) {
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
        viewModel.webViewLoadedFinished(at: indexPath)
        if viewModel.fromPreview == false { return }
        if viewModel.isOnRotation { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let index = self.getCenterItemIndexPath()?.row, let srn = self.viewModel.shortsListData[safe: index]?.srn else { return }
            viewModel.postActivePageNotification(srn: srn, index: index)
        }
    }
    
    func requestJSRequestForExternalWebView(request: (ShopLiveShortform.ShortsWebInterface.SdkToWeb, [String : Any]?)) {
        if case .EXTERNAL_COMMAND(let command) = request.0 {
            ShopLiveShortform.BridgeInterface.sendShortsEvent(event: command, parameter: request.1)

        }
        else {
            ShopLiveShortform.BridgeInterface.sendShortsEvent(event: request.0.key, parameter: request.1)
        }
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
        let shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        
        let requestModel = InternalShortformCollectionDto()
        if let collectionQuery = bridgeModel.collectionQuery {
            requestModel.tags = collectionQuery.tags
            requestModel.tagSearchOperator = collectionQuery.tagSearchOperator
            requestModel.brands = collectionQuery.brands
            requestModel.shuffle = collectionQuery.shuffle
            requestModel.delegate = self.shortformDelegate
        }
        else {
            requestModel.tags = bridgeModel.relatedQuery?.tags
            requestModel.tagSearchOperator = bridgeModel.relatedQuery?.tagSearchOperator
            requestModel.brands = bridgeModel.relatedQuery?.brands
            requestModel.shuffle = bridgeModel.relatedQuery?.shuffle
            requestModel.delegate = self.shortformDelegate
        }
        
        ShopLiveShortform.playNormalFullScreen(shortsId: bridgeModel.shorts?.shortsId, shortsSrn: bridgeModel.shorts?.srn, requestModel: requestModel,shopliveSessionId: shopliveSessionId)
    }
    
    func requestCloseShortform() {
        ShopLiveShortform.close()
    }
    
    func requestRemoveShortform(shortsId: String) {
        viewModel.removeShortformByShortsId(shortsIdOrSrn: shortsId, cv: self.shortsListView)
    }
    
    func setSnapShotForWindow(image: UIImage?) {
        if let size = image?.size {
           animateSnapshotSize(size: size)
        }
        snapShotView.image = image
        setSnapShotViewHidden(animate: false, isHidden: image == nil ? true : false)
    }
    
    private func animateSnapshotSize(size : CGSize){
        if UIDevice.current.userInterfaceIdiom == .pad {
            setSnapShotLayoutForIpad()
        }
        else {
            if let resizeMode = ShopLiveShortform.detailPlayerResizeMode {
                if resizeMode == .CENTER_CROP {
                   setSnapShotLayoutForIphoneCenterCrop()
                }
                else {
                    setSnapShotLayoutWithRatioSize(ratioSize: size)
                }
            }
            else {
                setSnapShotLayoutForIphoneCenterCrop()
            }
        }
    }
    
    func getShortsListDataForV2ActivePage() -> [SLShortsModel]? {
        return viewModel.getShortsListDataForV2ActivePage()
    }
    
    func getCurrentOnViewIndexPath() -> IndexPath? {
        if shortsListView.indexPathsForVisibleItems.count == 1 ,
           let indexPath = shortsListView.indexPathsForVisibleItems.first {
            return indexPath
        }
        else {
            return nil 
        }
    }
   
    /**
     v2 override
     */
    @objc func requestSetCustomShortformForV2(cell: ShortsCell, shortsId: String) {
        
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
            let productModel : SLProduct = try SLProduct.decode_SL(dictionary: product)
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
            let shortsDetailModel : SLShortsDetail = try SLShortsDetail.decode_SL(dictionary: shortsDetailDict)
            viewModel.postMoveToProductBannerPageNotification(scheme: scheme, srn: srn, shortsId: shortsId, shortsDetailModel: shortsDetailModel)
        }
        catch {
            return
        }
    }
    
    private func handleWebViewSetVideoMute(payload : [String : Any]?) {
        guard let isMuted = payload?["mute"] as? Bool else { return }
        viewModel.setIsMuted(isMuted: isMuted)
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
