//
//  SLPhotosPickerViewController.swift
//  SLPhotosPicker
//
//  Created by wade.hawk on 2017. 4. 14..
//  Copyright © 2017년 wade.hawk. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import MobileCoreServices
import ShopliveSDKCommon

public struct SLPhotosPickerConfigure {
    public var customLocalizedTitle: [String: String] = ["Camera Roll": "Camera Roll"]
    public var tapHereToChange = "Tap here to change"
    public var cancelTitle = "Cancel"
    public var doneTitle = "Done"
    public var emptyMessage = "No albums"
    public var selectMessage = "Select"
    public var deselectMessage = "Deselect"
    public var emptyImage: UIImage? = nil
    public var usedCameraButton = true
    public var defaultToFrontFacingCamera = false
    public var usedPrefetch = false
    public var allowedVideo = true
    public var allowedAlbumCloudShared = false
    public var allowedVideoRecording = true
    public var recordingVideoQuality: UIImagePickerController.QualityType = .typeHigh
    public var maxVideoDuration:TimeInterval? = nil
    public var preventAutomaticLimitedAccessAlert = true
    public var mediaType: PHAssetMediaType? = .video
    public var numberOfColumn = 3
    public var minimumLineSpacing: CGFloat = 8
    public var minimumInteritemSpacing: CGFloat = 8
    public var singleSelectedMode = false
    public var singleSelectedDismiss = true
    public var maxSelectedAssets: Int? = nil
    public var fetchOption: PHFetchOptions? = nil
    public var fetchCollectionOption: [FetchCollectionType: PHFetchOptions] = [:]
    public var selectedColor = UIColor(red: 88/255, green: 144/255, blue: 255/255, alpha: 1.0)
    public var cameraBgColor = UIColor(red: 221/255, green: 223/255, blue: 226/255, alpha: 1)
    public var cameraIcon = UIImage(named: "sl_camera")
    public var groupByFetch: PHFetchedResultGroupedBy? = nil
    public var supportedInterfaceOrientations: UIInterfaceOrientationMask = .portrait
    public var popup: [PopupConfigure] = []
    public init() {
        
    }
}

public enum FetchCollectionType {
    case assetCollections(PHAssetCollectionType)
    case topLevelUserCollections
}

extension FetchCollectionType: Hashable {
    private var identifier: String {
        switch self {
        case let .assetCollections(collectionType):
            return "assetCollections\(collectionType.rawValue)"
        case .topLevelUserCollections:
            return "topLevelUserCollections"
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
}

public enum PopupConfigure {
    case animation(TimeInterval)
}

public struct Platform {
    public static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
    }
}

open class SLPhotosPickerViewController: UIViewController {
    @IBOutlet open var navigationBar: UINavigationBar!
    @IBOutlet open var titleView: UIView!
    @IBOutlet open var titleLabel: UILabel!
    @IBOutlet open var albumPopView: SLAlbumPopView!
    @IBOutlet open var collectionView: UICollectionView!
    @IBOutlet open var indicator: UIActivityIndicatorView!
    @IBOutlet open var popArrowImageView: UIImageView!
    @IBOutlet open var customNavItem: UINavigationItem!
    @IBOutlet open var cancelButton: UIBarButtonItem!
    @IBOutlet open var navigationBarTopConstraint: NSLayoutConstraint!
    @IBOutlet open var emptyView: UIView!
    @IBOutlet open var emptyImageView: UIImageView!
    @IBOutlet open var emptyMessageLabel: UILabel!
    @IBOutlet open var photosButton: UIBarButtonItem!
    
    private var mediaPicker: UIImagePickerController?
    
    public lazy var loadingProgress: SLLoadingAlertController = {
        let vc = SLLoadingAlertController()
        vc.delegate = self
        return vc
    }()
    
    private var isViewLoading: Bool = false
    
    weak var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
    weak var shoplivePermissionDelegate : ShopLivePermissionHandler?
    var video: ShortsVideo? = nil
    open var selectedAssets = [SLPHAsset]()
    open var isSelectedFromCamera: Bool = false
    public var configure = SLPhotosPickerConfigure()
    
    private var usedCameraButton: Bool {
        return self.configure.usedCameraButton
    }
    
    private var allowedVideo: Bool {
        return self.configure.allowedVideo
    }
    private var usedPrefetch: Bool {
        get {
            return self.configure.usedPrefetch
        }
        set {
            self.configure.usedPrefetch = newValue
        }
    }
    
