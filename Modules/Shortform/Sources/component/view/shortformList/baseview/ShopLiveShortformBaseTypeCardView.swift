//
//  ShopLiveShortformBaseTypeCardView.swift
//  matrix-shortform-ios
//
//  Created by sangmin han on 2023/04/28.
//

import Foundation
import UIKit
import AVFoundation
import ShopliveSDKCommon



protocol ShopLiveShortformBaseTypeCardViewDelegate : NSObject {
    func onCardViewError(error : Error)
}
/**
 숏폼 목록뷰 셀 기본 바탕 뷰
 시청자 수, 포스터 이미지, 비디오 레이어 함유
 */
class ShopLiveShortformBaseTypeCardView : UIView {
    
    
    lazy private var playIcon : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        let bundle = Bundle(for: type(of: self))
        let imageView = UIImageView(image: ShopLiveShortformSDKAsset.slIcMediaFilled.image)
        imageView.contentMode = .scaleAspectFit
        let stack = UIStackView(arrangedSubviews: [imageView])
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        self.matchParent(child: stack, parent: view)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return view
    }()
    
    private var viewCountBackground : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.dim_black_60
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy private var personIcon : UIImageView = {
        let bundle = Bundle(for: type(of: self))
        let imageView = UIImageView(image: ShopLiveShortformSDKAsset.slIcPerson.image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    private var viewCountLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.set(size: 12, weight: ._400)
        label.text = "123.12"
        return label
    }()
    
    lazy private var videoPlayer : ShopLiveShortformBaseTypePlayerView = {
        let view = ShopLiveShortformBaseTypePlayerView(frame: .zero, delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private var youtubePlayer : ShopLiveShortformBaseTypeYTPlayerView = {
        let view = ShopLiveShortformBaseTypeYTPlayerView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var posterImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .init(sl_hex: "#CBCBCB")
        return imageView
    }()
    
    
    private weak var delegate : ShopLiveShortformBaseTypeCardViewDelegate?
    private var playIconLeftTopPadding : CGFloat = 8
    private var indexPath : IndexPath?
    private var reservePlayOnInitialLoad : Bool = false
    
    init(frame: CGRect,delegate : ShopLiveShortformBaseTypeCardViewDelegate,playIconLeftTopPadding : CGFloat) {
        super.init(frame: frame)
        bindYoutubePlayer()
        self.delegate = delegate
        self.clipsToBounds = true
        self.playIconLeftTopPadding = playIconLeftTopPadding
        setLayout()
    }
    
    
    required init?(coder : NSCoder){
        fatalError()
    }
    
    func setContents(viewCount : String, posterImageUrl : String?, videoUrl : String?, youtubeWebView : SLWebView?, currentMediaType : String, viewHideOption : ShopLiveListCellViewHideOptionModel,cornerRadius : CGFloat,backgroundColor : UIColor?, currentSrn : String?, indexPath : IndexPath ){
        self.indexPath = indexPath
        self.reservePlayOnInitialLoad = false
        videoPlayer.setIndexPath(indexPath: indexPath)
        var bgColor : UIColor = .init(sl_hex: "#CBCBCB")
        if let backgroundColor = backgroundColor {
            bgColor = backgroundColor
        }
        
        self.backgroundColor = bgColor
        self.layer.cornerRadius = cornerRadius
        self.playIcon.isHidden = viewHideOption.isViewCountVisible ? false : true
        self.viewCountLabel.isHidden = viewHideOption.isViewCountVisible ? false : true
        self.viewCountBackground.isHidden = viewHideOption.isViewCountVisible ? false : true
        self.personIcon.isHidden = viewHideOption.isViewCountVisible ? false : true
        
        self.viewCountLabel.text = viewCount
        if let videoUrl = videoUrl {
            self.videoPlayer.isHidden = !(currentMediaType == "VIDEO")
            self.videoPlayer.refreshPlayer()
            self.videoPlayer.setVideoUrl(urlString: videoUrl)
            self.videoPlayer.isHidden = false
            
            self.youtubePlayer.action( .emptyWebView )
            self.youtubePlayer.isHidden = true
            
        }
        else if let youtubeWebView = youtubeWebView {
            self.videoPlayer.refreshPlayer()
            self.videoPlayer.isHidden = true
            
            self.youtubePlayer.action( .setCurrentSrn( currentSrn ) )
            
            self.youtubePlayer.action( .setWebView(youtubeWebView) )
            self.youtubePlayer.isHidden = false
        }
        
        self.posterImageView.image = nil
        if let urlString = posterImageUrl, let url = URL(string: urlString) {
            ImageDownLoaderManager.shared.download(imageUrl: url) { [weak self] result  in
                guard let self = self else { return }
                switch result {
                case .success(let imageData):
                    self.posterImageView.backgroundColor = .clear
                    self.posterImageView.image = UIImage(data: imageData)
                case .failure(let error):
                    self.posterImageView.backgroundColor = bgColor
                    break
                }
            }
        }
    }
    
    func stopVideo(){
        self.posterImageView.alpha = 1
        if videoPlayer.isHidden == true && youtubePlayer.isHidden == false {
            youtubePlayer.action(.pause)
        }
        else {
            videoPlayer.pause()
        }
        
    }
    
    func playVideo(){
        if videoPlayer.isHidden == true && youtubePlayer.isHidden == false {
            self.youtubePlayer.action( .play )
        }
        else {
            if videoPlayer.getIsReadyToPlay() == false {
                return
            }
            videoPlayer.start()
        }
    }
    
    func playVideoOnInitialLoad() {
        if videoPlayer.isHidden == true && youtubePlayer.isHidden == false {
            self.youtubePlayer.action( .play )
        }
        else {
            if videoPlayer.getIsReadyToPlay() == false {
                self.reservePlayOnInitialLoad = true
                return
            }
            videoPlayer.start()
        }
    }
    
    func refreshPlayer(){
        videoPlayer.refreshPlayer()
        youtubePlayer.action( .emptyWebView )
    }
    
    private func animateHideOrShowPosterImage(hide : Bool,duration : Double = 1) {
        if hide {
            if self.posterImageView.alpha == 0 { return }
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn) { [weak self] in
                self?.posterImageView.alpha = 0
            }
        }
        else {
            UIView.animate(withDuration: 1) { [weak self] in
                self?.posterImageView.alpha = 1
            }
        }
    }
    
    func setVideoCache(originUrl : String, cacheUrl : URL) {
        videoPlayer.setVideoCache(originUrl: originUrl, cacheUrl: cacheUrl)
    }
}
extension ShopLiveShortformBaseTypeCardView {
    private func bindYoutubePlayer() {
        youtubePlayer.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .hidePosterImage(let hide):
                self.onYoutubePlayerHidePosterImage(hide: hide)
            }
        }
    }
    
    private func onYoutubePlayerHidePosterImage(hide : Bool) {
        animateHideOrShowPosterImage(hide: hide)
    }
}
extension ShopLiveShortformBaseTypeCardView {
    private func setLayout(){
        self.addSubview(youtubePlayer)
        self.addSubview(videoPlayer)
        self.addSubview(posterImageView)
        self.addSubview(playIcon)
        self.addSubview(viewCountBackground)
        viewCountBackground.addSubview(personIcon)
        viewCountBackground.addSubview(viewCountLabel)
        
        NSLayoutConstraint.activate([
            youtubePlayer.topAnchor.constraint(equalTo: self.topAnchor),
            youtubePlayer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            youtubePlayer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            youtubePlayer.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            videoPlayer.topAnchor.constraint(equalTo: self.topAnchor),
            videoPlayer.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            videoPlayer.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            videoPlayer.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            posterImageView.topAnchor.constraint(equalTo: self.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            posterImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            playIcon.topAnchor.constraint(equalTo: self.topAnchor,constant: playIconLeftTopPadding),
            playIcon.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: playIconLeftTopPadding),
            playIcon.widthAnchor.constraint(equalToConstant: 20),
            playIcon.heightAnchor.constraint(equalToConstant: 20),
            
            viewCountBackground.centerYAnchor.constraint(equalTo: playIcon.centerYAnchor),
            viewCountBackground.leadingAnchor.constraint(equalTo: playIcon.trailingAnchor,constant: 4),
            viewCountBackground.heightAnchor.constraint(equalToConstant: 20),
//            viewCountBackground.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -16),
            viewCountBackground.trailingAnchor.constraint(equalTo: viewCountLabel.trailingAnchor,constant: 10),
            
            personIcon.centerYAnchor.constraint(equalTo: viewCountBackground.centerYAnchor),
            personIcon.leadingAnchor.constraint(equalTo: viewCountBackground.leadingAnchor,constant: 10),
            personIcon.widthAnchor.constraint(equalToConstant: 10.5),
            personIcon.heightAnchor.constraint(equalToConstant: 10.5),
            
            viewCountLabel.centerYAnchor.constraint(equalTo: viewCountBackground.centerYAnchor),
            viewCountLabel.leadingAnchor.constraint(equalTo: personIcon.trailingAnchor,constant: 4),
            viewCountLabel.heightAnchor.constraint(equalToConstant: 14),
            viewCountLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100)
        ])

    }
    
    private func matchParent(child : UIView, parent : UIView){
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ])
    }
    
    
}
extension ShopLiveShortformBaseTypeCardView : ShopLiveShortformBaseTypePlayerViewDelegate {
    func onPlayerViewError(error: Error) {
        animateHideOrShowPosterImage(hide: false)
        delegate?.onCardViewError(error: error)
    }
    func onPlayerChangedToCacheFile() {
        animateHideOrShowPosterImage(hide: true, duration: 0.5)
    }
    
    func onPlayerDidStartPlaying() {
        animateHideOrShowPosterImage(hide: true)
    }
    
    func onPlayerIsReadyToPlay(isReady: Bool) {
        if isReady && reservePlayOnInitialLoad {
            self.reservePlayOnInitialLoad = false
            self.playVideoOnInitialLoad()
        }
    }
}
