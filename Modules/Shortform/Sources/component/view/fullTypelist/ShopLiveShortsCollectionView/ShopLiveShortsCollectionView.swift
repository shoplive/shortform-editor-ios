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
        case play
        case pause
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
        }
    }
    
    private func onStartRotation(size : CGSize) {
        let shortsCollectionView : ShortsCollectionBaseView
        if let shortsV1CollectionView = shortsV1CollectionView {
            shortsCollectionView = shortsV1CollectionView
        }
        else if let shortsV2CollectionView = shortsV2CollectionView {
            shortsCollectionView = shortsV2CollectionView
        }
        else {
            return
        }
        if shortsCollectionView.getCurrentShortsMode() == .detail {
            shortsCollectionView.onStartRotation(to: size)
        }
    }
    
    private func onChangingRotation(size : CGSize) {
        let shortsCollectionView : ShortsCollectionBaseView
        if let shortsV1CollectionView = shortsV1CollectionView {
            shortsCollectionView = shortsV1CollectionView
        }
        else if let shortsV2CollectionView = shortsV2CollectionView {
            shortsCollectionView = shortsV2CollectionView
        }
        else {
            return
        }
        if shortsCollectionView.getCurrentShortsMode() == .detail {
            shortsCollectionView.onChangingRotation(to: size)
        }
    }
    
    private func onFinishedRotation(size : CGSize) {
        let shortsCollectionView : ShortsCollectionBaseView
        if let shortsV1CollectionView = shortsV1CollectionView {
            shortsCollectionView = shortsV1CollectionView
        }
        else if let shortsV2CollectionView = shortsV2CollectionView {
            shortsCollectionView = shortsV2CollectionView
        }
        else {
            return
        }
        if shortsCollectionView.getCurrentShortsMode() == .detail {
            shortsCollectionView.onFinishedRotation(on: size)
        }
    }
    
    private func onPlay() {
        let shortsCollectionView : ShortsCollectionBaseView
        if let shortsV1CollectionView = shortsV1CollectionView {
            shortsCollectionView = shortsV1CollectionView
        }
        else if let shortsV2CollectionView = shortsV2CollectionView {
            shortsCollectionView = shortsV2CollectionView
        }
        else {
            return
        }
        shortsCollectionView.playeCurrentCell()
    }
    
    private func onPause() {
        let shortsCollectionView : ShortsCollectionBaseView
        if let shortsV1CollectionView = shortsV1CollectionView {
            shortsCollectionView = shortsV1CollectionView
        }
        else if let shortsV2CollectionView = shortsV2CollectionView {
            shortsCollectionView = shortsV2CollectionView
        }
        else {
            return
        }
        shortsCollectionView.pauseCells()
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
