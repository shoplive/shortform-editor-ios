//
//  SLCodeValidator.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 3/26/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ffmpegkit
import ShopliveSDKCommon



struct SLCodecValidator {
    static func runFFProbCommand(videoPath : String, completion : @escaping(Bool) -> ()){
        ShopLiveLogger.debugLog("[HASSAN LOG] videoPath tossed to ffprobe \(videoPath)")
        let command = "-v quiet -print_format json -show_format -show_streams -i \(videoPath)"
        FFprobeKit.executeAsync(command) { session in
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
                    completion(Self.checkIfCodecIsValid(codecName: codecName))
                    return
                }
            }
            completion(false)//file:///var/mobile/Media/DCIM/102APPLE/IMG_2295.MP4
        }
    }
    
    private static func checkIfCodecIsValid(codecName : String) -> Bool {
        let candidateCodecNames : [String] = ["vid.stab","xvidcore","hevc"]
        if candidateCodecNames.contains(where: { $0 == codecName }) {
            return true
        }
        return extractWordWithEnding264Or265(target: codecName )
    }
    
    private static func extractWordWithEnding264Or265(target : String) -> Bool {
        let suffix = target.suffix(3)
        if suffix == "264" || suffix == "265" {
            return true
        }
        return false
    }
}
