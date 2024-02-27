//
//  ViewController.swift
//  shortform-examples
//
//  Created by 김우현 on 3/20/23.
//
//
import Foundation
import UIKit
import Parchment
import ShopLiveShortformSDK
import ShopliveSDKCommon
import ShopLiveShortformEditorSDK

protocol ExampleViewControllerBaseDelegate {
    func onFullTypeViewDisappeared()
}

class ViewController: UIViewController {

    private var navBox : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private var settingMoreBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(ShortformDemoAsset.shortformIcThreeDot.image, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    private var v2PlayBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("V2", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return btn
    }()
    
//    lazy var webExampleVIewController: WebExampleVIewController = {
//        let vc = WebExampleVIewController()
//        return vc
//    }()
    
    lazy var cardTypeExampleViewController : CardTypeExampleViewController = {
        let vc = CardTypeExampleViewController()
        vc.delegate = self
        return vc
    }()
    
    lazy var verticalTypeExamplViewController : VerticalTypeViewExampleViewController = {
        let vc = VerticalTypeViewExampleViewController()
        vc.delegate = self
        return vc
    }()

    lazy var horizontalTypeExamplViewController : HorizontalTypeViewExampleViewController = {
        let vc = HorizontalTypeViewExampleViewController()
        vc.delegate = self
        return vc
    }()
    
    let optionSettingViewController = OptionSettingViewController()
    
    lazy var viewControllers: [ExampleViewControllerModel] = [
        .init(title: "MAIN", exampleViewControllable: cardTypeExampleViewController),
        .init(title: "COL", exampleViewControllable: verticalTypeExamplViewController),
        .init(title: "ROW", exampleViewControllable: horizontalTypeExamplViewController),
    ]
    
    var pagingViewController: PagingViewController?
    
    lazy var videoPickerButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("+", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.cornerRadiusV_SL = 15
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .heavy)
        view.addTarget(self, action: #selector(didTapVideoPicker), for: .touchUpInside)
        view.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        return view
    }()
    
    var latestItem: PagingItem?
    private var observerAdded : Bool = false
    var v2Shorts : V2ShortformExample?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .white
        setupDetaultLanding()
        setupTab()
        setLayout()
        pagingViewController!.select(index: 0)
        
        setObserver()
        var option = ShopLiveShortformVisibleDetailData()
        option.isBookMarkVisible = true
        option.isShareButtonVisible = true
        ShopLiveShortform.setVisibileDetailViews(options: option)
        
        settingMoreBtn.addTarget(self, action: #selector(didTapSettingMoreBtn(sender: )), for: .touchUpInside)
        v2PlayBtn.addTarget(self, action: #selector(v2PlayBtnTapped(sender: )), for: .touchUpInside)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let delgate = UIApplication.shared.delegate as! AppDelegate
            delgate.requestIDFAPermission { result in
                print("adidentifier result \(ShopLiveCommon.getAdIdentifier())")
            }
        }
        
    }
    
    func setupDetaultLanding() {
        ShopLiveCommon.setAccessKey(accessKey: LandingInfo.qa.accessKey)
    }
    


    @objc func didTapSettingMoreBtn(sender : UIButton) {
        
         let index = pagingViewController?.collectionView.indexPathsForSelectedItems?.first?.row ?? 0
         if  index == 0 {
             optionSettingViewController.setViewType(type: .card)
         }
         else if index == 1 {
             optionSettingViewController.setViewType(type: .vertical)
         }
         else if index == 2 {
             optionSettingViewController.setViewType(type: .horizontal)
         }
         else if index == 3 {
             optionSettingViewController.setViewType(type: .web)
         }
         
         optionSettingViewController.resultCallBack = { [weak self] type, model, accessKey in
             if let accessKey = accessKey {
                 ShopLiveCommon.setAccessKey(accessKey: accessKey)
                 ShortFormConfigurationInfosManager.shared.setConfigurationURLToEmpty()
                 self?.viewControllers.forEach {
                     $0.exampleViewControllable.changeLanding()
                 }
             }
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                 switch type {
                 case .card:
                     self?.cardTypeExampleViewController.setOptionsFromOptionSettingVC(model: model)
                 case .vertical:
                     self?.verticalTypeExamplViewController.setOptionsFromOptionSettingVC(model: model)
                 case .horizontal:
                     self?.horizontalTypeExamplViewController.setOptionsFromOptionSettingVC(model: model)
                 case .web:
                     break
                 }
             }
         }
         self.present(optionSettingViewController, animated: true)
    }
    
    
    private var lastLandingInfo : LandingInfo?
    
    @objc func didTapVideoPicker() {
        
        let cropOption = ShopLiveShortFormEditorAspectRatio(width: OptionSettingModel.editorWidth,
                                                            height: OptionSettingModel.editorheight,
                                                            isFixed: OptionSettingModel.editorIsFixed)
        let visibleContents = ShopLiveShortFormEditorVisibleContent(isDescriptionVisible: OptionSettingModel.editorShowDescription,
                                                                    isTagsVisible: OptionSettingModel.editorShowTags)
        
        ShopLiveShortformEditor()
            .setPermissionHandler(nil)
            .setConfiguration(ShopLiveShortformEditorConfiguration(videoCropOption: cropOption ,
                                                                   visibleContents: visibleContents,
                                                                    minVideoDuration: OptionSettingModel.editorMinVideoDuration,
                                                                    maxVideoDuration: OptionSettingModel.editorMaxVideoDuration))
            .setShortFormEditorDelegate(delegate: self)
            .start(self)
    }
    
