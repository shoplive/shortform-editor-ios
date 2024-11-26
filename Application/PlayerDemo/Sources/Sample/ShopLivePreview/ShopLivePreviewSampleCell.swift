//
//  ShopLivePreviewSampleCell.swift
//  PlayerDemo
//
//  Created by sangmin han on 9/9/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import ShopLiveSDK
import AVKit

protocol ShopLivePreviewSampleCellDelegate : NSObjectProtocol {
    func isCellOnWindow(indexPath : IndexPath?) -> Bool
}

class ShopLivePreviewSampleCell : UICollectionViewCell {
    
    
    
    var preview = ShopLivePlayerPreview()
    var indexPath : IndexPath?
    
    weak var delegate : ShopLivePreviewSampleCellDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.setLayout()
        bindPreview()
    }
    
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    func setPreview(accessKey : String, campaignKey : String) {
        preview.action( .stop )
        preview.action( .close )
        preview = ShopLivePlayerPreview()
        setLayout()
        bindPreview()
        preview.action( .setMuted(true) )
        preview.action( .initialize )
        preview.action( .setResolutionType(DemoConfiguration.shared.previewResolution))
        preview.action( .start(accessKey: accessKey, campaignKey: campaignKey, referrer: nil) )
        preview.action( .setEnabledVolumeKey(isEnabledVolumeKey: true) )
//        preview.action( .play )
    }
    
    func play() {
        preview.action( .play )
    }
    
    func pause() {
        preview.action( .pause )
    }
    
    func stop() {
        preview.action( .stop )
    }
    
    func getPlayerItemStatus() -> AVPlayerItem.Status? {
        return preview.getPlayerItemStatus()
    }
    
    private func bindPreview() {
        preview.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .log(name: let name, feature: let feature, campaignKey: let campaignKey, payload: let payload):
                break
            case .handleReceivedCommand(command: let command, payload: let payload):
                break
            case .avPlayerTimeControlStatus(let status):
                switch status {
                case .paused:
                    ShopLiveLogger.tempLog("paused")
                case .playing:
                    ShopLiveLogger.tempLog("playing")
                case .waitingToPlayAtSpecifiedRate:
                    ShopLiveLogger.tempLog("waitingToPlayAtSpecifiedRate")
                default:
                    ShopLiveLogger.tempLog("other")
                }
            case .avPlayerItemStatus(let status):
                if status == .readyToPlay && delegate?.isCellOnWindow(indexPath : indexPath) ?? false  {
//                    preview.action( .play )
                }
                else {
                    preview.action( .pause )
                }
            case .requestShowAlertController(_):
                break
            case .didChangeCampaignStatus(_):
                break
            case .onError(code: let code, message: let message):
                break
            case .handleCommand(command: let command, payload: let payload):
                break
            case .onSetUserName(payload: let payload):
                break
            case .handleShare(data: let data):
                break
            case .didChangeCampaignInfo(_):
                break
            case .didChangeVideoDimension(_):
                break
            case .handleShopLivePlayerCampaign(_):
                break
            case .handleShopLivePlayerBrand(_):
                break
            }
        }
    }
}
extension ShopLivePreviewSampleCell {
    private func setLayout() {
        self.addSubview(preview)
        preview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            preview.topAnchor.constraint(equalTo: self.topAnchor),
            preview.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            preview.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            preview.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
