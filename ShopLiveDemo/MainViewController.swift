//
//  MainViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit
import SideMenu
import SafariServices

class MainViewController: SideMenuBaseViewController {

    var safari: SFSafariViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white

        #if QA
            self.title = "Demo QA"
        #else
            self.title = "SDK Demo"
        #endif

        ShopLive.delegate = self

        self.items.insert("DevInfoCell", at: 0)
        self.tableView.register(DevInfoCell.self, forCellReuseIdentifier: "DevInfoCell")
        setupSampleOptions()
    }

    func setupSampleOptions() {
        SampleOptions.campaignNaviMoreOptions = ["campaign.menu.write".localized(), "Dev-Admin", "Admin", "campaign.menu.deleteall".localized()]
        SampleOptions.campaignNaviMoreSelectionAction = { (index: Int, item: String) in
            print("selected item: \(item) index: \(index)")
            var sourceScheme = ""
            #if DEMO
                #if QA
                    sourceScheme = "shopliveqa"
                #else
                    sourceScheme = "shoplive"
                #endif
            #endif
            switch index {
            case 0: // 직접 입력
                let vc = CampaignInputAlertController()
                vc.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(vc, animated: false, completion: nil)
                break
            case 1: // Dev-Admin
                // getkey
                DeepLinkManager.shared.sendDeepLink("shoplivestudiodev://getkey?source=\(sourceScheme)")
                break
            case 2: // Admin
                // getkey
                DeepLinkManager.shared.sendDeepLink("shoplivestudio://getkey?source=\(sourceScheme)")
                break
            case 3: // 전체삭제
                guard ShopLiveDemoKeyTools.shared.keysets.count > 0 else {
                    return
                }
                let alert = UIAlertController(title: "campaign.msg.deleteAll.title".localized(), message: nil, preferredStyle: .alert)
                alert.addAction(.init(title: "alert.msg.no".localized(), style: .cancel, handler: { action in

                }))
                alert.addAction(.init(title: "alert.msg.ok".localized(), style: .default, handler: { action in
                    ShopLiveDemoKeyTools.shared.clearKey()
                }))
                self.present(alert, animated: true, completion: nil)
                break
            default:
                break
            }

        }
    }

    func setupShopliveSettings() {
        let config = DemoConfiguration.shared

        if config.useJWT {
            ShopLive.authToken = config.jwtToken
        } else {
            // user setting
            if let userId = config.user.id, !userId.isEmpty {
                ShopLive.user = config.user
            }
        }

        // Keep play video on headphone unplugged setting
        ShopLive.setKeepPlayVideoOnHeadphoneUnplugged(config.useHeadPhoneOption1)

        // Auto resume video on call end setting
        ShopLive.setAutoResumeVideoOnCallEnded(config.useCallOption)

        // Custom Image Animation Indicator setting
        if config.useCustomProgress {
            var images: [UIImage] = []

            for i in 1...11 {
                images.append(.init(named: "loading\(i)")!)
            }

            ShopLive.setLoadingAnimation(images: images)
        }

        // Share URL/Scheme Setting
        if let scheme = config.shareScheme, !scheme.isEmpty {
            if config.useCustomShare {
                // Custom Share Setting
                ShopLive.setShareScheme(scheme, custom: {
                    let alert = UIAlertController.init(title: "guide.customShare".localized(), message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "alert.msg.confirm".localized(), style: .default, handler: { (action) in
                    }))
                    ShopLive.viewController?.present(alert, animated: true, completion: nil)
                })
            } else {
                // Default iOS Share
                ShopLive.setShareScheme(scheme, custom: nil)
            }
        }

        // Custom Font Setting
        let inputDefaultFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let sendButtonDefaultFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        if let customFont = config.customFont {
            ShopLive.setChatViewFont(inputBoxFont: config.useChatInputCustomFont ? customFont : inputDefaultFont, sendButtonFont: config.useChatSendButtonCustomFont ? customFont : sendButtonDefaultFont)
        }

        // Picture in Picture Setting
        ShopLive.pipScale = config.pipScale ?? 2/5
        ShopLive.pipPosition = config.pipPosition

        // Phase Setting
        #if DEMO
        ShopLiveDefines.phase = ShopLiveDevConfiguration.shared.phaseType
        #endif
    }

    override func preview() {
        guard let currentKey = ShopLiveDemoKeyTools.shared.currentKey() else {
            UIWindow.showToast(message: "sdk.msg.nonekey".localized())
            return
        }

        setupShopliveSettings()
        ShopLive.configure(with: currentKey.accessKey)
        ShopLive.preview(with: currentKey.campaignKey) {
            ShopLive.play(with: currentKey.campaignKey)
        }
    }

    override func play() {
        guard let currentKey = ShopLiveDemoKeyTools.shared.currentKey() else {
            UIWindow.showToast(message: "sdk.msg.nonekey".localized())
            return
        }

        setupShopliveSettings()
        ShopLive.configure(with: currentKey.accessKey)

        ShopLive.play(with: currentKey.campaignKey)
    }

}

