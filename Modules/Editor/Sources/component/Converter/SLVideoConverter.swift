//
//  SLVideoConverter.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 5/3/23.
//

import Foundation
import UIKit
import ffmpegkit
import ShopLiveSDKCommon

struct SLVideoInfo {
    var videoPath: String
    var cropRect: CGRect
    var videoSize: CGSize
    var timeRange: (start: Float64, end: Float64)
    var fileName: String
}

extension SLVideoInfo {
    var scaleSize720: Int {
        return Int(ceil((min(self.cropRect.width, self.cropRect.height) / 720.0) * 100000.0) / 100000.0) * 720
    }
    
    var scaleValue: String {
        return self.cropRect.width < self.cropRect.height ? "\(scaleSize720):-1" : "-1:\(scaleSize720)"
    }
    
    var totalDuration: Float64 {
        return (timeRange.end - timeRange.start)
    }
    
    var outputVideoPath: String {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let cachepath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let documents = path[0]
        let caches = cachepath[0]
        let cacheoutput = caches.appendingPathComponent("\(fileName)").deletingPathExtension().appendingPathExtension("mp4")
        return cacheoutput.absoluteString
    }
    
    var command720p: String {
        "-ss \(timeRange.start.timeHourMinuteSeconds_SL) -to \(timeRange.end.timeHourMinuteSeconds_SL) -i \(videoPath) -vf crop=\(cropRect.width):\(cropRect.height):\(cropRect.origin.x):\(cropRect.origin.y),scale=\(scaleValue) -y \(outputVideoPath)"
    }
    
    var commandRemoveScale: String {
        "-ss \(timeRange.start.timeHourMinuteSeconds_SL) -to \(timeRange.end.timeHourMinuteSeconds_SL) -i \(videoPath) -filter:v crop='\(cropRect.width):\(cropRect.height):\(cropRect.origin.x):\(cropRect.origin.y)' -y \(outputVideoPath)"
    }
    
    var commandDefault: String {
        "-ss \(timeRange.start.timeHourMinuteSeconds_SL) -to \(timeRange.end.timeHourMinuteSeconds_SL) -i \(videoPath) -filter:v crop='\(cropRect.width):\(cropRect.height):\(cropRect.origin.x):\(cropRect.origin.y)' -y \(outputVideoPath)"
    }
}

enum SLVideoConvertResult {
    case Success(videoPath: String)
    case Failed(error: Error)
}

enum SLVideoFFMpegExecuteResult {
    case Success(Void)
    case Failed(error: Error)
}

enum SLVideoConvertError: Error {
    case cancel
    case error
}

protocol SLVideoConverterDelegate: AnyObject {
    func updateConvertPercent(percent: Int)
}

class SLVideoConverter {
    
    weak var delegate: SLVideoConverterDelegate?
    
    private var videoInfo: SLVideoInfo?
    
    private(set) var inConvert: Bool = false
    
    func convertVideo(videoInfo: SLVideoInfo, completion: @escaping (SLVideoConvertResult) -> Void) {
        self.setDeviceIdleTimer(true)
        inConvert = true
        self.videoInfo = videoInfo
        runFfmpegCommand(command: videoInfo.command720p) { [weak self] result in
            switch result {
            case .Success():
                self?.inConvert = false
                self?.setDeviceIdleTimer(false)
                completion(.Success(videoPath: videoInfo.outputVideoPath))
                break
            case .Failed(_):
                self?.runFfmpegCommand(command: videoInfo.commandRemoveScale) { [weak self] result in
                    switch result {
                    case .Success():
                        self?.inConvert = false
                        self?.setDeviceIdleTimer(false)
                        completion(.Success(videoPath: videoInfo.outputVideoPath))
                        break
                    case .Failed(_):
                        self?.runFfmpegCommand(command: videoInfo.commandDefault) { [weak self] result in
                            self?.setDeviceIdleTimer(false)
                            switch result {
                            case .Success():
                                self?.inConvert = false
                                completion(.Success(videoPath: videoInfo.outputVideoPath))
                                break
                            case .Failed(let error):
                                self?.inConvert = false
                                ShopLiveLogger.debugLog("convert failed error \(error)")
                                completion(.Failed(error: error))
                                break
                            }
                        }
                        break
                    }
                }
                break
            }
        }
    }
    
    private var ffmpegSession: FFmpegSession?
    func cancelConvert() {
        inConvert = false
        FFmpegKit.cancel()
    }
    
    private func runFfmpegCommand(command: String, completion: @escaping (SLVideoFFMpegExecuteResult) -> Void) {
        ShopLiveLogger.debugLog("ffmpeg command \(command)")
        self.delegate?.updateConvertPercent(percent: Int(0))
        FFmpegKit.executeAsync(command) { [weak self] session in
            self?.ffmpegSession = session
            guard let returnCode = session?.getReturnCode() else { return }
            
            if ReturnCode.isSuccess(returnCode) {
                completion(.Success(()))
            } else if ReturnCode.isCancel(returnCode) {
                completion(.Failed(error: SLVideoConvertError.cancel))
            } else {
                completion(.Failed(error: SLVideoConvertError.error))
            }
        } withLogCallback: { log in
            ShopLiveLogger.debugLog(log?.getMessage() ?? "")
        } withStatisticsCallback: { [weak self] statistics in
            guard let self = self,
                  let convertTime = statistics?.getTime(),
                  let totalDuration = self.videoInfo?.totalDuration else { return }
            
            let total = totalDuration * 1000
            let current: Float64 = Float64(convertTime)
            let percent = (current / total) * 100
            
            self.delegate?.updateConvertPercent(percent: min(100,Int(percent)))
        }
        
    }
    
    private func setDeviceIdleTimer(_ isEnabled : Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = isEnabled
        }
    }
}
