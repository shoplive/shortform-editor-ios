//
//  ShopLiveWebView.swift
//  shopliveWebviewOveray
//
//  Created by ShopLive on 2021/03/12.
//

import Foundation
import WebKit
import ShopliveSDKCommon

/**
    Send data to web client
        - Sending the data to Web Client
 */
final class ShopLiveWebView: SLWKWebView {
  
    enum ViewMode : String {
        case fullPlayer
        case previewPlayer
    }
    
    var currentViewMode : ViewMode = .fullPlayer
    
    override var inputAccessoryView: SLView? {
        return nil
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
    }
    
    private var isLoaded : Bool = false
    
    private var queuedRequest : [String] = []
    
    func setIsLoaded(isLoaded : Bool) {
        self.isLoaded = isLoaded
    }
    
    func removeQueuedRequest() {
        self.queuedRequest.removeAll()
    }
    
    func invokeQueuedRequest() {
        guard let firstCommand = self.queuedRequest.first else { return }
        self.queuedRequest.removeFirst()
        self.evaluateJavaScript(firstCommand) { [weak self] some, error  in
            self?.invokeQueuedRequest()
        }
    }

    func sendEventToWeb(event: WebInterface, _ param: Any? = nil, _ wrapping: Bool = false) {
        let command: String = param == nil ? "window.__receiveAppEvent('\(event.functionString)');" : "window.__receiveAppEvent('\(event.functionString)', " + (wrapping ? "'\(String(describing: param!))');" : "\(String(describing: param!)));")
//        ShopLiveLogger.tempLog("[WEBVIEWESEND] \(command)")
//        ShopLiveLogger.tempLog("to Web [Interface: \(event.functionString)]: [payload: \(String(describing: param))]")
        if event.functionString != WebInterface.onVideoTimeUpdated.functionString && event.functionString != WebInterface.onVideoMetadataUpdated.functionString {
            ShopLiveLogger.tempLog(" \(currentViewMode.rawValue) to Web [Interface: \(event.functionString)]: [payload: \(String(describing: param))]")
        }
        if isLoaded == false {
            self.queuedRequest.append(command)
        }
        self.evaluateJavaScript(command, completionHandler: nil)
    }
    
    /**
     mute가 보내 졌는지 아닌지 확실한 반응을 얻기 위해서 새로 추가 
     */
    func sendMuteStateToWeb(event: WebInterface, _ param: Any? = nil, _ wrapping: Bool = false , completion : @escaping (_ success : Bool) -> ()) {
        let command: String = param == nil ? "window.__receiveAppEvent('\(event.functionString)');" : "window.__receiveAppEvent('\(event.functionString)', " + (wrapping ? "'\(String(describing: param!))');" : "\(String(describing: param!)));")
        if event.functionString != WebInterface.onVideoTimeUpdated.functionString && event.functionString != WebInterface.onVideoMetadataUpdated.functionString {
            ShopLiveLogger.tempLog("to Web [Interface: \(event.functionString)]: [payload: \(String(describing: param))]")
        }
        if isLoaded == false {
            self.queuedRequest.append(command)
        }
        else {
            self.evaluateJavaScript(command) { _, error  in
                guard let error = error else {
                    completion(true)
                    return
                }
                completion(false)
            }
        }
        
    }
}

