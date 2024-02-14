//
//  ShortformEventTraceManager.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/07/21.
//

import Foundation
import ShopliveSDKCommon


class ShortformEventTraceManager {
    
    
    enum ListType : String{
        case CARD
        case VERTICAL
        case HORIZONTAL
    }
    
    enum OverlayType : String {
        case TYPE0
        case TYPE1
        case TYPE2
    }
    
    class func processCollectionShowEventTrace(shortsList : [ShopLiveShortform.ShortsModel], shortsCollection : ShopLiveShortform.ShortsCollectionModel?, listType : ListType, overlayType : OverlayType,  isReset : Bool,paginationCount : Int,tagsAndBrandRequestParameterModel : InternalShortformCollectionData?, sdkOptionsData : ShopLiveShortformSDKOptionsData?,shopliveSessionId : String?){
        let srn : String? = shortsCollection?.srn
       
       
        let val1 : String = listType.rawValue
        let val2 : String = overlayType.rawValue
        let val3 : String = makeArrayToString(stringArray:  shortsList.map({ $0.shortsId ?? "null" }) )
        var val4 : [String : Any] = [:]
        if let model = tagsAndBrandRequestParameterModel {
            val4["tags"] = model.tags
            val4["tagSearchOperator"] = model.tagSearchOperator
            val4["brands"] = model.brands
            val4["shuffle"] = model.shuffle ?? false
        }
        var val5 : [String : Any] = [:]
        if let model = sdkOptionsData {
            val5 = model.toDictionary()
        }
        self.callEventTraceAPI(eventName: .COLLECTION_SHOW, eventCategory: .COLLECTION, eventType: .VIEW, srn: srn, referrer: nil, shopliveSessionId: shopliveSessionId, val1: val1, val2: val2, val3: val3, val4: val4.toJSONString_SL(),val5: val5.toJSONString_SL())
    }
    
    class func processCollectionClickItemEventTrace(shortCollectionSrn : String?,shortsSrn : String?,shopliveSessionId : String?){
        self.callEventTraceAPI(eventName: .COLLECTION_CLICK_ITEM, eventCategory: .COLLECTION, eventType: .UI, srn: shortCollectionSrn, referrer: nil, shopliveSessionId: shopliveSessionId, val1: shortsSrn, val2: nil, val3: nil, val4: nil,val5: nil)
    }
    
    
    class func processPreviewShownHidden(shortsCollectionSrn : String?, isShown : Bool, isClick : Bool,shopliveSessionId : String?){
        
        if isClick {
            let eventName : ShortsEventTraceAPI.EventName = isShown ? .PREVIEW_CLICK_SHOW : .PREVIEW_CLICK_CLOSE
            self.callEventTraceAPI(eventName: eventName, eventCategory: .PREVIEW, eventType: .VIEW, srn: shortsCollectionSrn, referrer: nil, shopliveSessionId: shopliveSessionId, val1: nil, val2: nil, val3: nil, val4: nil,val5: nil)
        }
        else {
            let eventName : ShortsEventTraceAPI.EventName = isShown ? .PREVIEW_SHOWN : .PREVIEW_HIDDEN
            self.callEventTraceAPI(eventName: eventName, eventCategory: .PREVIEW, eventType: .VIEW, srn: shortsCollectionSrn, referrer: nil, shopliveSessionId: shopliveSessionId, val1: nil, val2: nil, val3: nil, val4: nil,val5: nil)
        }
    }
    
    

    private class func callEventTraceAPI(eventName : ShortsEventTraceAPI.EventName, eventCategory : ShortsEventTraceAPI.EventCategory, eventType : ShortsEventTraceAPI.EventType,srn : String?, referrer : String?, shopliveSessionId : String?, val1 : Any?, val2 : Any?, val3 : Any?, val4 : Any?,val5 : Any?) {
        
        if ShortFormConfigurationInfosManager.shared.shortsConfiguration.eventTraceEndpoint == "" {
            return
        }
        ShortsEventTraceAPI(eventName: eventName, eventCategory: eventCategory ,eventType: eventType, srn: srn,referrer: referrer, shopliveSessionId: shopliveSessionId, val1: val1,val2: val2,val3: val3,val4: val4,val5: val5).request { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                break
            }
        }
    }
    
    
    private class func makeArrayToString(stringArray : [String]) -> String {
        if stringArray.isEmpty {
            return "[]"
        }
        var result = "["
        for i in 0 ..< stringArray.count {
            if i != stringArray.count - 1 {
                result += "\"" + stringArray[i] + "\","
            }
            else {
                result += "\"" + stringArray[i] + "\"]"
            }
            
        }
        return result
    }
    
    
    
}
