//
//  V1ShortsCollectionViewModel.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/29/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon



class V1ShortsCollectionViewModel : ShortsCollectionBaseViewModel {
    
    
}
extension V1ShortsCollectionViewModel {
    func prefetchItems(at indexPaths: [IndexPath]) {
        let itemCount = shortsListData.count
        if indexPaths.contains(where: { $0.item == itemCount - 1 }), self.hasMore, let reference = self.currentReference  {
            if self.currentApiType == .normal {
                self.loadShortsPlayCollection(reference: reference, onPagination: true) { _ in }
            }
            else {
                self.loadShortsRelatedCollection(reference: reference, onPagination: true, shortsId: nil, shortsSrn: nil, reset: false) { _ in  }
            }
        }
    }
    
    func loadShortsPlayCollection(reference : String?, onPagination : Bool, shortsId: String? = nil, reset: Bool = false, completion: @escaping (Error?) -> Void) {
        let apiInitializeCount = ShortFormConfigurationInfosManager.shared.shortsConfiguration.detailApiInitializeCount
        let paginationCount = ShortFormConfigurationInfosManager.shared.shortsConfiguration.detailApiPaginationCount
        let tags = self.collectionRequestData?.tags
        let tagSearchOperator = self.collectionRequestData?.tagSearchOperator
        let brands = self.collectionRequestData?.brands
        let shuffle = self.collectionRequestData?.shuffle
        
        let count = self.shortsListData.count >= apiInitializeCount ? paginationCount : apiInitializeCount
        self.callShortsConfigurationAPI { [weak self] isSucess in
            guard let self = self else { return }
            if isSucess {
                ShortsCollectionAPI(reference : reference, count: count, shortsId: shortsId,tags: tags,tagSearchOperator: tagSearchOperator,brands: brands,shuffle: shuffle ).request { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let response):
                        guard let shortsList = response.shortsList else {
                            if onPagination == false {
                                completion(nil)
                            }
                            return
                        }
                        self.shortsCollection = response
                        self.appendShortsListData(shortsList,reset: reset)
                        completion(nil)
                        break
                    case .failure(let error):
                        self.onError(error)
                        completion(error)
                        break
                    }
                }
            }
        }
    }
    
    func loadShortsRelatedCollection(reference : String?, onPagination : Bool, shortsId : String?, shortsSrn : String?, reset : Bool, completion : @escaping (Error?) -> ()){
        let requestModel = self.relatedRequestData
        let apiInitializeCount = ShortFormConfigurationInfosManager.shared.shortsConfiguration.detailApiInitializeCount
        let paginationCount = ShortFormConfigurationInfosManager.shared.shortsConfiguration.detailApiPaginationCount
        let count = (self.shortsListData.count >= apiInitializeCount && onPagination == true) ? paginationCount : apiInitializeCount
     
        
        self.callShortsConfigurationAPI { [weak self] isSucess in
            guard let self = self else { return }
            if isSucess == false { return }
            ShortsRelatedCollectionAPI(productId: requestModel?.productId,
                                       name: requestModel?.name, sku: requestModel?.sku,url: requestModel?.url,
                                       tags: requestModel?.tags, tagSearchOperator: requestModel?.tagSearchOperator,
                                       brands: requestModel?.brands,shortsId: shortsId,
                                       detailInfo : self.shortsMode == .preview ? nil : true,
                                       count : count,
                                       shuffle: requestModel?.shuffle,
                                       reference: reference).request { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    guard let shortsList = response.shortsList else {
                        if onPagination == false {
                            ShopLiveShortform.close()
                        }
                        completion(nil)
                        return
                    }
                    self.shortsCollection = response
                    self.appendShortsListData(shortsList,reset: reset)
                    completion(nil)
                    break
                case .failure(let error):
                    self.onError(error)
                    completion(error)
                }
            }
        }
    }
}
