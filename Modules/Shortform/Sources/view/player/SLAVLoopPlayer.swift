//
//  SLAVLoopPlayer.swift
//  matrix-shortform-ios
//
//  Created by sangmin han on 2023/05/02.
//

import Foundation
import AVFoundation
import ShopliveSDKCommon

protocol SLAVLoopPlayerDelegate {
    func onSLAVLoopPlayerError(error : Error)
    func onSLAVLoopPlayerItemReady(isReady : Bool)
}
/**
 숏폼 리스트에서 쓰는 무한 루프 AVPlayer
 */
class SLAVLoopPlayer: AVPlayer {
    
    
    private var playItemContext = 0
    private var previousItem : AVPlayerItem?
    private var observer : NSKeyValueObservation?
    
    var delegate : SLAVLoopPlayerDelegate?
    
    override func replaceCurrentItem(with item: AVPlayerItem?) {
        item?.canUseNetworkResourcesForLiveStreamingWhilePaused = false
        self.isMuted = true
        self.previousItem = self.currentItem
        super.replaceCurrentItem(with: item)
        self.setObserver(item: item)
        self.observer?.invalidate()
        self.observer = nil
        self.observer = item?.observe(\.status,options: [.new,.old], changeHandler: { [weak self] item, change in
            if item.status == .readyToPlay {
                self?.delegate?.onSLAVLoopPlayerItemReady(isReady: true)
                return
            }
            else if item.status == .failed {
                if let currentItem = self?.currentItem, let error = currentItem.error {
                    
                    let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .UnexpectedError, error: error, message: nil)
                
                    self?.delegate?.onSLAVLoopPlayerError(error: commonError)
                }
            }
            self?.delegate?.onSLAVLoopPlayerItemReady(isReady: false)
        })
    }
        
    deinit {
        self.observer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setObserver(item : AVPlayerItem?){
        guard let item = item else { return }
        if let previousItem = self.previousItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: previousItem)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(didRecieveNotification(sender: )), name: .AVPlayerItemDidPlayToEndTime, object: item)
    }

    @objc func didRecieveNotification(sender : Notification){
        if self.timeControlStatus == .paused { return }
        self.seek(to: CMTime.zero)
        self.play()
    }
    
}

