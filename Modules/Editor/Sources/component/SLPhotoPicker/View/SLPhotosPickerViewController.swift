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
    func photoPicker(picker : UIViewController, didSelectVideo absoluteUrl: URL, relativeUrl : URL,videoCreationDate : Date?)
    func photoPicker(picker : UIViewController,didSelectImage url: URL)
    func photoPiker(onClose picker : UIViewController)
    func photoPickerOnEvent(picker : UIViewController, name : EventTrace, payload : [String : Any]?)
}

public enum SLMediaType {
    case image
    case video
}

class SLPhotosPickerViewController : UIViewController {
    private var topNaviBox : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var closeBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(ShopLiveShortformEditorSDKAsset.slCloseButton.image.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.imageView?.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
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
    
    private var toastLabel : SlBlurBGLabel = {
        let view = SlBlurBGLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.label.textColor = .white
        view.label.setFont(font: .init(size: 15, weight: .bold))
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view._layoutMargin = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.alpha = 0
        return view
    }()
    
    private let reactor = SLPhotosPickerReactor()
    private let permissionHandler = SLPhotoPickerPermissionHandler()
    lazy private var loadingProgressVc : SLLoadingAlertController = {
        let vc = SLLoadingAlertController()
        vc.useProgress = false
        vc.delegate = reactor
        return vc
    }()
    
    weak var delegate : SLPhotosPickerViewControllerDelegate?
    weak var permissionDelegate : ShopLivePermissionHandler?
    
    
    required init(mediaType : SLMediaType,permissionDelegate : ShopLivePermissionHandler?) {
        super.init(nibName: nil, bundle: nil)
        var config = SLPhotosPickerConfigure()
        self.permissionDelegate = permissionDelegate
        config.mediaType = mediaType == .video ? .video : .image
        config.usedCameraButton = true
//        mediaType == .video ? true : false
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
        delegate?.photoPickerOnEvent(picker: self, name: .MEDIA_PICKER_CLICK_CLOSE, payload: nil)
        delegate?.photoPiker(onClose: self)
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
            case .didSelectVideo((let absoluteUrl, let relativeUrl, let videoCreationDate)):
                self.onReactorDidSelectVideo(absoluteUrl: absoluteUrl, relativeUrl: relativeUrl, videoCreationDate : videoCreationDate)
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
            case .updateGroupSelectBtnTitle(let title):
                self.onReactorUpdateGroupSelectBtnTitle(title: title)
            case .showToast(let message):
                self.onReactorShowToast(message : message)
            case .updateLoadingPercentLabel(let percent):
                self.onReactorUpdateLoadingPercentLabel(percent : percent)
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
        delegate?.photoPickerOnEvent(picker: self,name: .MEDIA_PICKER_CLICK_CONFIRM, payload: nil)
        delegate?.photoPicker(picker: self, didSelectImage: imageUrl)
    }
    
    private func onReactorDidSelectVideo(absoluteUrl : URL, relativeUrl : URL,videoCreationDate : Date?) {
        delegate?.photoPickerOnEvent(picker: self,name: .MEDIA_PICKER_CLICK_CONFIRM, payload: nil)
        delegate?.photoPicker(picker: self, didSelectVideo: absoluteUrl,relativeUrl: relativeUrl, videoCreationDate: videoCreationDate)
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
            self.loadingProgressVc.setLoadingText("0%")
            
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
    
    private func onReactorUpdateGroupSelectBtnTitle(title : String) {
        DispatchQueue.main.async { [weak self] in
            self?.groupSelectBtn.setTitle(title: title)
        }
    }
    
    
    private func onReactorShowToast(message : String) {
        self.animateToast(message: message)
    }
    
    private func onReactorUpdateLoadingPercentLabel(percent : String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loadingProgressVc.setLoadingText(percent)
        }
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
        self.view.addSubview(toastLabel)
        
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
            albumSelectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            toastLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            toastLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            toastLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 400),
            toastLabel.heightAnchor.constraint(equalToConstant: 40)

        ])
    }
    
    private func animateToast(message : String) {
        toastLabel.label.text = message
        UIView.animateKeyframes(withDuration: 2, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2) {
                self.toastLabel.alpha = 1
            }

            UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
                self.toastLabel.alpha = 0
            }
        })
    }
}