    private var collections = [SLAssetsCollection]()
    private var focusedCollection: SLAssetsCollection? = nil
    private var requestIDs = SLSynchronizedDictionary<IndexPath,PHImageRequestID>()
    private var photoLibrary = SLPhotoLibrary()
    private var queue = DispatchQueue(label: "tilltue.photos.pikcker.queue")
    private var queueForGroupedBy = DispatchQueue(label: "tilltue.photos.pikcker.queue.for.groupedBy", qos: .utility)
    private var thumbnailSize = CGSize.zero
    private var cameraImage: UIImage? = nil
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init() {
        super.init(nibName: "SLPhotosPickerViewController", bundle: Bundle(for: type(of: self)))
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.configure.supportedInterfaceOrientations
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateUserInterfaceStyle()
    }
    
    private func updateUserInterfaceStyle() {
        if #available(iOS 13.0, *) {
            let userInterfaceStyle = self.traitCollection.userInterfaceStyle
            let bundle = Bundle(for: type(of: self))
            let image = UIImage(named: "sl_pop_arrow", in: bundle, compatibleWith: nil)
            let subImage = UIImage(named: "sl_arrow", in: bundle, compatibleWith: nil)
            
            self.view.backgroundColor = .white
            self.collectionView.backgroundColor = .white
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setupPicker()
        makeUI()
        checkAuthorization()
        
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 11.0, *) {
        } else if self.navigationBarTopConstraint.constant == 0 {
            self.navigationBarTopConstraint.constant = 20
        }
        updateCancelButtonUI()
        
        initItemSize()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        if self.photoLibrary.delegate == nil {
            checkAuthorization()
        }
        if isViewLoading {
            isViewLoading = false
        }
    }
    
