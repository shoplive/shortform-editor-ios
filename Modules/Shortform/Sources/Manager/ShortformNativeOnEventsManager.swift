//
//  ShortformNativeOnEventsManager.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/07/27.
//

import Foundation


class ShortformNativeOnEventsManager {

    enum NativeOnEventsCommands : String {
        case collection_show = "COLLECTION_SHOW"
        case collection_click_item = "COLLECTION_CLICK_ITEM"

        case preview_shown = "PREVIEW_SHOWN"
        case preview_hidden = "PREVIEW_HIDDEN"
        case preview_click_show = "PREVIEW_CLICK_SHOW"
        case preview_click_close = "PREVIEW_CLICK_CLOSE"

        case detail_on_player_shown = "DETAIL_ON_PLAYER_SHOWN"
        case detail_on_player_dismiss = "DETAIL_ON_PLAYER_DISMISS"
        
        case video_muted = "VIDEO_MUTED"
        case video_unmuted = "VIDEO_UNMUTED"
    }


    
    class func sendNativeOnEvents(delegate : ShopLiveShortformReceiveHandlerDelegate?, command : NativeOnEventsCommands, payload : [String : Any]?, shortsId : String?, shortsDetail : ShortsDetail?) {
        let commandString = command.rawValue
        
        var payLoadJsonString : String? = nil
        var payLoadDict : [String : Any] = [:]
        var shortsDict : [String : Any] = [:]
        
        if let payload = payload {
            for (key,value) in payload {
                payLoadDict[key] = value
            }
        }
        if let shortsId = shortsId {
            shortsDict["shortsId"] = shortsId
        }
        if let shortsDetail = shortsDetail {
            shortsDict["shortsDetail"] = shortsDetail.dictionary_SL
        }
        if shortsDict.keys.count != 0 {
            payLoadDict["shorts"] = shortsDict
        }
        
        if payLoadDict.keys.count != 0{
            payLoadJsonString = payLoadDict.toJSONString_SL()
        }
        else {
            payLoadJsonString = "{}"
        }
        
        delegate?.onEvent?(messenger: nil, command: commandString, payload: payLoadJsonString)
    }
}
