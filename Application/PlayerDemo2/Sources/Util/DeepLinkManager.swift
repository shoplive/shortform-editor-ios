//
//  DeepLinkManager.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopLiveSDK
import ShopliveSDKCommon

final class DeepLinkManager {
    static let shared = DeepLinkManager()

    var isSendBackStatue: Bool = false

    enum DeepLink: String, CaseIterable {
        case live
        case product
        case pip
        case fullscreen
        case video
        
        
        case deepLinkVideo
        case deepLinkPip

        var command: String {
            return self.rawValue
        }
    }
    
    //ex deep link용 테스트 링크
    //shopliveqa://deepLinkVideo?ak=q3hZYwpJ1xukW8bTDsxj&ck=67331853a0c9&showType=preview&alias=deeplinkTest
    func handleDeepLink(_ url: URL?) {
        guard let url = url else { return }
        guard let urlComponent: URLComponents = .init(url: url, resolvingAgainstBaseURL: false), let host = urlComponent.host, let command = DeepLink(rawValue: host) else { return }
        var parameters: [String: Any] = [:]
        urlComponent.queryItems?.forEach({ item in
            if command == .deepLinkPip || command == .deepLinkVideo {
                if let value = item.value?.removingPercentEncoding {
                    parameters[item.name] = value
                }
            }
            else if command == .product {
                if let value = item.value?.removingPercentEncoding {
                    parameters[item.name] = value.base64Decoded
                }
            }
            else {
                if let value = item.value?.removingPercentEncoding {
                    parameters[item.name] = value.base64Decoded
                }
                else {
                    parameters[item.name] = ""
                }
            }
        })
        

        switch command {
        case .live, .video, .deepLinkVideo:
            guard let alias = parameters["alias"] as? String, let ak = parameters["ak"] as? String, let ck = parameters["ck"] as? String else { return }
            ShopLiveDemoKeyTools.shared.save(key: .init(alias: alias, campaignKey: ck, accessKey: ak))
            ShopLiveDemoKeyTools.shared.saveCurrentKey(alias: alias)
            ShopLive.configure(with: ak)
            ShopLive.setInAppPipConfiguration(config: .init(enableSwipeOut: true))
            if let showType = parameters["showType"] as? String {
                if showType == "preview" {
                    ShopLive.preview(data: ShopLivePlayerData(campaignKey: ck), completion: nil)
                }
                else {
                    ShopLive.play(data: ShopLivePlayerData(campaignKey: ck))
                }
            }
            else {
                ShopLive.play(data: ShopLivePlayerData(campaignKey: ck))
            }
        
            break
        case .product:
            ShopLive.startPictureInPicture()
            let alert = UIAlertController(title: command.command, message: (parameters != nil ? parameters.toJson() : ""), preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: UIAlertAction.Style.default))
            UIApplication.topViewController(base: AppDelegate.rootViewController)?.present(alert, animated: true)
            break
        case .pip, .deepLinkPip:
            ShopLive.startPictureInPicture()
            break
        case .fullscreen:
            ShopLive.stopPictureInPicture()
            break
        default:
            break
        }
    }

    func sendDeepLink(_ data: String) {
        guard let scheme = data.removingPercentEncoding,
                let schemeUrl = URL(string: scheme.removingPercentEncoding ?? ""),
                UIApplication.shared.canOpenURL(schemeUrl) else { return }

        UIApplication.shared.open(schemeUrl, options: [:], completionHandler: nil)
    }

    
    private func isBase64Encoded(_ input: String) -> Bool {
        if let inputData = Data(base64Encoded: input) {
            if let decodedString = String(data: inputData, encoding: .utf8) {
                return decodedString == input
            }
        }
        return false
    }
    
    func reset() {

    }
}
