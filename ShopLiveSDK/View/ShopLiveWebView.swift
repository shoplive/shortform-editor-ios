//
//  ShopLiveWebView.swift
//  shopliveWebviewOveray
//
//  Created by ShopLive on 2021/03/12.
//

import Foundation
import WebKit

internal final class ShopLiveWebView: WKWebView {
    override var inputAccessoryView: UIView? {
        return nil
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
    }

    deinit {
        ShopLiveLogger.debugLog("ShopLiveWebView deinit")
    }

    func sendEventToWeb(event: WebInterface, _ param: Any? = nil, _ wrapping: Bool = false) {
        let command: String = param == nil ? "window.__receiveAppEvent('\(event.functionString)');" : "window.__receiveAppEvent('\(event.functionString)', " + (wrapping ? "'\(String(describing: param!))');" : "\(String(describing: param!)));")
//        ShopLiveLogger.debugLog(command)
        ShopLiveViewLogger.shared.addLog(log: .init(logType: .callback, log: "to Web [Interface: \(String(describing: event.functionString))]: [payload: \(String(describing: param))]"))
        ShopLiveLogger.debugLog("to Web [Interface: \(event.functionString)]: [payload: \(param)]")
        self.evaluateJavaScript(command, completionHandler: nil)
    }
}

