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
            return
        }
        
        let imageInfo = extractImageInfo(from: encodedString)
        
        guard imageInfo.fileName != "" || imageInfo.fullUrl != "" || imageInfo.cacheFileName != "" else {
            completionHandler?(nil)
            return
        }
        
        originalImageUrl = imageInfo.fullUrl
        
        let documentsDirectory = SLFileManager.backgroundPosterDirectoryPath
        let destinationURL = documentsDirectory.appendingPathComponent(imageInfo.cacheFileName)
        
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            do {
                let htmlString = try String(contentsOf: destinationURL, encoding: .utf8)
                completionHandler?(htmlString)
                return
            } catch { }
        }
        
        if downloadTask?.state == .running {
            downloadTask?.cancel()
        }
        
        downloadTask = downloadSession?.downloadTask(with: url)
        downloadTask?.resume()
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            
            guard let originalUrl = downloadTask.originalRequest?.url else {
                completionHandler?(nil)
                return
            }
            
            let cacheFileName = extractImageInfo(from: originalUrl.absoluteString).cacheFileName
            
            let data = try Data(contentsOf: location)
            guard let htmlString = String(data: data, encoding: .utf8) else {
                return
            }
            
            let documentsDirectory = SLFileManager.backgroundPosterDirectoryPath
            let destinationURL = documentsDirectory.appendingPathComponent(cacheFileName)
            
            try data.write(to: destinationURL)
            completionHandler?(htmlString)
            
        } catch {
            completionHandler?(nil)
        }
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            completionHandler?(nil)
        }
    }
}
