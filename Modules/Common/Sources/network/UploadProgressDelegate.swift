//
//  UploadProgressDelegate.swift
//  ShopliveSDKCommon
//
//  Created by Tabber on 9/24/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

class UploadProgressDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    private let delegateKey: String
    private let progressHandler: ((Double) -> ())?
    private let completionHandler: (Data?, URLResponse?, Error?) -> ()
    private var responseData = Data()
    private var hasCompleted = false
    
    init(delegateKey: String, progressHandler: ((Double) -> ())?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> ()) {
        self.delegateKey = delegateKey
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
        super.init()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard totalBytesExpectedToSend > 0, !hasCompleted else { return }
        
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        DispatchQueue.main.async { [weak self] in
            self?.progressHandler?(progress)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard !hasCompleted else { return }
        responseData.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard !hasCompleted else { return }
        hasCompleted = true
        
        completionHandler(responseData.isEmpty ? nil : responseData, task.response, error)
        session.invalidateAndCancel()
    }
}
