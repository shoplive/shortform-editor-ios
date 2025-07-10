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

public enum DedicatedWebViewCommandCompletionType {
    case isMuted
}

public enum ShopLivePlayerControlAction {
    case play
    case pause
    case stop
    case resume
}

final class PlayControlManager : NSObject, SLReactor {
    
    enum PlayCommand {
        case play
        case pause
        case stop
        case resume
        case none
    }
    
    enum Action {
        case setAVPlayer(AVPlayer?)
        case setAVPlayerItem(AVPlayerItem?)
        case setLiveUrl(URL?)
        case setIsReplayMode(Bool)
        case setNeedSeek(Bool)
        case setIsScreenLock(Bool)
        case setNeedReload(Bool)
        case seekTo(CMTime)
        case seekToLatest
        case setPlayCommandToNone
    }
    
    enum Result {
        case requestInitPlayer(URL)
        case requestSetNeedReload(Bool)
        case resetPlayer
        case requestSetCurrentPlayTime(CMTime?)
        case didChangeCurrentPlayCommand(PlayCommand)
        case sendEventToWeb(event : WebInterface, param : Any?, wrapping : Bool = false, dedicatedCompletionType : DedicatedWebViewCommandCompletionType?)
    }
    
    private var player : AVPlayer?
    private var playerItem : AVPlayerItem?
    private var liveUrl : URL?
    private var isReplayMode : Bool = false
    private var needSeek : Bool = false
    private var needReload : Bool = false
    private var isScreenLock : Bool = false
    private var currentPlayCommand : PlayCommand = .none
    
    var resultHandler: ((Result) -> ())?
    
    func action(_ action: Action) {
        switch action {
        case .setAVPlayer(let player):
            self.player = player
        case .setAVPlayerItem(let playerItem):
            self.playerItem = playerItem
        case .setLiveUrl(let url):
            self.liveUrl = url
        case .setIsReplayMode(let isReplayMode):
            self.isReplayMode = isReplayMode
        case .setNeedSeek(let needSeek):
            self.needSeek = needSeek
        case .setNeedReload(let needReload):
            self.needReload = needReload
        case .seekTo(let time):
            resultHandler?( .requestSetCurrentPlayTime(time) )
            player?.seek(to: time)
        case .seekToLatest:
            self.onSeekToLatest()
        case .setIsScreenLock(let isScreenLock):
            self.isScreenLock = isScreenLock
        case .setPlayCommandToNone:
            self.currentPlayCommand = .none
        }
    }

    private func onSeekToLatest() {
        guard let player = self.player,
              let seekableTimeRange = player.currentItem?.seekableTimeRanges.last?.timeRangeValue else { return }
        
        let currenTime = player.currentTime()
        let seekEndTime = seekableTimeRange.end
        
        if seekEndTime.isValid && (seekEndTime > currenTime) {
            player.seek(to: seekEndTime,
                        toleranceBefore: .init(value: 1, timescale: 44100),
                        toleranceAfter: .init(value: 1, timescale: 44100))
        }
    }

    /// player 상태 조절 후 didChangeCurrentPlayCommand 방출
    func playControlAction(_ action : ShopLivePlayerControlAction) {
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
            resultHandler?( .sendEventToWeb(event: .setIsPlayingVideo(isPlaying: true), param: true, wrapping: false, dedicatedCompletionType: nil))
        }
        else {
            resultHandler?( .sendEventToWeb(event: .reloadBtn, param: false, wrapping: false, dedicatedCompletionType: nil))
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
        if let liveUrl {
            return liveUrl
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
    func getNeedReload() -> Bool {
        return self.needReload
    }
    
    func getNeedSeek() -> Bool {
        return self.needSeek
    }
    
    func getIsReplayMode() -> Bool {
        return self.isReplayMode
    }
    
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
    
    func getCurrentPlayCommand() -> PlayCommand {
        return self.currentPlayCommand
    }
}

