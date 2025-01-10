//
//  V2ShortformExample.swift
//  shortform-examples
//
//  Created by sangmin han on 8/30/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import ShopLiveShortformSDK


 
class V2ShortformExample  {
    
    var reference : String? = nil
    var hasMore : Bool? = nil
    
    func play() {
        self.reference = nil
        self.hasMore = nil
        self.callShortsCollectionAPI { [weak self] data,error  in
            guard let self = self, let ids = data?.ids else { return }
            let currentIdIndex = Int.random(in: 0..<ids.count)
            if let data = data {
                ShopLiveShortform.play(shortformIdsData: ShopLiveShortformIdsData(ids : ids, currentId: ids.map{ $0.shortsId }[safe : currentIdIndex] ?? "" ), dataSourceDelegate: self, shortsCollectionDelegate: self)
            }
        }
    }
}

extension V2ShortformExample : ShopLiveShortformReceiveHandlerDelegate {
    func onEvent(messenger: ShopLiveShortformMessenger?, command: String, payload: String?) {
//        if let messenger = messenger {
//            messenger.sendCommandMessage(command: "something", payload: [:])
//        }
        switch command {
        case "DETAIL_SHORTFORM_MORE_ENDED":
            ShopLiveLogger.tempLog("[DETAIL_SHORTFORM_MORE_ENDED]")
            break
        case "VIDEO_TOTAL_VIEWING_TIME":
            ShopLiveLogger.tempLog("[VIDEO_TOTAL_VIEWING_TIME] \(payload)")
        case "DETAIL_ACTIVE":
            break
        default:
            break
        }
    }
}
extension V2ShortformExample : ShortsCollectionViewDataSourcRequestDelegate {
    func onShortformListUpwardPagingation(completion: @escaping (((ShopLiveShortformSDK.ShopLiveShortformIdsMoreData?, (any Error)?)) -> ())) {
        
    }
    
    func onShortformListPaginationError(error: Error) {
        
    }
    
    func onShortformListDownwardPagination(completion: @escaping (((ShopLiveShortformSDK.ShopLiveShortformIdsMoreData?, Error?)) -> ())) {
        callShortsCollectionAPI { data,error in
            if let data = data {
                completion((data,nil))
            }
            else if let error = error {
                completion((nil,error))
            }
            else {
                completion((nil,nil))
            }
        }
    }
    
    func callShortsCollectionAPI(completion : @escaping((ShopLiveShortformIdsMoreData?,Error?) -> ())) {
        TestShortsCollectionAPI(reference: self.reference).request { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let shortsList = response.shortsList else {
                    completion(nil,nil)
                    return
                }
                self.reference = response.reference
                self.hasMore = response.hasMore
                let idsData = response.shortsList?.compactMap({ shortsModel in
                    return ShopLiveShortformIdData(shortsId: shortsModel.shortsId ?? "", payload: ["createIsFollow" : true] )
                })
                let moreData = ShopLiveShortformIdsMoreData(ids: idsData ,hasMore: hasMore)
                completion(moreData,nil)
                break
            case .failure(let error):
                ShopLiveLogger.tempLog("[V2SHORTFORMEXAMPLE] error \(error.localizedDescription)")
                completion(nil,error)
                break
            }
        }
    }
}


struct TestShortsCollectionAPI: APIDefinition {
    typealias ResultType = SLShortsCollectionModel

    var baseUrl: String {
        "https://qa-shortform-api.shoplive.cloud"
    }

    var urlPath: String {
        if let ak = ShopLiveCommon.getAccessKey(), ak.isEmpty == false {
            return "/sdk/v1/\(ak)/shorts/collection"
        }
        else {
            return "/sdk/v1/shorts/collection"
        }
    }


    var method: SLHTTPMethod {
        .post
    }

    var headers: [String : String] {
        var header : [String : String] = [:]
        header[CommonKeys.x_sl_player_app_version] = UIApplication.appVersion_SL()
        header[CommonKeys.x_sl_player_sdk_version] = ShopLiveShortform.sdkVersion
        return header
    }


    var parameters: [String : Any]? {
        var params: [String: Any] = [:]
        
        params["count"] = ShortFormConfigurationInfosManager.shared.getRequestCount()

        if let accessKey = ShopLiveCommon.getAccessKey() {
            params["accessKey"] = accessKey
        }

        if let reference = reference, reference.isEmpty == false {
            params["reference"] = reference
        }
        if let shortsId = shortsId {
            params["shortsId"] = shortsId
        }
        if let shortsCollectionsId = shortsCollectionsId {
            params["shortsCollectionId"] = shortsCollectionsId
        }
        if let shortsCollectionSrn = shortsCollectionSrn {
            params["shortsCollectionSrn"] = shortsCollectionSrn
        }
        if let tags = tags {
            params["tags"] = tags
        }
        if let tagSearchOperator = tagSearchOperator {
            params["tagSearchOperator"] = tagSearchOperator
        }
        if let brands = brands {
            params["brands"] = brands
        }
        if let shuffle = shuffle {
            params["shuffle"] = shuffle
        }
        if let type = type {
            params["type"] = type
        }

        if let finite = finite {
            params["finite"] = finite
        }

        return params
    }

    var reference : String?

    var shortsId: String?

    var shortsCollectionsId : Int?
    var shortsCollectionSrn : String?
    var tags : [String]?
    var tagSearchOperator : String?
    var brands : [String]?
    var shuffle : Bool?
    var type : String?
    var finite : Bool?



}
