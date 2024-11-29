//
//  ShopLiveBridgeInterface.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/28/23.
//

import Foundation
import WebKit
import ShopliveSDKCommon


extension ShopLiveShortform {
    final public class BridgeInterface  {
        typealias SdkToWeb = ShortsWebInterface.SdkToWeb
        
        internal static let shared = BridgeInterface()
        
        internal var reactor = ShopliveBridgeInterfaceReactor()
        internal weak var webView : WKWebView?
        
        public static func connect(_ webview: WKWebView) {
            Self.shared.webView = webview
            Self.shared.reactor.action( .setWebView(webview) )
        }
        
        public static func present(viewController: UIViewController?) {
            guard let viewController = viewController else { return }
            NotificationCenter.default.post(Notification(name: Notification.Name("presentViewController"), userInfo: ["vc": viewController]))
        }
        
        public static func disconnect() {
            guard let webView = Self.shared.webView else { return }
            Self.shared.reactor.action( .removeWebViewObserver(webView))
            Self.shared.webView = nil
        }
    }
}
extension ShopLiveShortform.BridgeInterface {
    private func bindReactor() {
        Self.shared.reactor.resultHandler = { result in
            switch  result {
            case .requestEvaluateJS((let command, let payload)):
                Self.shared.onRequestEvaluateJS(command: command, payload: payload)
            case .showShortformPreview((let reference, let shortsId, let shortsSrn, let requestModel, let shortsList, let shortsCollectionModel, let shopliveSessionId)):
                Self.shared.onShowShortformPreview(reference: reference, shortsId: shortsId, shortsSrn: shortsSrn, requestModel: requestModel, shortsList: shortsList, shortsCollectionModel: shortsCollectionModel, shopliveSessionId: shopliveSessionId)
            case .showNormalFullScreen((let reference, let shortsId, let shortsSrn, let requestModel, let shopliveSessionId)):
                Self.shared.onShowNormalFullScreen(reference: reference, shortsId: shortsId, shortsSrn: shortsSrn, requestModel: requestModel, shopliveSessionId: shopliveSessionId)
            case .showRelatedFullScreen((let reference, let shortsId, let shortsSrn, let requestModel, let shopliveSessionId)):
                Self.shared.onShowRelatedFullScreen(reference: reference , shortsId: shortsId, shortsSrn: shortsSrn, requestModel: requestModel, shopliveSessionId: shopliveSessionId)
            }
        }
    }
    
    internal func onRequestEvaluateJS(command : String, payload : [String : Any]?) {
        DispatchQueue.main.async {
            var command = "window.cloud.shoplive.ExternalMessageManager.send('\(command)'"
            if let payload = payload, let payloadData = payload.toJson_SL() {
                command += ",\(payloadData)"
            }
            command += ");"
            Self.shared.webView?.evaluateJavaScript(command) { _, _ in
            }
        }
    }
    
    private func onShowShortformPreview(reference : String? , shortsId : String?, shortsSrn : String?, requestModel : InternalShortformRelatedDTO?,shortsList : [SLShortsModel], shortsCollectionModel : SLShortsCollectionModel?,shopliveSessionId : String?) {
        ShopLiveShortform.showRelatedPreview(reference: reference, shortsId: shortsId, shortsSrn: shortsSrn, requestModel: requestModel, shortsList: shortsList, shortsCollectionModel: shortsCollectionModel, shopliveSessionId: shopliveSessionId,previewOptionDto: nil)
    }
    
    private func onShowNormalFullScreen(reference : String?, shortsId : String?, shortsSrn : String?, requestModel : InternalShortformCollectionDto?,shopliveSessionId : String?) {
        ShopLiveShortform.playNormalFullScreen(reference: reference, shortsId: shortsId, shortsSrn: shortsSrn, requestModel: requestModel, shopliveSessionId: shopliveSessionId)
    }
    
    private func onShowRelatedFullScreen(reference : String?, shortsId : String?, shortsSrn : String?, requestModel : InternalShortformRelatedDTO?,shopliveSessionId : String?) {
        ShopLiveShortform.playRelatedFullScreen(reference: reference, shortsId: shortsId, shortsSrn: shortsSrn, requestModel: requestModel, shopliveSessionId: shopliveSessionId)
    }
}
extension ShopLiveShortform {
    
    struct ShortsBridgeModel: Codable {
        let shortsList : [SLShortsModel]?
        let shorts: SLShortsModel?
        let shortsCollection: SLShortsCollectionModel?
        let relatedQuery : RelatedQueryModel?
        let collectionQuery : CollectionQueryModel?
        
    }
    
    struct RelatedQueryModel : Codable {
        var shuffle : Bool?
        var url : String?
        
        let tags : [String]?
        let tagSearchOperator : String?
        let brands : [String]?
        var productId : String?
        var customerProductId : String?
        var name : String? // product name
        var skus : [String]?
        var shortsId : String?
    }
    
    struct CollectionQueryModel : Codable {
        var shuffle : Bool?
        var tags : [String]?
        var tagSearchOperator : String?
        var brands : [String]?
        var skus : [String]?
        var shortsCollectionId : String?
    }
    
}
