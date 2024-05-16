//
//  SLPhotosPickerConfigure.swift
//  CustomImagePicker
//
//  Created by sangmin han on 5/3/24.
//

import Foundation
import UIKit
import Photos
import PhotosUI



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
    public var cameraIcon = ShopLiveShortformEditorSDKAsset.slCamera.image
    public var groupByFetch: PHFetchedResultGroupedBy? = nil
    public var supportedInterfaceOrientations: UIInterfaceOrientationMask = .portrait
    public init() {
        
    }
}
