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
}

public protocol ShopLiveShortformDetailHandlerDelegate: AnyObject {
    func handleProductItem(shortsId : String, shortsSrn : String, product : Product)
    func handleProductBanner(shortsId : String, shortsSrn : String, scheme : String, shortsDetail : ShortsDetail)
}

extension ShopLiveShortform {
    
    final public class ShortsReceiveInterface {
        internal static let receiveHandler = ShopLiveShortformReceiveHandler()
        
        public static func setHandler(_ handler: ShopLiveShortformReceiveHandlerDelegate?) {
            receiveHandler.setHandler(handler)
        }
        
        public static func setNativeHandler(_ handler: ShopLiveShortformDetailHandlerDelegate?) {
            receiveHandler.setNativeHandler(handler)
        }
        
        
        class ShopLiveShortformReceiveHandler {
            
            weak var delegate: ShopLiveShortformReceiveHandlerDelegate? = nil
            weak var nativeDelegate: ShopLiveShortformDetailHandlerDelegate? = nil
            
            init() {
                setupObserver()
            }
            
            deinit {
                teardownObserver()
            }
            
            func setHandler(_ handler: ShopLiveShortformReceiveHandlerDelegate?) {
                delegate = handler
            }
            
            func setNativeHandler(_ handler: ShopLiveShortformDetailHandlerDelegate?) {
                nativeDelegate = handler
            }
            
            private func setupObserver() {
                NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("handleShare"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("onError"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("onEvent"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("moveToProductPage"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("moveToProductBannerPage"), object: nil)
            }
            
            private func teardownObserver() {
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name("handleShare"), object: nil)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name("onError"), object: nil)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name("onEvent"), object: nil)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name("moveToProductPage"), object: nil)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name("moveToProductBannerPage"), object: nil)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name("handleShare"), object: nil)

                NotificationCenter.default.removeObserver(self)
            }
            
            @objc private func handleNotification(_ notification: Notification) {
                switch notification.name {
                case Notification.Name("handleShare"):
                    self.handleHandleShare(payLoad: notification.userInfo as? [String : Any])
                    break
                case Notification.Name("onError"):
                    guard let error = notification.userInfo?["error"] as? Error else {
                        return
                    }
                    delegate?.onError?(error: error)
                    break
                case Notification.Name("onEvent"):
                    guard let command = notification.userInfo?["command"] as? String else {
                        return
                    }
                    self.handleOnEvents(command: command, payLoad: notification.userInfo?["payload"] as? [String : Any])
                    break
                case Notification.Name("moveToProductPage"):
                    self.handlemoveToProductPage(userInfo: notification.userInfo)
                    break
                case Notification.Name("moveToProductBannerPage"):
                    self.handlemoveToProductBannerPage(userInfo: notification.userInfo)
                    break
                default:
                    break
                }
            }
            
            private func handlemoveToProductPage(userInfo : [AnyHashable : Any]?) {
                guard let srn = userInfo?["srn"] as? String,
                      let shortsId = userInfo?["shortsId"] as? String,
                      let productModel = userInfo?["productModel"] as? Product else { return }
                self.nativeDelegate?.handleProductItem(shortsId: shortsId, shortsSrn: srn, product: productModel)
            }
            
            private func handlemoveToProductBannerPage(userInfo : [AnyHashable : Any]?){
                guard let scheme = userInfo?["scheme"] as? String,
                      let srn = userInfo?["srn"] as? String,
                      let shortsId = userInfo?["shortsId"] as? String,
                      let shortsDetail = userInfo?["shortsDetail"] as? ShortsDetail else { return }
                
                
                self.nativeDelegate?.handleProductBanner(shortsId: shortsId, shortsSrn: srn, scheme: scheme, shortsDetail: shortsDetail)
            }
            
            internal func handleOnEvents(command : String, payLoad : [String : Any]?) {
                var jsonString : String?
                if let payload = payLoad {
                    jsonString = payload.toJSONString_SL()
                }
                self.delegate?.onEvent?(command: command, payload: jsonString)
            }
            
            private func handleHandleShare(payLoad : [String : Any]?){
                
                if let urlString = payLoad?["url"] as? String {
                    if let handleShare = delegate?.handleShare?(shareUrl: urlString) {
                        handleShare
                    }
                    else {
                        NotificationCenter.default.post(Notification(name: Notification.Name("osShareSheet"), userInfo: ["url": urlString]))
                    }
                }
                
                if let shorts = payLoad?["shorts"] as? [String : Any],
                        let shortsDetail = shorts["shortsDetail"] as? [String : Any] {
                    
                    let shareMeteData = ShopLiveShareMetaData()
                    shareMeteData.descriptions = shortsDetail["description"] as? String
                    let brand = shortsDetail["brand"] as? [String : Any]
                    shareMeteData.thumbnail = brand?["imageUrl"] as? String
                    shareMeteData.title = shortsDetail["title"] as? String
                    shareMeteData.shortsId = shorts["shortsId"] as? String
                    shareMeteData.shortsSrn = shorts["srn"] as? String
                    
                    if let handleShare = delegate?.handleShare?(shareMetadata: shareMeteData) {
                        handleShare
                    }
                }
            }
        }
    }
    
}
