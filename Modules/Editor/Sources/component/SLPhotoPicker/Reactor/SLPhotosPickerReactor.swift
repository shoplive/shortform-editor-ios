//
//  SLPhotosPickerReactor.swift
//  CustomImagePicker
//
//  Created by sangmin han on 5/3/24.
//

import Foundation
import UIKit
import Photos
import PhotosUI
import ShopliveSDKCommon
import MobileCoreServices

class SLPhotosPickerReactor : NSObject, SLReactor {
    
    enum Action {
        case setPickerConfigure(SLPhotosPickerConfigure)
        case registerCv(UICollectionView)
        case requestToLoadPhotos(limited : Bool)
        case setFocusedCollection(SLAssetsCollection)
        case setUpCameraPicker
    }
    
    enum Result {
        case hideEmptyView(Bool)
        case showAlbumSelectView(Bool)
        case reloadAlbumSelectTablView
        case reloadAlbumSelectTableViewRow(([IndexPath], UITableView.RowAnimation))
        
        case setPhotoLibraryForAlbumSelectView(SLPhotoLibrary)
        case setAssetsCollectionForAlbumSelectView([SLAssetsCollection])
        
        case didSelectVideo((localAbsolutUrl : URL, localRelativeUrl : URL))
        case didSelectImage(URL)
        
        case dismissMediaPicker
        case showCamera(UIImagePickerController)
        case setPickerPopoverPresentationController(UIImagePickerController)
        
        case requestForCameraPermission
        
        case requestStartLoading
        case requestCancelLoading
        case requsetFinishLoading
        case didFinishLoading
        case updateGroupSelectBtnTitle(String)
        case showToast(String)
        case updateLoadingPercentLabel(String)
        
    }
    
    var resultHandler: ((Result) -> ())?
    
    
    
    private var pickerCv : UICollectionView?
    private let cellSpacing : CGFloat = 6
    
    private var pickerConfigure = SLPhotosPickerConfigure()
    private var collections : [SLAssetsCollection] = []
    private var focusedCollection : SLAssetsCollection? = nil
    private var photoLibrary = SLPhotoLibrary()
    private var thumbnailSize : CGSize = .init(width: 480, height: 720)
    private var requestIDs = SLSynchronizedDictionary<IndexPath,PHImageRequestID>()
    
    
    private var queue = DispatchQueue(label: "shoplive.photos.pikcker.queue")
    private var queueForGroupedBy = DispatchQueue(label: "shoplive.photos.pikcker.queue.for.groupedBy", qos: .utility)
    private var avAssetExportProgressTimer : Timer?
    private var exportSession : AVAssetExportSession?
    
   
    
    
    
    func focusToFirstCollection() {
        if self.focusedCollection == nil, let collection = self.collections.first {
            self.focusedCollection = collection
//            self.updateTitle()
            self.reloadCollectionView()
        }
    }
    
    func photoLibraryFetchCollection() {
        self.photoLibrary.fetchCollection(configure: self.pickerConfigure)
    }
    
    func registerChangeObserver() {
        PHPhotoLibrary.shared().register(self)
    }
    
    func reloadCollectionView() {
        guard self.focusedCollection != nil else { return }
        if let groupedBy = self.pickerConfigure.groupByFetch, pickerConfigure.usedPrefetch == false {
            queueForGroupedBy.async { [weak self] in
                guard let self = self else { return }
                self.focusedCollection?.reloadSection(groupedBy: groupedBy)
                DispatchQueue.main.async {
                    self.pickerCv?.reloadData()
                }
            }
        }
        else {
            self.pickerCv?.reloadData()
        }
    }
    
    func reloadTableView() {
        resultHandler?( .setPhotoLibraryForAlbumSelectView(photoLibrary) )
        resultHandler?( .setAssetsCollectionForAlbumSelectView(collections) )
        resultHandler?( .reloadAlbumSelectTablView )
    }
}
//MARK: - action
extension SLPhotosPickerReactor {
    func action(_ action: Action) {
        switch action {
        case .setPickerConfigure(let configure):
            self.onSetPickerConfigure(configure: configure)
        case .registerCv(let cv):
            self.onRegisterCv(cv: cv)
        case .requestToLoadPhotos(limited :let limited):
            self.onRequestToLoadPhotos(limited: limited)
        case .setFocusedCollection(let collection):
            self.onSetFocusedCollection(collection: collection)
        case .setUpCameraPicker:
            self.onSetUpCameraPicker()
        }
    }
    
