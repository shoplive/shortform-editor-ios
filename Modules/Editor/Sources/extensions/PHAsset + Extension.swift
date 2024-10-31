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
        options.version = .current
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
            if let urlAsset = asset as? AVURLAsset {
                let localAbsoluteUrl : URL = urlAsset.url
                let localRelativeUrl : URL = URL(fileURLWithPath : urlAsset.url.relativePath)
                completion((localAbsoluteUrl,localRelativeUrl))
            } else {
                completion((nil,nil))
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
