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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ShopLiveShortform.ShortsReceiveInterface.setHandler(self)
        ShopLiveShortform.ShortsReceiveInterface.setNativeHandler(self)
        setCollectionViewAndBuilder()
        self.builder?.enablePlayVideos()
        
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
}
extension CardTypeExampleViewController : ShopLiveShortformDetailHandlerDelegate {
    func handleProductItem(shortsId : String, shortsSrn : String, product : Product) {
        print("[HASSAN LOG] srn \(shortsSrn)")
        print("[HASSAN LOG] shortsId \(shortsId)")
        print("[HASSAN LOG] productModel \(product.sku)")
        
        ShopLiveShortform.showPreview(requestData: ShopLiveShortformRelatedData(productId: product.productId))
        
    }
    
    func handleProductBanner(shortsId: String, shortsSrn: String, scheme: String, shortsDetail: ShortsDetail) {
        
        if let url = URL(string: scheme) {
            
        }
        print("[HASSAN LOG] srn \(shortsSrn)")
        print("[HASSAN LOG] shortsId \(shortsId)")
        print("[HASSAN LOG] scheme \(scheme)")
        print("[HASSAN LOG] productModel \(shortsDetail.tags)")
    }
}
extension CardTypeExampleViewController : ShopLiveShortformReceiveHandlerDelegate {
    func onError(error: Error) {
        if let error = error as? ShopLiveCommonError {
            guard let window = UIApplication.shared.keyWindow else { return }
            if let message = error.message {
                window.rootViewController?.showToast(message: message ,duration: .long)
            }
            else if let error = error.error {
                window.rootViewController?.showToast(message: error.localizedDescription ,duration: .long)
            }
        }
    }
    
    func onEvent(command: String, payload: String?) {
//        print("[HASSAN LOG] command \(command) payload\(payload)")
        guard let window = UIApplication.shared.windows.last else { return }
//        window.showToast(message: command,duration: .middle)
    }
    
    func handleShare(shareMetadata: ShopLiveShareMetaData) {
        print("[HASSSSAN LOG] descriptions \(shareMetadata.descriptions)")
        print("[HASSSSAN LOG] shortsId \(shareMetadata.shortsId)")
        print("[HASSSSAN LOG] shortsSrn \(shareMetadata.shortsSrn)")
        print("[HASSSSAN LOG] thumbnail \(shareMetadata.thumbnail)")
        print("[HASSSSAN LOG] title \(shareMetadata.title)")
    }
    
    func onDidAppear() {
        print("[HASSAN LOG] shortformplayer on CardTypeViewExampleViewController DidAppear")
       
    }
    
    func onDidDisAppear() {
        print("[HASSAN LOG] shortformplayer on CardTypeViewExampleViewController DidDisAppear")
        builder?.enablePlayVideos()
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
        if let window = ShopLiveShortform.getShopliveWindow() {
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
