//
//  VerticalTypeViewExampleViewController.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/05/02.
//

import Foundation
import UIKit
import ShopLiveShortformSDK
import FirebaseDynamicLinks
import ShopliveSDKCommon

class VerticalTypeViewExampleViewController : UIViewController {
   
    private var builder : ShopLiveShortform.ListViewBuilder?
    private var collectionView : UIView?
    private var currentSnap = false
    private var shareURLStorage : [String : URL] = [:]
    private var optionModels : OptionSettingModel?
    
    var delegate : ExampleViewControllerBaseDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    //MARK: - private func

    private func setCollectionViewAndBuilder(){
        if builder == nil && collectionView == nil {
            builder = ShopLiveShortform.ListViewBuilder()
            
            collectionView = builder!.build(cardViewType: .type1,
                                            listViewType: .vertical,
                                            playableType: .FIRST,
                                            listViewDelegate: self,
                                            shortsCollectionDelegate: self,
                                            enableSnap: currentSnap,
                                            enablePlayVideo: true,
                                            playOnlyOnWifi: false,
                                            cellSpacing: 5).getView()
            builder?.submit()
            builder?.setVisibleBrand(isVisible: true)
            builder?.setVisibleTitle(isVisisble: true)
            builder?.setVisibleProductCount(isVisible: true)
            builder?.setVisibleViewCount(isVisible: true)
            
            collectionView?.translatesAutoresizingMaskIntoConstraints = false
            setCollectionViewLayout()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        builder?.notifyViewRotated()
    }
}
extension VerticalTypeViewExampleViewController : ShopLiveShortformListViewDelegate {
    func onListViewError(error: Error) {
        
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
extension VerticalTypeViewExampleViewController : ShopLiveShortformReceiveHandlerDelegate {
    
    func handleProductItem(shortsId : String, shortsSrn : String, product : ProductData) {
        print("[HASSAN LOG] srn \(shortsSrn)")
        print("[HASSAN LOG] shortsId \(shortsId)")
        print("[HASSAN LOG] productModel \(product.sku)")
        
        
        ShopLiveShortform.showPreview(requestData: ShopLiveShortformPreviewData(productId: product.productId,isMuted: nil,delegate: self))
        
        let conversionProductData = ShopLiveConversionProductData(productId: product.productId,
                                                                  customerProductId: product.customerProductId,
                                                                  sku: product.sku,
                                                                  url: product.url,
                                                                  purchaseQuantity: 1,
                                                                  purchaseUnitPrice: product.discountPrice)
        
        ShopLiveEvent.sendConversionEvent(data: .init(type: "product",
                                                      products: [conversionProductData],
                                                      orderId: "ios_v_test_orderId",
                                                      referrer: "ios_v_test_referrer",
                                                      custom: nil))
        
    }
    
    func handleProductBanner(shortsId: String, shortsSrn: String, scheme: String, shortsDetail: ShortsDetailData) {
        
        if let url = URL(string: scheme) {
            
        }
        print("[HASSAN LOG] srn \(shortsSrn)")
        print("[HASSAN LOG] shortsId \(shortsId)")
        print("[HASSAN LOG] scheme \(scheme)")
        print("[HASSAN LOG] productModel \(shortsDetail.tags)")
    }
    
    func onDidAppear() {
        print("[HASSAN LOG] shortformplayer on VerticalTypeExampleViewConroller DidAppear")
    }
    
    func onDidDisAppear() {
        print("[HASSAN LOG] shortformplayer on VerticalTypeExampleViewConroller DidDisAppear")
        builder?.enablePlayVideos()
        delegate?.onFullTypeViewDisappeared()
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
    
    func onEvent(command: String, payload: String?) {}
   
    func handleShare(shareMetadata: ShopLiveShareMetaData) {
        var objectsToShare = [String]()
        objectsToShare.append(shareMetadata.title ?? "no title")
       
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        guard let w = ShopLiveShortform.getCurrentKeyWindow() else { return }
        w.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}

extension VerticalTypeViewExampleViewController {
    
    private func setCollectionViewLayout(){
        guard let collectionView = collectionView else { return }
        self.view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func setLayout(){

    }
}

// MARK: - ExampleViewControllable

extension VerticalTypeViewExampleViewController: ExampleViewControllable {
    func changeLanding() {
        builder?.submit()
    }
}
