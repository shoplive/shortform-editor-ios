//
//  SLUGCUploadReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by Tabber on 3/19/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import UIKit

class ShopLiveShortformUploaderReactor: NSObject, SLReactor {
    
    let uploaderData: ShopLiveShortformUploaderData?
    
    var resultHandler: ((Result) -> ())?
    
    var mainQueueResultHandler: ((Result) -> ())?
    
    enum Action {
        case viewWillAppear
        case viewDidLoad
        case sendWebEvent(event: ShopLiveShortformUploaderWebInterface, parameter: [String : Any]?)
        case onEvent(name: String, payload: [String : Any]?)
        case sendShortEvent(event: String, parameter: [String : Any]?)
        case openVideoEditor
        case openPreview(data: SLUploadAttachmentInfo)
        case openCoverPicker(shortsId: String, videoUrl: String?)
        case closeViewController
    }
    
    enum Result {
        case sendWebEvent(event: ShopLiveShortformUploaderWebInterface, parameter: [String : Any]?)
        case sendShortEvent(event: String, parameter: [String : Any]?)
        case loadWebView(url: URL)
        case openPreview(data: SLUploadAttachmentInfo)
        case openVideoEditor
        case openCoverPicker(shortsId: String, videoUrl: String?)
        case closeViewController
        case uploadComplete
        case onEvent(name: String, payload: [String : Any]?)
        case onError(error: ShopLiveCommonError)
    }
    
    init(uploadData: ShopLiveShortformUploaderData?) {
        self.uploaderData = uploadData
    }
    
    func action(_ action: Action) {
        switch action {
        case .viewWillAppear:
            self.onViewWillAppear()
        case .viewDidLoad:
            self.onViewDidLoad()
        case .sendWebEvent(let event, let parameter):
            self.onSendWebEvent(event: event, parameter: parameter)
        case .sendShortEvent(let event, let parameter):
            self.onSendShortEvent(event: event, parameter: parameter)
        case .openPreview(let data):
            self.onOpenPreview(data: data)
        case .openVideoEditor:
            self.onOpenVideoEditor()
        case .openCoverPicker(let shortsId, let videoUrl):
            self.onOpenCoverPicker(shortsId: shortsId, videoUrl: videoUrl)
        case .onEvent(let name,let payload):
            self.onEvent(name: name, payload: payload)
        case .closeViewController:
            self.onCloseViewController()
        }
    }
    
    deinit {
        ShopLiveLogger.memoryLog("SLUGCUploadRactor deinited")
    }
    
    private func onViewWillAppear() {
        
    }
    
    private func onViewDidLoad() {
        getOverlayUrl(completion: { [weak self] url in
            if let url {
                ShopLiveLogger.tempLog("URL \(url.absoluteString)")
                self?.mainQueueResultHandler?( .loadWebView(url: url) )
            }
        })
    }
    
    private func onSendWebEvent(event: ShopLiveShortformUploaderWebInterface, parameter: [String : Any]?) {
        mainQueueResultHandler?( .sendWebEvent(event: event, parameter: parameter) )
    }
    
    private func onSendShortEvent(event: String, parameter: [String : Any]?) {
        mainQueueResultHandler?( .sendShortEvent(event: event, parameter: parameter) )
    }
    
    private func onOpenPreview(data: SLUploadAttachmentInfo) {
        mainQueueResultHandler?( .openPreview(data: data) )
    }
    
    private func onOpenVideoEditor() {
        mainQueueResultHandler?( .openVideoEditor )
    }
    
    private func onOpenCoverPicker(shortsId: String, videoUrl: String?) {
        mainQueueResultHandler?( .openCoverPicker(shortsId: shortsId, videoUrl: videoUrl) )
    }
    
    private func onEvent(name: String, payload: [String : Any]?) {
        mainQueueResultHandler?( .onEvent(name: name, payload: payload) )
    }
    
    private func onCloseViewController() {
        mainQueueResultHandler?( .closeViewController )
    }
    
