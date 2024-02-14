//
//  HorizontalTypeViewExampleViewController.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/05/03.
//

import Foundation
import UIKit
import ShopLiveSDKCommon
import ShopLiveShortformSDK
import FirebaseDynamicLinks


class HorizontalTypeViewExampleViewController : UIViewController {
    
    private var playableTypeLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "재생 타입"
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private var firstPlayableBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("  FIRST  ", for: .normal)
        btn.setTitleColor(.black, for: .selected)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 6
        btn.isSelected = false
        btn.tag = 1
        return btn
    }()
    
    private var centerPlayableBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("  CENTER  ", for: .normal)
        btn.setTitleColor(.black, for: .selected)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 6
        btn.isSelected = false
        btn.tag = 2
        return btn
    }()
    
    private var allPlayableBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("  ALL  ", for: .normal)
        btn.setTitleColor(.black, for: .selected)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 6
        btn.isSelected = true
        btn.tag = 3
        return btn
    }()
    
    private var label1 : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.text = "  Height : 400pt"
        return label
    }()
    private var builder : ShopLiveShortform.ListViewBuilder?
    private var collectionView : UIView?
    
    private var label2 : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.text = "  Height : 300pt"
        return label
    }()
    
    private var builder2 : ShopLiveShortform.ListViewBuilder?
    private var collectionView2 : UIView?
    
    private var label3 : UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.text = "  Height : 200pt"
        return label
    }()
    private var builder3 : ShopLiveShortform.ListViewBuilder?
    private var collectionView3 : UIView?
    
    
    
    private var currentSnap : Bool = false
    private var shareURLStorage : [String : URL] = [:]
    
    private var scrollView = UIScrollView()
    private var scrollStack = UIStackView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setLayout()
        setCollectionViewAndBuilder()
        setCollectionViewAndBuilder2()
        setCollectionViewAndBuilder3()
        
        
        firstPlayableBtn.addTarget(self, action: #selector(playableTypeBtnTapped(sender: )), for: .touchUpInside)
        centerPlayableBtn.addTarget(self, action: #selector(playableTypeBtnTapped(sender: )), for: .touchUpInside)
        allPlayableBtn.addTarget(self, action: #selector(playableTypeBtnTapped(sender: )), for: .touchUpInside)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ShopLiveShortform.ShortsReceiveInterface.setHandler(self)
        ShopLiveShortform.ShortsReceiveInterface.setNativeHandler(self)
        builder?.submit()
        builder2?.submit()
        builder3?.submit()
        self.builder?.enablePlayVideos()
        self.builder2?.enablePlayVideos()
        self.builder3?.enablePlayVideos()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.builder?.disablePlayVideos()
        self.builder2?.disablePlayVideos()
        self.builder3?.disablePlayVideos()
    }
    
    //MARK: -Actions
    @objc func playableTypeBtnTapped(sender : UIButton){
        firstPlayableBtn.isSelected = sender.tag == 1
        centerPlayableBtn.isSelected = sender.tag == 2
        allPlayableBtn.isSelected = sender.tag == 3
        
        if sender.tag == 1 {
            builder?.setPlayableType(type: .FIRST)
            builder2?.setPlayableType(type: .FIRST)
            builder3?.setPlayableType(type: .FIRST)
        }
        else if sender.tag == 2 {
            builder?.setPlayableType(type: .CENTER)
            builder2?.setPlayableType(type: .CENTER)
            builder3?.setPlayableType(type: .CENTER)
        }
        else if sender.tag == 3 {
            builder?.setPlayableType(type: .ALL)
            builder2?.setPlayableType(type: .ALL)
            builder3?.setPlayableType(type: .ALL)
        }
    }
    
    //MARK: - public func
    func setOptionsFromOptionSettingVC(model : OptionSettingModel) {
        self.setBuilderOptions(builder: self.builder, model: model)
        self.setBuilderOptions(builder: self.builder2, model: model)
        self.setBuilderOptions(builder: self.builder3, model: model)
    }
    
    
    //MARK: - private func
    private func setBuilderOptions(builder : ListViewBaseBuilder?,model : OptionSettingModel){
        builder?.setBrands(brands: model.brands)
        builder?.setVisibleBrand(isVisible: model.brandVisible)
        builder?.setVisibleTitle(isVisisble: model.titleVisible)
        builder?.setVisibleDescription(isVisible: model.descriptionVisible)
        builder?.setVisibleProductCount(isVisible: model.productCountVisible)
        builder?.setVisibleViewCount(isVisible: model.viewCountVisible)
        builder?.setCellSpacing(spacing: model.cellSpacing)
        builder?.setCellCornerRadius(radius: model.cellCornerRadius)
        if model.shuffle {
            builder?.enableShuffle()
        }
        else {
            builder?.disableShuffle()
        }
        if model.snapEnabled {
            builder?.enableSnap()
        }
        else {
            builder?.disableSnap()
        }
        builder?.setCardViewType(type: model.cardType)
        builder?.setPlayOnlyWifi(isEnabled: model.playOnlyWifi)
        builder?.setHashTags(tags: model.tags, tagSearchOperator: model.tagSearchOperate)
        builder?.reloadItems()
    }
    
    private func setCollectionViewAndBuilder(){
        if builder == nil && collectionView == nil {
            builder = ShopLiveShortform.ListViewBuilder()
           
            collectionView = builder?.build(cardViewType: .type1,
                       listViewType: .horizontal,
                       playableType: .ALL,
                       listViewDelegate: self,
                       enableSnap: currentSnap,
                       enablePlayVideo: true,
                       playOnlyOnWifi: false,
                       cellSpacing: 8)
            .getView()
            collectionView?.backgroundColor = .white
            guard let cv = collectionView else { return }
            scrollStack.addArrangedSubview(label1)
            scrollStack.setCustomSpacing(5, after: label1)
            scrollStack.addArrangedSubview(cv)
            cv.translatesAutoresizingMaskIntoConstraints = false
            cv.heightAnchor.constraint(equalToConstant: 400).isActive = true
        }
    }
    
    private func setCollectionViewAndBuilder2(){
        if builder2 == nil && collectionView2 == nil {
            builder2 = ShopLiveShortform.ListViewBuilder()
            collectionView2 = builder2?.build(cardViewType: .type1,
                       listViewType: .horizontal,
                       playableType: .ALL,
                       listViewDelegate: self,
                       enableSnap: currentSnap,
                       enablePlayVideo: true,
                       playOnlyOnWifi: false,
                       cellSpacing: 8)
            .getView()
            collectionView2?.backgroundColor = .white
            guard let cv = collectionView2 else { return }
            scrollStack.addArrangedSubview(label2)
            scrollStack.setCustomSpacing(5, after: label2)
            scrollStack.addArrangedSubview(cv)
            cv.translatesAutoresizingMaskIntoConstraints = false
            cv.heightAnchor.constraint(equalToConstant: 300).isActive = true
        }
    }
    
    private func setCollectionViewAndBuilder3(){
        if builder3 == nil && collectionView3 == nil {
            builder3 = ShopLiveShortform.ListViewBuilder()
            collectionView3 = builder3?.build(cardViewType: .type1,
                       listViewType: .horizontal,
                       playableType: .ALL,
                       listViewDelegate: self,
                       enableSnap: currentSnap,
                       enablePlayVideo: true,
                       playOnlyOnWifi: false,
                       cellSpacing: 8)
            .getView()
            builder3?.setVisibleBrand(isVisible: false)
            builder3?.setVisibleTitle(isVisisble: false)
            guard let cv = collectionView3 else { return }
            scrollStack.addArrangedSubview(label3)
            scrollStack.setCustomSpacing(5, after: label3)
            scrollStack.addArrangedSubview(cv)
            cv.translatesAutoresizingMaskIntoConstraints = false
            cv.heightAnchor.constraint(equalToConstant: 200).isActive = true
        }
    }
}
extension HorizontalTypeViewExampleViewController : ShopLiveShortformListViewDelegate {
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
extension HorizontalTypeViewExampleViewController : ShopLiveShortformReceiveHandlerDelegate {
    func onDidAppear() {
        print("[HASSAN LOG] shortformplayer on HorizontalTypeExampleViewController DidAppear")
    }
    
    func onDidDisAppear() {
        print("[HASSAN LOG] shortformplayer on HorizontalTypeExampleViewController DidDisAppear")
        builder?.enablePlayVideos()
        builder2?.enablePlayVideos()
        builder3?.enablePlayVideos()
    }
    
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
//        guard let window = UIApplication.shared.windows.last else { return }
//        window.showToast(message: command,duration: .middle)
        
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
extension HorizontalTypeViewExampleViewController {
    
    private func setLayout(){
        
        let stack = UIStackView(arrangedSubviews: [playableTypeLabel, firstPlayableBtn,centerPlayableBtn,allPlayableBtn])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        self.view.addSubview(stack)
        
        
        self.view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(scrollStack)
        scrollStack.translatesAutoresizingMaskIntoConstraints = false
        scrollStack.axis = .vertical
        scrollStack.isLayoutMarginsRelativeArrangement = true
        scrollStack.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        scrollStack.spacing = 20
        
        
        NSLayoutConstraint.activate([
            
            stack.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            stack.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            stack.heightAnchor.constraint(equalToConstant: 30),
            
            scrollView.topAnchor.constraint(equalTo: stack.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            scrollStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1),
            scrollStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)

        ])
    }
    
}


extension HorizontalTypeViewExampleViewController: ShopLiveShortformNativeHandlerDelegate {
    func handleProductItem(shortsId : String, shortsSrn : String, product : Product) {
//        print("[HASSAN LOG] srn \(shortsSrn)")
//        print("[HASSAN LOG] shortsId \(shortsId)")
//        print("[HASSAN LOG] productModel \(product.url)")
        ShopLiveShortform.showPreview(requestData: ShopLiveShortformRelatedData(sku: product.sku))
    }
    
    func handleProductBanner(shortsId: String, shortsSrn: String, scheme: String, shortsDetail: ShortsDetail) {
//        print("[HASSAN LOG] srn \(shortsSrn)")
//        print("[HASSAN LOG] shortsId \(shortsId)")
//        print("[HASSAN LOG] scheme \(shortsId)")
//        print("[HASSAN LOG] productModel \(shortsDetail.tags)")
    }
}

// MARK: - ExampleViewControllable

extension HorizontalTypeViewExampleViewController: ExampleViewControllable {
    func changeLanding() {
        builder?.submit()
        builder2?.submit()
        builder3?.submit()
    }
}
