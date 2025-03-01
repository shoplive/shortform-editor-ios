//
//  MainViewController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import SideMenu
import SafariServices
import Toast
import RxSwift
import RxCocoa
import ShopLiveSDK
import ShopliveSDKCommon
import SnapKit

class MainViewController: UIViewController {
    
    // ViewModel
    var viewModel: MainViewModel
    
    // Etc View & ViewController
    private var safari: SFSafariViewController? = nil
    private let previewConverViewMaker = PreviewCoverViewMaker()
    private weak var popoverController: UIPopoverPresentationController?
    

    private var tabbar: UITabBar = {
        let view = UITabBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    
    // 하나 은행 프레임 워크 재현을 위한 더미 뷰
    private var dummyView : UIView = {
        let view = UIView()
        view.frame = UIScreen.main.bounds
        view.backgroundColor = .yellow
        view.alpha = 0.1
        return view
    }()
    
    
    // MARK: - ScrollView & Cotainer View
    private lazy var scrollView: UIScrollView = {
        let sc = UIScrollView()
        sc.showsVerticalScrollIndicator = true
        return sc
    }()
    
    private let contentView: UIView = UIView()
    
    private lazy var versionInfoContainerView = VersionInfoContainerView()
    private lazy var devInfoContainerView = DevInfoContainerView()
    private lazy var campaignContainerView = CampaignContainerView()
    private lazy var userInfoContainerView = UserInfoContainerView()
    
    // Property
    private var hanaBankTimer : Double = 0
    private var disposeBag: DisposeBag = DisposeBag()
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        campaignContainerView.configure(keySet: viewModel.loadCurrentCampaign())
        viewModel.updatedUserData()
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureIDFA()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(ShopLive.sdkVersion)
        
        // configure
        configureInit()
        SampleOptions.campaignNaviMoreOptions = ["campaign.menu.write".localized(), "QR code", "Dev-Admin", "Admin", "campaign.menu.deleteall".localized()]
        configureTabbar()
        configureShopLive()
        
        // MARK: - Setting ScrollView
        setScrollViewLayout()
        setScrollViewData()
        
        // Setup
        setupSDKButtons()
        setupSideMenu()
        setupNavigation()
        
        // MARK: - Bind
        bind()
    }
    
    func bind() {
        
        let viewDidLoadSubject = PublishSubject<Void>()
        let updateLandingUrl = PublishSubject<String>()
        let updateVersionInfoData = PublishSubject<(VersionInfoButtonType, String)>()
        
        let radioOptionObservable = PublishSubject<ShopLiveButtonType>()
        let boxButtonObservable = PublishSubject<ShopLiveButtonType>()
        
        // MARK: - MainView Input/Output
        let input = MainViewModel.Input(viewDidLoad: viewDidLoadSubject,
                                        updateLadingUrl: updateLandingUrl,
                                        updateVersionInfoData: updateVersionInfoData,
                                        radioOptionObservable: radioOptionObservable,
                                        boxButtonObservable: boxButtonObservable)

        let output = viewModel.transform(input: input)
        
        viewModel.updateNoti()
            .withUnretained(self)
            .subscribe(onNext: { owner, data in owner.campaignContainerView.configure(keySet: owner.viewModel.loadCurrentCampaign()) })
            .disposed(by: disposeBag)
        
        // MARK: - UserInfo Input/Output
        let containerInput: UserInfoContainerView.Input = .init(updatedData: output.updatedData)
        let containerOutput: UserInfoContainerView.Output = .init(showUserInfoViewController: output.showUserInfoViewController, updateData: output.updatedUserMode)
        userInfoContainerView.configure(input: containerInput,
                                        output: containerOutput)
        campaignContainerView.configure(keySet: viewModel.loadCurrentCampaign())
        
        // MARK: - devInfoContainerView Input/Output
        let devInfoInput = DevInfoContainerView.Input(setData: output.loadSDKConfiguration,
                                                      radioButtonSender: output.radioButtonSender,
                                                      boxButtonSender: output.boxButtonSender)
        let devInfoOutput = DevInfoContainerView.Output(checkBoxObservable: input.boxButtonObservable,
                                                        radioOptionObservable: input.radioOptionObservable,
                                                        urlTextObservable: input.updateLadingUrl)
        
        devInfoContainerView.configurationContainer(input: devInfoInput, output: devInfoOutput)
        
        let versionInfoInput = VersionInfoContainerView.Input(setData: output.loadSDKConfiguration)
        let versionInfoOutput = VersionInfoContainerView.Output(saveButton: input.updateVersionInfoData)
        
        versionInfoContainerView.configureContent(input: versionInfoInput, output: versionInfoOutput)
        
        viewDidLoadSubject.onNext(())
    }
    
