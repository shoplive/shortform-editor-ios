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
import WebKit

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
    
    private var shortsCollectionViewBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("UIView", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        return btn
    }()
   
    lazy var coverPickerImageResultPopUp : CoverPickerResultPopUp = {
        let view = CoverPickerResultPopUp(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alpha = 0
        return view
    }()
    
    lazy var videoEditorResultPopUp : VideoEditorResultPopUp = {
        let view = VideoEditorResultPopUp(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alpha = 0
        return view
    }()
    
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
    
    lazy private var editorPopUp : EditorOptionPopUp = {
        let popup = EditorOptionPopUp()
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.alpha = 0
        popup.vc = self
        return popup
    }()
    
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
    
    var mediaPickerViewController : UIViewController?
    var editorViewController : UIViewController?
    var coverPickerViewController : UIViewController?
    
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
//        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.isHidden = true
        SLFileManager.deleteShortformDirectoryFiles()
       
        setupDetaultLanding()
        setupTab()
        setLayout()
        pagingViewController!.select(index: 0)
        
        var option = ShopLiveShortformVisibleDetailData()
        option.isBookMarkVisible = true
        option.isShareButtonVisible = true
        ShopLiveShortform.setVisibileDetailViews(options: option)
        
        settingMoreBtn.addTarget(self, action: #selector(didTapSettingMoreBtn(sender: )), for: .touchUpInside)
        v2PlayBtn.addTarget(self, action: #selector(v2PlayBtnTapped(sender: )), for: .touchUpInside)
        shortsCollectionViewBtn.addTarget(self, action: #selector(shortsCollectionViewBtnTapped(sender:)), for: .touchUpInside)
        
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
                 switch type {
                 case .card:
                     self?.cardTypeExampleViewController.changeLanding()
                 case .vertical:
                     self?.verticalTypeExamplViewController.changeLanding()
                 case .horizontal:
                     self?.horizontalTypeExamplViewController.changeLanding()
                 case .web:
                     break
                 }
             }
             
             switch type {
             case .card:
                 self?.cardTypeExampleViewController.applyShortsSettings(model: model)
             case .horizontal:
                 self?.horizontalTypeExamplViewController.applyShortsSettings(model: model)
             case .vertical:
                 self?.verticalTypeExamplViewController.applyShortsSettings(model: model)
             case .web:
                 break
             }
             
         }
         self.present(optionSettingViewController, animated: true)
    }
    
    
    private var lastLandingInfo : LandingInfo?
    
    @objc func didTapVideoPicker() {
        editorPopUp.alpha = 1
    }
    
    @objc func v2PlayBtnTapped(sender : UIButton){
        v2Shorts = V2ShortformExample()
        v2Shorts?.play()
    }
    
    @objc func shortsCollectionViewBtnTapped(sender : UIButton) {
        let vc = UINavigationController(rootViewController: ShortsCollectionExampleView())
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
}
extension ViewController : ShopLiveShortformEditorDelegate {
    func onShopliveShortformError(error: ShopliveSDKCommon.ShopLiveCommonError) {
 
    }
    
    func onShopLiveShortformEditorVideoConvertSuccess(videoPath: String) {
        ShopLiveLogger.tempLog("[HASSAN LOG] onShopLiveShortformEditorVideoConvertSuccess videoPath \(videoPath)")
    }
    
    func onShopLiveShortformEditorCoverImageSuccess(image: UIImage?) {
        ShopLiveLogger.tempLog("[HASSAN LOG] onShopLiveShortformEditorCoverImageSuccess ")
    }
    
    func onShopLiveShortformEditorUploadSuccess(result: ShopliveEditorResultData?) {
        ShopLiveLogger.tempLog("[HASSAN LOG] onShopLiveShortformEditorUploadSuccess \(dump(result))")
    }
    
    func onShopLiveShortformEditorOnEvent(name: String, payload: [String : Any]?) {
        ShopLiveLogger.tempLog("[EVENTTRACE] name : \(name) payload :  \(payload)")
        self.showToastOnWindow(message: name)
    }
    
}
extension ViewController : ShopLiveVideoEditorDelegate {
    func onShopLiveVideoEditorCancelled(editor : UIViewController?) {
        if let navigationController = editor?.navigationController {
            navigationController.dismiss(animated: true)
        }
    }
    
    func onShopLiveVideoEditorError(editor : UIViewController?,error: ShopLiveCommonError) {
        ShopLiveLogger.tempLog("[HASSAN LOG] videoeditor error \(error.codes) \(error.message)")
    }
    
    func onShopLiveVideoEditorVideoConvertSuccess(editor : UIViewController?,videoPath: String) {
        ShopLiveLogger.tempLog("[HASSAN LOG] videoEditor videoPath \(videoPath)")
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self else { return }
//            self.videoEditorResultPopUp.setVideoPath(videoPath: videoPath)
//            self.videoEditorResultPopUp.alpha = 1
//        }
    }
    
    func onShopLiveVideoEditorUploadSuccess(editor : UIViewController?,result: ShopliveEditorResultData?) {
        ShopLiveLogger.tempLog("[HASSAN LOG] onShopLiveVideoEditorUploadSuccess \(dump(result))")
        if let nav = editorViewController?.navigationController {
            nav.dismiss(animated: true) { [weak self] in
                self?.editorViewController = nil
            }
        }
        else {
            editorViewController?.dismiss(animated: true, completion: { [weak self] in 
                self?.editorViewController = nil
            })
        }
    }
    
    func onShopLiveVideoEditorOnEvent(editor : UIViewController?,name: String, payload: [String : Any]?) {
        ShopLiveLogger.tempLog("[EVENTTRACE] name : \(name) payload :  \(payload)")
        self.showToastOnWindow(message: name)
    }
    
}
extension ViewController : ShopLiveMediaPickerDelegate {
    func onShopLiveMediaPickerCancelled(picker : UIViewController?) {
        print("onShopLiveMediaPickerCancelled")
    }
    
    func onShopLiveMediaPickerDidPickVideo(picker : UIViewController?,absoluteUrl: URL, relativeUrl: URL) {
        print("Picker Video Selected absoluteUrl: \(absoluteUrl) relativeUrl : \(relativeUrl)")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.videoEditorResultPopUp.setVideoPath(videoPath: absoluteUrl.absoluteString)
            self.videoEditorResultPopUp.alpha = 1
        }
    }
    
    func onShopLiveMediaPickerDidPickImage(picker : UIViewController?,imageUrl: URL) {
        print("Picker Image Selected image: \(imageUrl)")
        let image = UIImage(contentsOfFile: imageUrl.path)
        coverPickerImageResultPopUp.setResultImage(image: image)
        coverPickerImageResultPopUp.alpha = 1
    }
    
    func onShopLiveMediaPickerOnEvent(picker : UIViewController?,name: String, payload: [String : Any]?) {
        ShopLiveLogger.tempLog("[EVENTTRACE] name : \(name) payload :  \(payload)")
        self.showToastOnWindow(message: name)
    }
}
extension ViewController : ShopLiveCoverPickerDelegate {
    func onShopLiveCoverPickerError(picker : UIViewController?,error: ShopLiveCommonError) {
        ShopLiveLogger.tempLog("[HASSAN LOG] coverPicker error \(error.message)")
    }
    
    func onShopLiveCoverPickerCoverImageSuccess(picker : UIViewController?,image: UIImage?) {
        coverPickerImageResultPopUp.setResultImage(image: image)
        coverPickerImageResultPopUp.alpha = 1
        if let nav = editorViewController?.navigationController {
            nav.dismiss(animated: true) { [weak self] in
                self?.coverPickerViewController = nil
            }
        }
        else if let nav = coverPickerViewController?.navigationController {
            nav.dismiss(animated: true) { [weak self] in
                self?.coverPickerViewController = nil
            }
        }
        else {
            coverPickerViewController?.dismiss(animated: true, completion: { [weak self] in
                self?.coverPickerViewController = nil
            })
        }
    }
    
    func onShopLiveCoverPickerUploadSuccess(picker : UIViewController?,result: ShopliveEditorResultData?) {
        ShopLiveLogger.tempLog("[HASSAN LOG] onShopLiveCoverPickerUploadSuccess \(dump(result))")
    }
    
    func onShopLiveCoverPickerCancelled(picker : UIViewController?) {
        ShopLiveLogger.tempLog("[HASSAN LOG] coverPickerCancelled")
        if let navigationController = coverPickerViewController?.navigationController {
            navigationController.dismiss(animated: true) { [weak self] in
                self?.coverPickerViewController = nil
            }
        }
        else {
            coverPickerViewController?.dismiss(animated: true, completion: { [weak self] in
                self?.coverPickerViewController = nil
            })
        }
    }
    
    func onShopLiveCoverPickerOnEvent(picker : UIViewController?, name: String, payload: [String : Any]?) {
        ShopLiveLogger.tempLog("[EVENTTRACE] name : \(name) payload :  \(payload)")
        self.showToastOnWindow(message: name)
    }
    
    private func showToastOnWindow(message : String) {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first,
                let delegate = scene.delegate as? SceneDelegate,
                let window = delegate.window else { return }
            window.showToast(message: message)
        }
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
        self.view.addSubview(shortsCollectionViewBtn)
        self.addChild(pagingViewController!)
        view.addSubview(pagingViewController!.view)
        pagingViewController!.didMove(toParent: self)
        pagingViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(videoPickerButton)
        self.view.addSubview(editorPopUp)
        self.view.addSubview(coverPickerImageResultPopUp)
        self.view.addSubview(videoEditorResultPopUp)
        
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
            
            shortsCollectionViewBtn.centerYAnchor.constraint(equalTo: navBox.centerYAnchor),
            shortsCollectionViewBtn.trailingAnchor.constraint(equalTo: v2PlayBtn.leadingAnchor, constant: -15),
            shortsCollectionViewBtn.widthAnchor.constraint(equalToConstant: 50),
            shortsCollectionViewBtn.heightAnchor.constraint(equalToConstant: 25),
            
            pagingViewController!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            pagingViewController!.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagingViewController!.view.topAnchor.constraint(equalTo: navBox.bottomAnchor),
            pagingViewController!.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            videoPickerButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            videoPickerButton.bottomAnchor.constraint(equalTo: pagingViewController!.view.bottomAnchor,constant: -30),
            videoPickerButton.widthAnchor.constraint(equalToConstant: 30),
            videoPickerButton.heightAnchor.constraint(equalToConstant: 30),
            
            
            editorPopUp.topAnchor.constraint(equalTo: self.view.topAnchor),
            editorPopUp.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            editorPopUp.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            editorPopUp.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            coverPickerImageResultPopUp.topAnchor.constraint(equalTo: self.view.topAnchor),
            coverPickerImageResultPopUp.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            coverPickerImageResultPopUp.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            coverPickerImageResultPopUp.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            
            videoEditorResultPopUp.topAnchor.constraint(equalTo: self.view.topAnchor),
            videoEditorResultPopUp.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            videoEditorResultPopUp.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            videoEditorResultPopUp.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)

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
