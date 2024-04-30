//
//  ShopLiveShortformEditorFilterManager.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 2/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon


class ShopLiveShortformEditorFilterListManager {
    static let shared = ShopLiveShortformEditorFilterListManager()
    
    weak var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
    var filterList : [Filters] = []
    var isFilterExist : Bool {
        return filterList.isEmpty ? false : true
    }
   
    func callFilterListAPI(completion : @escaping ( () -> () )) {
        if filterList.isEmpty == false {
            completion()
            return
        }
        SLShortformFilterAPI().request { [weak self]  result in
            switch result {
            case .success(let result):
                self?.filterList = result.results ?? []
                completion()
                break
            case .failure(let error):
                self?.filterList = []
                self?.shortformEditorDelegate?.onShopLiveShortformEditorError?(error: error)
                completion()
                break
            }
        }
    }
    
}