    deinit {
        ShopLiveLogger.debugLog("[ShopliveShortformEditor] SLPhotosPickerViewController deinited")
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    private func setupPicker() {
        var configure = SLPhotosPickerConfigure()
        let bundle = Bundle(for: type(of: self))
        configure.cameraIcon = UIImage(named: "sl_camera", in: bundle, compatibleWith: nil)
        configure.mediaType = .video
        configure.numberOfColumn = 3
        configure.singleSelectedMode = true
        configure.singleSelectedDismiss = false
        self.configure = configure
    }

    private func loadPhotos(limitMode: Bool) {
        self.photoLibrary.limitMode = limitMode
        self.photoLibrary.delegate = self
        self.photoLibrary.fetchCollection(configure: self.configure)
    }
    
    private func checkAuthorization() {
        if #available(iOS 14.0, *) {
            let status = PHPhotoLibrary.authorizationStatus(for:  .readWrite)
            print("[HASSAN LOG] status \(status)")
            processAlbumAccessAuthorization(status: status)
        } else {
            let status = PHPhotoLibrary.authorizationStatus()
            print("[HASSAN LOG] status \(status)")
            processAlbumAccessAuthorization(status: status)
        }
    }
    
    
    private func processAlbumAccessAuthorization(status: PHAuthorizationStatus) {
        switch status {
        case .notDetermined:
            requestAuthorization()
        case .limited:
            loadPhotos(limitMode: true)
            self.handleAlbumPermissions(picker: self, status: .limited)
        case .authorized:
            loadPhotos(limitMode: false)
            self.handleAlbumPermissions(picker: self, status: .authorized)
        case .restricted, .denied:
            self.handleAlbumPermissions(picker: self, status:  .denied)
        @unknown default:
            break
        }
    }
    
    
    private func requestAuthorization() {
        if #available(iOS 14.0, *) {
            PHPhotoLibrary.requestAuthorization(for:  .readWrite) { [weak self] status in
                self?.processAlbumAccessAuthorization(status: status)
            }
        } else {
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                self?.processAlbumAccessAuthorization(status: status)
            }
        }
    }
    
    private func findIndexAndReloadCells(phAsset: PHAsset) {
        if
            self.configure.groupByFetch != nil,
            let indexPath = self.focusedCollection?.findIndex(phAsset: phAsset)
        {
            self.collectionView.reloadItems(at: [indexPath])
            return
        }
        if
            var index = self.focusedCollection?.fetchResult?.index(of: phAsset),
            let focused = self.focusedCollection,
            index != NSNotFound
        {
            index += (focused.useCameraButton) ? 1 : 0
            self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    open func deselectWhenUsingSingleSelectedMode() {
        if
            self.configure.singleSelectedMode == true,
            let selectedPHAsset = self.selectedAssets.first?.phAsset
        {
            self.selectedAssets.removeAll()
            findIndexAndReloadCells(phAsset: selectedPHAsset)
        }
    }
    
    open func maxCheck() -> Bool {
        deselectWhenUsingSingleSelectedMode()
        if let max = self.configure.maxSelectedAssets, max <= self.selectedAssets.count {
            return true
        }
        return false
    }
}

// MARK: - UI & UI Action
extension SLPhotosPickerViewController {
    
    @objc public func registerNib(nibName: String, bundle: Bundle) {
        self.collectionView.register(UINib(nibName: nibName, bundle: bundle), forCellWithReuseIdentifier: nibName)
    }
    
    private func centerAtRect(image: UIImage?, rect: CGRect, bgColor: UIColor = UIColor.white) -> UIImage? {
        guard let image = image else { return nil }
        UIGraphicsBeginImageContextWithOptions(rect.size, false, image.scale)
        bgColor.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        image.draw(in: CGRect(x:rect.size.width/2 - image.size.width/2, y:rect.size.height/2 - image.size.height/2, width:image.size.width, height:image.size.height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    private func initItemSize() {
        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        let count = CGFloat(self.configure.numberOfColumn)
        let width = floor(((self.view.safeAreaLayoutGuide.layoutFrame.size.width - 12) - (self.configure.minimumInteritemSpacing * (count-1))) / count)
        self.thumbnailSize = CGSize(width: width, height: width * 1.33333333)//1.52380952)
        layout.itemSize = self.thumbnailSize
        layout.minimumInteritemSpacing = self.configure.minimumInteritemSpacing
        layout.minimumLineSpacing = self.configure.minimumLineSpacing
        layout.sectionInset = .init(top: 0, left: 6, bottom: 0, right: 6)
        self.collectionView.collectionViewLayout = layout
        self.cameraImage = self.configure.cameraIcon
    }
    
    @objc open func makeUI() {
        registerNib(nibName: "SLPhotoCollectionViewCell", bundle: Bundle(for: type(of: self)))
        self.indicator.startAnimating()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(titleTap))
        self.titleView.addGestureRecognizer(tapGesture)
        self.titleLabel.text = self.configure.customLocalizedTitle["Camera Roll"]
        self.cancelButton.title = self.configure.cancelTitle
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)]
        self.emptyView.isHidden = true
        self.emptyImageView.image = self.configure.emptyImage
        self.emptyMessageLabel.text = self.configure.emptyMessage
        self.albumPopView.tableView.delegate = self
        self.albumPopView.tableView.dataSource = self
//        self.popArrowImageView.image = SLBundle.podBundleImage(named: "pop_arrow")
        self.popArrowImageView.isHidden = true

        if #available(iOS 10.0, *), self.usedPrefetch {
            self.collectionView.isPrefetchingEnabled = true
            self.collectionView.prefetchDataSource = self
        } else {
            self.usedPrefetch = false
        }
        
        self.collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        self.navigationBar.delegate = self
        updateUserInterfaceStyle()
    }
    
    private func updatePresentLimitedLibraryButton() {
        if #available(iOS 14.0, *), self.photoLibrary.limitMode && self.configure.preventAutomaticLimitedAccessAlert {
            self.customNavItem.rightBarButtonItems = [ self.photosButton ]
        } else {
            self.customNavItem.rightBarButtonItems = []
        }
    }
    
    private func updateTitle() {
        guard self.focusedCollection != nil else { return }
        let titleAttributedString = NSMutableAttributedString(string: self.focusedCollection?.title ?? "")
        
        let arrowImage = UIImage(named: "sl_arrow", in: Bundle(for: type(of: self)), compatibleWith: nil)
        let arrowAttachment = NSTextAttachment()
        arrowAttachment.image = arrowImage
        arrowAttachment.bounds = CGRectMake(0, -5, 20, 20)
        let arrowString = NSAttributedString(attachment: arrowAttachment)



        titleAttributedString.append(arrowString)
            
        self.titleLabel.attributedText = titleAttributedString
        
        
        updatePresentLimitedLibraryButton()
    }
    
    private func updateCancelButtonUI() {
        self.cancelButton.tintColor = .black
    }
    
    private func reloadCollectionView() {
        guard self.focusedCollection != nil else {
            return
        }
        if let groupedBy = self.configure.groupByFetch, self.usedPrefetch == false {
            queueForGroupedBy.async { [weak self] in
                self?.focusedCollection?.reloadSection(groupedBy: groupedBy)
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }else {
            self.collectionView.reloadData()
        }
    }
    
    private func reloadTableView() {
        
        let count = min(5, self.collections.count)
        var frame = self.albumPopView.popupView.frame
        frame.size.height = CGFloat(count * 75)
        self.albumPopView.popupViewHeight.constant = CGFloat(count * 75)
        UIView.animate(withDuration: self.albumPopView.show ? 0.1:0) {
            self.albumPopView.popupView.frame = frame
            self.albumPopView.setNeedsLayout()
        }
        self.albumPopView.tableView.reloadData()
        self.albumPopView.setupPopupFrame()
    }
    
    private func registerChangeObserver() {
        PHPhotoLibrary.shared().register(self)
    }
    
    private func getfocusedIndex() -> Int {
        guard let focused = self.focusedCollection, let result = self.collections.firstIndex(where: { $0 == focused }) else { return 0 }
        return result
    }
    
    private func getCollection(section: Int) -> PHAssetCollection? {
        guard section < self.collections.count else {
            return nil
        }
        return self.collections[section].phAssetCollection
    }
    
    private func focused(collection: SLAssetsCollection) {
        func resetRequest() {
            cancelAllImageAssets()
        }
        resetRequest()
        self.collections[getfocusedIndex()].recentPosition = self.collectionView.contentOffset
        var reloadIndexPaths = [IndexPath(row: getfocusedIndex(), section: 0)]
        self.focusedCollection = collection
        self.focusedCollection?.fetchResult = self.photoLibrary.fetchResult(collection: collection, configure: self.configure)
        reloadIndexPaths.append(IndexPath(row: getfocusedIndex(), section: 0))
        self.albumPopView.tableView.reloadRows(at: reloadIndexPaths, with: .none)
        self.albumPopView.show(false, duration: self.configure.popup.duration)
        self.updateTitle()
        self.reloadCollectionView()
        self.collectionView.contentOffset = collection.recentPosition
    }
    
    private func cancelAllImageAssets() {
        self.requestIDs.forEach{ (indexPath, requestID) in
            self.photoLibrary.cancelPHImageRequest(requestID: requestID)
        }
        self.requestIDs.removeAll()
    }
    
    // User Action
    @objc func titleTap() {
        guard collections.count > 0 else { return }
        if isAlbumEmpty() { return }
        self.albumPopView.show(self.albumPopView.isHidden, duration: self.configure.popup.duration)
    }
    
    private func isAlbumEmpty() -> Bool {
        var block : Bool = true
        for collection in collections {
            if collection.getAsset(at: 0) == nil {
                block = block && true
            }
            else {
                block = block && false
            }
        }
        return block
    }
    
    @IBAction open func cancelButtonTap() {
        self.dismiss(done: false)
    }
    
    @IBAction open func doneButtonTap() {
        self.dismiss(done: true)
    }
    
    @IBAction open func limitButtonTap() {
        if #available(iOS 14.0, *) {
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
        }
    }
    
    private func dismiss(done: Bool) {
        self.video = nil
        shortformEditorDelegate?.onShortformEditorMediaPickerDismiss()
        self.dismiss(animated: true)
    }
    
    private func focusFirstCollection() {
        if self.focusedCollection == nil, let collection = self.collections.first {
            self.focusedCollection = collection
            self.updateTitle()
            self.reloadCollectionView()
        }
    }
}

