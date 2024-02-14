//
//  LatestShortsCell.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/29/23.
//

import Foundation
import UIKit

class LatestShortsCell {
//    typealias ShortsCell = ShopLiveShortform.ShortsCell
//    typealias ShortsCell = ShortsCell2
    
    var latestCell: ShortsCell?
    var indexPath: IndexPath?
    
    init(latestCell: ShortsCell? = nil, indexPath: IndexPath? = nil) {
        self.latestCell = latestCell
        self.indexPath = indexPath
    }
    
    func setLatest(latestCell: ShortsCell? = nil, indexPath: IndexPath? = nil) {
        self.latestCell = latestCell
        self.indexPath = indexPath
    }
}


