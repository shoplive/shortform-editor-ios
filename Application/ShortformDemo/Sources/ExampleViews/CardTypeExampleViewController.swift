//
//  CardTypeExampleViewController.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/05/02.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import ShopLiveShortformSDK
import FirebaseDynamicLinks


class CardTypeExampleViewController : UIViewController {
    
    private var builder : ShopLiveShortform.CardTypeViewBuilder?
    private var collectionView : UIView?
    private var currentSnap = false
    private var shareURLStorage : [String : URL] = [:]
    private var optionModels : OptionSettingModel?
    
    var delegate : ExampleViewControllerBaseDelegate?
    
    private var isMuted : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setLayout()
        
        ShopLiveShortform.setResizeMode(mode: .AUTO)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setCollectionViewAndBuilder()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.builder?.disablePlayVideos()
    }
    
    
    //MARK: - public func
    func setOptionsFromOptionSettingVC(model : OptionSettingModel) {
        builder?.setBrands(brands: model.brands)
        builder?.setVisibleBrand(isVisible: model.brandVisible)
        builder?.setVisibleTitle(isVisisble: model.titleVisible)
        builder?.setVisibleDescription(isVisible: model.descriptionVisible)
        builder?.setVisibleProductCount(isVisible: model.productCountVisible)
        builder?.setVisibleViewCount(isVisible: model.viewCountVisible)
        builder?.setCellSpacing(spacing: model.cellSpacing)
        builder?.setCellCornerRadius(radius: model.cellCornerRadius)
        builder?.setScrollContentOffset(offset: 0)
        builder?.setSkus(skus: model.skus)
        if model.snapEnabled {
            builder?.enableSnap()
        }
        else {
            builder?.disableSnap()
        }
        builder?.setPlayOnlyWifi(isEnabled: model.playOnlyWifi)
        if model.shuffle {
            builder?.enableShuffle()
        }
        else {
            builder?.disableShuffle()
        }
        builder?.setCardViewType(type: model.cardType)
        builder?.setHashTags(tags: model.tags, tagSearchOperator: model.tagSearchOperate)
        builder?.reloadItems()
    }
    
    private func setCollectionViewAndBuilder(){
        if builder == nil && collectionView == nil {
            builder = ShopLiveShortform.CardTypeViewBuilder()
            collectionView = builder!.build(cardViewType: .type1,
                                            listViewDelegate: self,
                                            shortsCollectionDelegate: self,
                                            enableSnap: currentSnap,
                                            enablePlayVideo: true,
                                            playOnlyOnWifi: false,
                                            viewCountVisibility: false).getView()
            builder?.setVisibleBrand(isVisible: true)
            builder?.setVisibleTitle(isVisisble: true)
            builder?.setVisibleProductCount(isVisible: true)
            builder?.setVisibleViewCount(isVisible: true)
            collectionView?.translatesAutoresizingMaskIntoConstraints = false
            collectionView?.backgroundColor = .white
            setCollectionViewLayout()
            builder?.submit()
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        builder?.notifyViewRotated()
    }
}
extension CardTypeExampleViewController : ShopLiveShortformListViewDelegate {
    func onListViewError(error: Error) {
        if let error = error as? ShopLiveCommonError {
            var alert : UIAlertController
            if let message = error.message {
                alert = UIAlertController(title: "리스트 뷰 에러 알림", message: message, preferredStyle: UIAlertController.Style.alert)
            }
            else if let error = error.error {
                alert = UIAlertController(title: "리스트 뷰 에러 알림", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            }
            else {
                alert =  UIAlertController(title: "리스트 뷰 에러 알림", message: "", preferredStyle: UIAlertController.Style.alert)
            }
            let cancelAction = UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel, handler: nil)
            alert.addAction(cancelAction)
            guard let window = UIApplication.shared.windows.first else { return }
            window.rootViewController?.present(alert, animated: true)
        }
    }
    
    func onShortsSettingsInitialized() {
        if let model = self.optionModels {
            self.setOptionsFromOptionSettingVC(model: model)
        }
    }
    
    func applyShortsSettings(model : OptionSettingModel) {
        self.optionModels = model
    }
}
extension CardTypeExampleViewController : ShopLiveShortformReceiveHandlerDelegate {
    func handleProductItem(shortsId : String, shortsSrn : String, product : ProductData) {
        print("[HASSAN LOG] srn \(shortsSrn)")
        print("[HASSAN LOG] shortsId \(shortsId)")
        print("[HASSAN LOG] productModel \(product.sku ?? "")")
        ShopLiveShortform.showPreview(requestData: ShopLiveShortformPreviewData(shortsId: shortsId,
                                                                                isEnabledVolumeKey: OptionSettingModel.isEnabledVolumeKey,
                                                                                productId: product.productId,
                                                                                isMuted: OptionSettingModel.previewIsMuted,
                                                                                maxCount: OptionSettingModel.previewMaxCount,clickEventCallBack: {
            
        }, delegate: self))
        let conversionProductData = ShopLiveConversionProductData(productId: product.productId,
                                                                  customerProductId: product.customerProductId,
                                                                  sku: product.sku,
                                                                  url: product.url,
                                                                  purchaseQuantity: 1,
                                                                  purchaseUnitPrice: product.discountPrice)
        
        ShopLiveEvent.sendConversionEvent(data: .init(type: "purchase",
                                                      products: [conversionProductData],
                                                      orderId: "ios_c_test_orderId",
                                                      referrer: "ios_c_test_referrer",
                                                      custom: nil))
        
    }
    