// MARK: - SLPhotoLibraryDelegate
extension SLPhotosPickerViewController: SLPhotoLibraryDelegate {
    func loadCameraRollCollection(collection: SLAssetsCollection) {
        self.collections = [collection]
        self.focusFirstCollection()
        self.indicator.stopAnimating()
        self.reloadTableView()
        self.titleView.isHidden = isAlbumEmpty()
    }
    
    func loadCompleteAllCollection(collections: [SLAssetsCollection]) {
        self.collections = collections
        self.focusFirstCollection()
        let isEmpty = self.collections.count == 0
        self.emptyView.isHidden = !isEmpty
        self.emptyImageView.isHidden = self.emptyImageView.image == nil
        self.indicator.stopAnimating()
        self.reloadTableView()
        self.registerChangeObserver()
        self.titleView.isHidden = isAlbumEmpty()
    }
}

// MARK: - Camera Picker
extension SLPhotosPickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func showCameraIfAuthorized() {
        let cameraAuthorization = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorization {
        case .authorized:
            self.showCamera()
        case .notDetermined:
            self.requestCameraPermission()
        case .restricted, .denied:
            self.handleCameraPermissions(picker: self, status: .denied)
        @unknown default:
            break
        }
    }
    
    private func requestCameraPermission(){
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] (authorized) in
            DispatchQueue.main.async { [weak self] in
                if authorized {
                    self?.showCamera()
                } else {
                    if let self = self { 
                        self.handleAlbumPermissions(picker: self, status: .denied)
                    }
                }
            }
        })
    }
    
    private func showCamera() {
        guard !maxCheck() else { return }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        var mediaTypes: [String] = []
        if self.configure.allowedVideoRecording {
            mediaTypes.append(kUTTypeMovie as String)
            picker.videoQuality = self.configure.recordingVideoQuality
            if let duration = self.configure.maxVideoDuration {
                picker.videoMaximumDuration = duration
            }
        }
        guard mediaTypes.count > 0 else {
            return
        }
        picker.cameraDevice = configure.defaultToFrontFacingCamera ? .front : .rear
        picker.mediaTypes = mediaTypes
        picker.allowsEditing = false
        picker.delegate = self
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            picker.popoverPresentationController?.sourceView = view
        }
        isViewLoading = true
        self.present(picker, animated: true, completion: nil)
    }

