//
//  ShopLivePlayerErrorObserver.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 10/10/23.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon



protocol ShopLiveAVPlayerErrorObserverDelegate {
    func pauseAndWaitForBufferFromPlayerObserveError()
    func onStallDangerFromPlayerObserveError()
    func onMissingRenditionReport()
    func onLiveStreamDisconnect()
    func onPlayListParseError()
    func onBandWidthExceeds()
    func onNoMatchingMediaFileFound()
    func onUnableToGetPlayList()
}

class ShopLiveAVPlayerErrorObserver {
    
    
    enum ErrorCase {
        case extDiscontinuity
        case missinRenditionReport
        case stallDanger
        case disconnected
        case playListParseError
        case bandWithExceeds
        case noMatchingMediaFileFound
        case unableToGetPlayList
        case none
    }
    
    
    private var player : AVPlayer
    private var isInErrorRetry : Bool = false
    private var currentErrorCase : ErrorCase = .none
    
    var delegate : ShopLiveAVPlayerErrorObserverDelegate?
    
    init(player : AVPlayer) {
        self.player = player
        addObserver()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: player.currentItem)
    }
    
    func getCurrentErrorCase() -> ErrorCase {
        return self.currentErrorCase
    }
    
    private func addObserver(){
        guard let playerItem = player.currentItem else { return }
        NotificationCenter.default.addObserver(self, selector: #selector(handleErrorLogEntry(_:)), name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: playerItem)
    }
    
    @objc private func handleErrorLogEntry(_ notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem,
              let errorLog = playerItem.errorLog() else {
            return
        }

        // Access the error log entries
        let errorLogEntries = errorLog.events
        for logEntry in errorLogEntries {
            // Extract and handle the error details
            let errorDate = logEntry.date
            let errorStatusCode = logEntry.errorStatusCode
            let errorDomain = logEntry.errorDomain
            let errorComment = logEntry.errorComment
            if isInErrorRetry == false {
                let log = """
                ======================================================
                errorDate \(errorDate ?? Date())
                errorStatusCode \(errorStatusCode)
                errorDomain \(errorDomain)
                errorComment \(errorComment ?? "")
                ======================================================
                """
                ShopLiveLogger.debugLog("[HASSAN LOG] \n \(log)")
                let errorCase = getErrorCase(errorStatusCode: errorStatusCode, errorDomain: errorDomain, errorComment: errorComment ?? "")
                switch errorCase {
                case .extDiscontinuity:
                    self.handleextDiscontinuityError()
                case .missinRenditionReport:
                    self.handleMissinRenditionReportError()
                case .stallDanger:
                    self.handleStallDanger()
                case .disconnected:
                    self.handleDisconnected()
                case .playListParseError:
                    self.handlePlayListParseError()
                case .bandWithExceeds:
                    self.handleBandwithExceeds()
                case .noMatchingMediaFileFound:
                    self.handleNoMatchingMediaFileFound()
                case .unableToGetPlayList:
                    self.handleUnableToGetPlayList()
                case .none:
                    break
                }
            }
        }
    }
    
    private func getErrorCase(errorStatusCode : Int, errorDomain : String, errorComment : String) -> ErrorCase {
        if errorStatusCode == -12642 &&
            errorDomain == "CoreMediaErrorDomain" &&
            errorComment.contains("#EXT-X-DISCONTINUITY-SEQUENCE") {
            return .extDiscontinuity
        }
        else if errorStatusCode == -15418  &&
                errorDomain == "CoreMediaErrorDomain" &&
                errorComment.contains("missing Rendition Report"){
            return .missinRenditionReport
        }
        else if errorStatusCode == -16832  &&
                errorDomain == "CoreMediaErrorDomain" &&
                errorComment.contains("stall danger"){
            return .stallDanger
        }
        else if errorStatusCode == -12938 &&
                    errorDomain == "CoreMediaErrorDomain" &&
                    errorComment.contains("HTTP 404") {
            return .disconnected
        }
        else if errorDomain == "CoreMediaErrorDomain" &&
                    errorComment.contains("playlist parse error") {
            return .playListParseError
        }
        else if errorStatusCode == -12318 &&
                    errorDomain == "CoreMediaErrorDomain" &&
                    errorComment.contains("exceeds specified bandwidth") {
            return .bandWithExceeds
        }
        else if errorStatusCode == -12888 &&
                    errorDomain == "CoreMediaErrorDomain" &&
                    errorComment.contains("Stale index file") {
            return .disconnected
        }
        else if errorStatusCode == -12642 &&
                    errorDomain == "CoreMediaErrorDomain" &&
                    errorComment.contains("No matching mediaFile found from playlist") {
            return .noMatchingMediaFileFound
        }
        else if errorStatusCode == -12318 &&
                    errorDomain == "CoreMediaDomainError" &&
                    errorComment.contains("Unable to get playlist before long download timer") {
            return .unableToGetPlayList
        }
        else {
            return .none
        }
    }
    
    private func handleextDiscontinuityError(){
        self.isInErrorRetry = true
        self.currentErrorCase = .extDiscontinuity
        delegate?.pauseAndWaitForBufferFromPlayerObserveError()
    }
    
    private func handleMissinRenditionReportError(){
        self.isInErrorRetry = true
        self.currentErrorCase = .missinRenditionReport
        delegate?.onMissingRenditionReport()
    }
    
    private func handleStallDanger(){
        self.isInErrorRetry = true
        self.currentErrorCase = .stallDanger
        delegate?.onStallDangerFromPlayerObserveError()
    }
    
    private func handlePlayListParseError(){
        self.isInErrorRetry = true
        self.currentErrorCase = .playListParseError
        delegate?.onPlayListParseError()
    }
    
    private func handleDisconnected(){
        self.isInErrorRetry = true
        self.currentErrorCase = .disconnected
        delegate?.onLiveStreamDisconnect()
    }
    
    private func handleBandwithExceeds(){
        self.isInErrorRetry = true
        self.currentErrorCase = .bandWithExceeds
        delegate?.onBandWidthExceeds()
    }
    
    private func handleNoMatchingMediaFileFound(){
        self.isInErrorRetry = true
        self.currentErrorCase = .noMatchingMediaFileFound
        delegate?.onNoMatchingMediaFileFound()
    }
    
    private func handleUnableToGetPlayList() {
        self.isInErrorRetry = true
        self.currentErrorCase = .unableToGetPlayList
        delegate?.onUnableToGetPlayList()
    }
    
    func resetErrorCase(){
        self.isInErrorRetry = false
        self.currentErrorCase = .none
    }
}
