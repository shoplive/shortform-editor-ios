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
        asset.loadValuesAsynchronously(forKeys: ["tracks","duration"]) { [weak self] in
            guard let self = self else { return }
            var error: NSError?
            let tracksStatus = self.asset.statusOfValue(forKey: "tracks", error: &error)
            let durationStatus = self.asset.statusOfValue(forKey: "duration", error: &error)
            guard tracksStatus == .loaded || durationStatus == .loaded else { return }
            let generator = AVAssetImageGenerator(asset: self.asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 720, height: 1280)
            generator.apertureMode = .cleanAperture
            generator.requestedTimeToleranceBefore = .zero
            generator.requestedTimeToleranceAfter = .zero
            self.imageGenerator = generator
        }
    }
    
    func imageFromVideo(at: CGFloat) -> UIImage {
        guard let imageGenerator = imageGenerator else { return UIImage() }
        do {
            let ct = CMTime(seconds: at, preferredTimescale: 44100)
            let ref = try imageGenerator.copyCGImage(at: ct, actualTime: nil)
            let image = UIImage(cgImage: ref)
            return image
        } catch {
            return UIImage()
        }
    }
    
    
    
}