//    private func handleDeniedAlbumsAuthorization() {
//        self.delegate?.handleAlbumPermissions(picker: self,status: .denied)
//    }
    
//    private func handleDeniedCameraAuthorization() {
//        self.delegate?.handleCameraPermissions(picker: self,status: .denied)
//    }
    
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = (info[.originalImage] as? UIImage) {
            var placeholderAsset: PHObjectPlaceholder? = nil
            PHPhotoLibrary.shared().performChanges({
                let newAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                placeholderAsset = newAssetRequest.placeholderForCreatedAsset
            }, completionHandler: { [weak self] (success, error) in
                guard self?.maxCheck() == false else { return }
                if success, let `self` = self, let identifier = placeholderAsset?.localIdentifier {
                    guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else { return }
                    var result = SLPHAsset(asset: asset)
                    result.selectedOrder = self.selectedAssets.count + 1
                    result.isSelectedFromCamera = true
                    self.selectedAssets.append(result)
                }
            })
        }
        else if (info[.mediaType] as? String) == kUTTypeMovie as String {
            var placeholderAsset: PHObjectPlaceholder? = nil
            PHPhotoLibrary.shared().performChanges({
                let newAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: info[.mediaURL] as! URL)
                placeholderAsset = newAssetRequest?.placeholderForCreatedAsset
            }) { [weak self] (sucess, error) in
                guard self?.maxCheck() == false else { return }
                if sucess, let `self` = self, let identifier = placeholderAsset?.localIdentifier {
                    guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else { return }
                    
                    // print("loadVideo  - ")
                    var result = SLPHAsset(asset: asset)
                    result.selectedOrder = self.selectedAssets.count + 1
                    result.isSelectedFromCamera = true
                    self.isSelectedFromCamera = true
                    self.selectedAssets.append(result)
                    self.singleSelected()
                }
            }
        }
        
        guard self.isSelectedFromCamera else {
            mediaPicker = picker
            return
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func dismissPicker(completion : (() -> ())?) {
        self.isSelectedFromCamera = false
        mediaPicker?.dismiss(animated: true, completion: completion)
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension SLPhotosPickerViewController: PHPhotoLibraryChangeObserver {
    private func getChanges(_ changeInstance: PHChange) -> PHFetchResultChangeDetails<PHAsset>? {
        self.photoLibrary.fetchCollection(configure: self.configure)
        func isChangesCount<T>(changeDetails: PHFetchResultChangeDetails<T>?) -> Bool {
            guard let changeDetails = changeDetails else {
                return false
            }
            let before = changeDetails.fetchResultBeforeChanges.count
            let after = changeDetails.fetchResultAfterChanges.count
            return before != after
        }
        
        func isAlbumsChanges() -> Bool {
            guard let albums = self.photoLibrary.albums else {
                return false
            }
            let changeDetails = changeInstance.changeDetails(for: albums)
            return isChangesCount(changeDetails: changeDetails)
        }
        
        func isCollectionsChanges() -> Bool {
            for fetchResultCollection in self.photoLibrary.assetCollections {
                let changeDetails = changeInstance.changeDetails(for: fetchResultCollection)
                if isChangesCount(changeDetails: changeDetails) == true {
                    return true
                }
            }
            return false
        }
        
        if isAlbumsChanges() || isCollectionsChanges() {
            DispatchQueue.main.async {
                self.albumPopView.show(false, duration: self.configure.popup.duration)
                self.photoLibrary.fetchCollection(configure: self.configure)
            }
            return nil
        }else {
            guard let changeFetchResult = self.focusedCollection?.fetchResult else { return nil }
            guard let changes = changeInstance.changeDetails(for: changeFetchResult) else { return nil }
            return changes
        }
    }
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        var addIndex = 0
        if getfocusedIndex() == 0 {
            addIndex = self.usedCameraButton ? 1 : 0
        }
        DispatchQueue.main.async {
            guard let changes = self.getChanges(changeInstance) else {
                return
            }
            
            if changes.hasIncrementalChanges, self.configure.groupByFetch == nil {
                var deletedSelectedAssets = false
                var order = 0
                self.selectedAssets = self.selectedAssets.enumerated().compactMap({ (offset,asset) -> SLPHAsset? in
                    var asset = asset
                    if let phAsset = asset.phAsset, changes.fetchResultAfterChanges.contains(phAsset) {
                        order += 1
                        asset.selectedOrder = order
                        return asset
                    }
                    deletedSelectedAssets = true
                    return nil
                })
                if deletedSelectedAssets {
                    self.focusedCollection?.fetchResult = changes.fetchResultAfterChanges
                    self.reloadCollectionView()
                }else {
                    self.collectionView.performBatchUpdates({ [weak self] in
                        guard let `self` = self else { return }
                        self.focusedCollection?.fetchResult = changes.fetchResultAfterChanges
                        if let removed = changes.removedIndexes, removed.count > 0 {
                            self.collectionView.deleteItems(at: removed.map { IndexPath(item: $0+addIndex, section:0) })
                        }
                        if let inserted = changes.insertedIndexes, inserted.count > 0 {
                            self.collectionView.insertItems(at: inserted.map { IndexPath(item: $0+addIndex, section:0) })
                        }
                        changes.enumerateMoves { fromIndex, toIndex in
                            self.collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                         to: IndexPath(item: toIndex, section: 0))
                        }
                    }, completion: { [weak self] (completed) in
                        guard let `self` = self else { return }
                        if completed {
                            if let changed = changes.changedIndexes, changed.count > 0 {
                                self.collectionView.reloadItems(at: changed.map { IndexPath(item: $0+addIndex, section:0) })
                            }
                        }
                    })
                }
            }else {
                self.focusedCollection?.fetchResult = changes.fetchResultAfterChanges
                self.reloadCollectionView()
            }
            if let collection = self.focusedCollection {
                self.collections[self.getfocusedIndex()] = collection
                self.albumPopView.tableView.reloadRows(at: [IndexPath(row: self.getfocusedIndex(), section: 0)], with: .none)
            }
        }
    }
}

