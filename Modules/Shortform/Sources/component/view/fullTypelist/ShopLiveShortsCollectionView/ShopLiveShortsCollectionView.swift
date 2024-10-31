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
    
    let shortsCollectionView : V1ShortsDetailCollectionView
    
    public init(requestData : ShopLiveShortformCollectionData?){
        let internalShortFormRequestData = InternalShortformCollectionDto()
        internalShortFormRequestData.tags = requestData?.tags
        internalShortFormRequestData.tagSearchOperator = requestData?.tagSearchOperator?.rawValue
        internalShortFormRequestData.brands = requestData?.brands
        internalShortFormRequestData.shuffle = requestData?.shuffle
        internalShortFormRequestData.shortsCollectionId = requestData?.shortsCollectionId
        internalShortFormRequestData.skus = requestData?.skus
        internalShortFormRequestData.delegate = requestData?.delegate
        let shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        shortsCollectionView = V1ShortsDetailCollectionView(reference : requestData?.reference,
                                                            shortsMode: .detail,
                                                            showType: .normal,
                                                            shortsId: requestData?.shortsId,
                                                            shortsSrn: nil,
                                                            normalRequestParameterModel: internalShortFormRequestData,
                                                            viewProvideType: .view,
                                                            shopliveSessionId: shopliveSessionId)
        super.init(frame: .zero)
        setLayout()
        
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
        if shortsCollectionView.getCurrentShortsMode() == .detail {
            shortsCollectionView.onStartRotation(to: size)
        }
    }
    
    private func onChangingRotation(size : CGSize) {
        if shortsCollectionView.getCurrentShortsMode() == .detail {
            shortsCollectionView.onChangingRotation(to: size)
        }
    }
    
    private func onFinishedRotation(size : CGSize) {
        if shortsCollectionView.getCurrentShortsMode() == .detail {
            shortsCollectionView.onFinishedRotation(on: size)
        }
    }
    
    private func onPlay() {
        shortsCollectionView.playeCurrentCell()
    }
    
    private func onPause() {
        shortsCollectionView.pauseCells()
    }
}
extension ShopLiveShortsCollectionView {
    private func setLayout() {
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
