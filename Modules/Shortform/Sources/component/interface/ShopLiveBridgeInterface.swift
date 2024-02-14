//
//  ShopLiveBridgeInterface.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/28/23.
//

import Foundation
import WebKit
import ShopliveSDKCommon

protocol ShopLiveBridgeInterfaceHandlerDelegate: AnyObject {
    func sendShortsEvent(event: String, parameter: [String: Any]?, completion: @escaping ()->Void)
}


extension ShopLiveShortform {
    final public class BridgeInterface {
        private static let bridge = ShopLiveBridgeInterface()
        
        
        public static func connect(_ webview: WKWebView) {
            bridge.replaceWebview(webview)
        }
        
        public static func present(viewController: UIViewController?) {
            guard let viewController = viewController else { return }
            NotificationCenter.default.post(Notification(name: Notification.Name("presentViewController"), userInfo: ["vc": viewController]))
        }
        
        public static func disconnect() {
            bridge.releaseWebview()
        }
        
        
        internal static func isBridgeConnected() -> Bool {
            return bridge.isWebViewConnected()
        }
        
        //아래로 전부 다 임시 함수들
        internal static func sendShortsEvent(event: String, parameter: [String: Any]?) {
            bridge.sendShortsEvent(event: event, parameter: parameter) { }
        }
        
        internal static func closeShortsDetail(srn : String?) {
            var payLoad : [String : Any] = ["isShown": false ]
            if let srn = srn {
                payLoad["srn"] = srn
            }
            bridge.sendShortsEvent(event: "ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN", parameter: payLoad ) {}
        }
        
        internal static func showShortsDetail(srn : String?) {
            var payLoad : [String : Any] = ["isShown": true ]
            if let srn = srn {
                payLoad["srn"] = srn
            }
            bridge.sendShortsEvent(event: "ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN", parameter: payLoad) {}
        }
    }
}
extension ShopLiveShortform {
    class ShopLiveBridgeInterface: NSObject, WKScriptMessageHandler, ShopLiveBridgeInterfaceHandlerDelegate {
        
        private static let name: String = "ShopLiveBridgeInterface"
        private let handler = ShopLiveShortform.ShopLiveBridgeInterfaceHandler(interface: ShopLiveBridgeInterface.name)
        
        private weak var webview: WKWebView?
        
        
        override init() {
            super.init()
            handler.delegate = self
            setupObserver()
        }
        
        deinit {
            // print("ShopLiveBridgeInterface deinit")
            webview = nil
            teardownObserver()
        }
        
        func releaseWebview() {
            if let webView = self.webview {
                webView.safeRemoveObserver_SL(self, forKeyPath: "URL")
                webView.configuration.userContentController.removeScriptMessageHandler(forName: ShopLiveBridgeInterface.name)
            }
        }
        
        func isWebViewConnected() -> Bool{
            return webview == nil ? false : true
        }
        
        func replaceWebview(_ webview: WKWebView) {
            self.webview = webview
            if let webView = self.webview {
                webView.safeRemoveObserver_SL(self, forKeyPath: "URL")
                webView.configuration.userContentController.removeScriptMessageHandler(forName: ShopLiveBridgeInterface.name)
            }
            
            webview.addObserver(self, forKeyPath: "URL", options: [.old, .new], context: nil)
            webview.configuration.userContentController.add(LeakAvoider(delegate: self), name: ShopLiveBridgeInterface.name)
            
        }
        
        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            handler.handleMessage(message: message,with: webview)
        }
        