// MARK: - UICollectionView delegate & datasource
extension SLPhotosPickerViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDataSourcePrefetching {
    private func getSelectedAssets(_ asset: SLPHAsset) -> SLPHAsset? {
        if let index = self.selectedAssets.firstIndex(where: { $0.phAsset == asset.phAsset }) {
            return self.selectedAssets[index]
        }
        return nil
    }
    
    private func orderUpdateCells() {
        let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems.sorted(by: { $0.row < $1.row })
        for indexPath in visibleIndexPaths {
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? SLPhotoCollectionViewCell else { continue }
            guard let asset = self.focusedCollection?.getSLAsset(at: indexPath) else { continue }
            if let selectedAsset = getSelectedAssets(asset) {
                cell.selectedAsset = true
                cell.orderLabel?.text = "\(selectedAsset.selectedOrder)"
            }else {
                cell.selectedAsset = false
            }
        }
    }
    
    //Delegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let collection = self.focusedCollection, let cell = self.collectionView.cellForItem(at: indexPath) as? SLPhotoCollectionViewCell else { return }
        
        let isCameraRow = collection.useCameraButton && indexPath.section == 0 && indexPath.row == 0
        
        if isCameraRow {
            selectCameraCell(cell)
            return
        }
        toggleSelection(for: cell, at: indexPath)
        deselectWhenUsingSingleSelectedMode()
    }
    
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? SLPhotoCollectionViewCell {
            cell.endDisplayingCell()
        }
        guard let requestID = self.requestIDs[indexPath] else { return }
        self.requestIDs.removeValue(forKey: indexPath)
        self.photoLibrary.cancelPHImageRequest(requestID: requestID)
    }
    
    //Datasource
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        func makeCell(nibName: String) -> SLPhotoCollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: nibName, for: indexPath) as! SLPhotoCollectionViewCell
            cell.configure = self.configure
            cell.liveBadgeImageView?.image = nil
            return cell
        }
        let nibName = "SLPhotoCollectionViewCell"
        var cell = makeCell(nibName: nibName)
        guard let collection = self.focusedCollection else { return cell }
        cell.isCameraCell = collection.useCameraButton && indexPath.section == 0 && indexPath.row == 0
        if cell.isCameraCell {
            cell.imageView?.image = self.cameraImage
            cell.updateImage()
            return cell
        }
        
        guard let asset = collection.getSLAsset(at: indexPath) else { return cell }
        cell.asset = asset.phAsset
        
        if let selectedAsset = getSelectedAssets(asset) {
            cell.selectedAsset = true
            cell.orderLabel?.text = "\(selectedAsset.selectedOrder)"
        }else{
            cell.selectedAsset = false
        }
        if asset.state == .progress {
            cell.indicator?.startAnimating()
        }else {
            cell.indicator?.stopAnimating()
        }
        if let phAsset = asset.phAsset {
            if self.usedPrefetch {
                let options = PHImageRequestOptions()
                options.deliveryMode = .opportunistic
                options.resizeMode = .exact
                options.isNetworkAccessAllowed = true
                let requestID = self.photoLibrary.imageAsset(asset: phAsset, size: self.thumbnailSize, options: options) { [weak self, weak cell] (image,complete) in
                    guard let `self` = self else { return }
                    DispatchQueue.main.async {
                        if self.requestIDs[indexPath] != nil {
                            cell?.imageView?.image = image
                            cell?.update(with: phAsset)
                            if self.allowedVideo {
                                cell?.durationView?.isHidden = asset.type != .video
                                cell?.duration = asset.type == .video ? phAsset.duration : nil
                            }
                            if complete {
                                self.requestIDs.removeValue(forKey: indexPath)
                            }
                        }
                    }
                }
                if requestID > 0 {
                    self.requestIDs[indexPath] = requestID
                }
            }else {
                queue.async { [weak self, weak cell] in
                    guard let `self` = self else { return }
                    let requestID = self.photoLibrary.imageAsset(asset: phAsset, size: self.thumbnailSize, completionBlock: { (image,complete) in
                        DispatchQueue.main.async {
                            if self.requestIDs[indexPath] != nil {
                                cell?.imageView?.image = image
                                cell?.update(with: phAsset)
                                if self.allowedVideo {
                                    cell?.durationView?.isHidden = asset.type != .video
                                    cell?.duration = asset.type == .video ? phAsset.duration : nil
                                }
                                if complete {
                                    self.requestIDs.removeValue(forKey: indexPath)
                                }
                            }
                        }
                    })
                    if requestID > 0 {
                        self.requestIDs[indexPath] = requestID
                    }
                }
            }
        }
        cell.alpha = 0
        UIView.transition(with: cell, duration: 0.1, options: .curveEaseIn, animations: {
            cell.alpha = 1
        }, completion: nil)
        cell.updateImage()
        return cell
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.focusedCollection?.sections?.count ?? 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let collection = self.focusedCollection else {
            return 0
        }
        return self.focusedCollection?.sections?[safe: section]?.assets.count ?? collection.count
    }
    
    //Prefetch
    open func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if self.usedPrefetch {
            queue.async { [weak self] in
                guard let `self` = self, let collection = self.focusedCollection else { return }
                var assets = [PHAsset]()
                for indexPath in indexPaths {
                    if let asset = collection.getAsset(at: indexPath.row) {
                        assets.append(asset)
                    }
                }
                let scale = max(UIScreen.main.scale,2)
                let targetSize = CGSize(width: self.thumbnailSize.width*scale, height: self.thumbnailSize.height*scale)
                self.photoLibrary.imageManager.startCachingImages(for: assets, targetSize: targetSize, contentMode: .aspectFill, options: nil)
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        if self.usedPrefetch {
            for indexPath in indexPaths {
                guard let requestID = self.requestIDs[indexPath] else { continue }
                self.photoLibrary.cancelPHImageRequest(requestID: requestID)
                self.requestIDs.removeValue(forKey: indexPath)
            }
            queue.async { [weak self] in
                guard let `self` = self, let collection = self.focusedCollection else { return }
                var assets = [PHAsset]()
                for indexPath in indexPaths {
                    if let asset = collection.getAsset(at: indexPath.row) {
                        assets.append(asset)
                    }
                }
                let scale = max(UIScreen.main.scale,2)
                let targetSize = CGSize(width: self.thumbnailSize.width*scale, height: self.thumbnailSize.height*scale)
                self.photoLibrary.imageManager.stopCachingImages(for: assets, targetSize: targetSize, contentMode: .aspectFill, options: nil)
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SLPhotoCollectionViewCell else {
            return
        }
        cell.willDisplayCell()
        if self.usedPrefetch, let collection = self.focusedCollection, let asset = collection.getSLAsset(at: indexPath) {
            if let selectedAsset = getSelectedAssets(asset) {
                cell.selectedAsset = true
                cell.orderLabel?.text = "\(selectedAsset.selectedOrder)"
            }else{
                cell.selectedAsset = false
            }
        }
    }
}
// MARK: - UITableView datasource & delegate
extension SLPhotosPickerViewController: UITableViewDelegate, UITableViewDataSource {
    //delegate
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.focused(collection: self.collections[indexPath.row])
    }
    
    //datasource
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collections.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SLCollectionTableViewCell", for: indexPath) as! SLCollectionTableViewCell
        cell.accessoryType = .none
        cell.selectionStyle = .none
        let collection = self.collections[indexPath.row]
        cell.titleLabel.text = collection.title
        cell.subTitleLabel.text = "\(collection.fetchResult?.count ?? 0)"
        if let phAsset = collection.getAsset(at: collection.useCameraButton ? 1 : 0) {
            let scale = UIScreen.main.scale
            let size = CGSize(width: 80*scale, height: 80*scale)
            self.photoLibrary.imageAsset(asset: phAsset, size: size, completionBlock: {  (image,complete) in
                DispatchQueue.main.async {
                    if let cell = tableView.cellForRow(at: indexPath) as? SLCollectionTableViewCell {
                        cell.thumbImageView.image = image
                    }
                }
            })
        }
        return cell
    }
    
}
extension SLPhotosPickerViewController {
    func selectCameraCell(_ cell: SLPhotoCollectionViewCell) {
        guard Platform.isSimulator == false else { return }
        showCameraIfAuthorized()
    }
    