    func setScrollViewLayout() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        

        contentView.addSubview(versionInfoContainerView)
        contentView.addSubview(devInfoContainerView)
        contentView.addSubview(campaignContainerView)
        contentView.addSubview(userInfoContainerView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            $0.bottom.equalTo(tabbar.snp.top)
        }
        
        contentView.snp.makeConstraints {
            $0.width.equalTo(scrollView.snp.width)
            $0.top.equalTo(self.scrollView.snp.top)
            $0.leading.equalTo(self.scrollView.snp.leading)
            $0.trailing.equalTo(self.scrollView.snp.trailing)
            $0.bottom.equalTo(self.scrollView.snp.bottom)
        }
        
        versionInfoContainerView.snp.makeConstraints {
            $0.top.equalTo(self.contentView.snp.top)
            $0.leading.equalTo(self.contentView.snp.leading)
            $0.trailing.equalTo(self.contentView.snp.trailing)
            $0.bottom.equalTo(devInfoContainerView.snp.top)
        }

        devInfoContainerView.snp.makeConstraints {
            $0.top.equalTo(self.versionInfoContainerView.snp.bottom)
            $0.leading.equalTo(self.view.snp.leading)
            $0.trailing.equalTo(self.view.snp.trailing)
            $0.bottom.equalTo(campaignContainerView.snp.top)
        }
        
        campaignContainerView.snp.makeConstraints {
            $0.top.equalTo(self.devInfoContainerView.snp.bottom)
            $0.leading.equalTo(self.contentView.snp.leading)
            $0.trailing.equalTo(self.contentView.snp.trailing)
            $0.bottom.equalTo(self.userInfoContainerView.snp.top)
        }
        
