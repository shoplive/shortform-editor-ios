//
//  LiveStreamViewModel.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/04.
//

import Foundation
import AVKit

internal final class LiveStreamViewModel: NSObject {

    var overayUrl: URL?
    var accessKey: String?
    var campaignKey: String?
    var authToken: String? = nil
    var user: ShopLiveUser? = nil
    
    private var urlAsset: AVURLAsset?
    private var playerItem: AVPlayerItem?
    private var perfMeasurements: PerfMeasurements?
    
    deinit {
        teardownLiveStreamViewModel()
    }
    
    override init() {
        super.init()
        setupLiveStreamViewModel()
    }

    private func setupLiveStreamViewModel() {
        ShopLiveController.shared.addPlayerDelegate(delegate: self)
    }
    
    private func teardownLiveStreamViewModel() {
        ShopLiveController.shared.removePlayerDelegate(delegate: self)
        resetPlayer()
        
        overayUrl = nil
        accessKey = nil
        campaignKey = nil
        authToken = nil
        user = nil
    }

    func updatePlayerItem(with url: URL) {
        guard ShopLiveController.player != nil else { return }

        resetPlayer()

        let asset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        if asset.isPlayable {
            ShopLiveController.shared.playItem?.perfMeasurements = PerfMeasurements(playerItem: playerItem)
            let metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil)
            metadataOutput.setDelegate(self, queue: DispatchQueue.main)
            playerItem.add(metadataOutput)
            
            if #available(iOS 13.0, *) {
                playerItem.automaticallyPreservesTimeOffsetFromLive = true
                playerItem.configuredTimeOffsetFromLive = asset.minimumTimeOffsetFromLive
            }
            if #available(iOS 14.0, *) {
                playerItem.startsOnFirstEligibleVariant = true
            }
            if #available(iOS 14.5, *) {
                playerItem.variantPreferences = .scalabilityToLosslessAudio
            }
            
            playerItem.preferredForwardBufferDuration = 1
            
            ShopLiveController.playerItem = playerItem
            self.playerItem = playerItem
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .TimebaseEffectiveRateChangedNotification, object: self.playerItem?.timebase)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .AVPlayerItemPlaybackStalled, object: self.playerItem)
            ShopLiveController.shared.playerItem?.player?.replaceCurrentItem(with: playerItem)
        }
    }

    private func resetPlayer() {
        guard ShopLiveController.player != nil else { return }
        if ShopLiveController.player?.currentItem == nil {
            return
        }
        ShopLiveController.videoUrl = nil
        ShopLiveController.player?.currentItem?.asset.cancelLoading()
        ShopLiveController.player?.cancelPendingPrerolls()
        ShopLiveController.player?.replaceCurrentItem(with: nil)
        ShopLiveController.playerItem = nil
        ShopLiveController.urlAsset = nil
        ShopLiveController.shared.playItem?.perfMeasurements = nil

        ShopLiveController.perfMeasurements?.playbackEnded()
        ShopLiveController.perfMeasurements = nil

        NotificationCenter.default.safeRemoveObserver(self, name: .TimebaseEffectiveRateChangedNotification, object: nil)
        NotificationCenter.default.safeRemoveObserver(self, name: .AVPlayerItemPlaybackStalled, object: nil)

        ShopLiveController.playControl = .none
    }
    
    func play() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let url = ShopLiveController.streamUrl, !url.absoluteString.isEmpty, (ShopLiveController.playerItemStatus == .failed || ShopLiveController.player?.reasonForWaitingToPlay == AVPlayer.WaitingReason.evaluatingBufferingRate) {
                self.updatePlayerItem(with: url)
            }
            else {
                if ShopLiveController.isReplayMode {
                    if ShopLiveController.isReplayFinished {
                        self.seek(to: .init(value: 0, timescale: 1))
                    }
                }
                
                ShopLiveController.player?.play()
            }
        }
    }
    
    func stop() {
        resetPlayer()
    }

    func resume() {
        guard ShopLiveController.player?.timeControlStatus != .playing else { return }

        DispatchQueue.main.async {
            if ShopLiveController.isReplayMode {
                ShopLiveController.player?.play()
            } else {
                if let url = ShopLiveController.streamUrl, !url.absoluteString.isEmpty {
                    if ShopLiveController.shared.needSeek {
                        ShopLiveController.shared.needSeek = false
                        ShopLiveController.shared.seekToLatest()
                    }
                    ShopLiveController.player?.play()
                }
            }
        }
    }
    
    func reloadVideo() {
        guard let url = ShopLiveController.streamUrl else {
            resetPlayer()
            return
        }
        
        updatePlayerItem(with: url)
    }

    func seek(to: CMTime) {
        ShopLiveController.shared.currentPlayTime = to.value
        ShopLiveController.player?.seek(to: to)
    }

    @objc func handleNotification(_ notification: Notification) {
        switch notification.name {
        case .TimebaseEffectiveRateChangedNotification:
            if let timebase = ShopLiveController.timebase {
                let rate = CMTimebaseGetRate(timebase)
                self.perfMeasurements?.rateChanged(rate: rate)
            }
            break
        case .AVPlayerItemPlaybackStalled:
            if let _ = ShopLiveController.playerItem {
                self.perfMeasurements?.playbackStalled()
            }
            break
        default:
            break
        }
    }

    func handlePlayerItemStatus() {
        switch ShopLiveController.playerItemStatus {
        case .readyToPlay:
            ShopLiveLogger.debugLog("readyToPlay")
            ShopLiveLogger.debugLog("[1.3.2] readyToPlay")
            ShopLiveController.playerItem?.preferredForwardBufferDuration = 5
            if ShopLiveController.playControl != .pause, ShopLiveController.playControl != .play, ShopLiveController.windowStyle != .osPip {
                if ShopLiveController.isReplayMode && ShopLiveController.playControl == .resume { return }
                if ShopLiveController.isReplayMode, let duration = ShopLiveController.duration {
                    ShopLiveViewLogger.shared.addLog(log: .init(logType: .interface, log: "[ON_VIDEO_DURATION_CHANGED] duration total: \(duration)  CMTimeGetSeconds(duration): \(CMTimeGetSeconds(duration))"))
                    ShopLiveController.webInstance?.sendEventToWeb(event: .onVideoDurationChanged, CMTimeGetSeconds(duration))
                }
                ShopLiveController.retryPlay = false
                self.play()
            }
        case .failed:
            ShopLiveLogger.debugLog("failed")
            ShopLiveLogger.debugLog("[1.3.2] failed")
            ShopLiveLogger.debugLog("[1.3.2] failed retry true")
            ShopLiveController.retryPlay = true
            break
        default:
            break
        }
    }

}

