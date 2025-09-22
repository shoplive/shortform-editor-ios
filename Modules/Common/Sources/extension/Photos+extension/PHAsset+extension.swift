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
    func getURL_SL(completionHandler: @escaping((_ absoluteUrl: URL?,_ relativeUrl: URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable: Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?,contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .current
            options.isNetworkAccessAllowed = true
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localAbsoluteUrl: URL = urlAsset.url
                    let localRelativeUrl: URL = URL(fileURLWithPath: urlAsset.url.relativePath)
                    // 이미 파일이 있는지 확인하고 없을 때만 저장 처리
                    if !FileManager.default.fileExists(atPath: localAbsoluteUrl.path) {
                        completionHandler(localAbsoluteUrl, localRelativeUrl)
                    } else {
                        // 파일이 존재하면 기존 URL을 반환
                        completionHandler(localAbsoluteUrl, localRelativeUrl)
                    }
                } else {
                    completionHandler(nil,nil)
                }
            })
        }
    }
}