    func toggleSelection(for cell: SLPhotoCollectionViewCell, at indexPath: IndexPath) {
        guard let collection = focusedCollection, var asset = collection.getSLAsset(at: indexPath), let phAsset = asset.phAsset else { return }
        
        cell.popScaleAnim()
        
        if let index = selectedAssets.firstIndex(where: { $0.phAsset == asset.phAsset }) {
        //deselect
            selectedAssets.remove(at: index)
            selectedAssets = selectedAssets.enumerated().compactMap({ (offset,asset) -> SLPHAsset? in
                var asset = asset
                asset.selectedOrder = offset + 1
                return asset
            })
            cell.selectedAsset = false
            orderUpdateCells()
        } 
        else {
        //select
            guard !maxCheck() else {
                return
            }
            
            asset.selectedOrder = selectedAssets.count + 1
            selectedAssets.append(asset)
            cell.selectedAsset = true
            
            cell.orderLabel?.text = "\(asset.selectedOrder)"
            
            if self.configure.singleSelectedMode {
                if self.configure.singleSelectedDismiss {
                    self.dismiss(done: true)
                } else {
                    singleSelected()
                }
            }
        }
    }
}

extension SLPhotosPickerViewController: UINavigationBarDelegate {
    public func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension Array where Element == PopupConfigure {
    var duration: TimeInterval {
        var result: TimeInterval = 0.3
        forEach {
            if case let .animation(duration) = $0 {
                result = duration
            }
        }
        return result
    }
}
