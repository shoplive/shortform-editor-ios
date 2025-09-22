//
//  PlayControlManager.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/5/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import AVKit
import UIKit
import ShopliveSDKCommon

final class PlayControlManager: NSObject, SLReactor {
    
    enum PlayCommand {
        case play
        case pause
        case stop
        case resume
        case none
    }
    
    enum Action {
        case controlPlayer(PlayCommand)
        case seekTo(CMTime)
        case seekToLatest
    }
    
    enum Result {
        case requestInitPlayer(URL)
        case requestSetNeedReload(Bool)
        case resetPlayer
        case requestSetCurrentPlayTime(CMTime?)
        case didChangeCurrentPlayCommand(PlayCommand)
        case sendEventToWeb(
            event: WebInterface,
            param: Any?,
            wrapping: Bool = false
        )
    }
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var liveURL: URL?
    private var needReload: Bool = false
    private var isScreenLock: Bool = false
    private(set) var isReplayMode: Bool = false
    private(set) var needSeek: Bool = false
    private(set) var currentPlayCommand: PlayCommand = .none
    
    var resultHandler: ((Result) -> ())?
    
    func action(_ action: Action) {
        switch action {
        case .seekTo(let time):
            resultHandler?( .requestSetCurrentPlayTime(time) )
            player?.seek(to: time)
        case .seekToLatest:
            self.onSeekToLatest()
            
        case let .controlPlayer(action):
            switch action {
            case .play:
                self.play()
                self.resultHandler?( .didChangeCurrentPlayCommand(.play) )
            case .pause:
                self.pause()
                self.resultHandler?( .didChangeCurrentPlayCommand(.pause) )
            case .stop:
                self.stop()
                self.resultHandler?( .didChangeCurrentPlayCommand(.stop) )
            case .resume:
                self.resume()
                self.resultHandler?( .didChangeCurrentPlayCommand(.resume) )
            case .none:
                break
            }
        }
    }
    
//MARK: setFunction()
    func setAVPlayer(_ player: AVPlayer?) {
        self.player = player
    }
    func setAVPlayerItem(_ item: AVPlayerItem?){
        self.playerItem = item
    }
    func setLiveURL(_ url: URL?) {
        self.liveURL = url
    }
    func setIsReplayMode(by isReplay: Bool) {
        self.isReplayMode = isReplay
    }
    func setNeedSeek(_ needSeek: Bool) {
        self.needSeek = needSeek
    }
    func setIsScreenLock(_ isScreenLock: Bool) {
        self.isScreenLock = isScreenLock
    }
    func setNeedReload(_ isNeedReload: Bool) {
        self.needReload = isNeedReload
    }
    func setPlayCommandToNone() {
        self.currentPlayCommand = .none
    }

    private func onSeekToLatest() {
        guard let player = self.player,
              let seekableTimeRange = player.currentItem?.seekableTimeRanges.last?.timeRangeValue else { return }
        
        let currenTime = player.currentTime()
        let seekEndTime = seekableTimeRange.end
        
        if seekEndTime.isValid && (seekEndTime > currenTime) {
            player.seek(
                to: seekEndTime,
                toleranceBefore: .init(value: 1, timescale: 44100),
                toleranceAfter: .init(value: 1, timescale: 44100)
            )
        }
    }
    
    private func play() {
        guard let player, currentPlayCommand != .play else { return }
        self.currentPlayCommand = .play
        
        activatePreserveTimeOffsetFromLive()
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if self.isReplayMode {
                if self.isReplayFinised() {
                    self.action( .seekTo( .init(value: 0, timescale: 44100) ) )
                }
                player.play()
                return
            }
            player.play()
            if self.needSeek {
                self.needSeek = false
                guard let lastLoadedTime = player.currentItem?.loadedTimeRanges.first as? CMTimeRange else { return }
                let latestVideoTime = lastLoadedTime.start
                let currentVideoTime = player.currentTime()
                if latestVideoTime.seconds > currentVideoTime.seconds + 2 {
                    player.seek(to: latestVideoTime, toleranceBefore: .zero, toleranceAfter: .zero)
                }
            }
        }
    }
    
    private func pause() {
        guard let player, currentPlayCommand != .pause else { return }
        
        self.currentPlayCommand = .pause
        deactivatePreserveTimeOffsetFromLive()
        if Thread.isMainThread {
            player.pause()
            //정확히 어떤 이유인지는 모르겠지만,
            //async로 감싸지 않고 바로 한번 호출 해주고 다시 또 async에서 호출해야지 로딩 되자마자 pause되는 현상이 있음
            //asyncAfter 2초까지도 되지 않음
        }
        DispatchQueue.main.async {
            player.pause()
        }
    }
    
    private func resume() {
        guard let player else { return }
        guard currentPlayCommand == .play || currentPlayCommand == .resume else { return }
        
        self.currentPlayCommand = .resume
        activatePreserveTimeOffsetFromLive()
        if self.isReplayMode {
            resultHandler?( .sendEventToWeb(event: .setIsPlayingVideo(isPlaying: true), param: true, wrapping: false))
        }
        else {
            resultHandler?( .sendEventToWeb(event: .reloadBtn, param: false, wrapping: false))
        }
        
        DispatchQueue.main.async {
            player.play()
        }
    }
    
    private func stop() {
        self.currentPlayCommand = .stop
        self.resultHandler?( .resetPlayer )
    }
    
}
extension PlayControlManager {
    private func getCurrentUrl() -> URL? {
        if let liveURL {
            return liveURL
        }
        return (player?.currentItem as? AVURLAsset)?.url
    }
    
    private func activatePreserveTimeOffsetFromLive() {
        guard let player else { return }
        if #available(iOS 13.0, *) {
            //해당 옵션이 켜져 있으면 pause상태에서도 최신으로 따라잡으려는 성질 때문에 화면이 렌더링 됨
            player.currentItem?.automaticallyPreservesTimeOffsetFromLive = true
            if let timeOffset = player.currentItem?.asset.minimumTimeOffsetFromLive {
                player.currentItem?.configuredTimeOffsetFromLive = timeOffset
            }
        }
    }
    
    private func deactivatePreserveTimeOffsetFromLive() {
        guard let player else { return }
        if #available(iOS 13.0, *) {
            //해당 옵션이 켜져 있으면 pause상태에서도 최신으로 따라잡으려는 성질 때문에 화면이 렌더링 됨
            player.currentItem?.automaticallyPreservesTimeOffsetFromLive = false
        }
    }
    
}
extension PlayControlManager {
    
    func getVideoDuration() -> CMTime? {
        return player?.currentItem?.asset.duration
    }
    
    func isReplayFinised() -> Bool {
        guard self.isReplayMode,
              let player = self.player,
              let totalTime = self.getVideoDuration() else {
            return false
        }
        let currentTime = player.currentTime()
        let roundedCurrentTime = Int64(round(Double(currentTime.value) / 1000000000))
        return (totalTime.value / 1000) <= roundedCurrentTime
    }
}