    private func onSetPickerConfigure(configure : SLPhotosPickerConfigure) {
        self.pickerConfigure = configure
    }
    
    private func onRegisterCv(cv : UICollectionView) {
        self.pickerCv = cv
        cv.delegate = self
        cv.dataSource = self
        cv.register(SLPhotosPickerVideoCell.self, forCellWithReuseIdentifier: SLPhotosPickerVideoCell.cellId)
    }
    
    private func onRequestToLoadPhotos(limited : Bool) {
        self.photoLibrary.limitMode = limited
        self.photoLibrary.delegate = self
        self.photoLibrary.fetchCollection(configure: self.pickerConfigure)
    }
    
    private func onSetFocusedCollection(collection : SLAssetsCollection) {
        cancelAllImageAssets()
        guard let pickerCv = self.pickerCv else { return }
        self.collections[getCurrentFocusedCollectionIndex()].recentPosition = pickerCv.contentOffset
        var reloadIndexPaths = [IndexPath(row: getCurrentFocusedCollectionIndex(), section: 0)]
        self.focusedCollection = collection
        self.focusedCollection?.fetchResult = self.photoLibrary.fetchResult(collection: collection, configure: self.pickerConfigure)
        reloadIndexPaths.append(IndexPath(row: getCurrentFocusedCollectionIndex(), section: 0))
        resultHandler?( .reloadAlbumSelectTableViewRow((reloadIndexPaths, .none)))
        resultHandler?( .showAlbumSelectView(false) )
//        self.updateTitle()
        resultHandler?( .updateGroupSelectBtnTitle(collection.title))
        self.reloadCollectionView()
        pickerCv.contentOffset = collection.recentPosition
    }
    
    private func cancelAllImageAssets() {
        self.requestIDs.forEach{ (indexPath, requestID) in
            self.photoLibrary.cancelPHImageRequest(requestID: requestID)
        }
        self.requestIDs.removeAll()
    }
    
