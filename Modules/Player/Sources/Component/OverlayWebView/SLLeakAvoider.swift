//
//  SLLeakAvoider.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 11/28/23.
//

import Foundation
import UIKit
import WebKit

final class SLLeakAvoider : NSObject, WKScriptMessageHandler {
    weak var delegate : WKScriptMessageHandler?
    init(delegate:WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(
            userContentController, didReceive: message)
    }
}
