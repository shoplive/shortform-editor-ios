//
//  ShortsReceiveInterface.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/28/23.
//

import Foundation
import WebKit
import ShopliveSDKCommon

@objc public protocol ShopLiveShortformReceiveHandlerDelegate: AnyObject {
    @objc optional func handleShare(shareUrl: String)
    @objc optional func handleShare(shareMetadata : ShopLiveShareMetaData)
    @objc optional func onError(error: Error)
    @objc optional func onEvent(command: String, payload: String?)
    @objc optional func onDidDisAppear()
    @objc optional func onDidAppear()
    @objc optional func handleProductItem(shortsId : String, shortsSrn : String, product : ProductData)
    @objc optional func handleProductBanner(shortsId : String, shortsSrn : String, scheme : String, shortsDetail : ShortsDetailData)
}

extension ShopLiveShortform {
    
    //기존 NativeDelegate, Hybrid 전용등으로 쪼개져 있던 것은 그냥 Delegate로 통합
    final public class Delegate {
        internal static let receiveHandler = ShopLiveShortformReceiveHandler()
        
        public static func setDelegate(_ delegate: ShopLiveShortformReceiveHandlerDelegate?) {
            receiveHandler.setDelegate(delegate)
        }
        
        class ShopLiveShortformReceiveHandler {
            
            weak var delegate: ShopLiveShortformReceiveHandlerDelegate? = nil
            
            
            func setDelegate(_ delegate: ShopLiveShortformReceiveHandlerDelegate?) {
                self.delegate = delegate
            }
        }
    }
    
}