    private func onSetUpCameraPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        var mediaTypes : [String] = []
        if self.pickerConfigure.allowedVideoRecording {
            mediaTypes.append(kUTTypeMovie as String)
            picker.videoQuality = self.pickerConfigure.recordingVideoQuality
            if let duration = self.pickerConfigure.maxVideoDuration {
                picker.videoMaximumDuration = duration
            }
        }
        guard mediaTypes.count > 0 else {
            return
        }
        picker.cameraDevice = pickerConfigure.defaultToFrontFacingCamera ? .front : .rear
        picker.mediaTypes = mediaTypes
        picker.allowsEditing = false
        picker.delegate = self
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            resultHandler?( .setPickerPopoverPresentationController(picker) )
        }
        resultHandler?( .showCamera(picker) )
    }
}
extension SLPhotosPickerReactor : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.focusedCollection?.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let collection = self.focusedCollection else {
            return 0
        }
        return self.focusedCollection?.sections?[safe : section]?.assets.count ?? collection.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SLPhotosPickerVideoCell.cellId, for: indexPath) as! SLPhotosPickerVideoCell
        guard let collection = self.focusedCollection else {
            return cell
        }
        if collection.useCameraButton && indexPath.row == 0 {
            return configureCellForCamera(cell: cell, cellForItemAt: indexPath, collection: collection)
        }
        else {
            guard let asset = collection.getSLAsset(at: indexPath) else {
                return cell
            }
            return configureCellForAssets(cell: cell, cellForItemAt: indexPath,collection: collection,slAsset: asset)
        }
    }
    
    private func configureCellForCamera(cell: SLPhotosPickerVideoCell, cellForItemAt indexPath: IndexPath,collection : SLAssetsCollection) -> UICollectionViewCell {
        cell.configure(image: nil, duration: .zero)
        cell.setDurationLabelHidden(isHidden: true)
        cell.showCameraContents(show: true)
        return cell
    }
    
    private func configureCellForAssets(cell: SLPhotosPickerVideoCell, cellForItemAt indexPath: IndexPath,collection : SLAssetsCollection, slAsset : SLPHAsset) -> UICollectionViewCell {
        if let phAsset = slAsset.phAsset {
            if pickerConfigure.usedPrefetch {
                let options = PHImageRequestOptions()
                options.deliveryMode = .opportunistic
                options.resizeMode = .exact
                options.isNetworkAccessAllowed = true
                self.requestImageAssetForAssets(cell: cell, indexPath: indexPath, phAsset: phAsset, thumbnailSize: self.thumbnailSize, options: options)
            }
            else {
                queue.async { [weak self, weak cell] in
                    guard let self = self, let cell = cell else { return }
                    self.requestImageAssetForAssets(cell: cell, indexPath: indexPath, phAsset: phAsset, thumbnailSize: self.thumbnailSize, options: nil)
                }
            }
            cell.setDurationLabelHidden(isHidden: pickerConfigure.mediaType == .video ? false : true)
        }
        cell.showCameraContents(show: false)
        return cell
    }
    
    private func requestImageAssetForAssets(cell : SLPhotosPickerVideoCell, indexPath : IndexPath, phAsset : PHAsset, thumbnailSize : CGSize, options : PHImageRequestOptions?) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .exact
        options.isNetworkAccessAllowed = true
        let requestId = self.photoLibrary.imageAsset(asset: phAsset, size: thumbnailSize, options: options) { [weak self, weak cell] image , complete in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if self.requestIDs[indexPath] != nil && self.pickerConfigure.mediaType == .video {
                    cell?.configure(image: image, duration: phAsset.duration)
                    cell?.setDurationLabelHidden(isHidden: false)
                }
                else if self.requestIDs[indexPath] != nil && self.pickerConfigure.mediaType == .image {
                    cell?.configure(image: image, duration: .zero)
                    cell?.setDurationLabelHidden(isHidden: true)
                }
                else {
                    cell?.setDurationLabelHidden(isHidden: true)
                }
                if complete {
                    self.requestIDs.removeValue(forKey: indexPath)
                }
            }
        }
        if requestId > 0 {
            self.requestIDs[indexPath] = requestId
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = floor((collectionView.frame.width - (cellSpacing * 2)) / 3)
        let h = floor(w * (16 / 9))
        return .init(width: w, height: h + cellSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let requestID = self.requestIDs[indexPath] else { return }
        self.requestIDs.removeValue(forKey: indexPath)
        self.photoLibrary.cancelPHImageRequest(requestID: requestID)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let focusedCollection = self.focusedCollection else { return }
        
        let isCameraRow = focusedCollection.useCameraButton && indexPath.section == 0 && indexPath.row == 0
        
        if isCameraRow {
            resultHandler?( .requestForCameraPermission )
        }
        else {
            //TODO: - HASSAN need loading View
            guard let asset = focusedCollection.getSLAsset(at: indexPath) else { return }
            
            resultHandler?( .requestStartLoading )
            if self.pickerConfigure.mediaType == .video {
                if let duration = asset.phAsset?.duration {
                    let mediaPickerVideoDurationOption = ShopLiveEditorConfigurationManager.shared.mediaPickerVideoDurationOption
                    let minDuration = mediaPickerVideoDurationOption.minVideoDuration
                    let maxDuration = mediaPickerVideoDurationOption.maxVideoDuration
                    
                    if duration < Double(minDuration)  || duration > Double(maxDuration) {
                        var message : String
                        if let toastMessage = mediaPickerVideoDurationOption.invalidDurationToastMessage {
                            message = toastMessage
                        }
                        else if maxDuration >= 60 {
                            message = ShopLiveShortformEditorSDKStrings.Editor.Toast.Duration.Minute.shoplive(minDuration, Int(maxDuration / 60))
                        }
                        else {
                            message = ShopLiveShortformEditorSDKStrings.Editor.Toast.Duration.Second.shoplive(minDuration, maxDuration)
                        }
                        self.resultHandler?( .showToast(message) )
                        self.resultHandler?( .requsetFinishLoading )
                        return
                    }
                }
                
                guard let phAsset = asset.phAsset else  {
                    self.resultHandler?( .requsetFinishLoading )
                    return
                }
                self.getVideoUrlFromPhAsset(phAsset: phAsset) { [weak self] absoluteUrl,relativeUrl in
                    guard let absoluteUrl = absoluteUrl, let relativeUrl = relativeUrl else { return }
                    self?.resultHandler?( .requsetFinishLoading )
                    self?.resultHandler?( .didSelectVideo((absoluteUrl,relativeUrl)))
                }
            }
            else if self.pickerConfigure.mediaType == .image {
                asset.phAsset?.getImageUrl(completion: { [weak self] imageUrl in
                    guard let url = imageUrl else { return }
                    self?.resultHandler?( .requsetFinishLoading )
                    self?.resultHandler?( .didSelectImage(url) )
                })
            }
        }
    }
    
    private func getVideoUrlFromPhAsset(phAsset : PHAsset, completion : @escaping((absoluteUrl : URL?, relativeUrl : URL?)) -> () ) {
        guard phAsset.mediaType == .video else {
            completion((nil,nil))
            return
        }
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        options.version = .current
        options.isNetworkAccessAllowed = true
        
        
        if self.avAssetExportProgressTimer != nil {
            removeAVAssetExportSessionTimer()
        }
        self.avAssetExportProgressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.exportProgressTimer), userInfo: nil, repeats: true)
        self.avAssetExportProgressTimer?.fire()
        
        PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options, resultHandler: { [weak self] (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
            guard let asset = asset, let self = self else {
                self?.removeAVAssetExportSessionTimer()
                return
            }
            
            let dirPath = SLFileManager.editorDirectoryPath
            let outputURL = dirPath.appendingPathComponent("\(UUID().uuidString)_ShopLive.mp4")
            
            var preset : String = ""
            
            if self.isAsset4K(asset: asset) {
                preset = AVAssetExportPresetMediumQuality
            }
            else {
                preset = AVAssetExportPresetHighestQuality
            }
            
            self.exportSession = AVAssetExportSession(asset: asset, presetName: preset )
            guard let exportSession = self.exportSession else {
                self.removeAVAssetExportSessionTimer()
                completion((nil,nil))
                return
            }
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            exportSession.exportAsynchronously {
                self.removeAVAssetExportSessionTimer()
                if exportSession.status == .completed {
                    completion((outputURL,outputURL))
                } else {
                    ShopLiveLogger.tempLog("[SLPHOTOPICKER] exportSession error \(exportSession.error?.localizedDescription)")
                    completion((nil,nil))
                }
            }
        })
    }
    
    @objc
    private func exportProgressTimer(){
        let percentage = Int((exportSession?.progress ?? 0.0) * 100)
        let percentLabel = "\(percentage)%"
        resultHandler?( .updateLoadingPercentLabel(percentLabel) )
    }
    
    func removeAVAssetExportSessionTimer() {
        self.avAssetExportProgressTimer?.invalidate()
        self.avAssetExportProgressTimer = nil
    }
    
    private func isAsset4K(asset : AVAsset) -> Bool {
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            return true
        }
        
        let resolutionWidth = videoTrack.naturalSize.width
        let resolutionHeight = videoTrack.naturalSize.height
        
        return resolutionWidth >= 3840 && resolutionHeight >= 2160
    }
}
extension SLPhotosPickerReactor : UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard pickerConfigure.usedPrefetch else { return }
        queue.async { [weak self] in
            guard let self = self, let collection = self.focusedCollection else { return }
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
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        guard pickerConfigure.usedPrefetch else { return }
        for indexPath in indexPaths {
            guard let requestID = self.requestIDs[indexPath] else { continue }
            self.photoLibrary.cancelPHImageRequest(requestID: requestID)
            self.requestIDs.removeValue(forKey: indexPath)
        }
        
    }
    
}
//MARK: - Camera Picker
extension SLPhotosPickerReactor : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = (info[.originalImage] as? UIImage) {
            self.didPictureImageFromPickerController(picker : picker, info: info, image: image)
        }
        else if (info[.mediaType] as? String) == kUTTypeMovie as String {
            self.didPictureVideoFromPickerController(picker : picker, info: info)
        }
    }
    
    private func didPictureImageFromPickerController(picker : UIImagePickerController, info: [UIImagePickerController.InfoKey : Any], image : UIImage ) {
        var placeHolderAsset : PHObjectPlaceholder? = nil
        PHPhotoLibrary.shared().performChanges {
            let newAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            placeHolderAsset = newAssetRequest.placeholderForCreatedAsset
        } completionHandler: { [weak self] success, error in
            if success, let self = self, let identifier = placeHolderAsset?.localIdentifier {
                guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else { return }
                var result = SLPHAsset(asset: asset)
                result.selectedOrder = 1
                result.isSelectedFromCamera = true
                asset.getImageUrl { [weak self] url in
                    guard let url = url else { return }
                    DispatchQueue.main.async {
                        picker.dismiss(animated: true) {
                            self?.resultHandler?( .didSelectImage(url) )
                        }
                    }
                }
            }
        }
    }
    
    private func didPictureVideoFromPickerController(picker : UIImagePickerController,  info: [UIImagePickerController.InfoKey : Any]) {
        var placeHolderAsset : PHObjectPlaceholder? = nil
        PHPhotoLibrary.shared().performChanges {
            let newAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: info[.mediaURL] as! URL)
            placeHolderAsset = newAssetRequest?.placeholderForCreatedAsset
        } completionHandler: { [weak self] (sucess, error) in
            if sucess, let self = self, let identifier = placeHolderAsset?.localIdentifier {
                guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else { return }
                var result = SLPHAsset(asset: asset)
                
                result.selectedOrder = 1
                result.isSelectedFromCamera = true
                
                
                if let duration = result.phAsset?.duration {
                    let mediaPickerVideoDurationOption = ShopLiveEditorConfigurationManager.shared.mediaPickerVideoDurationOption
                    let minDuration = mediaPickerVideoDurationOption.minVideoDuration
                    let maxDuration = mediaPickerVideoDurationOption.maxVideoDuration
                    
                    if duration < Double(minDuration)  || duration > Double(maxDuration) {
                        var message : String = ""
                        if duration < Double(minDuration) {
                            message = ShopLiveShortformEditorSDKStrings.Editor.Alert.Min.Duration.shoplive(minDuration)
                        }
                        else if duration > Double(maxDuration) {
                            message = ShopLiveShortformEditorSDKStrings.Editor.Alert.Max.Duration.shoplive(maxDuration)
                        }
                        DispatchQueue.main.async {
                            picker.dismiss(animated: true) {
                                self.resultHandler?( .showToast(message) )
                                self.resultHandler?( .requsetFinishLoading )
                            }
                        }
                        return
                    }
                }
                
                asset.getVideoURl { [weak self] absoluteUrl,relativeUrl in
                    guard let absoluteUrl = absoluteUrl, let relativeUrl = relativeUrl else { return }
                    DispatchQueue.main.async {
                        picker.dismiss(animated: true) {
                            self?.resultHandler?( .didSelectVideo((absoluteUrl,relativeUrl)) )
                        }
                    }
                }
            }
        }

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        DispatchQueue.main.async {
            picker.dismiss(animated: true)
        }
        resultHandler?( .dismissMediaPicker )
    }
}
//MARK: - Setter
extension SLPhotosPickerReactor {
    func setAssetsCollections(collections : [SLAssetsCollection]) {
        self.collections = collections
    }
    
