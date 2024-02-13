//
//  VideoCardView.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/26/23.
//

import Foundation
import UIKit
import ShopLiveSDKCommon
import AVKit

extension ShopLiveShortform {
    class CardView: SLBaseView, SLShortsCardViewProtocol {
        func play() {}
        func pause() {}
        func stop() {}
        func replay() {}
        func setMute(_ mute: Bool) {}
        func seekTo(time: CMTime) {}
        func setShortsMode(mode: ShortsMode) {}
        func itemRelease() {}
        func getSnapshot(completion: @escaping (UIImage?) -> Void) {}
        func invalidateLayout() { }
        deinit {
            // print("CardView deinit")
        }
    }
}

extension ShopLiveShortform {
    class VideoCardView: CardView {
        
        class ViewModel: NSObject {
            private(set) weak var cardData: VideoCardData?
            
            var card: Card? {
                guard let cardData = cardData else { return nil }
                return Card(videoCardData: cardData)
            }
            
            var video: ShortsVideo? {
                guard let video = cardData?.shortsVideo else { return nil }
                return video
            }
            
            var posterImageURL: URL? {
                guard let posterImage = cardData?.posterImageURL else { return nil }
                return URL(string: posterImage)
            }
            
            var shortsMode: ShopLiveShortform.ShortsMode
            
            var isPlaying: Bool = false
            
            init(cardData: VideoCardData, shortsMode: ShortsMode) {
                self.cardData = cardData
                self.shortsMode = shortsMode
            }
            
            deinit {
                cardData?.shortsVideo = nil
                cardData = nil
                
            }

        }
        
        private var shortsPlayer: ShopLiveShortform.VideoPlayer?
        private let audioRouteObserver = AudioRouteObserver()
        
        private var viewModel: ViewModel
        
        weak var delegate: SLShortsCardViewDelegate?
        
        private lazy var posterImageView: UIImageView = {
            let view = UIImageView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.contentMode = .scaleAspectFill
            view.clipsToBounds = true
            return view
        }()
        
        private lazy var snapshotImageView: UIImageView = {
            let view = UIImageView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .clear
            view.contentMode = .scaleAspectFill
            view.image = nil
            view.isHidden = true
            return view
        }()
        
        init(cardData: VideoCardData, shortsMode: ShortsMode) {
            shortsPlayer = ShopLiveShortform.VideoPlayer()
            viewModel = ViewModel(cardData: cardData, shortsMode: shortsMode)
            super.init(frame: .zero)
            self.backgroundColor = .black
            self.clipsToBounds = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
            self.shortsPlayer?.teardown()
            self.shortsPlayer = nil
        }
        
        override func layout() {
            self.addSubview(posterImageView)
            if let playerView = shortsPlayer?.playerView {
                self.addSubview(playerView)
            }
            self.addSubview(snapshotImageView)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.setIpadLayout()
            }
            else if UIScreen.isLandscape_SL {
                self.setIphoneHorizontalLayout()
            }
            else {
                self.setIphoneVerticalLayout()
            }
        }
        
        
        override func attributes() {
            shortsPlayer?.playerDelegate = self
            audioRouteObserver.delegate = self
        }
        
        override func bindData() {
            if let url = viewModel.posterImageURL {
                ImageDownLoaderManager.shared.download(imageUrl: url) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let imageData):
                        self.posterImageView.image = UIImage(data: imageData)
                    case .failure(_):
                        self.posterImageView.image = nil
                        break
                    }
                }
            }
            else {
                self.posterImageView.image = nil
            }
            guard let video = viewModel.video else { return }
            shortsPlayer?.setShortsVideo(video: video)
        }
        
        override func bindView() {
            
        }
        
        override func getSnapshot(completion: @escaping (UIImage?) -> Void) {
            self.shortsPlayer?.snapShot(completion: { image in
                completion(image)
            })
        }
        
        func showSnapshotBackground() {
            self.shortsPlayer?.snapShot(completion: { [weak self] image in
                guard let self = self else { return }
                self.snapshotImageView.image = image
                self.snapshotImageView.isHidden = false
            })
        }
        
        func hideSnapshotBackground() {
            self.snapshotImageView.isHidden = true
        }
        
        override func play() {
            if viewModel.shortsMode == .preview { setMute(true) }
            shortsPlayer?.play()
        }
        
        override func pause() {
            shortsPlayer?.pause()
        }
        
        override func replay() {
            if viewModel.shortsMode == .preview { setMute(true) }
            shortsPlayer?.replay()
        }
        
        override func stop() {
            viewModel.isPlaying = false
            shortsPlayer?.stop()
        }
        
        override func seekTo(time: CMTime) {
            shortsPlayer?.seekTo(time: time)
        }
        
        override func setShortsMode(mode: ShopLiveShortform.ShortsMode) {
            viewModel.shortsMode = mode
        }
        
        override func setMute(_ mute: Bool) {
            shortsPlayer?.setMute(mute)
        }
        
        func getVideoDuration() -> Float64? {
            return self.shortsPlayer?.videoDuration
        }
        
        func getCurrentTime() -> Double? {
            return self.shortsPlayer?.getCurrentTime()
        }
        
        override func itemRelease() {
            
        }

        override func invalidateLayout(){
            self.posterImageView.image = nil
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.setIpadLayout()
            }
            else if UIScreen.isLandscape_SL {
                self.setIphoneHorizontalLayout()
            }
            else {
                self.setIphoneVerticalLayout()
            }
            DispatchQueue.main.async { [weak self] in
                self?.setNeedsLayout()
            }
        }
    }
}
extension ShopLiveShortform.VideoCardView {
    
