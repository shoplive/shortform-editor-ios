//
//  CardViewInterface.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/26/23.
//

import Foundation

protocol SLShortsCardViewProtocol {
    func play()
    func pause()
    func replay()
}

protocol SLShortsCardViewDelegate: AnyObject {
    func onChangedShortsItemPlayStatus(status: ShopLiveShortform.ItemPlayStatus, videoUrl: String)
    func readyToPlay(card: ShopLiveShortform.Card)
    func didFinishPlaying(card: ShopLiveShortform.Card)
    func onVideoTimeUpdated(time: Float64, videoUrl: String)
    func onVideoDurationChanged(duration: Float64, videoUrl: String)
}

extension ShopLiveShortform {
    enum ItemPlayStatus{
        case playing
        case paused
    }
}
