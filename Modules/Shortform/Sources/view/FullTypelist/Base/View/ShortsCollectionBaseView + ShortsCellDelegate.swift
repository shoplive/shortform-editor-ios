//
//  ShortsCollectionBaseView + ShortsDelegate.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/29/23.
//

import Foundation
import UIKit
import ShopLiveSDKCommon


extension ShortsCollectionBaseView : ShortsCellDelegate {
    func getShortsListDataForV2ActivePage() -> [ShopLiveShortform.ShortsModel]? {
        return viewModel.getShortsListDataForV2ActivePage()
    }
    
    func didFinishdPlayingShorts(cell: ShopLiveShortform.ShortsCell, item: ShopLiveShortform.ShortsModel?) {
        guard let item = item else { return }
        guard viewModel.shortsMode == .preview else { return }
        
        if let nextItemindex = viewModel.getNextShortItemIndex(item) {
            if let latestCell = viewModel.latestCell.latestCell {
                latestCell.stop()
            }
            if let index = self.getCenterItemIndexPath()?.row, let srn = self.viewModel.shortsListData[safe : index]?.srn {
                viewModel.postActivePageNotification(srn: srn, index: index)
            }
            viewModel.postPreviewShowNotification()
            playPage(nextItemindex)
        }
        else if let latestCell = viewModel.latestCell.latestCell {
            latestCell.replay()
        }
    }
    
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
    
    func didFinishLoadingWebView() {
        if viewModel.fromPreview == false { return }
        if viewModel.isOnRotation { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let index = self.getCenterItemIndexPath()?.row, let srn = self.viewModel.shortsListData[safe: index]?.srn else { return }
            viewModel.postActivePageNotification(srn: srn, index: index)
        }
    }
    
    func shortsCommand(name: String, payload: [String : Any]?) {
        guard let webInterface = ShopLiveShortform.ShortsWebInterface.WebToSdk(rawValue: name) else { return }
        switch webInterface {
        case .ENABLE_SWIPE_DOWN:
            if viewModel.shortsMode == .detail {
                shortsListView.isScrollEnabled = true
            }
            break
        case .DISABLE_SWIPE_DOWN:
            shortsListView.isScrollEnabled = false
            break
        case .ON_CLICK_PRODUCT_ITEM:
            self.handleON_CLICK_PRODUCT_ITEM(payload: payload)
            break
        case .ON_CLICK_PRODUCT_BANNER:
            self.handleON_CLICK_PRODUCT_BANNER(payload : payload)
            break
        case .SET_VIDEO_MUTE:
            guard let isMuted = payload?["mute"] as? Bool else {
                return
            }
            viewModel.isMuted = isMuted
            ShortFormConfigurationInfosManager.shared.setWhenMutedStart(isMuted: isMuted)
            break
        case .ON_CLICK_SHARE_BUTTON:
            viewModel.postHandleShareNotification(payload: payload)
            break
        case .ON_SHORTFORM_DETAIL_INITIALIZED:
            if let srn = self.viewModel.currentShortsSrn, let index = self.viewModel.latestCell.indexPath?.row, self.viewModel.latestActivePageIndex != index {
                self.viewModel.latestActivePageIndex = index
                viewModel.postActivePageNotification(srn: srn, index: index)
            }
            break
        case .CLOSE_SHORTFORM_DETAIL:
            if self.viewModel.fromPreview {
                viewModel.postRequestShortsPreview(url: viewModel.currentOverlayUrl, srn: viewModel.currentShortsSrn)
            } else {
                viewModel.postCloseShortsDetail(srn: viewModel.currentShortsSrn)
                viewModel.latestCell.setLatest(latestCell: nil,indexPath: nil)
                ShopLiveShortform.close()
            }
            break
        default:
            break
        }
    }
    
    func handleON_CLICK_PRODUCT_ITEM(payload : [String : Any]?){
        guard let shorts = payload?["shorts"] as? [String:Any],
              let product = payload?["product"] as? [String:Any] else { return }
        do {
            let srn = shorts["srn"] as? String
            let shortsId = shorts["shortsId"] as? String
            let productModel : Product = try Product.decode_SL(dictionary: product)
            viewModel.postMoveToProductPageNotification(shortsId: shortsId, srn: srn, productModel: productModel)
        }
        catch {
            return
        }
    }
    
    func handleON_CLICK_PRODUCT_BANNER(payload : [String : Any]?){
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
    
}
