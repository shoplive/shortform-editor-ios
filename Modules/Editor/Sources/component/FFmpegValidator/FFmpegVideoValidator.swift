//
//  FFmpegVideoValidator.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/7/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import ffmpegkit
import Photos

class FFmpegVideoValidator {
    static let shared = FFmpegVideoValidator()
    
    
    func checkValidCodec(videoUrl : URL, completion : @escaping (Bool) -> ()) {
        self.runFFProbCommand(videoUrl: videoUrl, completion: completion)
    }
    
    private func runFFProbCommand(videoUrl : URL, completion : @escaping(Bool) -> ()) {
        let command = "-v quiet -print_format json -show_format -show_streams -i \(videoUrl.absoluteString)"
        
        FFprobeKit.executeAsync(command) { [weak self] session in
            guard let session = session,
                  let data = session.getOutput().data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                  let jsonDict = json as? [String : Any],
                  let streams = jsonDict["streams"] as? [[String : Any]] else {
                completion(false)
                return
            }
            for stream in streams {
                if let codecType = stream["codec_type"] as? String, codecType == "video",
                   let codecName = stream["codec_name"] as? String {
                    completion(self?.checkIfCodecIsValid(codecName: codecName) ?? false)
                    return
                }
            }
            completion(false)
        }
    }
    
    private func checkIfCodecIsValid(codecName : String) -> Bool {
        let candidateCodecNames : [String] = ["vid.stab","xvidcore","hevc"]
        if candidateCodecNames.contains(where: { $0 == codecName }) {
            return true
        }
        return extractWordWithEnding264Or265(target: codecName )
    }
    
    private func extractWordWithEnding264Or265(target : String) -> Bool {
        let suffix = target.suffix(3)
        if suffix == "264" || suffix == "265" {
            return true
        }
        return false
    }
    
}
