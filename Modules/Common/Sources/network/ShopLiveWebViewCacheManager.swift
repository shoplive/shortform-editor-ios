//
//  ShopLiveWebViewCacheManager.swift
//  ShopliveSDKCommon
//
//  Created by Tabber on 2/21/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

public class ShopLiveWebViewCacheManager: NSObject, URLSessionDownloadDelegate {
    
    private var downloadTask: URLSessionDownloadTask?
    private var downloadSession: URLSession?
    public var completionHandler: ((String?) -> Void)?
    
    private var originalImageUrl: String = ""
    
    public func getUrl() -> String {
        return originalImageUrl
    }
    
    public override init() {
        super.init()
        downloadSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
    
    private func extractImageInfo(from url: String) -> (fileName: String, fullUrl: String, cacheFileName: String) {
        guard let urlComponents = URLComponents(string: url),
              let srcParam = urlComponents.queryItems?.first(where: { $0.name == "src" })?.value,
              let decodedSrc = srcParam.removingPercentEncoding,
              let srcUrl = URL(string: decodedSrc) else {
            return ("", "", "")
        }
        
        let cacheFileName: String = extractBaseUrl(from: url) ?? ""
        
        return (srcUrl.lastPathComponent, decodedSrc, cacheFileName)
    }
    
    func extractBaseUrl(from fullUrl: String) -> String? {
        guard let url = URL(string: fullUrl),
              let baseUrl = url.absoluteString.components(separatedBy: "?").first else {
            return nil
        }
        return baseUrl.replacingOccurrences(of: "/", with: "").replacingOccurrences(of: ":", with: "")
    }

    
    public func startDownload(url: URL) {
        
        let absoluteString: String = url.absoluteString
        
        guard let encodedString = absoluteString.removingPercentEncoding,
              let url = URL(string: encodedString) else {
            ShopLiveLogger.tempLog("[ShopLiveWebViewCacheManager] Invalid URL")
            return
        }
        
        let imageInfo = extractImageInfo(from: encodedString)
        
        // url 파싱이 실패했을 경우 HTML nil 값 전송
        ShopLiveLogger.tempLog("[ShopLiveWebViewCacheManager]\nimageInfo.fileName: \(imageInfo.fileName)\nimageInfo.fullUrl: \(imageInfo.fullUrl)\ndomain: \(imageInfo.cacheFileName)")
        
        guard imageInfo.fileName != "" || imageInfo.fullUrl != "" || imageInfo.cacheFileName != "" else {
            completionHandler?(nil)
            return
        }
        
        originalImageUrl = imageInfo.fullUrl
        
        let documentsDirectory = SLFileManager.backgroundPosterDirectoryPath
        let destinationURL = documentsDirectory.appendingPathComponent(imageInfo.cacheFileName)
        
        ShopLiveLogger.tempLog("[ShopLiveWebViewCacheManager] fileName : \(imageInfo.cacheFileName)")
        
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            do {
                let htmlString = try String(contentsOf: destinationURL, encoding: .utf8)
                ShopLiveLogger.tempLog("[ShopLiveWebViewCacheManager] File already exists, returning cached version")
                ShopLiveLogger.tempLog(htmlString)
                completionHandler?(htmlString)
                return
            } catch {
                ShopLiveLogger.tempLog("[ShopLiveWebViewCacheManager] Error reading existing file: \(error.localizedDescription)")
            }
        }
        
        if downloadTask?.state == .running {
            ShopLiveLogger.tempLog("[ShopLiveWebViewCacheManager] Running Download Cancel")
            downloadTask?.cancel()
        }
        
        downloadTask = downloadSession?.downloadTask(with: url)
        downloadTask?.resume()
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        ShopLiveLogger.tempLog("[ShopLiveWebViewCacheManager] Download progress: \(progress * 100)%")
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            
            guard let originalUrl = downloadTask.originalRequest?.url else {
                ShopLiveLogger.tempLog("[ShopLiveWebViewCacheManager] Failed to extract domain from URL")
                completionHandler?(nil)
                return
            }
            
            let cacheFileName = extractImageInfo(from: originalUrl.absoluteString).cacheFileName
            
            let data = try Data(contentsOf: location)
            guard let htmlString = String(data: data, encoding: .utf8) else {
                ShopLiveLogger.tempLog("[ShopLiveWebViewCacheManager] Failed to convert data to string")
                return
            }
            
            let documentsDirectory = SLFileManager.backgroundPosterDirectoryPath
            let destinationURL = documentsDirectory.appendingPathComponent(cacheFileName)
            
            try data.write(to: destinationURL)
            ShopLiveLogger.tempLog("[ShopLiveWebViewCacheManager] File saved to: \(destinationURL.path)")
            
            ShopLiveLogger.tempLog("[ShopLiveWebViewCacheManager] Original HTML \n")
            ShopLiveLogger.tempLog(htmlString)
            
            completionHandler?(htmlString)
            
        } catch {
            completionHandler?(nil)
            ShopLiveLogger.tempLog("[ShopLiveWebViewCacheManager] Error processing file: \(error.localizedDescription)")
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            completionHandler?(nil)
            ShopLiveLogger.tempLog("[ShopLiveWebViewCacheManager] Download failed: \(error.localizedDescription)")
        }
    }
}
