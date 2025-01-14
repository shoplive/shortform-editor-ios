//
//  ShopLiveShortsCollectionView.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 10/31/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon


public class ShopLiveShortsCollectionView : UIView, SLReactor {
   
    public enum Action {
        case onStartRotation(size : CGSize)
        case onChangingRotation(size : CGSize)
        case onFinishedRotation(size : CGSize)
        case remove(String)
        case play
        case pause
        case setScrollEnabled(Bool)
        case setInActive
        case setActive
        case setMuted(Bool)
    }
    
    public enum Result {
        
    }
   
    public var resultHandler: ((Result) -> ())?
    
    var shortsV1CollectionView : V1ShortsDetailCollectionView?
    var shortsV2CollectionView : V2ShortsCollectionView?

    public init(requestData : ShopLiveShortformCollectionData?){
        super.init(frame: .zero)
        let internalShortFormRequestData = InternalShortformCollectionDto()
        internalShortFormRequestData.tags = requestData?.tags
        internalShortFormRequestData.tagSearchOperator = requestData?.tagSearchOperator?.rawValue
        internalShortFormRequestData.brands = requestData?.brands
        internalShortFormRequestData.shuffle = requestData?.shuffle
        internalShortFormRequestData.shortsCollectionId = requestData?.shortsCollectionId
        internalShortFormRequestData.skus = requestData?.skus
        internalShortFormRequestData.delegate = requestData?.delegate
        let shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        shortsV1CollectionView = V1ShortsDetailCollectionView(reference : requestData?.reference,
                                                            shortsMode: .detail,
                                                              showType: .normal,
                                                            shortsId: requestData?.shortsId,
                                                            shortsSrn: nil,
                                                            normalRequestParameterModel: internalShortFormRequestData,
                                                            viewProvideType: .view,
                                                            shopliveSessionId: shopliveSessionId)
        setV1Layout()
    }
    
    
    public init(shortformIdsData : ShopLiveShortformIdsData, dataSourceDelegate : ShortsCollectionViewDataSourcRequestDelegate, shortsCollectionDelegate : ShopLiveShortformReceiveHandlerDelegate?) {
        super.init(frame: .zero)
        shortsV2CollectionView = V2ShortsCollectionView(shortformIdsData: shortformIdsData, requestDelegate: dataSourceDelegate, shortformDelegate: shortsCollectionDelegate)
        setV2Layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ShopLiveLogger.memoryLog("[SHOPLIVESHORTSCOLLECTIONVIEW] deinit")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard let shortsCollectionView = getShortsCollectionView() else { return }
        shortsCollectionView.updateItemSize(self.frame.size)
    }
    
    
    
    public func action(_ action: Action) {
        switch action {
        case .onStartRotation(let size):
            onStartRotation(size: size)
        case .onChangingRotation(let size):
            onChangingRotation(size: size)
        case .onFinishedRotation(let size):
            onFinishedRotation(size: size)
        case .play:
            onPlay()
        case .pause:
            onPause()
        case .remove(let shortsIdOrSrn):
            onRemove(shortsIdOrSrn: shortsIdOrSrn)
        case .setScrollEnabled(let isScrollEnabled):
            onIsScrollEnabled(isScrollEnabled: isScrollEnabled)
        case .setActive:
            self.onSetActive()
        case .setInActive:
            self.onSetInActive()
        case .setMuted(let isMuted):
            self.onSetMuted(isMuted : isMuted)
        }
    }
    
    private func onStartRotation(size : CGSize) {
        guard let shortsCollectionView = getShortsCollectionView() else { return }
        if shortsCollectionView.getCurrentShortsMode() == .detail {
            shortsCollectionView.onStartRotation(to: size)
        }
    }
    
    private func onChangingRotation(size : CGSize) {
        guard let shortsCollectionView = getShortsCollectionView() else { return }
        if shortsCollectionView.getCurrentShortsMode() == .detail {
            shortsCollectionView.onChangingRotation(to: size)
        }
    }
    
    private func onFinishedRotation(size : CGSize) {
        guard let shortsCollectionView = getShortsCollectionView() else { return }
        if shortsCollectionView.getCurrentShortsMode() == .detail {
            shortsCollectionView.onFinishedRotation(on: size)
        }
    }
    
    private func onPlay() {
        guard let shortsCollectionView = getShortsCollectionView() else { return }
        shortsCollectionView.playCurrentItemOnUserCommand()
    }
    
    private func onPause() {
        guard let shortsCollectionView = getShortsCollectionView() else { return }
        shortsCollectionView.pauseCells()
    }
    
    private func onRemove(shortsIdOrSrn : String) {
        guard let shortsCollectionView = getShortsCollectionView() else { return }
        shortsCollectionView.removeData(where: shortsIdOrSrn )
    }
    
    private func onIsScrollEnabled(isScrollEnabled : Bool) {
        guard let shortsCollectionView = getShortsCollectionView() else { return }
        shortsCollectionView.setIsScrollEnabled(isScrollEnabled: isScrollEnabled)
    }
    
    private func onSetActive() {
        guard let shortsCollectionView = getShortsCollectionView() else { return }
        shortsCollectionView.setActive()
    }
    
    private func onSetInActive() {
        guard let shortsCollectionView = getShortsCollectionView() else { return }
        shortsCollectionView.setInActive()
    }
    
    private func onSetMuted(isMuted : Bool) {
        guard let shortsCollectionView = getShortsCollectionView() else { return }
        shortsCollectionView.setMuted(isMuted: isMuted)
    }
}
extension ShopLiveShortsCollectionView {
    private func getShortsCollectionView() -> ShortsCollectionBaseView? {
        let shortsCollectionView : ShortsCollectionBaseView
        if let shortsV1CollectionView = shortsV1CollectionView {
            shortsCollectionView = shortsV1CollectionView
        }
        else if let shortsV2CollectionView = shortsV2CollectionView {
            shortsCollectionView = shortsV2CollectionView
        }
        else {
            return nil
        }
        return shortsCollectionView
    }
}
extension ShopLiveShortsCollectionView {
    private func setV1Layout() {
        guard let shortsCollectionView = shortsV1CollectionView else { return }
        self.addSubview(shortsCollectionView)
        shortsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            shortsCollectionView.topAnchor.constraint(equalTo: self.topAnchor),
            shortsCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            shortsCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            shortsCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func setV2Layout() {
        guard let shortsCollectionView = shortsV2CollectionView else { return }
        self.addSubview(shortsCollectionView)
        shortsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            shortsCollectionView.topAnchor.constraint(equalTo: self.topAnchor),
            shortsCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            shortsCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            shortsCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
