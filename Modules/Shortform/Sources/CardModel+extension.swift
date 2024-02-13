//
//  CardModel+extension.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/27/23.
//

import Foundation

extension CardModel {
    func getCard(shortsMode: ShopLiveShortform.ShortsMode) -> ShopLiveShortform.Card? {
        guard let type = self.cardType else { return nil }
        
        guard let cardType = ShopLiveShortform.CardType(rawValue: type) else { return nil }
        
        switch cardType {
        case .video:
            var videoDataUrl: String = ""
            if let videoUrlStr = self.videoUrl {
                videoDataUrl = videoUrlStr
            }
            guard let videoUrl = URL(string: videoDataUrl) else { return nil }
            let videoData = ShopLiveShortform.VideoCardData(shortsVideo: ShopLiveShortform.ShortsVideo(videoUrl: videoUrl), posterImageURL: self.screenshotUrl ?? "")
            return .VideoCard(video: videoData)
        case .image:
            return nil
        }
    }
}
