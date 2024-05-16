//
//  SLPhotosPickerReactor + PhotoLibraryDelegate.swift
//  CustomImagePicker
//
//  Created by sangmin han on 5/3/24.
//

import Foundation
import UIKit
import Photos
import PhotosUI



extension SLPhotosPickerReactor : SLPhotoLibraryDelegate {
    func loadCameraRollCollection(collection: SLAssetsCollection) {
        self.setAssetsCollections(collections: [collection])
        self.focusToFirstCollection()
        self.reloadTableView()
        
    }
    
    func loadCompleteAllCollection(collections: [SLAssetsCollection]) {
        self.setAssetsCollections(collections: collections)
        self.focusToFirstCollection()
        let isEmpty = self.getAssetsCollection().count == 0
        resultHandler?( .hideEmptyView(isEmpty ? false : true))
        
        self.reloadTableView()
        
        self.registerChangeObserver()
        
//        let isEmpty = self.collections.count == 0
//        self.emptyView.isHidden = !isEmpty
//        self.emptyImageView.isHidden = self.emptyImageView.image == nil
//        self.indicator.stopAnimating()
//        self.reloadTableView()
//        self.registerChangeObserver()
//        self.titleView.isHidden = isAlbumEmpty()
    }
}