        private func setupObserver() {
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("moveToProductPage"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("moveToProductBannerPage"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("onChangedUserAuthSdk"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("requestShortsPreview"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("previewShown"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("clickPreview"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("previewHidden"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("previewClose"), object: nil)
            
        }
                
        private func teardownObserver() {
            self.webview?.removeObserver(self, forKeyPath: "URL")
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("moveToProductPage"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("onChangedUserAuthSdk"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("requestShortsPreview"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("previewShown"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("clickPreview"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("previewHidden"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("previewClose"), object: nil)
            NotificationCenter.default.removeObserver(self)
        }
        
        internal func sendShortsEvent(event: String, parameter: [String: Any]? = nil, completion: @escaping ()->Void) {
            DispatchQueue.main.async { [weak self] in
                var command = "window.cloud.shoplive.ExternalMessageManager.send('\(event)'"
                if let payload = parameter, let payloadData = payload.toJson_SL() {
                    command += ",\(payloadData)"
                }
                
                command += ");"
                self?.webview?.evaluateJavaScript(command) { _, _ in
                    completion()
                }
            }
        }
        
        private func sendChangedUserAuthSdk(userJWT: String?, guestUid: String?) {
            if let userJWT = userJWT {
                ShortFormAuthManager.shared.setUserJWT(userJWT: userJWT)
            }
            
            if let guestUid = guestUid {
                ShortFormAuthManager.shared.setGuestUid(guestUid: guestUid)
            }
            
            let payLoad : [String : Any] = ShortFormAuthManager.shared.getAkAndUserJWTasDict()
            
            self.sendShortsEvent(event: ShortsWebInterface.SdkToWeb.ON_CHANGED_USER_AUTH_SDK.rawValue, parameter: payLoad) {}
        }
        
        private func sendWebToRequestPreview(url: String, completion: @escaping ()->Void) {
            guard let url = webview?.url?.absoluteString else { return }
            let payload: [String: Any] = [
                "url": url
            ]
            self.sendShortsEvent(event: ShortsWebInterface.SdkToWeb.REQUEST_SHORTFORM_PREVIEW.rawValue, parameter: payload) {
                completion()
            }
        }
        
        private func sendWebToPreviewShown(shorts: [String: Any], completion: @escaping ()->Void) {
            let payload: [String: Any] = [
                "shorts": shorts
            ]
            self.sendShortsEvent(event: ShortsWebInterface.SdkToWeb.ON_SHORTFORM_PREVIEW_SHOWN.rawValue, parameter: payload) {
                completion()
            }
        }
        
        private func sendWebToClickPreview(shorts: [String: Any], completion: @escaping ()->Void) {
            let payload: [String: Any] = [
                "shorts": shorts
            ]
            self.sendShortsEvent(event: ShortsWebInterface.SdkToWeb.ON_CLICK_SHORTFORM_PREVIEW.rawValue, parameter: payload) {
                completion()
            }
        }
        
        private func sendWebToPreviewHidden(shorts: [String: Any], completion: @escaping ()->Void) {
            let payload: [String: Any] = [
                "shorts": shorts
            ]
            self.sendShortsEvent(event: ShortsWebInterface.SdkToWeb.ON_SHORTFORM_PREVIEW_HIDDEN.rawValue, parameter: payload) {
                completion()
            }
        }
        
        private func sendWebToPreviewClose(shorts: [String: Any], completion: @escaping ()->Void) {
            let payload: [String: Any] = [
                "shorts": shorts
            ]
            self.sendShortsEvent(event: ShortsWebInterface.SdkToWeb.ON_CLICK_SHORTFORM_PREVIEW_CLOSE.rawValue, parameter: payload) {
                completion()
            }
        }
        
        @objc func handleNotification(_ notification: Notification) {
            switch notification.name {
            case Notification.Name("requestShortsPreview"):
                guard let overlayUrl = notification.userInfo?["url"] as? String,
                      let srn = notification.userInfo?["srn"] as? String else {
                    return
                }
                
                ShopLiveShortform.close()
                self.sendShortsEvent(event: "ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN", parameter: ["isShown": false, "srn" : srn ]) {}
                sendWebToRequestPreview(url: overlayUrl) { }
                break
            case Notification.Name("moveToProductPage"):
                let userInfo = notification.userInfo
                guard let srn = userInfo?["srn"] as? String,
                      let productModel = userInfo?["productModel"] as? Product,
                      let urlString = productModel.url,
                      let productUrl = URL(string: urlString) else { return }
                if let webView = webview {
                    self.webview?.load(URLRequest(url: productUrl))
                    ShopLiveShortform.close()
                }
                self.sendShortsEvent(event: "ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN", parameter: ["isShown": false,"srn" : srn]) {}
               break
            case Notification.Name("moveToProductBannerPage"):
                let userInfo = notification.userInfo
                guard let scheme = userInfo?["scheme"] as? String,
                      let srn = userInfo?["srn"] as? String,
                      let url = URL(string: scheme) else { return }
                if let webView = webview {
                    self.webview?.load(URLRequest(url: url))
                    ShopLiveShortform.close()
                }
                self.sendShortsEvent(event: "ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN", parameter: ["isShown": false, "srn" : srn]) {}
                break
            case Notification.Name("onChangedUserAuthSdk"):
                let userJWT = ShortFormAuthManager.shared.getuserJWT()
                let guestUid = ShortFormAuthManager.shared.getGuestUId()
                self.sendChangedUserAuthSdk(userJWT: userJWT, guestUid: guestUid)
                break
            case Notification.Name("previewShown"):
                guard let shorts = notification.userInfo?["shorts"] as? ShortsModel, let shortsData = shorts.dictionary_SL else {
                    return
                }
                self.sendWebToPreviewShown(shorts: shortsData) {}
                break
            case Notification.Name("clickPreview"):
                guard let shorts = notification.userInfo?["shorts"] as? ShortsModel, let shortsData = shorts.dictionary_SL else {
                    return
                }
                self.sendWebToClickPreview(shorts: shortsData, completion: {})
                break
            case Notification.Name("previewHidden"):
                guard let shorts = notification.userInfo?["shorts"] as? ShortsModel, let shortsData = shorts.dictionary_SL else {
                    return
                }
                self.sendWebToPreviewHidden(shorts: shortsData) {}
                break
            case Notification.Name("previewClose"):
                guard let shorts = notification.userInfo?["shorts"] as? ShortsModel, let shortsData = shorts.dictionary_SL else {
                    return
                }
                self.sendWebToPreviewClose(shorts: shortsData) {}
                break
            default:
                break
            }
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            switch keyPath {
            case "URL":
                guard let oldUrl = change?[NSKeyValueChangeKey.oldKey] as? URL,
                        let newUrl = change?[NSKeyValueChangeKey.newKey] as? URL,
                      oldUrl.absoluteString != newUrl.absoluteString else {
                    return
                }
                
                NotificationCenter.default.post(Notification(name: Notification.Name("closePreview"), userInfo: nil))
                break
            default:
                break
            }
            
        }
    }
    
    struct ShortsBridgeModel: Codable {
        let shortsList : [ShortsModel]?
        let shorts: ShortsModel?
        let shortsCollection: ShortsCollectionModel?
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
        var sku : String?
    }
    
    struct CollectionQueryModel : Codable {
        var shuffle : Bool?
        var tags : [String]?
        var tagSearchOperator : String?
        var brands : [String]?
    }
    
}


extension ShopLiveShortform {
    class ShopLiveMessageHandler {
        private let interfaceName: String
        var web : WKWebView?
        
        init(interface: String) {
            self.interfaceName = interface
        }
        
        func handleMessage(message: WKScriptMessage,with web : WKWebView?) {
            self.web = web
            guard message.name == interfaceName else { return }
            internalMessageHandler(name: message.name, body: message.body)
        }
        
        func internalMessageHandler(name: String, body: Any) {}
    }
}

extension ShopLiveShortform {
    class ShopLiveBridgeInterfaceHandler: ShopLiveMessageHandler {
        weak var delegate: ShopLiveBridgeInterfaceHandlerDelegate?
        
        override func internalMessageHandler(name: String, body: Any) {
            guard let body = body as? [String: Any],
                  let event = body["shopliveShortsEvent"] as? [String : Any],
                  let eventName = event["name"] as? String else {
                return
            }
            
            if let webToSDKInterface = ShortsWebInterface.WebToSdk(rawValue: eventName), webToSDKInterface == .REQUEST_CLIENT_VERSION {
                self.onWebToSdkInternalMessageHandler(name: webToSDKInterface, body: body)
            }
            else if let bridgeInterfece = ShortsWebInterface.Bridge(rawValue: eventName) {
                self.onBridgeInterfaceMessageHandler(eventName: bridgeInterfece, body: body)
            }
        }
        
        private func onError(_ error: ShopLiveCommonError) {
            NotificationCenter.default.post(Notification(name: Notification.Name("onError"), object: nil, userInfo: ["error": error]))
        }
        
        private func onWebToSdkInternalMessageHandler(name : ShopLiveShortform.ShortsWebInterface.WebToSdk, body : Any ){
            switch name {
            case .REQUEST_CLIENT_VERSION:
                let payload: [String: Any] = [
                    "appVersion": UIApplication.appVersion_SL(),
                    "sdkVersion": ShopLiveShortform.sdkVersion
                ]
                let sendName : String = ShortsWebInterface.SdkToWeb.SEND_CLIENT_VERSION.rawValue
                self.sendCommandToWeb(event: sendName, parameter: payload)
            default:
                break
            }
        }
        
        private func onBridgeInterfaceMessageHandler(eventName : ShortsWebInterface.Bridge, body : [String : Any]){
            let parameters = body["payload"] as? [String: Any]
            
            switch eventName {
            case .SHOW_SHORTFORM_PREVIEW:
                guard let parameter = parameters, let param = parameter.toJson_SL(), let shortsList = param.convert_SL(to: ShortsBridgeModel.self) else { return }
                self.showShortFormPreview(model : shortsList)
                break
            case .HIDE_SHORTFORM_PREVIEW:
                ShopLiveShortform.close()
                break
            case .PLAY_SHORTFORM_DETAIL:
                guard let parameter = parameters, let param = parameter.toJson_SL(), let bridgeModel = param.convert_SL(to: ShortsBridgeModel.self) else { return }
                ShortFormAuthManager.shared.setAuthInfo(parameter)
                self.showShortFormFullScreen(model: bridgeModel)
                delegate?.sendShortsEvent(event: "ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN", parameter: ["isShown": true, "srn" : bridgeModel.shorts?.srn]) {}
                break
            case .ON_SHORTFORM_CLIENT_INITIALIZED:
                let ak = ((parameters?["ak"] ?? nil) as? String) ?? nil
                ShortFormConfigurationInfosManager.shared.callShortsConfigurationAPI(accessKey : ak,params: parameters) {  _ in
                    NotificationCenter.default.post(Notification(name: Notification.Name("onChangedUserAuthSdk"), object: nil, userInfo: nil))
                }
                break
            case .ON_CHANGED_USER_AUTH:
                guard let param = parameters else { return }
                ShortFormAuthManager.shared.setAuthInfo(param)
                break
            case .ON_CHANGED_USER_AUTH_WEB:
                guard let param = parameters else { return }
                self.handleOnChangeUserAuthWeb(params: param)
                break
            default:
                break
            }
        }
        
        private func showShortFormPreview(model : ShortsBridgeModel){
            dump(model)
            let requestModel = InternalShortformRelatedData()
            requestModel.tags = model.relatedQuery?.tags
            requestModel.tagSearchOperator = model.relatedQuery?.tagSearchOperator
            requestModel.brands = model.relatedQuery?.brands
            requestModel.productId = model.relatedQuery?.productId
            requestModel.name = model.relatedQuery?.name
            requestModel.sku = model.relatedQuery?.sku
            requestModel.url = model.relatedQuery?.url
            requestModel.shuffle = model.relatedQuery?.shuffle
            let shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
            ShopLiveShortform.showRelatedPreview(reference: nil, shortsId: model.shorts?.shortsId, shortsSrn: model.shorts?.srn,requestModel: requestModel, shortsList: model.shortsList ?? [] ,shortsCollectionModel: model.shortsCollection,shopliveSessionId: shopliveSessionId)
        }
        
        private func showShortFormFullScreen(model : ShortsBridgeModel){
            let shopliveSessionId = ShopLiveCommon.makeShopLiveSessionId()
            if ShortFormConfigurationInfosManager.shared.shortsConfiguration.detailCollectionListAll {
                let requestModel = InternalShortformCollectionData()
                requestModel.tags = model.collectionQuery?.tags
                requestModel.tagSearchOperator = model.collectionQuery?.tagSearchOperator
                requestModel.brands = model.collectionQuery?.brands
                requestModel.shuffle = model.collectionQuery?.shuffle
                ShopLiveShortform.playNormalFullScreen(shortsId: model.shorts?.shortsId, shortsSrn: model.shorts?.srn, requestModel: requestModel,shopliveSessionId: shopliveSessionId)
            }
            else {
                let requestModel = InternalShortformRelatedData()
                requestModel.tags = model.relatedQuery?.tags
                requestModel.tagSearchOperator = model.relatedQuery?.tagSearchOperator
                requestModel.brands = model.relatedQuery?.brands
                requestModel.productId = model.relatedQuery?.productId
                requestModel.name = model.relatedQuery?.name
                requestModel.sku = model.relatedQuery?.sku
                requestModel.url = model.relatedQuery?.url
                requestModel.shuffle = model.relatedQuery?.shuffle
        
                ShopLiveShortform.playRelatedFullScreen(shortsId: model.shorts?.shortsId, shortsSrn: model.shorts?.srn, requestModel: requestModel,shopliveSessionId: shopliveSessionId)
            }
        }
        
        private func handleOnChangeUserAuthWeb(params : [String : Any]) {
            let deviceJwt = ShopLiveCommon.getAuthToken()
            let webJwt : String? = params["userJWT"] as? String
            if deviceJwt != nil || webJwt == nil {
                ShortFormAuthManager.shared.setAuthInfo(params)
            }
        }
        
        
        private func sendCommandToWeb(event: String, parameter: [String: Any]? = nil, completion: (()->())? = nil) {
            guard let web = self.web else { return }
            var command = "window.cloud.shoplive.ExternalMessageManager.send('\(event)'"
            if let payload = parameter, let payloadData = payload.toJson_SL() {
                command += ",\(payloadData)"
            }
            
            command += ");"
            
            web.evaluateJavaScript(command) { _, _ in
                completion?()
            }
        }
        
    }
    
}
