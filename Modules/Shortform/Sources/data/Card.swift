//
//  Card.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/24/23.
//

import Foundation

extension ShopLiveShortform {
    
    class VideoCardData {
        var shortsVideo: ShortsVideo?
        var posterImageURL: String
        
        init(shortsVideo: ShortsVideo, posterImageURL: String) {
            self.shortsVideo = shortsVideo
            self.posterImageURL = posterImageURL
        }
        
        deinit {
            // print("VideoCardData deinit")
            shortsVideo = nil
        }
        
        var validate: Bool {
            guard let videoUrl = shortsVideo?.videoUrl.absoluteString else { return false }
            return !videoUrl.isEmpty
        }
    }
    
    class ImageCardData {
        var imageUrl: URL
        
        init(imageUrl: URL) {
            self.imageUrl = imageUrl
        }
        
        var validate: Bool {
            !self.imageUrl.absoluteURL.absoluteString.isEmpty
        }
    }
    
    enum CardType: String {
        case video = "VIDEO"
        case image = "IMAGE"
    }
    
    enum Card: Equatable {
        case VideoCard(video: VideoCardData)
        case ImageCard(image: ImageCardData)
        
        var type: CardType {
            switch self {
            case .VideoCard:
                return .video
            case .ImageCard:
                return .image
            }
        }
        
        init(videoCardData: VideoCardData) {
            self = .VideoCard(video: videoCardData)
        }
        
        init(imageCardData: ImageCardData) {
            self = .ImageCard(image: imageCardData)
        }
        
        static func ==(lhs: Card, rhs: Card) -> Bool {
            switch (lhs, rhs) {
            case (.VideoCard(let leftData), .VideoCard(let rightData)):
                return (leftData.shortsVideo?.videoUrl == rightData.shortsVideo?.videoUrl && leftData.posterImageURL == rightData.posterImageURL)
            case (.VideoCard, .ImageCard), (.ImageCard, .VideoCard):
                return false
            case (.ImageCard(let leftImage), .ImageCard(let rightImage)):
                return (leftImage.imageUrl == rightImage.imageUrl)
            }
        }
        
        func validate() -> Bool {
            switch self {
            case .ImageCard(let _):
                return false
            case .VideoCard(let video):
                // print("Card validate \(video.validate)")
                return video.validate
            }
        }
    }
}