    @objc func v2PlayBtnTapped(sender : UIButton){
        v2Shorts = V2ShortformExample()
        v2Shorts?.play()
    }
    
    private func setObserver(){
        if self.observerAdded == false {
            self.observerAdded = true
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotifcation(_:)), name: NSNotification.Name("moveToProductPage"), object: nil)
        }
      
    }
    
    private func tearDownObserver(){
        self.observerAdded = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("moveToProductPage"), object: nil)
    }
    
    @objc private func handleNotifcation(_ notification : Notification){
        switch notification.name {
        case Notification.Name("moveToProductPage"):
            break
            guard let product = notification.userInfo?["product"] as? Product, let urlString = product.url, let url = URL(string: urlString) else { return }
            pagingViewController?.select(index: 3)
        default:
            break
        }
    }
}
extension ViewController : ShopLiveShortformEditorDelegate {
    func onShortformEditorSuccess() {
        print("onShortformEditorSuccess")
    }
    
    func onShortformUploadError(error: ShopLiveCommonError) {
//        switch error {
//        case .statusCode(let code):
//            print("onShortformUploadError statusCodeError \(code)")
//        case .invalidConfig:
//            print("onShortformUploadError invalidConfig")
//        case .other(let error):
//            print("onShortformUploadError other \(error.localizedDescription)")
//        }
    }
    
    func onShortformEditorMediaPickerDismiss() {
        print("onShortformEditorMediaPickerDismiss")
    }
}
extension ViewController {
    
    func setupTab() {
        var options = PagingOptions()
        options.indicatorColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        options.selectedTextColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        options.menuBackgroundColor = .white
        options.borderOptions = .hidden
        options.menuPosition = .bottom
        options.menuItemSize = .sizeToFit(minWidth: view.bounds.width/4, height: 44)
        options.menuInteraction = .none
        options.contentInteraction = .none
        
        pagingViewController = PagingViewController(options: options)
        pagingViewController?.delegate = self
        pagingViewController?.dataSource = self
        pagingViewController?.collectionView.isScrollEnabled = false
    }
    
    private func setLayout(){
        
        self.view.addSubview(navBox)
        self.view.addSubview(settingMoreBtn)
        self.view.addSubview(v2PlayBtn)
        self.addChild(pagingViewController!)
        view.addSubview(pagingViewController!.view)
        pagingViewController!.didMove(toParent: self)
        pagingViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(videoPickerButton)
        
        NSLayoutConstraint.activate([
            navBox.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            navBox.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navBox.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            navBox.heightAnchor.constraint(equalToConstant: 30),
            
            settingMoreBtn.centerYAnchor.constraint(equalTo: navBox.centerYAnchor),
            settingMoreBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            settingMoreBtn.widthAnchor.constraint(equalToConstant: 25),
            settingMoreBtn.heightAnchor.constraint(equalToConstant: 25),
            
            v2PlayBtn.centerYAnchor.constraint(equalTo: navBox.centerYAnchor),
            v2PlayBtn.trailingAnchor.constraint(equalTo: settingMoreBtn.leadingAnchor, constant: -15),
            v2PlayBtn.widthAnchor.constraint(equalToConstant: 25),
            v2PlayBtn.heightAnchor.constraint(equalToConstant: 25),
            
            pagingViewController!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            pagingViewController!.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagingViewController!.view.topAnchor.constraint(equalTo: navBox.bottomAnchor),
            pagingViewController!.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            videoPickerButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            videoPickerButton.bottomAnchor.constraint(equalTo: pagingViewController!.view.bottomAnchor,constant: -30),
            videoPickerButton.widthAnchor.constraint(equalToConstant: 30),
            videoPickerButton.heightAnchor.constraint(equalToConstant: 30),
            
        ])
    }
}
extension ViewController: PagingViewControllerDataSource {
    func numberOfViewControllers(in pagingViewController: Parchment.PagingViewController) -> Int {
        return viewControllers.count
    }
    
    func pagingViewController(_: Parchment.PagingViewController, viewControllerAt index: Int) -> UIViewController {
        return viewControllers[index].exampleViewControllable
    }
    
    func pagingViewController(_: Parchment.PagingViewController, pagingItemAt index: Int) -> Parchment.PagingItem {
        return PagingIndexItem(index: index, title: viewControllers[index].title)
    }
    
    
}

extension ViewController: PagingViewControllerDelegate {
    func pagingViewController(_ pagingViewController: PagingViewController, didSelectItem pagingItem: PagingItem) {
        if pagingItem.identifier == 3 {
            tearDownObserver()
        }
        else {
            setObserver()
        }
    }

}
#if DEVAPP
extension ViewController: LandingSelectProtocol {
    func didChangedLanding() {}
}
#endif
extension ViewController : ExampleViewControllerBaseDelegate {
    func onFullTypeViewDisappeared() {
        v2Shorts = nil
    }
}
