//
//  SLPhotosPickerViewController.swift
//  CustomImagePicker
//
//  Created by sangmin han on 5/3/24.
//

import Foundation
import UIKit
import Photos
import PhotosUI
import ShopliveSDKCommon

protocol SLPhotosPickerViewControllerDelegate : NSObjectProtocol {
    func photoPicker(didSelectVideo url: URL)
    func photoPicker(didSelectImage url: URL)
}


class SLPhotosPickerViewController : UIViewController {
    
    enum MediaType {
        case image
        case video
    }
    
    private var topNaviBox : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var closeBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .red
        return btn
    }()
    
    private var groupSelectBtn : SLPhotosPickerGroupSelectBtn = {
        let btn = SLPhotosPickerGroupSelectBtn()
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private var pickerCv : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero,collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        
        return cv
    }()
    
    
    private let albumSelectView : SLAlbumSelectView = {
        let view = SLAlbumSelectView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    
    private let reactor = SLPhotosPickerReactor()
    private let permissionHandler = SLPhotoPickerPermissionHandler()
    lazy private var loadingProgressVc : SLLoadingAlertController = {
        let vc = SLLoadingAlertController()
        vc.delegate = reactor
        return vc
    }()
    
    weak var delegate : SLPhotosPickerViewControllerDelegate?
    weak var permissionDelegate : ShopLivePermissionHandler?
    weak var editorDelegate : ShopLiveShortformEditorDelegate?
    
    
    required init(mediaType : MediaType,permissionDelegate : ShopLivePermissionHandler?) {
        super.init(nibName: nil, bundle: nil)
        var config = SLPhotosPickerConfigure()
        self.permissionDelegate = permissionDelegate
        config.mediaType = mediaType == .video ? .video : .image
        config.usedCameraButton = true
        reactor.action( .setPickerConfigure(config) )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.navigationController?.navigationBar.isHidden = true
        setLayout()
        bindReactor()
        bindPermissionHandler()
        bindAlbumSelectView()
        
        reactor.action(.registerCv(pickerCv) )
        permissionHandler.action( .setDelegate(self.permissionDelegate) )
        
        
        groupSelectBtn.addTarget(self, action: #selector(albumSelectBtnTapped(sender: )), for: .touchUpInside)
        closeBtn.addTarget(self, action: #selector(closeBtnTapped(sender: )), for: .touchUpInside)
    }
    
    deinit {
        ShopLiveLogger.debugLog("SLPhotosPickerViewController deinited")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //로딩되는 시작점
        permissionHandler.action( .checkAlbumPermissions )
    }
    
    @objc func albumSelectBtnTapped(sender : UIButton) {
        albumSelectView.action( .show(true) )
    }
    
    @objc func closeBtnTapped(sender : UIButton) {
        ShopLiveShortformEditor.shared.close()
    }
    
    
}
extension SLPhotosPickerViewController {
    private func bindAlbumSelectView() {
        albumSelectView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .setFocusedCollection(let collection):
                self.onAlbumSelectViewSetFocusedCollection(collection : collection)
            }
        }
    }
    
    private func onAlbumSelectViewSetFocusedCollection(collection : SLAssetsCollection) {
        reactor.action( .setFocusedCollection(collection) )
    }
    
    
}
extension SLPhotosPickerViewController {
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .hideEmptyView(_):
                break
            case .showAlbumSelectView(let show):
                self.onReactorShowAlbumSelectView(show: show)
            case .reloadAlbumSelectTablView:
                self.onReactorReloadAlbumSelectTableView()
            case .reloadAlbumSelectTableViewRow((let indexPaths, let animation)):
                self.onReactorReloadAlbumSelecTableViewRow(indexPaths: indexPaths, anim: animation)
            case .setPhotoLibraryForAlbumSelectView(let pl):
                self.onReactorOnSetPhotoLibraryForAlbumSelectView(pl: pl)
            case .setAssetsCollectionForAlbumSelectView(let collections):
                self.onReactorOnSetAssetsCollectionForAlbumSelectView(collections : collections)
            case .didSelectImage(let image):
                self.onReactorDidSelectImage(imageUrl: image)
            case .didSelectVideo(let videoUrl):
                self.onReactorDidSelectVideo(videoUrl: videoUrl)
            case .dismissMediaPicker:
                break
            case .showCamera(let picker):
                self.onReactorShowCamera(picker: picker)
            case .setPickerPopoverPresentationController(let picker):
                self.onReactorSetPickerPopoverPresentationController(picker: picker)
            case .requestForCameraPermission:
                self.onReactorRequestForCameraPermission()
            case .requestStartLoading:
                self.onReactorRequestStartLoading()
            case .requestCancelLoading:
                self.onReactorRequestCancelLoading()
            case .requsetFinishLoading:
                self.onReactorRequestFinishLoading()
            case .didFinishLoading:
                self.onReactorDidFinishLoading()
            }
        }
    }
    
    private func onReactorShowAlbumSelectView(show : Bool) {
        albumSelectView.action( .show(show) )
    }
    
    private func onReactorReloadAlbumSelectTableView() {
        albumSelectView.action( .reloadData )
    }
    
    private func onReactorReloadAlbumSelecTableViewRow(indexPaths : [IndexPath], anim : UITableView.RowAnimation ) {
        albumSelectView.action( .reloadRow((indexPaths, anim)))
    }
    
    private func onReactorOnSetPhotoLibraryForAlbumSelectView(pl : SLPhotoLibrary) {
        albumSelectView.action( .setPhotoLibrary(pl) )
    }
    
    private func onReactorOnSetAssetsCollectionForAlbumSelectView(collections : [SLAssetsCollection]) {
        albumSelectView.action( .setAssetsCollection(collections) )
    }
    
    private func onReactorDidSelectImage(imageUrl : URL) {
        print("imageURl \(imageUrl)")
        delegate?.photoPicker(didSelectImage: imageUrl)
    }
    
    private func onReactorDidSelectVideo(videoUrl : URL) {
        print("videoUrl \(videoUrl)")
        delegate?.photoPicker(didSelectVideo: videoUrl)
    }
    
    private func onReactorShowCamera(picker : UIImagePickerController) {
        self.present(picker, animated: true)
    }
    
    private func onReactorSetPickerPopoverPresentationController(picker : UIImagePickerController) {
        picker.popoverPresentationController?.sourceView = view
    }
    
    private func onReactorRequestForCameraPermission() {
        permissionHandler.action( .checkCameraPermissions )
    }
    
    private func onReactorRequestStartLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loadingProgressVc.modalPresentationStyle = .overFullScreen
            self.loadingProgressVc.setLoadingText("Loading...")
            
            guard self.loadingProgressVc.isBeingPresented == false else { return }
            self.navigationController?.present(self.loadingProgressVc, animated: false)
        }
    }
    
    private func onReactorRequestCancelLoading() {
        self.loadingProgressVc.cancelLoading = false
    }
    
    private func onReactorRequestFinishLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loadingProgressVc.finishLoading()
        }
    }
    
    private func onReactorDidFinishLoading() {
        /** no - op */
    }
    
    
}
extension SLPhotosPickerViewController {
    private func bindPermissionHandler() {
        permissionHandler.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .dismiss:
                self.onPermissionHandlerDismiss()
            case .openAlertController(let alertController):
                self.onPermissionHandlerOpenAlertController(alertController: alertController)
            case .requestLoadPhotos(limited: let limited):
                self.onPermissionHandlerRequestLoadPhotos(limited: limited)
            case .showCamera:
                self.onPermissionHandlerShowCamera()
            }
        }
    }
    
    private func onPermissionHandlerDismiss() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true)
        }
    }
    
    private func onPermissionHandlerOpenAlertController(alertController : UIAlertController) {
        self.present(alertController, animated: true)
    }
    
    private func onPermissionHandlerRequestLoadPhotos(limited : Bool) {
        reactor.action( .requestToLoadPhotos(limited: limited) )
    }
    
    private func onPermissionHandlerShowCamera() {
        reactor.action( .setUpCameraPicker )
    }
}
extension SLPhotosPickerViewController {
    private func setLayout() {
        self.view.addSubview(topNaviBox)
        self.view.addSubview(closeBtn)
        self.view.addSubview(groupSelectBtn)
        self.view.addSubview(pickerCv)
        self.view.addSubview(albumSelectView)
        
        
        NSLayoutConstraint.activate([
            topNaviBox.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            topNaviBox.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            topNaviBox.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            topNaviBox.heightAnchor.constraint(equalToConstant: 48),
            
            
            closeBtn.centerYAnchor.constraint(equalTo: topNaviBox.centerYAnchor),
            closeBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 16),
            closeBtn.widthAnchor.constraint(equalToConstant: 24),
            closeBtn.heightAnchor.constraint(equalToConstant: 24),
            
            groupSelectBtn.centerYAnchor.constraint(equalTo: topNaviBox.centerYAnchor),
            groupSelectBtn.centerXAnchor.constraint(equalTo: topNaviBox.centerXAnchor),
            groupSelectBtn.heightAnchor.constraint(equalToConstant: 30),
            
            
            pickerCv.topAnchor.constraint(equalTo: topNaviBox.bottomAnchor, constant: 0),
            pickerCv.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            pickerCv.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            pickerCv.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            
            albumSelectView.topAnchor.constraint(equalTo: self.view.topAnchor),
            albumSelectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            albumSelectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            albumSelectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            
        ])
        
    }
}
