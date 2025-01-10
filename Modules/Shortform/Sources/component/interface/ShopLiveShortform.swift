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
    
    public static var sdkVersion: String = ShopLiveCommon.shortformSdkVersion
    
    private static var shortsCollection: ShortsCollectionBaseView?
    private static var shortformWindow: SLShortFormWindow?
    
    internal static var detailWebViewViewHideOptionData = ShopLiveShortformVisibleDetailData()
    internal static var isEnabledVolumeKey : Bool = false
    internal static var detailPlayerResizeMode : ShopLiveResizeMode?
    internal static var enableResumeOnForeGround : Bool = true
    
    
    public static func play(requestData : ShopLiveShortformCollectionData?){
        let internalShortFormRequestData = InternalShortformCollectionDto()
        internalShortFormRequestData.tags = requestData?.tags
        internalShortFormRequestData.tagSearchOperator = requestData?.tagSearchOperator?.rawValue
        internalShortFormRequestData.brands = requestData?.brands
        internalShortFormRequestData.shuffle = requestData?.shuffle
        internalShortFormRequestData.shortsCollectionId = requestData?.shortsCollectionId
        internalShortFormRequestData.skus = requestData?.skus
        internalShortFormRequestData.delegate = requestData?.delegate
        
        let shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        self.playNormalFullScreen(reference : requestData?.reference, shortsId: requestData?.shortsId, shortsSrn: nil,requestModel: internalShortFormRequestData,shopliveSessionId: shopliveSessionId)
    }
    
    
    public static func play(shortformIdsData : ShopLiveShortformIdsData, dataSourceDelegate : ShortsCollectionViewDataSourcRequestDelegate, shortsCollectionDelegate : ShopLiveShortformReceiveHandlerDelegate?){
        self.playV2FullScreen(shortformIdsData: shortformIdsData, dataSourceDelegate: dataSourceDelegate, shortsCollectionDelegate: shortsCollectionDelegate)
        
    }
    
    @available(iOS, deprecated : 1.4.6 , message: "this method will be removed on 1.4.7")
    public static func play(requestData : ShopLiveShortformRelatedData?) {
        let internalShortFormRequestData = InternalShortformRelatedDTO()
        internalShortFormRequestData.productId = requestData?.productId
        internalShortFormRequestData.name = requestData?.name
        internalShortFormRequestData.skus = requestData?.skus
        internalShortFormRequestData.tags = requestData?.tags
        internalShortFormRequestData.tagSearchOperator = requestData?.tagSearchOperator?.rawValue
        internalShortFormRequestData.brands = requestData?.brands
        internalShortFormRequestData.shuffle = requestData?.shuffle
        internalShortFormRequestData.shortsId = requestData?.shortsId
        internalShortFormRequestData.delegate = requestData?.delegate
        
        let shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
        self.playRelatedFullScreen(shortsId: nil, shortsSrn: nil, requestModel: internalShortFormRequestData,shopliveSessionId: shopliveSessionId)
    }
    
    
    public static func showPreview(requestData : ShopLiveShortformPreviewData){
        let internalShortFormRequestData = InternalShortformRelatedDTO()
        internalShortFormRequestData.productId = requestData.productId
        internalShortFormRequestData.name = requestData.name
        internalShortFormRequestData.skus = requestData.skus
        internalShortFormRequestData.tags = requestData.tags
        internalShortFormRequestData.tagSearchOperator = requestData.tagSearchOperator?.rawValue
        internalShortFormRequestData.brands = requestData.brands
        internalShortFormRequestData.shuffle = requestData.shuffle
        internalShortFormRequestData.shortsId = requestData.shortsId
        internalShortFormRequestData.delegate = requestData.delegate
        Self.isEnabledVolumeKey = requestData.isEnabledVolumeKey
        
        self.showRelatedPreview(reference: requestData.reference, shortsId: requestData.shortsId, shortsSrn: nil, requestModel: internalShortFormRequestData, shortsList: [], shortsCollectionModel: nil,shopliveSessionId: nil, previewOptionDto: ShortformPreviewOptionDTO(previewData: requestData))

    }
    
    public static func close() {
        shortsCollection?.cleanUpMemoryLeak()
        
        DispatchQueue.main.async {
            shortformWindow?.hide()
            
            if shortsCollection != nil {
                shortsCollection?.removeFromSuperview()
                shortsCollection = nil
            }
            shortformWindow?.teardownWindow()
            shortformWindow = nil
        }
    }
    
    public static func getCurrentKeyWindow() -> UIWindow? {
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
    
    public static func getShopliveWindow() -> UIWindow? {
        guard let shortsCollection = Self.shortsCollection,
              let shortformWindow = Self.shortformWindow else {
            return nil
        }
        if shortsCollection.getCurrentShortsMode() == .preview {
            return nil
        }
        else {
            return shortformWindow.getCurrentWindow()
        }
    }
    
    public static func setReferrer(referrer : String?){
        ShortFormAuthManager.shared.setReferrer(referrer: referrer)
    }
    
    public static func setVisibileDetailViews(options : ShopLiveShortformVisibleDetailData){
        self.detailWebViewViewHideOptionData = options
    }
    
    public static func setResizeMode(mode : ShopLiveResizeMode) {
        self.detailPlayerResizeMode = mode
    }
    
    public static func setEnableResumeOnForeGround(enable : Bool) {
        self.enableResumeOnForeGround = enable
    }
    
    //MARK: - internal static funcs
    internal static func playNormalFullScreen(reference : String? = nil, shortsId : String?, shortsSrn : String?, requestModel : InternalShortformCollectionDto?,shopliveSessionId : String?){
        if shortsCollection != nil {
            shortsCollection?.removeFromSuperview()
            shortsCollection = nil
        }
        
        if shortformWindow == nil {
            shortformWindow = SLShortFormWindow(delegate: requestModel?.delegate)
        }
        
        shortsCollection = V1ShortsDetailCollectionView(reference : reference, shortsMode: .detail, showType: .normal, shortsId: shortsId, shortsSrn: shortsSrn, normalRequestParameterModel: requestModel, viewProvideType: .window,shopliveSessionId: shopliveSessionId)
        
        shortformWindow?.showPlay(shortsCollection)
    }
    
    internal static func playV2FullScreen(shortformIdsData : ShopLiveShortformIdsData, dataSourceDelegate : ShortsCollectionViewDataSourcRequestDelegate, shortsCollectionDelegate : ShopLiveShortformReceiveHandlerDelegate?) {
        if shortsCollection != nil {
            shortsCollection?.removeFromSuperview()
            shortsCollection = nil
        }
        
        if shortformWindow == nil {
            shortformWindow = SLShortFormWindow(delegate: shortsCollectionDelegate)
        }
        
        shortsCollection = V2ShortsCollectionView(shortformIdsData: shortformIdsData, requestDelegate: dataSourceDelegate,shortformDelegate: shortsCollectionDelegate)
        shortformWindow?.showPlay(shortsCollection)
    }
    
    internal static func playRelatedFullScreen(reference : String? = nil, shortsId : String?, shortsSrn : String?, requestModel : InternalShortformRelatedDTO?,shopliveSessionId : String?){
        if shortsCollection != nil {
            shortsCollection?.removeFromSuperview()
            shortsCollection = nil
        }
        
        if shortformWindow == nil {
            shortformWindow = SLShortFormWindow(delegate: requestModel?.delegate)
        }
        
        shortsCollection = V1ShortsDetailCollectionView(shortsMode: .detail, showType: .related, reference: reference, shortsId: shortsId, shortsSrn: shortsSrn,relatedRequestModel: requestModel,shortsList: [], shortsCollection: nil,viewProvideType: .window,shopliveSessionId: shopliveSessionId, previewOptionDTO: nil)
        
        shortformWindow?.showPlay(shortsCollection)
    }
    
    
    internal static func showRelatedPreview(reference : String? , shortsId : String?, shortsSrn : String?, requestModel : InternalShortformRelatedDTO?,shortsList : [SLShortsModel], shortsCollectionModel : SLShortsCollectionModel?,shopliveSessionId : String?,previewOptionDto : ShortformPreviewOptionDTO?){
        if shortformWindow == nil {
            shortformWindow = SLShortFormWindow(delegate: requestModel?.delegate)
        }
        
        shortformWindow?.setPreviewDTO(dto: previewOptionDto)
        shortsCollection = V1ShortsDetailCollectionView(shortsMode : .preview, showType : .related, reference : reference, shortsId : shortsId, shortsSrn : shortsSrn, relatedRequestModel : requestModel,shortsList: shortsList,shortsCollection: shortsCollectionModel,viewProvideType: .window,shopliveSessionId: shopliveSessionId, previewOptionDTO: previewOptionDto)
        
        shortformWindow?.showPreview(shortsCollection)
    }
    
    internal static func closeShortformPreview() {
        guard shortsCollection?.viewModel.shortsMode == .preview else { return }
        Self.close()
    }
    
}

extension ShopLiveShortform {
    @objc public enum PreviewPosition: Int {
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
