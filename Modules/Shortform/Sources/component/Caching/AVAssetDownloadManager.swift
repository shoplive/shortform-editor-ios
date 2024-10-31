//
//  AVAssetDownloadManager.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 10/30/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon


final class CacheDataClass : NSObject {
    var data : Data?
    
    init(data: Data){
        self.data = data
    }
}

public final class AVAssetDownloadManager : NSObject {
    public static let shared = AVAssetDownloadManager()
    typealias downloadCallBack = ((_ originUrl : String, _ cacheUrl : URL) -> ())
    private var activeDownloadSession : [String : AVAssetDownLoader] = [:]
    private var reservedCallback : [String : downloadCallBack] = [:]
    private var deleteCacheOnTerminate : Bool = true
    private var dirPathURL : URL? = {
        let tempUrl =  URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let shopLiveTempUrl = tempUrl.appendingPathComponent("Shoplive/Temp", isDirectory: true)
        return shopLiveTempUrl
    }()
   
    private override init() {
        super.init()
        guard let dirPathURL = dirPathURL else { return }
        do {
            try FileManager.default.createDirectory(at: dirPathURL, withIntermediateDirectories: true)
        }
        catch( let error) {
            ShopLiveLogger.tempLog("[CACHE] cache directory creation error \(error.localizedDescription)")
        }
        NotificationCenter.default.addObserver(self,
             selector: #selector(applicationWillTerminate(notification:)),
             name: UIApplication.willTerminateNotification,
             object: nil)
    }
    
    @objc func applicationWillTerminate(notification: Notification) {
        if self.deleteCacheOnTerminate == false { return }
        self.deleteShopLiveCacheDirectory()
    }
    
    func downloadStream(sessionIdentifier : String, urlString : String, downloadCallback : downloadCallBack? ) {
        if ShortFormConfigurationInfosManager.shared.shortsConfiguration.isCached == false {
            return
        }
        guard activeDownloadSession[sessionIdentifier] == nil else { return }
        guard getCachedData(with: urlString) == nil else { return }
        let downloadSession = AVAssetDownLoader(sessionIdentifier: sessionIdentifier, urlString: urlString, assetDownloadDelegate: self)
        activeDownloadSession[sessionIdentifier] = downloadSession
        reservedCallback[sessionIdentifier] = downloadCallback
    }
    
    func cancelDownload(for sessionIdentifier : String){
        if let activeSession = activeDownloadSession[sessionIdentifier] {
            activeSession.cancelDownloading()
            activeDownloadSession.removeValue(forKey: sessionIdentifier)
        }
    }
    
    func getCachedData(with urlString : String) -> URL? {
        guard let dirPathURL = dirPathURL else { return  nil }
        guard let searchPath = self.getFileNameFromUrl(url: urlString) else { return nil }
        let searchURL = dirPathURL.appendingPathComponent("\(searchPath)")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: searchURL.path) {
            return searchURL
        }
        else {
            return nil
        }
    }
    
    private func moveDownloadedData(from : URL, to : String) {
        guard let dirPathURL = dirPathURL else { return }
        guard let destinationPath = self.getFileNameFromUrl(url: to) else { return }
        let destinationUrl = dirPathURL.appendingPathComponent("\(destinationPath)")
        
        do {
            try FileManager.default.moveItem(at: from, to: destinationUrl)
        }
        catch(let error) {
            ShopLiveLogger.tempLog("[CACHE] cache move error \(error.localizedDescription)")
        }
    }
    
    private func getFileNameFromUrl(url : String) -> String? {
        guard let nsUrl = NSURL(string: url),
              let pathExtension = nsUrl.pathExtension,
              let path = nsUrl.path  else { return nil }
        
        var fileName : String = path.replacingOccurrences(of: "/", with: "_")
        fileName = String(fileName.components(separatedBy: ".")[0])
        if pathExtension == "m3u8" {
            return fileName + ".movpkg"
        }
        else {
            return fileName + ".\(pathExtension)"
        }
    }
    
    public func deleteCaches() {
        DispatchQueue.global(qos: .background).async {
            self.deleteShopLiveCacheDirectory()
        }
    }
    
    public func enableDeleteCacheOnTerminate(isEnabled : Bool) {
        self.deleteCacheOnTerminate = isEnabled
    }


    private func deleteShopLiveCacheDirectory() {
        guard let dirPath = self.dirPathURL else { return }
        do {
            let fileUrls = try FileManager.default.contentsOfDirectory(at: dirPath, includingPropertiesForKeys: nil)
            for fileUrl in fileUrls {
                try FileManager.default.removeItem(at: fileUrl)
            }
        }
        catch(let error) {
            ShopLiveLogger.tempLog("[CACHE] ShopLive cache delete error \(error.localizedDescription)")
        }
    }
}
extension AVAssetDownloadManager : AVAssetDownloadDelegate {
    public func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        if let identifier = session.configuration.identifier {
            moveDownloadedData(from: location, to: identifier)
            if activeDownloadSession[identifier] != nil {
                activeDownloadSession.removeValue(forKey: identifier)
            }
            if let reservecallback = reservedCallback[identifier] {
                if let cachedUrl = getCachedData(with: identifier) {
                    reservecallback(identifier,cachedUrl)
                    reservedCallback.removeValue(forKey: identifier)
                }
            }
        }
    }
}
fileprivate class AVAssetDownLoader {
    
    private var configuration : URLSessionConfiguration?
    private var downloadSession : AVAssetDownloadURLSession?
    private var urlString : String?
    private var asset : AVURLAsset?
    private var downloadTask : AVAssetDownloadTask?
    
    
    init(sessionIdentifier : String, urlString : String, assetDownloadDelegate : AVAssetDownloadDelegate) {
        guard let url = URL(string: urlString) else { return }
        asset = AVURLAsset(url: url)
        
        configuration = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
        guard let configuration = configuration else { return }
        
        downloadSession = AVAssetDownloadURLSession(configuration: configuration,
                                                    assetDownloadDelegate: assetDownloadDelegate,
                                                    delegateQueue: OperationQueue.main)
        
        guard let session = downloadSession,
              let asset = asset else { return }
        downloadTask = session.makeAssetDownloadTask(asset: asset,
                                                     assetTitle: sessionIdentifier,
                                                     assetArtworkData: nil)
        downloadTask?.resume()
    }
    
    func cancelDownloading() {
        downloadTask?.cancel()
        downloadTask = nil
    }
}
