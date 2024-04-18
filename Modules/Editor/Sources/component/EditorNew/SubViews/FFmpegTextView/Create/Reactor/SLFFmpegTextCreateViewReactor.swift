//
//  SLFFmpegTextCreateViewReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/27/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit



class SLFFmpegTextCreateViewReactor : NSObject, SLReactor {
    
    struct TextInfo {
        var text : String
        var fontSize : Int
        var textColor : String
        var textBackgroundColor : String
        var timeRange : CMTimeRange
    }
    
    enum Action {
        case requestPopView
        case requestFontSizeChange(Int)
        case setText(String)
        case setTextColor(String)
        case setTextBackgroundColor(String)
        case setStartTime(Double)
        case setEndTime(Double)
        
        case requestConfirm
    }
    
    enum Result {
        case requestPopView
        case setFontSize(Int)
        
        case setTextCreateCompletion(TextInfo)
        
    }
    
    private var fontSize : Int = 15
    private var currentText : String = ""
    private var textColor : String = "#000000"
    private var textBackgroundColor : String = "#000000"
    private var startTime : Double = 0
    private var endTime : Double = 0
    
    
    
    var resultHandler: ((Result) -> ())?
    var mainQueueResultHandler : ((Result) -> ())?
    
    
    func action(_ action: Action) {
        switch action {
        case .requestPopView:
            self.onRequestPopView()
        case .requestFontSizeChange(let size):
            self.onRequestFontSizeChange(size: size)
        case .setText(let text):
            self.onSetText(text: text)
        case .setTextColor(let color):
            self.onSetTextColor(color: color)
        case .setTextBackgroundColor(let color):
            self.onSetTextBackgroundColor(color: color)
        case .setStartTime(let startTime):
            self.onSetStartTime(time: startTime)
        case .setEndTime(let endTime):
            self.onSetEndTime(time: endTime)
        
            
            
            
        case .requestConfirm:
            self.onRequestConfirm()
        }
        
    }
    
    
    private func onRequestPopView() {
        mainQueueResultHandler?( .requestPopView )
    }
    
    private func onRequestFontSizeChange(size : Int) {
        self.fontSize = size
        mainQueueResultHandler?( .setFontSize(size) )
    }
    
    private func onSetText(text : String) {
        self.currentText = text
    }
    
    private func onSetTextColor(color : String) {
        self.textColor = color
    }
    
    private func onSetTextBackgroundColor(color: String) {
        self.textBackgroundColor = color
    }
    
    private func onSetStartTime(time : Double) {
        self.startTime = time
    }
    
    private func onSetEndTime(time : Double) {
        self.endTime = time
    }
    
    
    private func onRequestConfirm() {
        let timeRange = CMTimeRange(start: .init(seconds: startTime, preferredTimescale: 44100), end: .init(seconds: endTime, preferredTimescale: 44100))
        let textInfo = TextInfo(text: currentText, fontSize: fontSize,textColor: textColor, textBackgroundColor:  textBackgroundColor, timeRange: timeRange)
        resultHandler?( .setTextCreateCompletion(textInfo) )
        mainQueueResultHandler?( .requestPopView )
    }
    
}
extension SLFFmpegTextCreateViewReactor {
    
    
    
}
