//
//  ShopliveShortformListViewCellDelegate.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/05/16.
//

import Foundation



protocol ShopliveShortformListViewCellDelegate : NSObject {
    func onCellError(error : Error)
    func onCellAttached(indexPath : IndexPath)
    func onCellDetached(indexPath : IndexPath)
}
