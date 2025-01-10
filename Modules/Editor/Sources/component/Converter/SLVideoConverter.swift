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
    var volume : Double
    var speed : Double
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
        let resolution = CGFloat(globalConfig.shared.videoOutputOption.videoOutputResolution.rawValue)
        if cropRect.width < cropRect.height {
            return "-1:\(Int(ceil(resolution * videoRatio)))"
        }
        else {
            return "\(Int(resolution)):-1"
        }
    }
    
    var totalDuration: Float64 {
        return (timeRange.end - timeRange.start)
    }
   
    var ffmpegOutPutVideoPath : String {
        let path = SLFileManager.ffmpegDirectorypath
        let cacheoutput = path.appendingPathComponent("\(fileName)_\(Int64(Date().timeIntervalSince1970))").deletingPathExtension().appendingPathExtension("mp4")
        return cacheoutput.relativePath
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
    
    var videoQuality : String {
        switch globalConfig.shared.videoOutputOption.videoOutputQuality {
        case .normal:
            return "-q:v 6"
        case .high:
            return "-q:v 4"
        case .max:
            return "-q:v 2"
        }
    }
    
    var volumeCommand : String {
        return "[0:a]volume=\(volume/100)[a];"
    }
    
    var speedCommand : String {
        return "[crop]setpts=\(1/speed)*PTS[speed]; [a]atempo=\(speed)[aa];"
    }
    
    var speedCommandForRemovedScale : String {
        return "[crop]setpts=\(1/speed)*PTS[speed]; [a]atempo=\(speed)[aa]"
    }
    
    var modifiedCropWidth : CGFloat {
        let roundedWidth = cropRect.width
        if roundedWidth.truncatingRemainder(dividingBy: 2) != 0 {
            return roundedWidth - 1
        }
        else {
            return roundedWidth
        }
    }
    
    var modifiedCropHeight : CGFloat {
        let roundedHeight = cropRect.height
        if roundedHeight.truncatingRemainder(dividingBy: 2) != 0 {
            return roundedHeight - 1
        }
        else {
            return roundedHeight
        }
    }
    
    var videoCodec : String {
        return ""
    }
    //1077
    //436
    var command720p: String {
        if let filterConfig = ffmpegFilterConfig, filterConfig.isEmpty == false {
            return """
    -ss \(timeRange.start.timeHourMinuteSeconds_SL) \
    -to \(timeRange.end.timeHourMinuteSeconds_SL) \
    -i \(videoPath) \
    -c:v mpeg4 \
    -filter_complex "\(filterConfig)[filter]; \
    [filter]crop=\(Int(modifiedCropWidth)):\(Int(modifiedCropHeight)):\(Int(cropRect.origin.x)):\(Int(cropRect.origin.y))[crop]; \
    \(volumeCommand) \
    \(speedCommand) \
    [speed]\( drawTextCommand == "" ? "" : "\(drawTextCommand)," )scale=\(scaleValue)[out]" \
    -map "[aa]" \
    -map "[out]" \
    \(videoQuality) \
    -y \(ffmpegOutPutVideoPath)
    """
        }
        else {
            return """
-ss \(timeRange.start.timeHourMinuteSeconds_SL) \
-to \(timeRange.end.timeHourMinuteSeconds_SL) \
-i \(videoPath) \
-c:v mpeg4 \
-filter_complex "[0:v]crop=\(Int(modifiedCropWidth)):\(Int(modifiedCropHeight)):\(Int(cropRect.origin.x)):\(Int(cropRect.origin.y))[crop]; \
\(volumeCommand) \
\(speedCommand) \
[speed]\( drawTextCommand == "" ? "" : "\(drawTextCommand)," )scale=\(scaleValue)[out]" \
-map "[aa]" \
-map "[out]" \
\(videoQuality) \
-y \(ffmpegOutPutVideoPath)
"""
        }
    }
//    -c:v libx264 \
//    -c:v mpeg2video \
    //-c:v libvpx-vp9 -cpu-used 5 -threads 4 -tile-columns 4 -row-mt 1 -frame-parallel 1 -g 10 \

    var commandRemoveScale: String {
        if let filterConfig = ffmpegFilterConfig, filterConfig.isEmpty == false {
            return """
    -ss \(timeRange.start.timeHourMinuteSeconds_SL) \
    -to \(timeRange.end.timeHourMinuteSeconds_SL) \
    -i \(videoPath) \
    -c:v mpeg4 \
    -filter_complex "\(filterConfig)[filter]; \
    [filter]crop=\(Int(modifiedCropWidth)):\(Int(modifiedCropHeight)):\(Int(cropRect.origin.x)):\(Int(cropRect.origin.y))[crop]; \
    \(volumeCommand) \
    \(speedCommandForRemovedScale)" \
    -map "[aa]" \
    -map "[speed]" \
    \(videoQuality) \
    -y \(ffmpegOutPutVideoPath)
    """
        }
        else {
            return """
-ss \(timeRange.start.timeHourMinuteSeconds_SL) \
-to \(timeRange.end.timeHourMinuteSeconds_SL) \
-i \(videoPath) \
-c:v mpeg4 \
-filter_complex "[0:v]crop=\(Int(modifiedCropWidth)):\(Int(modifiedCropHeight)):\(Int(cropRect.origin.x)):\(Int(cropRect.origin.y))[crop]; \
\(volumeCommand) \
\(speedCommandForRemovedScale)" \
-map "[aa]" \
-map "[speed]" \
\(videoQuality) \
-y \(ffmpegOutPutVideoPath)
"""
        }
    }
    
    var commandDefault: String {
        "-ss \(timeRange.start.timeHourMinuteSeconds_SL) -to \(timeRange.end.timeHourMinuteSeconds_SL) -i \(videoPath) -filter:v crop='\(modifiedCropWidth):\(modifiedCropHeight):\(cropRect.origin.x):\(cropRect.origin.y)' -y \(ffmpegOutPutVideoPath)"
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
    private var convertCompletion : ( (SLVideoConvertResult) -> Void )?
    
    private(set) var inConvert: Bool = false
    private var didForceCancel : Bool = false
    
    private var ffmpegConverQueue2 = OperationQueue()
    private var semaphoreLock : DispatchSemaphore = .init(value: 0)
    
    override init(){
        super.init()
        ffmpegConverQueue2.maxConcurrentOperationCount = 1
        ffmpegConverQueue2.qualityOfService = .background
    }
    
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

    private var ffmpegSessions : [FFmpegSession] = []
    
    func cancelConvert() {
        ffmpegConverQueue2.addOperation { [weak self] in
            guard let self = self else { return }
            self.inConvert = false
            self.didForceCancel = true
            FFmpegKit.cancel()
            self.ffmpegSessions.forEach { session in
                FFmpegKit.cancel(session.getId())
                session.cancel()
            }
            self.ffmpegSessions = []
            self.semaphoreLock.wait()
        }
    }
    
    private func runFfmpegCommand(command: String, completion: @escaping (SLVideoFFMpegExecuteResult) -> Void) {
        ffmpegConverQueue2.addOperation { [weak self] in
            guard let self = self else { return }
            self.delegate?.updateConvertPercent(percent: Int(0))
            ShopLiveLogger.tempLog("ffmpeg command \(command)")
            let session = FFmpegKit.executeAsync(command) { [weak self] session in
                guard let self = self else { return }
                if let session = session {
                    if session.getState() == .completed {
                        semaphoreLock.signal()
                    }
                }
                guard let returnCode = session?.getReturnCode() else { return }
                if ReturnCode.isSuccess(returnCode) {
                    completion(.Success(()))
                } else if ReturnCode.isCancel(returnCode) {
                    completion(.Failed(error: SLVideoConvertError.cancel))
                } else {
                    completion(.Failed(error: SLVideoConvertError.error))
                }
            } withLogCallback: { log in
                ShopLiveLogger.tempLog(log?.getMessage() ?? "")
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
            
            if let session = session {
                self.ffmpegSessions.append(session)
            }
        }
    }
    
    private func setDeviceIdleTimer(_ isEnabled : Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = isEnabled
        }
    }
    
}

// ffmpeg -i gizmo.mp4 -filter_complex "[0]drawtext=fontcolor=#000000:text='나라말싸미':x=145.0:y=321.0[out]" -map "[out]" -y test20.mp4



