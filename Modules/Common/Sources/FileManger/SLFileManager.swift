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
    
    public static var shortformDirectoryPath : URL {
        let tempUrl =  URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let shopLiveTempUrl = tempUrl.appendingPathComponent("Shoplive/Temp/Shortform", isDirectory: true)
        Self.createShopLiveDirectory(with: shopLiveTempUrl)
        return shopLiveTempUrl
    }
    
    public static var editorDirectoryPath : URL {
        let tempUrl =  URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let shopLiveTempUrl = tempUrl.appendingPathComponent("Shoplive/Temp/Editor", isDirectory: true)
        Self.createShopLiveDirectory(with: shopLiveTempUrl)
        return shopLiveTempUrl
    }
    
    public static var ffmpegDirectorypath : URL {
        let tempUrl =  URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let shopLiveTempUrl = tempUrl.appendingPathComponent("Shoplive/Temp/FFmpeg", isDirectory: true)
        Self.createShopLiveDirectory(with: shopLiveTempUrl)
        return shopLiveTempUrl
    }
    
    
    public static func createShopLiveDirectory(with path : URL) {
        guard isDirectoryExists(at: path) == false else { return }
        do {
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
            ShopLiveLogger.tempLog("[SLFILEMANAGER] directory created \(path) ")
        }
        catch( let error) {
            ShopLiveLogger.tempLog("[SLFILEMANAGER] cache directory creation error \(error.localizedDescription)")
        }
    }
    
    private static func  isDirectoryExists(at url: URL) -> Bool {
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
                    ShopLiveLogger.tempLog("[SLFILEMANAGER] Deleted: \(file.lastPathComponent)")
                }
            }
            catch {
                ShopLiveLogger.tempLog("[SLFILEMANAGER] Error deleting ShopLive files: \(error.localizedDescription)")
            }
        }
    }
    
    public static func deleteEditorDirectoryFiles() {
        let path = Self.editorDirectoryPath
        DispatchQueue.global(qos: .background).async {
            do {
                let files = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
                
                for file in files {
                    try FileManager.default.removeItem(at: file)
                    ShopLiveLogger.tempLog("[SLFILEMANAGER] Deleted: \(file.lastPathComponent)")
                }
            }
            catch {
                ShopLiveLogger.tempLog("[SLFILEMANAGER] Error deleting ShopLive files: \(error.localizedDescription)")
            }
        }
    }
    
    public static func deleteFFMpegDirectoryFiles() {
        let path = Self.ffmpegDirectorypath
        DispatchQueue.global(qos: .background).async {
            do {
                let files = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
                
                for file in files {
                    try FileManager.default.removeItem(at: file)
                    ShopLiveLogger.tempLog("[SLFILEMANAGER] Deleted: \(file.lastPathComponent)")
                }
            }
            catch {
                ShopLiveLogger.tempLog("[SLFILEMANAGER] Error deleting ShopLive files: \(error.localizedDescription)")
            }
        }
    }
}
