//
//  ThumbnailManager.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 4/30/23.
//

import Foundation
import UIKit
import AVKit

class SLThumbnailManager {
    
    private var imageGenerator: AVAssetImageGenerator!
    
    private var asset: AVAsset
    private var videoUrl: URL
    
    init(videoUrl: URL) {
        self.videoUrl = videoUrl
        self.asset = AVAsset(url: videoUrl)
        
        initialize()
    }
    
    private func initialize() {
        self.imageGenerator = AVAssetImageGenerator.init(asset: asset)
        self.imageGenerator?.appliesPreferredTrackTransform = true
        
        self.imageGenerator?.maximumSize = CGSize(width: 720, height: 1280)
        self.imageGenerator?.apertureMode = .cleanAperture
    }
    
    func imageFromVideo(at: CGFloat) -> UIImage {
        do {
            let ct = CMTime(seconds: at, preferredTimescale: 44100)
            let ref = try imageGenerator.copyCGImage(at: ct, actualTime: nil)
            let image = UIImage.init(cgImage: ref)
            return image
        } catch let e {
            // print(e.localizedDescription)
        }
        return UIImage.init()
    }
    
    
    
}