        userInfoContainerView.snp.makeConstraints {
            $0.top.equalTo(self.campaignContainerView.snp.bottom)
            $0.leading.equalTo(self.contentView.snp.leading)
            $0.trailing.equalTo(self.contentView.snp.trailing)
            $0.bottom.equalTo(self.contentView.snp.bottom).offset(-20)
        }
        
    }
    
    func setScrollViewData() {
        campaignContainerView.delegate = self
    }
    
    func configureInit() {
        
        // View 초기 설정
        AppDelegate.rootViewController = self.navigationController
        self.view.backgroundColor = .white
        self.title = "PlayerDemo"
        
        // TapGesture/NotificationCenter 설정
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.shopliveHideKeyboard_SL))

        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func configureShopLive() {
        ShopLive.delegate = self
        ShopLive.pipPosition = .bottomLeft
        ShopLiveCommon.setUtmMedium(utmMedium: "testUtmMedium")
        ShopLiveCommon.setUtmContent(utmContent: "testUtmContent")
        ShopLiveCommon.setUtmCampaign(utmCampaign: "testUtmCampaign")
    }
    
    func configureTabbar() {
        self.view.addSubviews(tabbar)
        
        NSLayoutConstraint.activate([
            tabbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tabbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tabbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    
    func configureIDFA() {
        let delgate = UIApplication.shared.delegate as! AppDelegate
        delgate.requestIDFAPermission { result in }
    }
    
    func setupSDKButtons() {
        let preview = UIBarButtonItem(title: "sdk.preview".localized(from: "shoplive"), style: .plain, target: self, action: #selector(preview))

        let play = UIBarButtonItem(title: "sdk.play".localized(from: "shoplive"), style: .plain, target: self, action: #selector(play))

        let shopLivePreview = UIBarButtonItem(title: "List", style: .plain, target: self, action: #selector(shopLivePreview))
        
        preview.tintColor = .white
        play.tintColor = .white
        shopLivePreview.tintColor = .white
        self.navigationItem.rightBarButtonItems = [play, preview, shopLivePreview]
    }
    
    func setupSideMenu() {
        let menuButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))

        let spacing: CGFloat = 8.0
        menuButton.contentEdgeInsets = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        menuButton.setImage(UIImage.init(named:"ic_hamburger"), for: .normal)
        menuButton.addTarget(self, action: #selector(openSideMenu(_:)), for: .touchUpInside)
        
        menuButton.debounce()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: menuButton)
        let desiredWidth = 35.0
        let desiredHeight = 35.0

        let widthConstraint = NSLayoutConstraint(item: menuButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: desiredWidth)
        let heightConstraint = NSLayoutConstraint(item: menuButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: desiredHeight)

        menuButton.addConstraints([widthConstraint, heightConstraint])
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeGesture(_:)))
        edgePanGesture.edges = .left
        self.view.addGestureRecognizer(edgePanGesture)
    }
    
    func setupNavigation() {
        let naviBgColor = UIColor(red: 238/255, green: 52/255, blue: 52/255, alpha: 1)
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = naviBgColor
            self.navigationController?.navigationBar.standardAppearance = appearance;
            self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        } else {
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.navigationBar.tintColor = naviBgColor
        }
    }

    func setupShopliveSettings() {
        
        guard let config = viewModel.loadUserData() else { return }

        if let utmSource = config.utmSource, !utmSource.isEmpty {
            ShopLiveCommon.setUtmSource(utmSource: utmSource)
        } else {
            ShopLiveCommon.setUtmSource(utmSource: "")
        }
        
        if let utmContent = config.utmContent, !utmContent.isEmpty {
            ShopLiveCommon.setUtmContent(utmContent: utmContent)
        }
        else {
            ShopLiveCommon.setUtmContent(utmContent: "")
        }
        
        if let utmCampaign = config.utmCampaign, !utmCampaign.isEmpty {
            ShopLiveCommon.setUtmCampaign(utmCampaign: utmCampaign)
        }
        else {
            ShopLiveCommon.setUtmCampaign(utmCampaign: "")
        }
        
        if let utmMedium = config.utmMedium, !utmMedium.isEmpty {
            ShopLiveCommon.setUtmMedium(utmMedium: utmMedium)
        }
        else {
            ShopLiveCommon.setUtmMedium(utmMedium: "")
        }
        
        if let anonId = config.anonId, !anonId.isEmpty {
            ShopLiveCommon.setAnonId(anonId: anonId)
        }
        else {
            ShopLiveCommon.setAnonId(anonId: "")
        }
        
        if let adId = config.adId, !adId.isEmpty {
            ShopLiveCommon.setAdId(adId: adId)
        }
        else {
            ShopLiveCommon.setAdId(adId: nil)
        }
//        
//        ShopLive.setResizeMode(mode: config.resizeMode)
//        
//        ShopLive.setEnabledPictureInPictureMode(isEnabled: config.enablePip)
//        ShopLive.setEnabledOSPictureInPictureMode(isEnabled: config.enableOsPip)
//        
//        ShopLive.setAppVersion("3.39.0")
//        if !config.isGuestMode {
//            if config.useJWT {
//                ShopLive.authToken = config.jwtToken
//            } else {
//                // user setting
//                if !config.user.userId.isEmpty {
//                    ShopLive.user = config.user
//                } else {
//                    ShopLive.user = nil
//                }
//            }
//        } else {
//            ShopLive.user = nil
//        }
//        
//        DemoConfiguration.shared.customParameters.forEach { customParam in
//            if customParam.isUseParam, let value = customParam.paramValue {
//                ShopLive.addParameter(key: customParam.paramKey, value: value)
//            } else {
//                ShopLive.removeParameter(key: customParam.paramKey)
//            }
//        }
//        
//        
//        ShopLive.setMixWithOthers(isMixAudio: config.useMixAudio)
//        
//        ShopLive.useCloseButton(config.useCloseButton)
//        
//        // Keep play video on headphone unplugged setting
//        ShopLive.setKeepPlayVideoOnHeadphoneUnplugged(config.useHeadPhoneOption1, isMute: config.useHeadPhoneOption2)
//
//        // Auto resume video on call end setting
//        ShopLive.setAutoResumeVideoOnCallEnded(config.useCallOption)
//
//        // Custom Image Animation Indicator setting
//        if config.useCustomProgress {
//            var images: [UIImage] = []
//
//            for i in 1...11 {
//                images.append(.init(named: "loading\(i)")!)
//            }
//
//            ShopLive.setLoadingAnimation(images: images)
//        }
//        
//        if let progressColor = config.progressColor {
//            ShopLive.indicatorColor = UIColor(progressColor)
//        }
//        
//        if let scheme = config.shareScheme {
//            if config.useCustomShare {
//                // Custom Share Setting
//                ShopLive.setShareScheme(scheme, shareDelegate: self)
//                
//            } else {
//                // Default iOS Share
//                ShopLive.setShareScheme(scheme, shareDelegate: nil)
//            }
//        } else {
//            if config.useCustomShare {
//                ShopLive.setShareScheme(nil, shareDelegate: self)
//            } else {
//                // Default iOS Share
//                ShopLive.setShareScheme(nil, shareDelegate: self)
//            }
//        }
//    
//        // Custom Font Setting
//        if let customFont = config.customFont {
//            ShopLive.setChatViewFont(inputBoxFont: config.useChatInputCustomFont ? customFont : nil, sendButtonFont: config.useChatSendButtonCustomFont ? customFont : nil)
//        }
//
//        // Custom App Version Setting
        if let appVersion = config.customerAppVersion {
            ShopLive.setAppVersion(appVersion)
        }
//        
//        // Picture in Picture Setting
//        // legacy type setting
////        ShopLive.pipScale = config.pipScale ?? 2/5
////        ShopLive.pipPosition = config.pipPosition
//
//        // handle Navigation Action Type
//        ShopLive.setNextActionOnHandleNavigation(actionType: DemoConfiguration.shared.nextActionTypeOnHandleNavigation)
//        
//        // Pip padding setting
//        let padding = config.pipPadding
//        let paddingSuccessed = ShopLive.setPictureInPicturePadding(padding: .init(top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right))
//        
//        // Pip floating offset setting
//        let floatingOffset = config.pipFloatingOffset
//        let floatingSuccessed = ShopLive.setPictureInPictureFloatingOffset(offset: .init(top: floatingOffset.top, left: floatingOffset.left, bottom: floatingOffset.bottom, right: floatingOffset.right))
//        
//        // Mute Sound Setting
//        ShopLive.setMuteWhenPlayStart(config.isMuted)
//        
//        
        // Phase Setting
        let phase = ShopLiveDevConfiguration.shared.phase
        
        var landingUrl: String = "https://www.shoplive.show/v1/sdk.html"
        switch phase {
        case "DEV":
            landingUrl = "https://dev.shoplive.show/v1/sdk.html"
            break
        case "QA":
            landingUrl = "https://qa.shoplive.show/v1/sdk.html"
            break
        case "STAGE":
            landingUrl = "https://stg.shoplive.show/v1/sdk.html"
            break
        case "CUSTOM":
            
            if !viewModel.landingUrl.isEmpty {
                landingUrl = viewModel.landingUrl
                viewModel.updateCustomLandingUrl()
            } else {
                landingUrl = ""
            }
            break
        default:
            break
        }
        
        if !landingUrl.isEmpty {
            ShopLive.setEndpoint(landingUrl)
        } else {
            ShopLive.setEndpoint(nil)
        }
//        
//        let pipSize : ShopLiveInAppPipSize
//        if let max = DemoConfiguration.shared.maxPipSize {
//            pipSize = .init(pipMaxSize: max)
//        }
//        else if let fixedHeight = DemoConfiguration.shared.fixedHeightPipSize {
//            pipSize = .init(pipFixedHeight: fixedHeight)
//        }
//        else {
//            pipSize = .init(pipFixedWidth: DemoConfiguration.shared.fixedWidthPipSize ?? 100)
//        }
//        
//        let inAppPipConfig = ShopLiveInAppPipConfiguration(useCloseButton: DemoConfiguration.shared.useCloseButton,
//                                                           pipPosition: config.pipPosition,
//                                                           enableSwipeOut: config.pipEnableSwipeOut,
//                                                           pipSize: pipSize,
//                                                           pipRadius: DemoConfiguration.shared.pipCornerRadius ?? 10,
//                                                           pipPinPositions: DemoConfiguration.shared.pipPinPosition)
//        
//        ShopLive.setInAppPipConfiguration(config: inAppPipConfig)
//        
//        ShopLive.setKeepWindowStyleOnReturnFromOsPip(config.usePipKeepWindowStyle)
//        ShopLive.setEnabledPipSwipeOut(config.pipEnableSwipeOut)
//        
//        ShopLive.setVisibleStatusBar(isVisible: DemoConfiguration.shared.statusBarVisibility)
//        
//        previewConverViewMaker.setCustomerPreviewCoverView()
        
    }
    
    func regenerateHanaBankFrameworkIssue() {
        hanaBankTimer = 0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer  in
            let keywindow = UIApplication.shared.keyWindow
            keywindow?.addSubview(self.dummyView)
            keywindow?.bringSubviewToFront(self.dummyView)
            
            self.hanaBankTimer += 0.5
            if self.hanaBankTimer > 10 {
                timer.invalidate()
            }
        }
    }
    
    func openSideMenuAct() {
        viewModel.showSideMenuViewController()
    }
 
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - ShopLiveSDKDelegate
extension MainViewController: ShopLiveSDKDelegate {
    
