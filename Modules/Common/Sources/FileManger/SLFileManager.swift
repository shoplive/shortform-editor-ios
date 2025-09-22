//
//  SLFileManager.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 11/16/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation

public class SLFileManager {
    static let shared = SLFileManager()
    private init () {
        
    }
    
    public static var shortformDirectoryPath: URL {
        let tempUrl =  URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let shopLiveTempUrl = tempUrl.appendingPathComponent("Shoplive/Temp/Shortform", isDirectory: true)
        Self.createShopLiveDirectory(with: shopLiveTempUrl)
        return shopLiveTempUrl
    }
    
    public static var editorDirectoryPath: URL {
        let tempUrl =  URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let shopLiveTempUrl = tempUrl.appendingPathComponent("Shoplive/Temp/Editor", isDirectory: true)
        Self.createShopLiveDirectory(with: shopLiveTempUrl)
        return shopLiveTempUrl
    }
    
    public static var ffmpegDirectorypath: URL {
        let tempUrl =  URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let shopLiveTempUrl = tempUrl.appendingPathComponent("Shoplive/Temp/FFmpeg", isDirectory: true)
        Self.createShopLiveDirectory(with: shopLiveTempUrl)
        return shopLiveTempUrl
    }
    
    public static var backgroundPosterDirectoryPath: URL {
        let tempUrl =  URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let shopLiveTempUrl = tempUrl.appendingPathComponent("Shoplive/Temp/BackgroundPoster", isDirectory: true)
        Self.createShopLiveDirectory(with: shopLiveTempUrl)
        return shopLiveTempUrl
    }
    
    
    public static func createShopLiveDirectory(with path: URL) {
        guard isDirectoryExists(at: path) == false else { return }
        do {
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
        }
        catch { }
    }
    
    private static func isDirectoryExists(at url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    public static func deleteShortformDirectoryFiles() {
        let path = Self.shortformDirectoryPath
        DispatchQueue.global(qos: .background).async {
            do {
                let files = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
                
                for file in files {
                    try FileManager.default.removeItem(at: file)
                }
            }
            catch { }
        }
    }
    
    public static func deleteEditorDirectoryFiles() {
        let path = Self.editorDirectoryPath
        DispatchQueue.global(qos: .background).async {
            do {
                let files = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
                
                for file in files {
                    try FileManager.default.removeItem(at: file)
                }
            }
            catch { }
        }
    }
    
    public static func deleteFFMpegDirectoryFiles() {
        let path = Self.ffmpegDirectorypath
        DispatchQueue.global(qos: .background).async {
            do {
                let files = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
                
                for file in files {
                    try FileManager.default.removeItem(at: file)
                }
            }
            catch { }
        }
    }
    
    public static func deleteBackgroundPosterDirectoryFiles() {
        let path = Self.backgroundPosterDirectoryPath
        DispatchQueue.global(qos: .background).async {
            do {
                let files = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
                
                for file in files {
                    try FileManager.default.removeItem(at: file)
                }
            }
            catch { }
        }
    }
    
    public static  func getShortformDirectorySize() -> String? {
        let path: URL = Self.shortformDirectoryPath
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
            return ShopliveFileSizeConverter.convertFileSize(totalSize)
        }
        catch {
            return nil
        }
    }
}
