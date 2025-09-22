//
//  Mp4CachingManager.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 3/22/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

public enum ShopliveCacheType {
    case memory
    case disk
}


public class ShopliveMP4CachingManager: NSObject {
    public static let shared = ShopliveMP4CachingManager()
    

    private let assetKeysRequiredToPlay: [String] = [ "playable", "hasProtectedContent"]
    private var cachedSize: UInt64 = 0
    private lazy var maxCacheSize: UInt64 = oneGB
    private let oneGB: UInt64 = 1024 * 1024 * 1024
    private var cacheType: ShopliveCacheType = .memory
    private var downloadingUrls: [URL] = []
    
    
    private var dirPathURL: URL? {
        return SLFileManager.shortformDirectoryPath
    }
    
    private override init() {
        super.init()
        
    }
    
    public func getCurrentCacheType() -> ShopliveCacheType {
        return self.cacheType
    }
    
    public func isVideoMP4(url: URL) -> Bool {
        return url.pathExtension.lowercased() == "mp4"
    }
    
    public func setCacheType(type: ShopliveCacheType = .memory) {
        self.cacheType = type
    }
    
    public func setMaxCacheSize(maxSize: UInt64 = 1024 * 1024 * 1024) {
        self.maxCacheSize = maxSize
    }
    
    public func getCachedSize() -> String? {
        guard let dirPathURL = dirPathURL else { return nil }
        let path: URL = dirPathURL

        
        let fileManager = FileManager.default
        var totalSize: UInt64 = 0
        do {
            let contents = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            for item in contents {
                if let attributes = try? fileManager.attributesOfItem(atPath: item.path),
                   let fileSize = attributes[.size] as? UInt64 {
                    totalSize += fileSize
                }
            }
            self.cachedSize = totalSize
            return ShopliveFileSizeConverter.convertFileSize(totalSize)
        }
        catch {
            return nil
        }
    }
    
    public func removeCaches() {
        DispatchQueue.global(qos: .background).async {
            guard let dirPathURL = self.dirPathURL else { return }
            var path: URL = dirPathURL
            
            
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: path)
            }
            catch { }
        }
    }
    
    public func downloadVideo(url: URL,completion: @escaping(AVPlayerItem) -> ()) {
        DispatchQueue.global(qos: .background).async {
            if url.pathExtension.lowercased() != "mp4" {
                DispatchQueue.main.async {
                    completion(AVPlayerItem(url: url))
                }
            }
            else if let cached = self.findCachedVideo(url: url) {
                DispatchQueue.main.async {
                    completion(AVPlayerItem(url: cached))
                }
            }
            else {
                self.asynchronouslyLoadURLAssets(AVURLAsset(url: url)) { playerItem in
                    DispatchQueue.main.async {
                        completion(playerItem)
                    }
                }
            }
        }
        
    }
    
    private func asynchronouslyLoadURLAssets(_ asset: AVURLAsset, completion: @escaping(AVPlayerItem) -> ()) {
        asset.loadValuesAsynchronously(forKeys: assetKeysRequiredToPlay) {
            var error: NSError?
            for key in self.assetKeysRequiredToPlay {
                if asset.statusOfValue(forKey: key, error: &error) == .failed {
                    return
                }
            }
            if !asset.isPlayable || asset.hasProtectedContent {
                return
            }
            let currentItem = AVPlayerItem(asset: asset)
            switch asset.statusOfValue(forKey: "playable", error: &error) {
            case .loaded:
                completion(currentItem)
                self.saveVideoDataToDevice(asset: asset, url: asset.url)
            case .failed:
                break
            case .cancelled:
                break
            default:
                break
            }
            
        }
    }
    
    
    private func saveVideoDataToDevice(asset: AVURLAsset, url: URL) {
        guard let dirPathURL = dirPathURL else { return }
        guard let videoName = url.pathComponents.last else { return }
        
        if cachedSize > maxCacheSize { return }
        
        if findCachedVideo(url: url) != nil { return }
        
        if downloadingUrls.contains(where: { $0 == url }) {
            return
        }
        
        DispatchQueue.main.async {
            asset.resourceLoader.setDelegate(self, queue: DispatchQueue.main)
            guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough), exporter.supportedFileTypes.contains(AVFileType.mp4) else {
                return
            }
            
            self.downloadingUrls.append(url)
            
            
            let exportURL: URL = dirPathURL.appendingPathComponent("\(videoName)")
            
            
            
            exporter.outputURL = exportURL
            exporter.outputFileType = AVFileType.mp4
            
            
            exporter.exportAsynchronously(completionHandler: {
                switch exporter.status {
                case .cancelled:
                    self.downloadingUrls.removeAll(where: { $0 == url })
                    break
                case .completed:
                    let fileManager = FileManager.default
                    if let attributes = try? fileManager.attributesOfItem(atPath: exportURL.path),
                       let fileSize = attributes[.size] as? UInt64 {
                        self.cachedSize += fileSize
                    }
                    self.downloadingUrls.removeAll(where: { $0 == url })
                    break
                case .exporting:
                    break
                case .failed:
                    self.downloadingUrls.removeAll(where: { $0 == url })
                    break
                case .unknown:
                    break
                case .waiting:
                    break
                @unknown default:
                    break
                }
            })
        }
    }
    
    private func findCachedVideo(url: URL) -> URL? {
        guard let dirPathURL = dirPathURL else { return nil }
        guard let videoName = url.pathComponents.last else { return nil }
        let searchURL: URL = dirPathURL.appendingPathComponent("\(videoName)")
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: searchURL.path) {
            return searchURL
        }
        else {
            return nil
        }
    }
    
}
extension ShopliveMP4CachingManager: AVAssetResourceLoaderDelegate {
    
}

//mp4 캐싱 테스트용
//private let testMp4: [String] = ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
//                                  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
//                                  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
//                                  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
//                                  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
//                                  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
//                                  "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"]
