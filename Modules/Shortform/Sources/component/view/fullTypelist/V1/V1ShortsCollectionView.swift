//
//  V1ShortsCollectionView.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/29/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon




class V1ShortsDetailCollectionView : ShortsCollectionBaseView {
    typealias ShortsApiType = V1ShortsCollectionViewModel.ShortsApiType
    
    
    private var errorView : FullTypeErrorView = {
        let view = FullTypeErrorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
     var childViewModel : V1ShortsCollectionViewModel {
        return self.viewModel as! V1ShortsCollectionViewModel
    }
    
    
    //normal show
    internal init(reference : String?, shortsMode : ShopLiveShortform.ShortsMode, showType : ShortsApiType, shortsId : String?, shortsSrn : String?, normalRequestParameterModel : InternalShortformCollectionDto?,viewProvideType : ShortsCollectionBaseViewModel.ViewProvidedType,shopliveSessionId : String?){
        super.init(viewmodel: V1ShortsCollectionViewModel(shopliveSessionId: shopliveSessionId, shortformDelegate: normalRequestParameterModel?.delegate)
                   ,shortformDelegate: normalRequestParameterModel?.delegate)
        childViewModel.latestActivePageIndex = -1
        childViewModel.shortsMode = shortsMode
        childViewModel.currentApiType = showType
        childViewModel.viewProvideType = viewProvideType
        
        self.childViewModel.collectionRequestData = normalRequestParameterModel
        self.childViewModel.loadShortsPlayCollection(isOnInitialLaunch : true, reference: reference,onPagination: false, shortsId: shortsId, reset: true) { [weak self] error in
            guard let self = self else { return }
            if self.handleInitializeError(error: error) == false {
                return
            }
            self.shortsListView.isScrollEnabled = self.viewModel.isSwipable
            ShortformNativeOnEventsManager.sendNativeOnEvents(delegate : self.shortformDelegate, command: .detail_on_player_shown, payload: nil, shortsId: nil, shortsDetail: nil)
            ShortformEventTraceManager.processDetailOnPlayerShow(shortsCollectionSrn: self.getCurrentShortsSrn(), shopliveSessionId: shopliveSessionId)
        }
    }
    
    //related show
    internal init(shortsMode : ShopLiveShortform.ShortsMode,showType : ShortsApiType, reference : String?, shortsId : String?, shortsSrn : String?, relatedRequestModel : InternalShortformRelatedDTO?, shortsList : [SLShortsModel], shortsCollection : SLShortsCollectionModel?, viewProvideType : ShortsCollectionBaseViewModel.ViewProvidedType,shopliveSessionId : String?, previewOptionDTO : ShortformPreviewOptionDTO?) {
        super.init(viewmodel: V1ShortsCollectionViewModel(shopliveSessionId: shopliveSessionId, shortformDelegate: relatedRequestModel?.delegate)
                   ,shortformDelegate: relatedRequestModel?.delegate)
        self.backgroundColor = .clear
        childViewModel.latestActivePageIndex = -1
        childViewModel.shortsMode = shortsMode
        if shortsMode == .preview {
            childViewModel.setPreviewOptionDTO(dto: previewOptionDTO)
        }
        childViewModel.currentApiType = showType
        childViewModel.shortsCollection = shortsCollection
        childViewModel.isFullNative = shortsList.isEmpty // shortsList가 empty가 아니라면 bridge를 통해서 넘어온 데이터 이므로 풀 네이티브 가 아님.
        childViewModel.relatedRequestData = relatedRequestModel
        childViewModel.viewProvideType = viewProvideType
        if shortsMode == .preview  && shortsList.count == 0 {//풀 네이트브여서 바로 프리뷰를 킨 경우
            childViewModel.loadShortsRelatedCollection(isOnInitialLaunch : true, reference: nil, onPagination: false, shortsId: shortsId, shortsSrn: shortsSrn, reset: true) { [weak self] error in
                DispatchQueue.main.async { [weak self] in
                    self?.backgroundColor = .black
                }
                if self?.handleInitializeError(error: error) == false {
                    return
                }
                ShortformEventTraceManager.processPreviewShownHidden(shortsCollectionSrn: self?.getPreviewEventTraceSrn(),
                                                                     isShown: true, isClick: false, shopliveSessionId: shopliveSessionId)
                ShortformNativeOnEventsManager.sendNativeOnEvents(delegate: self?.shortformDelegate, command: .preview_shown, payload: nil, shortsId: shortsId, shortsDetail: self?.viewModel.shortsListData.first?.shortsDetail)
              
            }
           
        }
        else if shortsMode == .preview && shortsList.count != 0 { //bridge interface통해서 들어온 경우
            self.backgroundColor = .black
            self.childViewModel.appendShortsListData(shortsList,reset: true)
        }
        else {
            childViewModel.loadShortsRelatedCollection(isOnInitialLaunch : true, reference: nil, onPagination: false, shortsId: shortsId, shortsSrn: shortsSrn, reset: true) { [weak self] error in
                DispatchQueue.main.async { [weak self] in
                    self?.backgroundColor = .black
                }
                if self?.handleInitializeError(error: error) == false {
                    return
                }
                ShortformNativeOnEventsManager.sendNativeOnEvents(delegate: self?.shortformDelegate,command: .detail_on_player_shown, payload: nil, shortsId: nil, shortsDetail: nil)
                ShortformEventTraceManager.processDetailOnPlayerShow(shortsCollectionSrn: self?.getCurrentShortsSrn(), shopliveSessionId: shopliveSessionId)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ShopLiveLogger.memoryLog("V1ShortsCollectionView Deinited")
    }
    
    override func setPreviewToDetailMaintainTimeInfo() {
        if let cell = self.shortsListView.visibleCells.first as? ShortsCell {
            childViewModel.setVideoCurrentTimeWhenPreviewTapped(time: cell.getCurrentVidoeTime())
            childViewModel.setVideoShortsIdWhenPreviewTapped()
        }
    }
    
    override func viewTappedInPreviewMode(reset: Bool, shortsId: String?, srn: String?, completion: (() -> ())? = nil) {
        let config = ShortFormConfigurationInfosManager.shared.shortsConfiguration
        if reset == false { return }
//        viewModel.latestCell.latestCell?.stop()
        childViewModel.removeAllWebViewLists()
//        viewModel.latestCell.setLatest()
        viewModel.didAnimatePreviewToFullScreen = true
        self.viewModel.latestActivePageIndex = -1
        childViewModel.setCanUseShortformCurrentTimeDTO(canUse: true)
        if config.previewDetailCollectionListAll {
            viewModel.currentApiType = .normal
            self.childViewModel.loadShortsPlayCollection(reference: nil,onPagination: false, shortsId: shortsId, reset: true) { [weak self] _ in
                guard let self = self else { return }
                self.shortsListView.isScrollEnabled = self.viewModel.isSwipable
                self.viewModel.fromPreview = true
                self.shortsListView.contentOffset.y = 0
                completion?()
            }
        }
        else {
            viewModel.currentApiType = .related
            self.childViewModel.loadShortsRelatedCollection(reference: nil, onPagination: false,shortsId: shortsId, shortsSrn : srn, reset: reset) { [weak self] _ in
                guard let self = self else { return }
                self.shortsListView.isScrollEnabled = self.viewModel.isSwipable
                self.viewModel.fromPreview = true
                self.shortsListView.contentOffset.y = 0
                completion?()
            }
        }
    }
    
    
    override func layout() {
        super.layout()
        self.addSubview(errorView)
        
        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: self.topAnchor,constant: UIScreen.topSafeArea_SL),
            errorView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func handleInitializeError(error : Error?) -> Bool {
        guard let error = error else {
            self.errorView.isHidden = true
            return true
        }
        var msg : String = error.localizedDescription
        
        if let error = error as? ShopLiveCommonError, let message = error.message {
            msg = message
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.bringSubviewToFront(self.errorView)
            self.errorView.isHidden = false
            self.errorView.setErrorMsg(msg: msg)
        }
        return false
    }
    
}
extension V1ShortsDetailCollectionView {
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        if indexPath.row >= self.childViewModel.getShortsListDataCount() - 2 {
            childViewModel.checkForPagination()
        }
    }
    
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let index = self.getCenterItemIndexPath(), let srn = self.viewModel.shortsListData[safe: index.row]?.srn else { return }
            
            if let cell = self.shortsListView.cellForItem(at: index) as? ShortsCell {
                cell.play(skipIfPaused: true)
            }

//            latestCell.play(skipIfPaused: true)
//            latestCell.play(true)
            if self.viewModel.latestActivePageIndex != index.row {
                self.viewModel.latestActivePageIndex = index.row
                self.viewModel.postActivePageNotification(srn: srn, index: index.row)
            }
            
            childViewModel.appendCells()
        }
    }
    
}
