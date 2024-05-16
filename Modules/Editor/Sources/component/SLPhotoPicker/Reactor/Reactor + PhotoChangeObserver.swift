//
//  Reactor + PhotoChangeObserver.swift
//  CustomImagePicker
//
//  Created by sangmin han on 5/3/24.
//

import Foundation
import Photos
import PhotosUI


extension SLPhotosPickerReactor : PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        var addIndex : Int = 0
        if getCurrentFocusedCollectionIndex() == 0 {
            addIndex = 1
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let changes = self.getChanges(changeInstance) else { return }
            
            if changes.hasIncrementalChanges, self.getPickerConfigureGroupByFetch() == nil {
                guard let cv = self.getPickerCv() else { return }
                cv.performBatchUpdates {
                    self.setCurrentFocusedCollectionFetchResult(result: changes.fetchResultAfterChanges)
                    
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        cv.deleteItems(at: removed.map { IndexPath(item: $0+addIndex, section:0) })
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        cv.insertItems(at: inserted.map { IndexPath(item: $0+addIndex, section:0) })
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        cv.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                     to: IndexPath(item: toIndex, section: 0))
                    }
                } completion: { completed in
                    guard completed else { return }
                    if let changed = changes.changedIndexes, changed.count > 0 {
                        cv.reloadItems(at: changed.map { IndexPath(item: $0+addIndex, section:0) })
                    }
                }
            }
            else  {
                self.setCurrentFocusedCollectionFetchResult(result: changes.fetchResultAfterChanges)
                self.reloadCollectionView()
            }
            
            guard let focused = self.getCurrentFocusedCollection() else { return }
            let targetIndex = self.getCurrentFocusedCollectionIndex()
            self.setAssetsCollection(collection: focused, at: targetIndex)
            self.resultHandler?( .reloadAlbumSelectTableViewRow(([IndexPath(row: targetIndex, section: 0)], .none)))
        }
        
    }
    
    
    private func getChanges(_ changeInstance: PHChange) -> PHFetchResultChangeDetails<PHAsset>? {
        self.photoLibraryFetchCollection()
        if isAlbumsChanges(changeInstance: changeInstance) || isCollectionsChanges(changeInstance: changeInstance) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.resultHandler?( .showAlbumSelectView(false) )
                self.photoLibraryFetchCollection()
            }
            return nil
        }else {
            guard let changeFetchResult = self.getFocusedCollectionFetchResult() else { return nil }
            guard let changes = changeInstance.changeDetails(for: changeFetchResult) else { return nil }
            return changes
        }
    }
    
    private func isChangesCount<T>(changeDetails: PHFetchResultChangeDetails<T>?) -> Bool {
        guard let changeDetails = changeDetails else {
            return false
        }
        let before = changeDetails.fetchResultBeforeChanges.count
        let after = changeDetails.fetchResultAfterChanges.count
        return before != after
    }
    
    private func isAlbumsChanges(changeInstance : PHChange) -> Bool {
        guard let albums = self.getPhotoLibraryAlbum() else {
            return false
        }
        let changeDetails = changeInstance.changeDetails(for: albums)
        return isChangesCount(changeDetails: changeDetails)
    }
    
    private func isCollectionsChanges(changeInstance : PHChange) -> Bool {
        for fetchResultCollection in self.getPhotoLibraryAssetCollections() {
            let changeDetails = changeInstance.changeDetails(for: fetchResultCollection)
            if isChangesCount(changeDetails: changeDetails) == true {
                return true
            }
        }
        return false
    }
}