    func setCurrentFocusedCollectionFetchResult(result : PHFetchResult<PHAsset>?) {
        self.focusedCollection?.fetchResult = result
    }
    
    func setAssetsCollection(collection : SLAssetsCollection, at index : Int) {
        guard index < self.collections.count else { return }
        self.collections[index] = collection
    }
}
//MARK: -Getter
extension SLPhotosPickerReactor {
    func getAssetsCollection() -> [SLAssetsCollection] {
        return self.collections
    }
    
    func getPhotoLibraryAlbum() -> PHFetchResult<PHCollection>? {
        return self.photoLibrary.albums
    }
    
    func getPhotoLibraryAssetCollections() -> [PHFetchResult<PHAssetCollection>] {
        return self.photoLibrary.assetCollections
    }
    
    func getCurrentFocusedCollection() -> SLAssetsCollection? {
        return self.focusedCollection
    }
    
    func getFocusedCollectionFetchResult() -> PHFetchResult<PHAsset>? {
        return self.focusedCollection?.fetchResult
    }
    
    func getCurrentFocusedCollectionIndex() -> Int {
        guard let focused = self.focusedCollection, let result = self.collections.firstIndex(where: { $0 == focused }) else { return 0 }
        return result
    }
    
    func getPickerConfigureGroupByFetch() -> PHFetchedResultGroupedBy? {
        return self.pickerConfigure.groupByFetch
    }
    
    func getPickerCv() -> UICollectionView? {
        return self.pickerCv
    }
}
