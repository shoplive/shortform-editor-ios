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
        case product

        var command: String {
            return self.rawValue
        }
    }

    func handleDeepLink(_ url: URL?) {
        ShopLive.startPictureInPicture()
        return
        guard let url = url else { return }

        guard let urlComponent: URLComponents = .init(url: url, resolvingAgainstBaseURL: false), let host = urlComponent.host, let command = DeepLink(rawValue: host) else { return }

        var parameters: [String: Any] = [:]
        urlComponent.queryItems?.forEach({ item in
            parameters[item.name] = (command == .product) ? item.value?.removingPercentEncoding :  item.value?.removingPercentEncoding?.base64Decoded
        })

        switch command {
        case .video:
            guard let alias = parameters["alias"] as? String, let ak = parameters["ak"] as? String, let ck = parameters["ck"] as? String else { return }
            ShopLiveDemoKeyTools.shared.save(key: .init(alias: alias, campaignKey: ck, accessKey: ak))
            ShopLiveDemoKeyTools.shared.saveCurrentKey(alias: alias)
            break
        case .product:
            ShopLive.startPictureInPicture()
            let alert = UIAlertController(title: command.command, message: (parameters != nil ? parameters.toJson() : ""), preferredStyle: .alert)
            alert.addAction(.init(title: "Ok", style: UIAlertAction.Style.default))
            UIApplication.topViewController(base: AppDelegate.rootViewController)?.present(alert, animated: true)
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
