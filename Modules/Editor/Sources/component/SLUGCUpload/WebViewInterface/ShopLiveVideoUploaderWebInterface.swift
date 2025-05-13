//
//  ShopLiveShortformUploaderWebInterface.swift
//  ShopLiveShortformEditorSDK
//
//  Created by Tabber on 3/19/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import WebKit
import ShopliveSDKCommon

public enum ShopLiveShortformUploaderWebInterface {
    
    static var allFunctions: [WebFunction] {
        return WebFunction.allCases
    }
    
    case setUgcInitialized
    case setShowUgcEditPage
    case ugcNetworkError(message: String)
    case clickVideoEdit
    case clickVideoPlay(data: SLUploadAttachmentInfo)
    case clickCoverChange(shortsId: String, videoUrl: String?)
    case sendUGCEditPageWithShorts
    case ugcUploadComplete
    case closeShortformUgcDetail
    case closeUgcListPage
    
    
    var functionString: String {
        switch self {
        case .setUgcInitialized:
            return WebFunction.setUgcInitialized.rawValue
        case .setShowUgcEditPage:
            return WebFunction.setShowUgcEditPage.rawValue
        case .clickVideoEdit:
            return WebFunction.clickVideoEdit.rawValue
        case .clickVideoPlay:
            return WebFunction.clickVideoPlay.rawValue
        case .clickCoverChange:
            return WebFunction.clickCoverChange.rawValue
        case .sendUGCEditPageWithShorts:
            return WebFunction.sendUGCEditPageWithShorts.rawValue
        case .closeShortformUgcDetail:
            return WebFunction.closeShortformUgcDetail.rawValue
        case .ugcNetworkError:
            return WebFunction.ugcNetworkError.rawValue
        case .closeUgcListPage:
            return WebFunction.closeUgcListPage.rawValue
        case .ugcUploadComplete:
            return WebFunction.ugcUploadComplete.rawValue
        }
    }
    
    enum WebFunction: String, CustomStringConvertible, CaseIterable {
        var description: String { return self.rawValue }
        
        case setShowUgcEditPage = "SET_SHOW_UGC_EDIT_PAGE"
        case setUgcInitialized = "SDK_UGC_INITIALIZED"
        case clickVideoEdit = "SDK_UGC_CLICK_VIDEO_EDIT"
        case clickVideoPlay = "SDK_UGC_CLICK_VIDEO_PLAY"
        case clickCoverChange = "SDK_UGC_CLICK_COVER_CHANGE"
        case sendUGCEditPageWithShorts = "SET_SHOW_UGC_EDIT_PAGE_WITH_SHORTS"
        case closeShortformUgcDetail = "CLOSE_SHORTFORM_UGC_DETAIL"
        case closeUgcListPage = "CLOSE_UGC_LIST_PAGE"
        case ugcNetworkError = "SDK_UGC_NETWORK_ERROR"
        case ugcUploadComplete = "SDK_UGC_UPLOAD_COMPLETE"
    }
}

extension ShopLiveShortformUploaderWebInterface {
    init?(message: WKScriptMessage) {
        
        ShopLiveLogger.tempLog("[ShopLiveShortformUploaderWebInterface] message.name \(message.name)")
        
        guard message.name == "ShopLiveAppInterface" else { return nil }
        guard let body = message.body as? [String: Any] else { return nil }
        guard let event = body["shopliveShortsEvent"] as? [String : Any] else { return nil }
        guard let command = event["name"] as? String else { return nil }
        
        let paramters = body["payload"] as? [String : Any]
        
        let function = WebFunction(rawValue: command)
        
        ShopLiveLogger.tempLog("from Web [Interface: \(String(describing: function))]:[payload: \(String(describing: paramters))")
        
        switch function {
        case .setUgcInitialized:
            self = .setUgcInitialized
        case .setShowUgcEditPage:
            self = .setShowUgcEditPage
        case .clickVideoEdit:
            self = .clickVideoEdit
        case .clickVideoPlay:
            let shorts = paramters?["shorts"] as? [String : Any]
            let cards = (shorts?["cards"] as? [[String: Any]])?.first
            guard let originVideoUrl = cards?["originVideoUrl"] as? String else { return nil }
            self = .clickVideoPlay(data: .init(videoUrl: originVideoUrl))
        case .clickCoverChange:
            let shorts = paramters?["shorts"] as? [String : Any]
            let shortsId = shorts?["shortsId"] as? String ?? ""
            let cards = (shorts?["cards"] as? [[String: Any]])?.first
            guard let originVideoUrl = cards?["originVideoUrl"] as? String else { return nil }
            self = .clickCoverChange(shortsId: shortsId, videoUrl: originVideoUrl)
        case .sendUGCEditPageWithShorts:
            self = .sendUGCEditPageWithShorts
        case .closeShortformUgcDetail:
            self = .closeShortformUgcDetail
        case .closeUgcListPage:
            self = .closeUgcListPage
        case .ugcNetworkError:
            guard let message = paramters?["message"] as? String else { return nil }
            self = .ugcNetworkError(message: message)
        case .ugcUploadComplete:
            self = .ugcUploadComplete
        default: return nil
        }
    }
}
