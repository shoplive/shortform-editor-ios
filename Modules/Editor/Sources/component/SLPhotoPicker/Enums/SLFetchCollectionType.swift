//
//  SLFetchCollectionType.swift
//  CustomImagePicker
//
//  Created by sangmin han on 5/3/24.
//

import Foundation
import Photos
import PhotosUI


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
