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
    @objc optional func onEvent(messenger : ShopLiveShortformMessenger?, command: String, payload: String?)
    @objc optional func onDidDisAppear()
    @objc optional func onDidAppear()
    @objc optional func handleProductItem(shortsId : String, shortsSrn : String, product : ProductData)
    @objc optional func handleProductBanner(shortsId : String, shortsSrn : String, scheme : String)
    /**
     collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)와 똑같은 시점에 호출됩니다.
     */
    @objc optional func onShortsAttached(data : ShopLiveShortformData )
/**
     collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath)와 똑같은 시점에 호출됩니다.
 그리고 해당뷰가 removeFromSuperView()의 호출시점에도 이벤트가 생성됩니다.
     */
    @objc optional func onShortsDetached(data :  ShopLiveShortformData )
}

extension ShopLiveShortform {
    
    //기존 NativeDelegate, Hybrid 전용등으로 쪼개져 있던 것은 그냥 Delegate로 통합
//    final public class Delegate {
//        internal static let receiveHandler = ShopLiveShortformReceiveHandler()
//        
//        public static func setDelegate(_ delegate: ShopLiveShortformReceiveHandlerDelegate?) {
//            receiveHandler.setDelegate(delegate)
//        }
//        
//        class ShopLiveShortformReceiveHandler {
//            
//            weak var delegate: ShopLiveShortformReceiveHandlerDelegate? = nil
//            
//            
//            func setDelegate(_ delegate: ShopLiveShortformReceiveHandlerDelegate?) {
//                self.delegate = delegate
//            }
//        }
//    }
    
}
