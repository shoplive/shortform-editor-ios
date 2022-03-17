//
//  DeepLInkManager.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/21.
//

import Foundation
import UIKit

final class DeepLinkManager {
    static let shared = DeepLinkManager()

    var isSendBackStatue: Bool = false

    enum DeepLink: String, CaseIterable {
        case video

        var command: String {
            switch self {
            case .video:
                return "video"
            }
        }
    }

    func handleDeepLink(_ url: URL?) {

        guard let url = url else { return }

        guard let urlComponent: URLComponents = .init(url: url, resolvingAgainstBaseURL: false), let host = urlComponent.host, let command = DeepLink(rawValue: host) else { return }

        var parameters: [String: Any] = [:]
        urlComponent.queryItems?.forEach({ item in
            parameters[item.name] = item.value?.removingPercentEncoding?.base64Decoded
        })

        switch command {
        case .video:
            guard let alias = parameters["alias"] as? String, let ak = parameters["ak"] as? String, let ck = parameters["ck"] as? String else { return }
            ShopLiveDemoKeyTools.shared.save(key: .init(alias: alias, campaignKey: ck, accessKey: ak))
            ShopLiveDemoKeyTools.shared.saveCurrentKey(alias: alias)
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

    func reset() {

    }
}
