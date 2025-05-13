//
//  SLUGCUploadViewController + WebInterface.swift
//  ShopLiveShortformEditorSDK
//
//  Created by Tabber on 3/19/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import WebKit
import ShopliveSDKCommon

extension ShopLiveShortformUploaderViewController: SLWebviewResponseDelegate {
    func handleEventMessage(message: WKScriptMessage) {
        handleWebInterface(message: message)
        reactor.action(.onEvent(name: message.name, payload: message.body as? [String : Any]))
        ShopLiveLogger.tempLog("[SLUGCUploadViewController] handleEvent -------")
        ShopLiveLogger.tempLog("[SLUGCUploadViewController] handleEvent Name \(message.name)")
        ShopLiveLogger.tempLog("[SLUGCUploadViewController] handleEvent Body \(message.body as? [String : Any])")
    }
    
    func handleWebInterface(message: WKScriptMessage) {
        guard let interface = ShopLiveShortformUploaderWebInterface(message: message) else { return }
        
        switch interface {
        case .setUgcInitialized:
            let dic = reactor.uploaderData?.toDTO().dictionary_SL
            
            ShopLiveLogger.tempLog("[handleWebInterface] setUgcInitialized Dictionary: \(dic)")
            
            reactor.action( .sendShortEvent(event: "SET_SHOW_UGC_EDIT_PAGE", parameter: dic) )
        case .clickVideoEdit:
            reactor.action( .openVideoEditor )
        case .clickVideoPlay(let data):
            reactor.action( .openPreview(data: data) )
        case .clickCoverChange(let shortsId , let videoUrl):
            
            ShopLiveLogger.tempLog("쇼츠 ID \(shortsId)")
            
            reactor.action( .openCoverPicker(shortsId: shortsId, videoUrl: videoUrl) )
        case .closeShortformUgcDetail, .closeUgcListPage:
            reactor.action( .closeViewController )
        case .ugcNetworkError(let message):
            
            let code = Int(message.filter { $0.isNumber }) ?? 0
            
            reactor.mainQueueResultHandler?(.onError(error: .init(code: code,
                                                                message: message,
                                                                error: NSError(domain: message, code: code))))
        case .ugcUploadComplete:
            reactor.mainQueueResultHandler?( .uploadComplete )
        default:
            break
        }
    }
}
