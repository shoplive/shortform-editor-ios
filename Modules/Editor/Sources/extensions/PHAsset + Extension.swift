//
//  PHAsset + Extension.swift
//  CustomImagePicker
//
//  Created by sangmin han on 5/7/24.
//

import Foundation
import Photos
import AVKit
import ShopliveSDKCommon


extension PHAsset {
    
    func getVideoURl(completion : @escaping((absoluteUrl : URL?, relativeUrl : URL?)) -> ()) {
        guard self.mediaType == .video else {
            completion((nil,nil))
            return
        }
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.deliveryMode = .automatic
        options.version = .current
        options.isNetworkAccessAllowed = true
        
        let dirPath = SLFileManager.editorDirectoryPath
        let outputURL = dirPath.appendingPathComponent("\(UUID().uuidString)_ShopLive.mp4")
        PHImageManager.default().requestExportSession(forVideo: self, options: options, exportPreset: AVAssetExportPresetHighestQuality) { session, info in
            guard let session = session else {
                completion((nil,nil))
                return
            }
            session.outputURL = outputURL
            session.shouldOptimizeForNetworkUse = true
            if session.supportedFileTypes.contains(.mp4) {
                session.outputFileType = .mp4
            } else if let first = session.supportedFileTypes.first {
                session.outputFileType = first
            } else {
                session.outputFileType = .mov
            }
            session.exportAsynchronously {
                switch session.status {
                case .completed:
                    completion((outputURL, outputURL))
                case .failed, .cancelled:
                    completion((nil,nil))
                default:
                    break
                }
            }
        }
    }
    
    func getImageUrl(progress: @escaping (Double) -> Void, completion: @escaping (URL?) -> Void) {
        guard self.mediaType == .image else {
            completion(nil)
            return
        }
        
        let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
        
        options.isNetworkAccessAllowed = true
        
        options.canHandleAdjustmentData = { (adjustmeta: PHAdjustmentData) -> Bool in
            return true
        }
        
        options.progressHandler = { (progressPercent, error) in
            progress(progressPercent)
        }
        
        self.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
            DispatchQueue.main.async {
                // When complete, pass the URL
                completion(contentEditingInput?.fullSizeImageURL as URL?)
            }
        })
    }
    
}
