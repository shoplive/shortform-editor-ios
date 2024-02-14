//
//  ShopLiveShortform.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/22/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon

public class ShopLiveShortform {
    
    public static var sdkVersion: String = "1.5.5"
    
    private static var shortsCollection: ShortsCollectionBaseView?
    private static var shortformWindow: SLShortsWindow?
    
    internal static var detailWebViewViewHideOptionData = ShopLiveShortformVisibleFullTypeData()
    
    public static func play(requestData : ShopLiveShortformCollectionData?){
        let internalShortFormRequestData = InternalShortformCollectionData()
        internalShortFormRequestData.tags = requestData?.tags
        internalShortFormRequestData.tagSearchOperator = requestData?.tagSearchOperator?.rawValue
        internalShortFormRequestData.brands = requestData?.brands
        internalShortFormRequestData.shuffle = requestData?.shuffle
        
        let shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        self.playNormalFullScreen(reference : requestData?.reference, shortsId: requestData?.shortsId, shortsSrn: requestData?.shortsSrn,requestModel: internalShortFormRequestData,shopliveSessionId: shopliveSessionId)
    }
    
    
    
    public static func play(shortformIdsData : ShopLiveShortformIdsData, delegate : ShortsCollectionViewDataSourcRequestDelegate){
        self.playV2FullScreen(shortformIdsData: shortformIdsData, delegate: delegate)
        
    }
    
    @available(iOS, deprecated : 1.4.6 , message: "this method will be removed on 1.4.7")
    public static func play(requestData : ShopLiveShortformRelatedData?) {
        let internalShortFormRequestData = InternalShortformRelatedData()
        internalShortFormRequestData.productId = requestData?.productId
        internalShortFormRequestData.name = requestData?.name
        internalShortFormRequestData.sku = requestData?.sku
        internalShortFormRequestData.tags = requestData?.tags
        internalShortFormRequestData.tagSearchOperator = requestData?.tagSearchOperator?.rawValue
        internalShortFormRequestData.brands = requestData?.brands
        internalShortFormRequestData.shuffle = requestData?.shuffle
        
        let shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        self.playRelatedFullScreen(shortsId: nil, shortsSrn: nil, requestModel: internalShortFormRequestData,shopliveSessionId: shopliveSessionId)
    }
    
    
    public static func showPreview(requestData : ShopLiveShortformRelatedData){
        let internalShortFormRequestData = InternalShortformRelatedData()
        internalShortFormRequestData.productId = requestData.productId
        internalShortFormRequestData.name = requestData.name
        internalShortFormRequestData.sku = requestData.sku
        internalShortFormRequestData.tags = requestData.tags
        internalShortFormRequestData.tagSearchOperator = requestData.tagSearchOperator?.rawValue
        internalShortFormRequestData.brands = requestData.brands
        internalShortFormRequestData.shuffle = requestData.shuffle
        
        
        self.showRelatedPreview(reference: requestData.reference, shortsId: nil, shortsSrn: nil, requestModel: internalShortFormRequestData, shortsList: [], shortsCollectionModel: nil,shopliveSessionId: nil)
    }
    

    
    
    
    public static func close() {
        DispatchQueue.main.async {
            shortformWindow?.hide()
            
            if shortsCollection != nil {
                shortsCollection?.removeFromSuperview()
                shortsCollection = nil
            }
            
            shortformWindow = nil
        }
    }
    
    public static func getShopliveWindow() -> UIWindow? {
        guard let shortsCollection = Self.shortsCollection,
              let shortformWindow = Self.shortformWindow else {
            return UIApplication.shared.keyWindow
        }
        if shortsCollection.getCurrentShortsMode() == .preview {
            return UIApplication.shared.keyWindow
        }
        else {
            return shortformWindow.getCurrentWindow()
        }
    }
    
    public static func setReferrer(referrer : String?){
        ShortFormAuthManager.shared.setReferrer(referrer: referrer)
    }
    
    public static func setVisibileFullTypeViews(options : ShopLiveShortformVisibleFullTypeData){
        self.detailWebViewViewHideOptionData = options
    }
    