extension LiveStreamViewModel: ShopLivePlayerDelegate {

    var identifier: String {
        return "LiveStreamViewModel"
    }

    func updatedValue(key: ShopLivePlayerObserveValue) {
        switch key {
        case .videoUrl:
            guard let videoUrl = ShopLiveController.videoUrl else { return }
            ShopLiveViewLogger.shared.addLog(log: .init(logType: .interface, log: videoUrl.absoluteString))
            updatePlayerItem(with: videoUrl)
            break
        case .playerItemStatus:
            handlePlayerItemStatus()
            break
        case .releasePlayer:
            resetPlayer()
            break
        default:
            break
        }
    }
}

extension LiveStreamViewModel: AVPlayerItemMetadataOutputPushDelegate {
    func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {

        let payloads: NSMutableDictionary = .init()
        var timedMeta: String = "[timedMeta]\n"
        groups.forEach { group in
            group.items.forEach { item in

                if let key = item.key as? String, let datav = item.value as? Data {
                    timedMeta += "\(key): \(String(describing: item.value)) \n"
                    payloads[key] = datav.base64EncodedString()
                }
            }
        }

        if payloads.count > 0 {
            ShopLiveController.shared.webInstance?.sendEventToWeb(event: .onVideoMetadataUpdated, payloads.toJson())
        }
    }
}
