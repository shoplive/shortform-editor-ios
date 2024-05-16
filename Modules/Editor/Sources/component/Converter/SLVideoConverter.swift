//
//  SLVideoConverter.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 5/3/23.
//

import Foundation
import UIKit
import ffmpegkit
import ShopliveSDKCommon
import ShopliveFilterSDK
import AVKit


struct FFMpegTextInfo {
    var text : String
    var textColor : String
    var textSize : Int
    var frame : CGRect
    var textBackgroundColor : String
    var timeRange : CMTimeRange
   
}

struct SLFilterConfig {
    var filterConfig : String
    var filterIntensity : Float
}


struct SLVideoInfo {
    var videoPath: String
    var cropRect: CGRect
    var videoSize: CGSize
    var timeRange: (start: Float64, end: Float64)
    var fileName: String
    var filterConfig : SLFilterConfig?
    var ffmpegFilterConfig : String? {
        let parser = CGERootParser()
        guard let filter = filterConfig else { return nil }
        return parser.parseCommand(cgeCommand: filter.filterConfig,intensity: filter.filterIntensity, size: videoSize )
    }
    var ffmpegTextInfo : FFMpegTextInfo?
}


extension SLVideoInfo {
    typealias globalConfig = ShopLiveEditorConfigurationManager
    var scaleValue : String {
        var videoRatio : CGFloat = ( 9 / 16)
        if globalConfig.shared.videoCropOption.isFixed {
            let h = globalConfig.shared.videoCropOption.height
            let w = globalConfig.shared.videoCropOption.width
            videoRatio = CGFloat( h ) / CGFloat( w )
        }
        if cropRect.width < cropRect.height {
            return "-1:\(ceil(720 * videoRatio))"
        }
        else {
            return "720:-1"
            
        }
    }
    
    var totalDuration: Float64 {
        return (timeRange.end - timeRange.start)
    }
    
    var filterVideoPath: String {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let cacheoutput = path.appendingPathComponent("filtered_\(fileName)").deletingPathExtension().appendingPathExtension("mp4")
        return cacheoutput.absoluteString
    }
    
    var ffmpegOutPutVideoPath : String {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let cacheoutput = path.appendingPathComponent("ffmpeg_\(fileName)").deletingPathExtension().appendingPathExtension("mp4")
        return cacheoutput.absoluteString
    }
    
    var drawTextCommand : String {
        guard let textInfo = ffmpegTextInfo else { return "" }
        
        //  1080 * 1920, UIFont 15 적정 ffmpegTextSize -> 60
        let preferredFFmpegTextSize : Double = Double(textInfo.textSize * 4)
        let ffmpegTextSize = Int((sqrt(videoSize.width*videoSize.width + videoSize.height*videoSize.height) / 2202.0) * preferredFFmpegTextSize)
        
        let startTime = Int(textInfo.timeRange.start.seconds)
        let endTime = Int(textInfo.timeRange.end.seconds)
        
        return """
        drawtext=fontcolor=\(textInfo.textColor):box=1:boxcolor=\(textInfo.textBackgroundColor):text='\(textInfo.text)':x=\(textInfo.frame.minX):y=\(textInfo.frame.minY):fontsize=\(ffmpegTextSize)
        """
        //:enable='between(t,\(startTime),\(endTime))'
    }
    
    
//    -c:v h264_videotoolbox -c:a aac \
//    -r 24 \
//    -compression_level 1 \
//    화질이 너무 나쁨
    var command720p: String {
        
        if let filterConfig = ffmpegFilterConfig, filterConfig.isEmpty == false {
            return """
    -ss \(timeRange.start.timeHourMinuteSeconds_SL) \
    -to \(timeRange.end.timeHourMinuteSeconds_SL) \
    -i \(videoPath) \
    -filter_complex "\(filterConfig)[filter]; \
    [filter]crop=\(cropRect.width):\(cropRect.height):\(cropRect.origin.x):\(cropRect.origin.y)[crop]; \
    [crop]\( drawTextCommand == "" ? "" : "\(drawTextCommand)," )scale=\(scaleValue)[out]" \
    -map "[out]" \
    -q:v 8 \
    -y \(ffmpegOutPutVideoPath)
    """
        }
        else {
            return """
-ss \(timeRange.start.timeHourMinuteSeconds_SL) \
-to \(timeRange.end.timeHourMinuteSeconds_SL) \
-i \(videoPath) \
-filter_complex "crop=\(cropRect.width):\(cropRect.height):\(cropRect.origin.x):\(cropRect.origin.y)[crop]; \
[crop]\( drawTextCommand == "" ? "" : "\(drawTextCommand)," )scale=\(scaleValue)[out]" \
-map "[out]" \
-q:v 8 \
-y \(ffmpegOutPutVideoPath)
"""
        }
    }
    