    internal static func playNormalFullScreen(reference : String? = nil, shortsId : String?, shortsSrn : String?, requestModel : InternalShortformCollectionData?,shopliveSessionId : String?){
        if shortsCollection != nil {
            shortsCollection?.removeFromSuperview()
            shortsCollection = nil
        }
        
        if shortformWindow == nil {
            shortformWindow = SLShortsWindow()
        }
        
        shortsCollection = V1ShortsFullTypeCollectionView(reference : reference, shortsMode: .detail, showType: .normal, shortsId: shortsId, shortsSrn: shortsSrn, normalRequestParameterModel: requestModel, viewProvideType: .window,shopliveSessionId: shopliveSessionId)
        
        shortformWindow?.showPlay(shortsCollection)
    }
    
    internal static func playV2FullScreen(shortformIdsData : ShopLiveShortformIdsData, delegate : ShortsCollectionViewDataSourcRequestDelegate) {
        if shortsCollection != nil {
            shortsCollection?.removeFromSuperview()
            shortsCollection = nil
        }
        
        if shortformWindow == nil {
            shortformWindow = SLShortsWindow()
        }
        
        shortsCollection = V2ShortsCollectionView(shortformIdsData: shortformIdsData, requestDelegate: delegate)
        shortformWindow?.showPlay(shortsCollection)
    }
    
    internal static func playRelatedFullScreen(reference : String? = nil, shortsId : String?, shortsSrn : String?, requestModel : InternalShortformRelatedData?,shopliveSessionId : String?){
        if shortsCollection != nil {
            shortsCollection?.removeFromSuperview()
            shortsCollection = nil
        }
        
        if shortformWindow == nil {
            shortformWindow = SLShortsWindow()
        }
        
        shortsCollection = V1ShortsFullTypeCollectionView(shortsMode: .detail, showType: .related, reference: reference, shortsId: shortsId, shortsSrn: shortsSrn,relatedRequestModel: requestModel,shortsList: [], shortsCollection: nil,viewProvideType: .window,shopliveSessionId: shopliveSessionId)
        
        shortformWindow?.showPlay(shortsCollection)
    }
    
    internal static func showRelatedPreview(reference : String? , shortsId : String?, shortsSrn : String?, requestModel : InternalShortformRelatedData?,shortsList : [ShortsModel], shortsCollectionModel : ShortsCollectionModel?,shopliveSessionId : String?){
        if shortformWindow == nil {
            shortformWindow = SLShortsWindow()
        }
        
        shortsCollection = V1ShortsFullTypeCollectionView(shortsMode : .preview, showType : .related, reference : reference, shortsId : shortsId, shortsSrn : shortsSrn, relatedRequestModel : requestModel,shortsList: shortsList,shortsCollection: shortsCollectionModel,viewProvideType: .window,shopliveSessionId: shopliveSessionId)
        
        shortformWindow?.showPreview(shortsCollection)
    }
    
}

extension ShopLiveShortform {
    @objc enum PreviewPosition: Int {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case `default`

        public var name: String {
            switch self {
            case .default, .bottomRight:
                return "bottomRight"
            case .bottomLeft:
                return "bottomLeft"
            case .topLeft:
                return "topLeft"
            case .topRight:
                return "topRight"
            default:
                return "bottomRight"
            }
        }
        
        static func previewPosition(name: String) -> PreviewPosition {
            let positionDataSource = ["topLeft", "topRight", "bottomLeft","bottomRight"]
            
            guard let index = positionDataSource.firstIndex(where: { $0 == name}),
                  let previewPosition = PreviewPosition(rawValue: index) else {
                return .bottomRight
            }
            
            return previewPosition
        }
    }
    
    
}


extension ShopLiveShortform {
    enum ShortsMode {
        case preview
        case detail
    }
    
    enum VideoType: CaseIterable {
        case mp4
        case hls
        case image
        case gif
        case unknown
        
        var fileExtension: String {
            switch self {
            case .mp4:
                return "mp4"
            case .hls:
                return "m3u8"
            case .image:
                return "png"
            case .gif:
                return "gif"
            case .unknown:
                return "unknown"
            }
        }
    }
}