extension MainViewController: ShopLiveSDKDelegate {
    func handleNavigation(with url: URL) {
        print("handleNavigation \(url)")
        ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: "handleNavigation \(url)"))

        guard url.absoluteString.hasPrefix("http") else {
            let alert = UIAlertController(title: nil, message: "campaign.msg.wrongurl".localized() + "[\(url.absoluteString)]", preferredStyle: .alert)
            alert.addAction(.init(title: "alert.msg.confirm".localized(), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }

        if #available(iOS 13, *) {
            if let browser = self.safari {
                browser.dismiss(animated: false, completion: nil)
            }

            safari = .init(url: url)

            guard let browser = self.safari else { return }
            self.present(browser, animated: true)
        } else {
            // TODO: Single UIWindow 에서 PIP 처리 적용 필요
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func handleChangeCampaignStatus(status: String) {
        print("handleChangeCampaignStatus \(status)")
        ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: "handleChangeCampaignStatus \(status)"))
    }

    func handleError(code: String, message: String) {
        print("handleError")
        ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: "handleError \(code)  \(message)"))
    }

    func handleCampaignInfo(campaignInfo: [String : Any]) {
        print("handleCampaignInfo")
        ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: "handleCampaignInfo \(campaignInfo)"))
    }

    func handleDownloadCouponResult(with couponId: String, completion: @escaping (CouponResult) -> Void) {
        print("handleDownloadCouponResult")
        let alert = UIAlertController(title: "sample.coupon.download".localized(), message: "sample.coupon.id".localized() + ": \(couponId)", preferredStyle: .alert)
        alert.addAction(.init(title: "alert.msg.failed".localized(), style: .cancel, handler: { _ in
            DispatchQueue.main.async {
                let message = SDKSettings.downloadCouponFailedMessage
                let status = SDKSettings.downloadCouponFailedStatus
                let alertType = SDKSettings.downloadCouponFailedAlertType
                DispatchQueue.main.async {
                    let result = CouponResult(couponId: couponId, success: false, message: message, status: status, alertType: alertType)
                    completion(result)
                }
            }
        }))
        alert.addAction(.init(title: "alert.msg.success".localized(), style: .default, handler: { _ in
            let message = SDKSettings.downloadCouponSuccessMessage
            let status = SDKSettings.downloadCouponSuccessStatus
            let alertType = SDKSettings.downloadCouponSuccessAlertType
            DispatchQueue.main.async {
                let result = CouponResult(couponId: couponId, success: true, message: message, status: status, alertType: alertType)
                completion(result)
            }
        }))
        ShopLive.viewController?.present(alert, animated: true, completion: nil)
    }

    /*
     // deprecated
    func handleCustomAction(with id: String, type: String, payload: Any?, completion: @escaping () -> Void) {
        print("handleCustomAction \(id) \(type) \(payload.debugDescription)")
    }
    */

    func handleCustomActionResult(with id: String, type: String, payload: Any?, completion: @escaping (CustomActionResult) -> Void) {
        print("handleCustomActionResult")

        let alert = UIAlertController(title: "CUSTOM ACTION", message: "id: \(id)\ntype: \(type)\npayload: \(String(describing: payload))", preferredStyle: .alert)
        alert.addAction(.init(title: "alert.msg.failed".localized(), style: .cancel, handler: { _ in
            DispatchQueue.main.async {
                let message = SDKSettings.downloadCouponFailedMessage
                let status = SDKSettings.downloadCouponFailedStatus
                let alertType = SDKSettings.downloadCouponFailedAlertType
                let result = CustomActionResult(id: id, success: false, message: message, status: status, alertType: alertType)
                completion(result)
            }
        }))
        alert.addAction(.init(title: "alert.msg.success".localized(), style: .default, handler: { _ in
            let message = SDKSettings.downloadCouponSuccessMessage
            let status = SDKSettings.downloadCouponSuccessStatus
            let alertType = SDKSettings.downloadCouponSuccessAlertType
            DispatchQueue.main.async {
                let result = CustomActionResult(id: id, success: true, message: message, status: status, alertType: alertType)
                completion(result)
            }
        }))
        ShopLive.viewController?.present(alert, animated: true, completion: nil)
    }

    func handleCommand(_ command: String, with payload: Any?) {
        print("handleCommand: \(command)  payload: \(String(describing: payload))")
        ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: "handleCommand \(command)"))
    }

    func onSetUserName(_ payload: [String : Any]) {
        print("onSetUserName")
        payload.forEach { (key, value) in
            print("onSetUserName key: \(key) value: \(value)")
        }
    }

    func handleReceivedCommand(_ command: String, with payload: Any?) {
        print("handleReceivedCommand command: \(command) payload: \(String(describing: payload))")
    }
}