    var commandRemoveScale: String {
        "-ss \(timeRange.start.timeHourMinuteSeconds_SL) -to \(timeRange.end.timeHourMinuteSeconds_SL) -i \(videoPath) -filter:v crop='\(cropRect.width):\(cropRect.height):\(cropRect.origin.x):\(cropRect.origin.y)' -y \(ffmpegOutPutVideoPath)"
    }
    
    var commandDefault: String {
        "-ss \(timeRange.start.timeHourMinuteSeconds_SL) -to \(timeRange.end.timeHourMinuteSeconds_SL) -i \(videoPath) -filter:v crop='\(cropRect.width):\(cropRect.height):\(cropRect.origin.x):\(cropRect.origin.y)' -y \(ffmpegOutPutVideoPath)"
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

class SLVideoConverter : NSObject {
    
    weak var delegate: SLVideoConverterDelegate?
    
    private var videoInfo: SLVideoInfo?
    private var frameRecorder : ShopliveFilterSDKVideoFrameRecorder?
    private var convertCompletion : ( (SLVideoConvertResult) -> Void )?
    
    private(set) var inConvert: Bool = false
    private var didForceCancel : Bool = false
    
    func convertVideo(videoInfo: SLVideoInfo, completion: @escaping (SLVideoConvertResult) -> Void) {
        convertCompletion = completion
        self.setDeviceIdleTimer(true)
        inConvert = true
        self.videoInfo = videoInfo
        runFfmpegCommand(command: videoInfo.command720p) { [weak self] result in
            switch result {
            case .Success():
                self?.setDeviceIdleTimer(false)
                self?.inConvert = false
                completion(.Success(videoPath: videoInfo.ffmpegOutPutVideoPath))
                break
            case .Failed(let error ):
                guard self?.didForceCancel == false else {
                    self?.didForceCancel = false
                    ShopLiveLogger.debugLog("convert failed error \(error)")
                    completion(.Failed(error: error))
                    return
                }
                self?.runFfmpegCommand(command: videoInfo.commandRemoveScale) { [weak self] result in
                    switch result {
                    case .Success():
                        self?.setDeviceIdleTimer(false)
                        self?.inConvert = false
                        completion(.Success(videoPath: videoInfo.ffmpegOutPutVideoPath))
                        break
                    case .Failed(let error):
                        guard self?.didForceCancel == false else {
                            self?.didForceCancel = false
                            ShopLiveLogger.debugLog("convert failed error \(error)")
                            completion(.Failed(error: error))
                            return
                        }
                        self?.runFfmpegCommand(command: videoInfo.commandDefault) { [weak self] result in
                            switch result {
                            case .Success():
                                self?.setDeviceIdleTimer(false)
                                self?.inConvert = false
                                completion(.Success(videoPath: videoInfo.ffmpegOutPutVideoPath))
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
            }
        }
    }

    private var ffmpegSession: FFmpegSession?
    func cancelConvert() {
        inConvert = false
        didForceCancel = true
        if let session = ffmpegSession {
            FFmpegKit.cancel(session.getId())
        }
        FFmpegKit.cancel()
        ffmpegSession?.cancel()
        ffmpegSession = nil
       
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
            
            if percent > Double(Int.max) {
                self.delegate?.updateConvertPercent(percent: 100)
            }
            else {
                self.delegate?.updateConvertPercent(percent: min(100,Int(percent)))
            }
        }
        
    }
    
    private func setDeviceIdleTimer(_ isEnabled : Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = isEnabled
        }
    }
    
    
    private func processFilterFrameRecording(urlString : String,filterConfig : String) {
        guard let videoInfo = videoInfo else {
            convertCompletion?(.Failed(error: SLVideoConvertError.error))
            return
        }
        let dict : [AnyHashable : Any] = [
            "sourceURL" : URL(string: urlString)!,
            "filterConfig" : String(cString: filterConfig),
            "filterIntensity" : 1.0
        ]
        let destUrl = URL(string: videoInfo.filterVideoPath)!
        
        
        self.frameRecorder = ShopliveFilterSDKVideoFrameRecorder.generateVideo(withFilter: destUrl, size: .zero, with: self, videoConfig: dict)
    }
    
}
extension SLVideoConverter : ShopliveFilterSDKVideoFrameRecorderDelegate {
    func videoReadingComplete(_ videoFrameRecorder: ShopliveFilterSDKVideoFrameRecorder!) {
        guard let recorder = self.frameRecorder else {
            convertCompletion?(.Failed(error: SLVideoConvertError.error))
            return
        }
        recorder.endRecording { [weak self] in
            self?.convertCompletion?(.Success(videoPath: recorder.outputVideoURL.absoluteString))
            self?.setDeviceIdleTimer(false)
            self?.inConvert = false
            
            self?.frameRecorder?.clear()
            self?.frameRecorder = nil
        }
    }
}
// ffmpeg -i gizmo.mp4 -filter_complex "[0]drawtext=fontcolor=#000000:text='나라말싸미':x=145.0:y=321.0[out]" -map "[out]" -y test20.mp4