    private func setIpadLayout(){
        removeConstraints()
        let resolution = ShortFormConfigurationInfosManager.shared.shortsConfiguration.resolution
        NSLayoutConstraint.activate([
            posterImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0),
            posterImageView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: resolution.width/resolution.height),
            posterImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            posterImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            snapshotImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0),
            snapshotImageView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: resolution.width/resolution.height),
            snapshotImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            snapshotImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
        
        guard let playerView = shortsPlayer?.playerView else { return }
        
        NSLayoutConstraint.activate([
            playerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            playerView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: resolution.width/resolution.height),
            playerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            playerView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
    }
    
    private func setIphoneVerticalLayout(){
        removeConstraints()
        NSLayoutConstraint.activate([
            posterImageView.heightAnchor.constraint(equalTo: self.heightAnchor),
            posterImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            snapshotImageView.heightAnchor.constraint(equalTo: self.heightAnchor),
            snapshotImageView.widthAnchor.constraint(equalTo: self.heightAnchor),
            snapshotImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            snapshotImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        guard let playerView = shortsPlayer?.playerView else { return }
        
        NSLayoutConstraint.activate([
            playerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            playerView.widthAnchor.constraint(equalTo: self.widthAnchor),
            playerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            playerView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
        
    }
    
    private func setIphoneHorizontalLayout(){
        removeConstraints()
        let resolution = ShortFormConfigurationInfosManager.shared.shortsConfiguration.resolution
        NSLayoutConstraint.activate([
            posterImageView.heightAnchor.constraint(equalTo: self.heightAnchor),
            posterImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            posterImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            posterImageView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: resolution.width / resolution.height),
            
            
            snapshotImageView.heightAnchor.constraint(equalTo: self.heightAnchor),
            snapshotImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            snapshotImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            snapshotImageView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: resolution.width / resolution.height)
        ])
        
        guard let playerView = shortsPlayer?.playerView else { return }
        NSLayoutConstraint.activate([
            playerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            playerView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: resolution.width/resolution.height),
            playerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            playerView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
    }
    
    private func removeConstraints(){
        snapshotImageView.constraints.forEach { constraints in
            constraints.isActive = false
        }
        snapshotImageView.removeConstraints(snapshotImageView.constraints)
        
        posterImageView.constraints.forEach { constraints in
            constraints.isActive = false
        }
        posterImageView.removeConstraints(posterImageView.constraints)
        
        guard let playerView = shortsPlayer?.playerView else { return }
        playerView.constraints.forEach { constraints in
            constraints.isActive = false
        }
        playerView.removeConstraints(playerView.constraints)
    }

}
extension ShopLiveShortform.VideoCardView {
    
}
extension ShopLiveShortform.VideoCardView: SLShortsVideoPlayerDelegate {
    
    func onVideoTimeUpdated(time: Float64) {
        guard let videoUrl = viewModel.video?.videoUrl.absoluteString else { return }
        delegate?.onVideoTimeUpdated(time: time, videoUrl: videoUrl)
    }
    
    func handlePlayerItemStatus(_ status: AVPlayerItem.Status) {
        switch status {
        case .unknown:
            //NSLog("handlePlayerItemStatus unknown")
            break
        case .readyToPlay:
            //NSLog("handlePlayerItemStatus readyToPlay")
            if let duration = shortsPlayer?.videoDuration,
               let videoUrl = viewModel.video?.videoUrl.absoluteString {
                delegate?.onVideoDurationChanged(duration: duration, videoUrl: videoUrl)
            }
            
            self.shortsPlayer?.snapShot(completion: { [weak self] image in
                guard let self = self else { return }
                self.snapshotImageView.image = image
            })
            
            guard let card = viewModel.card else { return }
            delegate?.readyToPlay(card: card)
            break
        case .failed:
            //NSLog("handlePlayerItemStatus failed")
            break
        @unknown default:
            break
        }
    }
    
    func handleTimeControlStatus(_ status: AVPlayer.TimeControlStatus) {
        switch status {
        case .paused:
            guard let videoUrl = viewModel.video?.videoUrl.absoluteString else { return }
            delegate?.onChangedShortsItemPlayStatus(status: .paused, videoUrl: videoUrl)
            break
        case .playing:
            hideSnapshotBackground()
            viewModel.isPlaying = true
            guard let videoUrl = viewModel.video?.videoUrl.absoluteString else { return }
            delegate?.onChangedShortsItemPlayStatus(status: .playing, videoUrl: videoUrl)
            break
        case .waitingToPlayAtSpecifiedRate:
            if self.shortsPlayer?.playerView?.getCurrentTime() ?? 0.0 == 0 {
                showSnapshotBackground()
            }
            guard let videoUrl = viewModel.video?.videoUrl.absoluteString else { return }
            break
        @unknown default:
            break
        }
    }
    
    func handleDidPlayToEndTime(video: ShopLiveShortform.ShortsVideo?) {
        guard let card = viewModel.card else { return }
        delegate?.didFinishPlaying(card: card)
    }
}

extension ShopLiveShortform.VideoCardView: SLShortsAudioRouteObserverDelegate {
    func handleInterruption(type: SLShortsAudioInterruptionType) {
        // 재생중이였으면 인터럽트 이벤트 처리.
        /*
        // print("handleHeadPhoneStatus \(type)")
        switch type {
        case .begin:
            shortformPlayer.pause()
            break
        case .ended:
            shortformPlayer.play()
            break
        }
         */
    }
    
    func handleHeadPhoneStatus(plugged: Bool) {
        // 재생중이였으면 헤드폰/이어폰 plugged 이벤트 처리
        /*
        // print("handleHeadPhoneStatus \(plugged)")
        plugged ? shortformPlayer.play() : shortformPlayer.pause()
         */
    }
}

