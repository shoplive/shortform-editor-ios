//
//  PHAsset+extension.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 4/14/23.
//

import Foundation
import Photos
import AVKit

public extension PHAsset {
    func getURL_SL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    do {
                        let videoData = try Data.init(contentsOf: localVideoUrl)
                        // print("File size before compression \(Double(videoData.count / 1048576)) mb")
                    } catch {
                        
                    }
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}
