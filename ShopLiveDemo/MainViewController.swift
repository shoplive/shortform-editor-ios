//
//  MainViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit
import SideMenu
import SafariServices
import Toast

class MainViewController: SideMenuBaseViewController {

    static var instance: UIViewController?
    var safari: SFSafariViewController? = nil

    lazy var tabbar: UITabBar = {
        let view = UITabBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(ShopLive.sdkVersion)
        AppDelegate.rootViewController = self.navigationController

        self.view.backgroundColor = .white

        #if QA
            #if EBAY
            self.title = "Demo QA"
            #else
            self.title = "Demo QA"
            #endif
        #else
            self.title = "SDK Demo"
        #endif

        ShopLive.delegate = self

        self.items.insert("DevInfoCell", at: 0)
        self.tableView.register(DevInfoCell.self, forCellReuseIdentifier: "DevInfoCell")
        setupSampleOptions()
        ShopLive.pipPosition = .bottomLeft
        
        self.view.addSubviews(tabbar)
        tabbar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    func setupSampleOptions() {
        
        SampleOptions.campaignNaviMoreOptions = ["campaign.menu.write".localized(), "Dev-Admin", "Admin", "campaign.menu.deleteall".localized()]
        SampleOptions.campaignNaviMoreSelectionAction = { (index: Int, item: String) in
            print("selected item: \(item) index: \(index)")
            var sourceScheme = ""
            #if DEMO
                #if QA
                    sourceScheme = "shopliveqa"
                    #if EBAY
                    sourceScheme = "shopliveqa"//"shoplivesample"
                    #endif
                #else
                    sourceScheme = "shoplive"
                #endif
            #endif
            switch index {
            case 0: // Direct input
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
            case 3: // Remove all
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
            } else {
                ShopLive.user = nil
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
        
        if let progressColor = config.progressColor {
            ShopLive.indicatorColor = UIColor(progressColor)
        }

        // Share URL/Scheme Setting
        if let scheme = config.shareScheme, !scheme.isEmpty {
            if config.useCustomShare {
                // Custom Share Setting
                
                ShopLive.setShareScheme(scheme, custom: {
                    let customShareVC = CustomShareViewController()
                    customShareVC.modalPresentationStyle = .overFullScreen
                    ShopLive.viewController?.present(customShareVC, animated: false, completion: nil)
                })
            } else {
                // Default iOS Share
                ShopLive.setShareScheme(scheme, custom: nil)
            }
        }

        // Custom Font Setting
        if let customFont = config.customFont {
            ShopLive.setChatViewFont(inputBoxFont: config.useChatInputCustomFont ? customFont : nil, sendButtonFont: config.useChatSendButtonCustomFont ? customFont : nil)
        }

        // Picture in Picture Setting
        ShopLive.pipScale = config.pipScale ?? 2/5
//        ShopLive.pipPosition = config.pipPosition

        // handle Navigation Action Type
        ShopLive.setNextActionOnHandleNavigation(actionType: DemoConfiguration.shared.nextActionTypeOnHandleNavigation)
        
        // Pip padding setting
        let padding = config.pipPadding
        ShopLive.setPictureInPicturePadding(padding: .init(top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right))
        
        // Pip floating offset setting
        let floatingOffset = config.pipFloatingOffset
        ShopLive.setPictureInPictureFloatingOffset(offset: .init(top: floatingOffset.top, left: floatingOffset.left, bottom: floatingOffset.bottom, right: floatingOffset.right))
        
        // Mute Sound Setting
        ShopLive.setMuteWhenPlayStart(config.isMuted)
        
        // Phase Setting
        #if DEMO
        ShopLiveDefines.phase = ShopLiveDevConfiguration.shared.phaseType
        #endif

        #if LOCAL_LANDING
        ShopLive.setUsingLocalLanding(ShopLiveDevConfiguration.shared.useLocalLanding)
        #endif
        
        ShopLive.setKeepAspectOnTabletPortrait(config.useAspectOnTablet)
        
        #if MUSINSA
        ShopLive.fixedPipWidth = DemoConfiguration.shared.fixedPipWidth as? NSNumber
        #endif
    }

    override func preview() {
        guard let currentKey = ShopLiveDemoKeyTools.shared.currentKey() else {
            UIWindow.showToast(message: "sdk.msg.nonekey".localized())
            return
        }

        setupShopliveSettings()
        ShopLive.setEndpoint(nil)
        ShopLive.configure(with: currentKey.accessKey)
        ShopLive.preview(with: currentKey.campaignKey) {
            if DemoConfiguration.shared.usePlayWhenPreviewTapped {
                ShopLive.play(with: currentKey.campaignKey, keepWindowStateOnPlayExecuted: DemoConfiguration.shared.useKeepWindowStateOnPlayExecuted)
            } else {
                var toastStyle = ToastStyle()
                toastStyle.titleAlignment = .center
                toastStyle.messageAlignment = .center
                self.view.makeToast("tap preview", duration: 2,style: toastStyle)
            }
        }
    }

    override func play() {
        guard let currentKey = ShopLiveDemoKeyTools.shared.currentKey() else {
            UIWindow.showToast(message: "sdk.msg.nonekey".localized())
            return
        }
        
        ShopLive.setEndpoint(nil)
        setupShopliveSettings()
        ShopLive.configure(with: currentKey.accessKey)

        ShopLive.play(with: currentKey.campaignKey, keepWindowStateOnPlayExecuted: DemoConfiguration.shared.useKeepWindowStateOnPlayExecuted)
    }

}

extension MainViewController: ShopLiveSDKDelegate {
    #if MUSINSA
    func log(name: String, feature: ShopLiveLog.Feature, campaign: String, parameter: [String : String]) {
        ShopLiveLogger.debugLog("log name \(name) feature \(feature.name) campaignKey \(campaign) parameter \(parameter)")
    }
    
    func playerPanGesture(state: UIGestureRecognizer.State, position: CGPoint) {
        ShopLiveLogger.debugLog("window gesture state \(state) position \(position)")
    }
    #endif
    func handleNavigation(with url: URL) {
        print("handleNavigation \(url)")
        ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: "handleNavigation \(url)"))
        
        var presenter: UIViewController?
        
        switch DemoConfiguration.shared.nextActionTypeOnHandleNavigation {
        case .PIP, .CLOSE:
            presenter = self
            break
        case .KEEP:
            presenter = ShopLive.viewController
            break
        }

        guard url.absoluteString.hasPrefix("http") else {
            let alert = UIAlertController(title: nil, message: "campaign.msg.wrongurl".localized() + "[\(url.absoluteString)]", preferredStyle: .alert)
            alert.addAction(.init(title: "alert.msg.confirm".localized(), style: .default, handler: nil))
            presenter?.present(alert, animated: true, completion: nil)
            return
        }

        if #available(iOS 13, *) {
            if let browser = self.safari {
                browser.dismiss(animated: false, completion: nil)
            }

            safari = .init(url: url)

            guard let browser = self.safari else { return }
            presenter?.present(browser, animated: true)
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
        print("handleError \(code)  \(message)")
        ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: "handleError \(code)  \(message)"))
    }

    func handleCampaignInfo(campaignInfo: [String : Any]) {
        print("handleCampaignInfo")
        
        campaignInfo.forEach { info in
            print("campaignInfo key: \(info.key)  value: \(info.value)")
        }
        ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: "handleCampaignInfo \(campaignInfo)"))
    }

    /*
     // deprecated
     func handleDownloadCoupon(with couponId: String, completion: @escaping () -> Void)
    
     func handleDownloadCouponResult(with couponId: String, completion: @escaping (CouponResult) -> Void)
    */
    
    func handleDownloadCoupon(with couponId: String, result: @escaping (ShopLiveCouponResult) -> Void) {
        print("handleDownloadCouponResult")
        let alert = UIAlertController(title: "sample.coupon.download".localized(), message: "sample.coupon.id".localized() + ": \(couponId)", preferredStyle: .alert)
        alert.addAction(.init(title: "alert.msg.failed".localized(), style: .cancel, handler: { _ in
            DispatchQueue.main.async {
                let message = SDKSettings.downloadCouponFailedMessage
                let status = SDKSettings.downloadCouponFailedStatus
                let alertType = SDKSettings.downloadCouponFailedAlertType
                DispatchQueue.main.async {
                    let couponResult = ShopLiveCouponResult(couponId: couponId, success: false, message: message, status: status, alertType: alertType)
                    result(couponResult)
                }
            }
        }))
        alert.addAction(.init(title: "alert.msg.success".localized(), style: .default, handler: { _ in
            let message = SDKSettings.downloadCouponSuccessMessage
            let status = SDKSettings.downloadCouponSuccessStatus
            let alertType = SDKSettings.downloadCouponSuccessAlertType
            DispatchQueue.main.async {
                let couponResult = ShopLiveCouponResult(couponId: couponId, success: true, message: message, status: status, alertType: alertType)
                result(couponResult)
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

    /*
     // deprecated
    func handleCustomActionResult(with id: String, type: String, payload: Any?, completion: @escaping (CustomActionResult) -> Void) {
    }
     */
    
    func handleCustomAction(with id: String, type: String, payload: Any?, result: @escaping (ShopLiveCustomActionResult) -> Void) {
        print("handleCustomActionResult")

        let alert = UIAlertController(title: "CUSTOM ACTION", message: "id: \(id)\ntype: \(type)\npayload: \(String(describing: payload))", preferredStyle: .alert)
        alert.addAction(.init(title: "alert.msg.failed".localized(), style: .cancel, handler: { _ in
            DispatchQueue.main.async {
                let message = SDKSettings.downloadCouponFailedMessage
                let status = SDKSettings.downloadCouponFailedStatus
                let alertType = SDKSettings.downloadCouponFailedAlertType
                let customActionResult = ShopLiveCustomActionResult(id: id, success: false, message: message, status: status, alertType: alertType)
                result(customActionResult)
            }
        }))
        alert.addAction(.init(title: "alert.msg.success".localized(), style: .default, handler: { _ in
            let message = SDKSettings.downloadCouponSuccessMessage
            let status = SDKSettings.downloadCouponSuccessStatus
            let alertType = SDKSettings.downloadCouponSuccessAlertType
            DispatchQueue.main.async {
                let customActionResult = ShopLiveCustomActionResult(id: id, success: true, message: message, status: status, alertType: alertType)
                result(customActionResult)
            }
        }))
        ShopLive.viewController?.present(alert, animated: true, completion: nil)
    }

    func handleCommand(_ command: String, with payload: Any?) {
        print("handleCommand: \(command)  payload: \(String(describing: payload))")
        ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: "handleCommand \(command)"))
        
        if command == "didTapCloseButton" {
            self.preview()
        } else if command == "CLOSE_FROM_PIP" {
            
        }
    }

    func onSetUserName(_ payload: [String : Any]) {
        print("onSetUserName")
        payload.forEach { (key, value) in
            print("onSetUserName key: \(key) value: \(value)")
        }
    }

    func handleReceivedCommand(_ command: String, with payload: Any?) {
        print("handleReceivedCommand command: \(command) payload: \(String(describing: payload))")
        switch command {
        case "LOGIN_REQUIRED":
            let alert = UIAlertController(title: command, message: "alert.login.required.description".localized(), preferredStyle: .alert)
            alert.addAction(.init(title: "alert.msg.ok".localized(), style: .default, handler: { _ in
                /*
                    1. 로그인 화면으로 이동
                    2. 로그인이 성공하면, 인증 사용자 계정을 연동하여 샵라이브플레이어를 다시 호출
                 */
                ShopLive.startPictureInPicture()
                let login = LoginViewController()
                login.delegate = self
                self.navigationController?.pushViewController(login, animated: true)
            }))
            alert.addAction(.init(title: "alert.msg.no".localized(), style: .default, handler: { _ in
                alert.dismiss(animated: true)
            }))
            ShopLive.viewController?.present(alert, animated: true, completion: nil)
            break
        default:
            break
        }
    }
}

extension MainViewController: LoginDelegate {
    func loginSuccess() {
        
        guard let currentKey = ShopLiveDemoKeyTools.shared.currentKey() else {
            UIWindow.showToast(message: "sdk.msg.nonekey".localized())
            return
        }
        
        let loginUser = ShopLiveUser(id: "shoplive", name: "loginUser", gender: .male, age: 20)
        ShopLive.user = loginUser
        
        ShopLive.play(with: currentKey.campaignKey, keepWindowStateOnPlayExecuted: true)
    }
}