    func getOverlayUrl(completion: @escaping ((URL?) -> ())) {
        var payload: String = ""
        
        var customValue: [String : Any] = [:]
        
        if let rating = uploaderData?.ui.rating {
            customValue["uiRating"] = rating
        }
        
        if let videoChange = uploaderData?.ui.videoChange {
            customValue["uiVideoChange"] = videoChange
        }
        
        if let hashTag = uploaderData?.ui.hashTag {
            customValue["uiHashTag"] = hashTag
        }
        
        let payloadDict = getAkAndUserJWTasDict(customValue: customValue)
        
        guard payloadDict["userJWT"] != nil else {
            mainQueueResultHandler?(.onError(error: .init(code: 0, message: "User JWT 확인 필요.\n설정->setUser를 확인해주세요.", error: NSError(domain: "UserJWT is Nil", code: 0))))
            completion(nil)
            return
        }
        
        if let shortJson = payloadDict.toJson_SL()  {
            payload = shortJson
        } else {
            completion(nil)
        }
        
        ShortFormUploadConfigurationInfosManager.shared.callShortsConfigurationAPI { [weak self] value in
            
            let urlString = ShortFormUploadConfigurationInfosManager.shared.getUgcUrl().trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard var urlComponents = URLComponents(string: urlString) else {
                ShopLiveLogger.tempLog("[getOverlayUrl] Invalid base URL: \(urlString)")
                completion(URL(string: urlString))
                return
            }
            
            ShopLiveLogger.tempLog("[getOverlayUrl] payload \(payload)")
            
            var queryItems = urlComponents.queryItems ?? []
            queryItems.append(URLQueryItem(name: "payload", value: payload))
            urlComponents.queryItems = queryItems
            
            guard let url = urlComponents.url else {
                ShopLiveLogger.tempLog("[getOverlayUrl] Failed to create URL from components")
                completion(URL(string: urlString))
                return
            }
            
            ShopLiveLogger.tempLog("[SLUGCUploadReactor] \(#function) URL : \(url.absoluteString)")
            completion(url)
        }
           
    }
    
    private func getAkAndUserJWTasDict(customValue: [String : Any] = [:]) -> [String : Any] {
        var dict : [String : Any] = [:]
        if let ak = ShopLiveCommon.getAccessKey() {
            dict["ak"] = ak
        }
        if let userJWT = ShopLiveCommon.getAuthToken() {
            dict["userJWT"] = userJWT
        }
        if let guestUid = ShopLiveCommon.getGuestUid() {
            dict["guestUid"] = guestUid
        }
        if let ceId = ShopLiveCommon.getCeId() {
            dict["ceId"] = ceId
        }
        if let gaId = ShopLiveCommon.getAdIdentifier() {
            dict["gaId"] = gaId
        }
        if let idfv = UIDevice.idfv_sl, idfv.isEmpty == false {
            dict["idfv"] = idfv
        }
        if let anonId = ShopLiveCommon.getAnonId() {
            dict["anonId"] = anonId
        }
        if let adIdentifier = ShopLiveCommon.getAdIdentifier() {
            dict["adIdentifier"] = adIdentifier
        }
        
        dict["appVersion"] = UIApplication.appVersion_SL()
        dict["sdkVersion"] = ShopLiveCommon.sdkVersion
        
        if let utm_source = ShopLiveCommon.getUtmSource() {
            dict["utm_source"] = utm_source
        }
        if let utm_medium = ShopLiveCommon.getUtmMedium() {
            dict["utm_medium"] =  utm_medium
        }
        if let utm_campaign = ShopLiveCommon.getUtmCampaign() {
            dict["utm_campaign"] =   utm_campaign
        }
        if let utm_content = ShopLiveCommon.getUtmContent() {
            dict["utm_content"] =  utm_content
        }
        
        if !customValue.isEmpty {
            customValue.forEach({ key, value in
                dict[key] = value
            })
        }
        
        return dict
    }
}