    func log(name: String, feature: ShopLiveLog.Feature, campaign: String, parameter: [String : String]) {
//        ShopLiveLogger.tempLog("log name \(name) feature \(feature.name) campaignKey \(campaign) parameter(String:String) \(parameter)")
//        let eventLog = ShopLiveLog(name: name, feature: feature, campaign: campaign, parameter: parameter)
//        
    }
    
    func onEvent(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String : Any]) {
        switch name {
        case "product_list":
            
            ShopLiveEvent.sendConversionEvent(data: .init(
                type: "purchase",
                products: [.init(
                    productId: payload["goodsId"] as? String,
                    sku: payload["sku"] as? String,
                    url: payload["url"] as? String,
                    purchaseQuantity: 1,
                    purchaseUnitPrice: payload["discountedPrice"] as? Double )],
                orderId: "customOrderId",
                referrer: "customReferrer",
                custom: ["key" : "value" ])
            )
            
        default:
            break
        }
    }
    
    func playerPanGesture(state: UIGestureRecognizer.State, position: CGPoint) {}

    func handleNavigation(with url: URL) {
                
        var presenter: UIViewController?
        
//        switch DemoConfiguration.shared.nextActionTypeOnHandleNavigation {
//        case .PIP, .CLOSE:
//            presenter = self
//            break
//        case .KEEP:
//            presenter = ShopLive.viewController
//            break
//        @unknown default:
//            break
//        }
//        
//        if url.absoluteString.hasPrefix("http") == false && url.absoluteString.hasPrefix("shoplive") == false {
//            let alert = UIAlertController(title: nil, message: "campaign.msg.wrongurl".localized() + "[\(url.absoluteString)]", preferredStyle: .alert)
//            alert.addAction(.init(title: "alert.msg.confirm".localized(), style: .default, handler: nil))
//            presenter?.present(alert, animated: true, completion: nil)
//            return
//        }
//
//        if #available(iOS 13, *) {
//            if url.absoluteString.hasPrefix("shoplive") {
//                UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                return
//            }
//            if let browser = self.safari {
//                browser.dismiss(animated: false, completion: nil)
//            }
//
//            safari = .init(url: url)
//
//            guard let browser = self.safari else { return }
//            presenter?.present(browser, animated: true)
//        } else {
//            // TODO: Single UIWindow 에서 PIP 처리 적용 필요
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//        }
    }

    func handleChangedPlayerStatus(status: String) {}
    
    func handleChangeCampaignStatus(status: String) {}

    func handleError(code: String, message: String) {}

    func handleCampaignInfo(campaignInfo: [String : Any]) {}

    /*
     // deprecated
     func handleDownloadCoupon(with couponId: String, completion: @escaping () -> Void)
     func handleDownloadCouponResult(with couponId: String, completion: @escaping (CouponResult) -> Void)
    */
    
    func handleDownloadCoupon(with couponId: String, result: @escaping (ShopLiveCouponResult) -> Void) {
        let alert = UIAlertController(title: "sample.coupon.download".localized(), message: "sample.coupon.id".localized() + ": \(couponId)", preferredStyle: .alert)
        alert.addAction(.init(title: "alert.msg.failed".localized(), style: .cancel, handler: { _ in
            DispatchQueue.main.async {
                let message = SDKSettings.downloadCouponFailedMessage
                let status = SDKSettings.downloadCouponFailedStatus
                let alertType = SDKSettings.downloadCouponFailedAlertType
                
                let couponResult = ShopLiveCouponResult(couponId: couponId, success: false, message: message, status: status, alertType: alertType)
                result(couponResult)
            }
        }))
        alert.addAction(.init(title: "alert.msg.success".localized(), style: .default, handler: { _ in
            DispatchQueue.main.async {
                let message = SDKSettings.downloadCouponSuccessMessage
                let status = SDKSettings.downloadCouponSuccessStatus
                let alertType = SDKSettings.downloadCouponSuccessAlertType
                
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

        let alert = UIAlertController(title: "CUSTOM ACTION", message: "id: \(id)\ntype: \(type)\npayload: \(String(describing: payload))", preferredStyle: .alert)
        alert.addAction(.init(title: "alert.msg.failed".localized(), style: .cancel, handler: { _ in
            let message = SDKSettings.downloadCouponFailedMessage
            let status = SDKSettings.downloadCouponFailedStatus
            let alertType = SDKSettings.downloadCouponFailedAlertType
            let customActionResult = ShopLiveCustomActionResult(id: id, success: false, message: message, status: status, alertType: alertType)
            result(customActionResult)
        }))
        alert.addAction(.init(title: "alert.msg.success".localized(), style: .default, handler: { _ in
            let message = SDKSettings.downloadCouponSuccessMessage
            let status = SDKSettings.downloadCouponSuccessStatus
            let alertType = SDKSettings.downloadCouponSuccessAlertType
            let customActionResult = ShopLiveCustomActionResult(id: id, success: true, message: message, status: status, alertType: alertType)
            result(customActionResult)
        }))
        ShopLive.viewController?.present(alert, animated: true, completion: nil)
    }

    func handleCommand(_ command: String, with payload: Any?) {
        
        if ShopLiveViewTrackEvent.allCases.map({ $0.name }).contains(where: { $0 == command }) {
            guard let payload = payload as? [String : Any] else { return }
        }
        
        switch command {
        case "didTapCloseButton":
            break
        case "CLOSE_FROM_PIP":
            break
        case "didShopLiveOff":
            break
        default:
//            var log = "\nhandleCommand\n"
//            log += "command : \(command)\n"
//            log += "payload : \(payload)\n"
//            log += "=================="
//            ShopLiveLogger.tempLog(log)
            break
        }
    }

    
    func onSetUserName(_ payload: [String : Any]) {
        
        let alert = UIAlertController(title: "대화명 변경", message: "대화명 변경이 완료되었습니다.".localized(), preferredStyle: .alert)
        alert.addAction(.init(title: "alert.msg.ok".localized(), style: .default, handler: { _ in
            alert.dismiss(animated: true)
        }))
        ShopLive.viewController?.present(alert, animated: true, completion: nil)
    }

    
    
    func handleReceivedCommand(_ command: String, with payload: Any?) {
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
        case "CLICK_ROTATE_BUTTON":
            DispatchQueue.main.async {
                UIWindow.showToast(message: "[CLICK_ROTATE_BUTTON]\n 회전버튼이 클릭되었습니다.\n고객사앱에서 이 커맨드를 수신하여 회전처리")
            }
            break
        case "CLICK_BACK_BUTTON":
            preview()
            break
        case "ON_CHANGED_BRAND_FAVORITE":
            guard let parameters = payload as? [String: Any],
                  let favorite = parameters["favorite"] as? Bool,
                  let identifier = parameters["identifier"] as? String else {
                return
            }
            break
        case "ON_CLICK_BRAND_FAVORITE_BUTTON":
            guard let parameters = payload as? [String: Any],
                  let favorite = parameters["favorite"] as? Bool,
                  let identifier = parameters["identifier"] as? String else {
                return
            }
            let result: [String: Any] = ["identifier" : identifier, "favorite" : !favorite]
            ShopLive.sendCommandMessage(command: "SET_BRAND_FAVORITE", payload: result)
            
            ShopLivePlayerToastCommandManager.shared.showToast(message: "ON_CLICK_BRAND_FAVORITE_BUTTON : \(!favorite)")
            break
        case "CLICK_BACK_BUTTON":
            preview()
        
            break
        default:
            break
        }
    }
    
    func handleReceivedCommand(_ command: String, data: [String : Any]?) {
        switch command {
        case "ON_CLICK_SELLER","ON_RECEIVED_SELLER_CONFIG","ON_CLICK_VIEW_SELLER_STORE","ON_CLICK_SELLER_SUBSCRIPTION":
            SellerManager.shared.parseCommand(command: command, payload: data)
        default:
            break
        }
    }
}

extension MainViewController: LoginDelegate {
    func loginSuccess(name : String?, pwd : String?) {
        
        guard let currentKey = viewModel.getCurrentKeySet() else {
            DispatchQueue.main.async {
                UIWindow.showToast(message: "sdk.msg.nonekey".localized())
            }
            return
        }
        
        if let name = name, let pwd = pwd {
            let user = ShopLiveCommonUser(userId: name)
            user.userName = pwd
            user.gender = .male
            user.age = 20
            ShopLiveCommon.setUser(user: user,accessKey: currentKey.accessKey )
        }
        else {
            let user = ShopLiveCommonUser(userId: "ShopLive")
            user.userName = "loginUser"
            user.gender = .male
            user.age = 20
            ShopLiveCommon.setUser(user: user,accessKey: currentKey.accessKey )
        }
        
//        ShopLive.play(with: currentKey.campaignKey, keepWindowStateOnPlayExecuted: DemoConfiguration.shared.useKeepWindowStateOnPlayExecuted, referrer: DemoConfiguration.shared.customReferrer)
    }
}

extension MainViewController : ShopLivePlayerShareDelegate {
    func handleShare(data: ShopLivePlayerShareData) {
        
        if let urlString = data.url , let url = URL(string: urlString) {
            let shareAll:[Any] = [url]
            let activityViewController = UIActivityViewController(activityItems: shareAll , applicationActivities: nil)
            popoverController = activityViewController.popoverPresentationController
            popoverController?.sourceView = self.view
            if UIDevice.current.userInterfaceIdiom == .pad {
                popoverController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController?.permittedArrowDirections = []
            }
            if let vc = ShopLive.viewController {
                vc.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
}

// MARK: @objc
extension MainViewController {
    @objc func handleNotification(_ notification: Notification) {
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            break
        case UIResponder.keyboardWillHideNotification:
            break
        default:
            break
        }
    }
    

    @objc private func handleEdgeGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard gesture.state == .recognized else {
            return
        }
        openSideMenuAct()
    }

    @objc private func openSideMenu(_ sender: UIButton) {
        sender.debounce()
        openSideMenuAct()
//        viewModel.showOptionSettingViewController()
    }
    
    
    @objc func preview() {
//        guard let currentKey = viewModel.getCurrentKeySet() else {
//            DispatchQueue.main.async {
//                UIWindow.showToast(message: "sdk.msg.nonekey".localized())
//            }
//            return
//        }
//        
//        ShopLiveCommon.setAccessKey(accessKey: currentKey.accessKey)
//        setupShopliveSettings()
//        
//        let playerData = ShopLivePreviewData(campaignKey: currentKey.campaignKey,
//                                             keepWindowStateOnPlayExecuted: DemoConfiguration.shared.useKeepWindowStateOnPlayExecuted,
//                                             referrer: DemoConfiguration.shared.customReferrer,
//                                             isMuted: !DemoConfiguration.shared.enablePreviewSound,
//                                             isEnabledVolumeKey: DemoConfiguration.shared.isEnabledVolumeKey,
//                                             resolution: DemoConfiguration.shared.previewResolution) { campaign in } brandHandler: { brand in }
//        
//        ShopLive.preview(data: playerData) {
//            if DemoConfiguration.shared.usePlayWhenPreviewTapped {
//                ShopLive.play(with: currentKey.campaignKey,keepWindowStateOnPlayExecuted: DemoConfiguration.shared.useKeepWindowStateOnPlayExecuted,referrer: DemoConfiguration.shared.customReferrer)
//            }
//        }
    }
    
    @objc func play() {
//        guard let currentKey = viewModel.getCurrentKeySet() else {
//            DispatchQueue.main.async {
//                UIWindow.showToast(message: "sdk.msg.nonekey".localized())
//            }
//            return
//        }
//
//        
//        ShopLiveCommon.setAccessKey(accessKey: currentKey.accessKey)
        setupShopliveSettings()
//        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
//        
//        
//        let playerData = ShopLivePlayerData(campaignKey: currentKey.campaignKey ,//"9f59cfe5ae7c"
//                                             keepWindowStateOnPlayExecuted: DemoConfiguration.shared.useKeepWindowStateOnPlayExecuted,
//                                             referrer: DemoConfiguration.shared.customReferrer,
//                                             isEnabledVolumeKey: DemoConfiguration.shared.isEnabledVolumeKey)
//        
//        ShopLive.play(data: playerData )
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            self.regenerateHanaBankFrameworkIssue()
//        }
    }

    @objc
    func shopLivePreview() {
        guard let currentKey = viewModel.getCurrentKeySet() else {
            DispatchQueue.main.async {
                UIWindow.showToast(message: "sdk.msg.nonekey".localized())
            }
            return
        }
        setupShopliveSettings()
        ShopLive.setMuteWhenPlayStart(false)
        let vc = ShopLivePreviewSampleView(accessKey: currentKey.accessKey, campaignkey: currentKey.campaignKey)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MainViewController: CampaignContainerDelegate {
    
    func showCampaignsViewController() {
        viewModel.showCampaignsViewController()
    }
    
    func updateKeySet(_ keyset: ShopLiveKeySet) {
        viewModel.updateSetKey(value: keyset)
    }
}
