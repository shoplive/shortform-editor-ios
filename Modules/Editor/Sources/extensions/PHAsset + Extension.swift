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
        PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
            
            guard let asset = asset else { return }
            
            let dirPath = SLFileManager.editorDirectoryPath
            let outputURL = dirPath.appendingPathComponent("\(UUID().uuidString)_ShopLive.mp4")
            
            let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
            exportSession?.outputURL = outputURL
            exportSession?.outputFileType = .mp4
            
            exportSession?.exportAsynchronously {
                if exportSession?.status == .completed {
                    completion((outputURL,outputURL))
                } else {
                    ShopLiveLogger.tempLog("[SLPHOTOPICKER] exportSession error \(exportSession?.error?.localizedDescription)")
                    completion((nil,nil))
                }
            }
        })
    }
    
    func getImageUrl(completion : @escaping (URL?) -> () ) {
        guard self.mediaType == .image else {
            completion(nil)
            return
        }
        let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
            return true
        }
        self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
            completion(contentEditingInput!.fullSizeImageURL as URL?)
        })
    }
    
}