    func handleProductBanner(shortsId: String, shortsSrn: String, scheme: String) {
        print("[HASSAN LOG] srn \(shortsSrn)")
        print("[HASSAN LOG] shortsId \(shortsId)")
        print("[HASSAN LOG] scheme \(scheme)")
        guard let window = UIApplication.shared.keyWindow else { return }
        window.rootViewController?.showToast(message: "banner clicked" ,duration: .long)
    }
    
    func onError(error: Error) {
        if let error = error as? ShopLiveCommonError {
            guard let window = UIApplication.shared.keyWindow else { return }
            if let message = error.message {
                window.rootViewController?.showToast(message: message + "\(error.codes)" ,duration: .long)
            }
            else if let error = error.error {
                window.rootViewController?.showToast(message: error.localizedDescription ,duration: .long)
            }
        }
    }
    
    
    func onEvent(messenger: ShopLiveShortformMessenger?, command: String, payload: String?) {
        if let messenger = messenger {
            messenger.sendCommandMessage(command: "something", payload: [:])
        }
        switch command {
        case "VIDEO_MUTED", "DETAIL_CLICK_MUTE":
            isMuted = true
        case "VIDEO_UNMUTED", "DETAIL_CLICK_UNMUTE":
            isMuted = false
        default:
            break
        }
    }
    
    func handleShare(shareMetadata: ShopLiveShareMetaData) {
        print("[HASSSSAN LOG] descriptions \(shareMetadata.descriptions ?? "")")
        print("[HASSSSAN LOG] shortsId \(shareMetadata.shortsId ?? "")")
        print("[HASSSSAN LOG] shortsSrn \(shareMetadata.shortsSrn ?? "")")
        print("[HASSSSAN LOG] thumbnail \(shareMetadata.thumbnail ?? "")")
        print("[HASSSSAN LOG] title \(shareMetadata.title ?? "")")
        
        var objectsToShare = [String]()
        objectsToShare.append(shareMetadata.title ?? "no title")
       
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        guard let w = ShopLiveShortform.getCurrentKeyWindow() else { return }
        w.rootViewController?.present(activityVC, animated: true, completion: nil)
        
    }
    
    func onDidAppear() {
        print("[HASSAN LOG] shortformplayer on CardTypeViewExampleViewController DidAppear")
       
    }
    
    func onDidDisAppear() {
        print("[HASSAN LOG] shortformplayer on CardTypeViewExampleViewController DidDisAppear")
        builder?.enablePlayVideos()
        delegate?.onFullTypeViewDisappeared()
    }
    
    
    func handleShare(shareUrl: String) {
        
        guard let shareURL = URL(string: shareUrl),
              let components = URLComponents(url: shareURL, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let payLoad = queryItems.first(where: { $0.name == "payload" })?.value,
              let data = payLoad.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String : Any] else { return }

        let shorts = dict["shorts"] as! [String : Any]
        let shortsId = shorts["shortsId"] as! String

        let shortDetail = shorts["shortsDetail"] as! [String : Any]
        let title = shortDetail["title"] as! String

        let card = shorts["cards"] as! [[String : Any]]
        let imageUrl = card[0]["screenshotUrl"] as! String

        if let cacheUrl = self.shareURLStorage[shortsId] {
            self.openShareSheet(url: cacheUrl)
            return
        }

        var shareComponents = URLComponents()
        shareComponents.scheme = "https"
        shareComponents.host = "shortformdev.page.link"
        shareComponents.path = "/shortform"

        let shortsIdQuery = URLQueryItem(name: "shortsId", value: shortsId)
        shareComponents.queryItems = [shortsIdQuery]

        guard let linkParameters = shareComponents.url else {return}

        guard let sharelink = DynamicLinkComponents.init(link: linkParameters, domainURIPrefix: "https://shortformdev.page.link") else {
            print("dynamic link failed")
            return
        }

        //다른 플랫폼 일시 fallback url 설정(선택사항)
        sharelink.otherPlatformParameters = DynamicLinkOtherPlatformParameters()
        sharelink.otherPlatformParameters?.fallbackUrl = URL(string: "https://www.shoplive.cloud/kr")
        //ios 플랫폼 설정
        sharelink.iOSParameters =  DynamicLinkIOSParameters(bundleID: "cloud.shoplive.dev.shortform-examples")
        sharelink.iOSParameters?.appStoreID = "6447755168"
        //android 플랫폼 설정
        sharelink.androidParameters = DynamicLinkAndroidParameters(packageName: "cloud.shoplive.dev.shortform-examples")
        //metadata 설정
        sharelink.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        //제목 설정
        sharelink.socialMetaTagParameters?.title = title
        //이미지 설정
        if let imageURL = URL(string: imageUrl) {
            sharelink.socialMetaTagParameters?.imageURL = imageURL
        }

        sharelink.shorten { [weak self] url, warnings , error  in
            guard let self = self else { return }
            if let error = error {
                print("dynamic link error \(error.localizedDescription)")
            }
            guard let shorturl = url else {
                print("failed to shorten url")
                return
            }
            self.shareURLStorage[shortsId] = shorturl
            DispatchQueue.main.async {
                self.openShareSheet(url: shorturl)
            }
        }
    }
    
    private func openShareSheet(url : URL){
        let activityvc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let window = ShopLiveShortform.getCurrentKeyWindow() {
            window.rootViewController?.present(activityvc, animated: true)
        }
        else {
            self.present(activityvc, animated: true)
        }
    }
}
extension CardTypeExampleViewController {
    private func setCollectionViewLayout(){
        guard let collectionView = collectionView else { return }
        self.view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func setLayout(){
        
    }
    
}

// MARK: - ExampleViewControllable

extension CardTypeExampleViewController: ExampleViewControllable {
    func changeLanding() {
        builder?.submit()
    }
}
