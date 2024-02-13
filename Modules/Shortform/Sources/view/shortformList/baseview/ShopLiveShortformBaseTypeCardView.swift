//
//  ShopLiveShortformBaseTypeCardView.swift
//  matrix-shortform-ios
//
//  Created by sangmin han on 2023/04/28.
//

import Foundation
import UIKit
import AVFoundation
import ShopLiveSDKCommon



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
        let imageView = UIImageView(image: UIImage(named: "sl_ic_media_filled",in: bundle, compatibleWith: nil))
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
        let imageView = UIImageView(image: UIImage(named: "sl_ic_person",in: bundle, compatibleWith: nil))
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
    
    private var posterImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .init("#CBCBCB")
        return imageView
    }()
    
    
    private weak var delegate : ShopLiveShortformBaseTypeCardViewDelegate?
    private var playIconLeftTopPadding : CGFloat = 8
    
    init(frame: CGRect,delegate : ShopLiveShortformBaseTypeCardViewDelegate,playIconLeftTopPadding : CGFloat) {
        super.init(frame: frame)
        self.delegate = delegate
        self.clipsToBounds = true
        self.playIconLeftTopPadding = playIconLeftTopPadding
        setLayout()
    }
    
    
    required init?(coder : NSCoder){
        fatalError()
    }
    
    func setContents(viewCount : String, posterImageUrl : String?, videoUrl : String?, currentMediaType : String, viewHideOption : ShopLiveListCellViewHideOptionModel,cornerRadius : CGFloat,backgroundColor : UIColor? ){
        
        var bgColor : UIColor = .init("#CBCBCB")
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
        self.videoPlayer.isHidden = !(currentMediaType == "VIDEO")
        self.videoPlayer.refreshPlayer()
        self.videoPlayer.setVideoUrl(urlString: videoUrl)
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
        videoPlayer.pause()
    }
    
    func playVideo(){
        if videoPlayer.getIsReadyToPlay() == false { return }
        videoPlayer.start()
    }
    
    func refreshPlayer(){
        videoPlayer.refreshPlayer()
    }
}
extension ShopLiveShortformBaseTypeCardView {
    private func setLayout(){
        self.addSubview(videoPlayer)
        self.addSubview(posterImageView)
        self.addSubview(playIcon)
        self.addSubview(viewCountBackground)
        viewCountBackground.addSubview(personIcon)
        viewCountBackground.addSubview(viewCountLabel)
        
        NSLayoutConstraint.activate([
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
        UIView.animate(withDuration: 1) { [weak self] in
            self?.posterImageView.alpha = 1
        }
        delegate?.onCardViewError(error: error)
    }
    func onPlayerChangedToCacheFile() {
        self.posterImageView.alpha = 1
        UIView.animate(withDuration: 0.5) { [weak self] in 
            self?.posterImageView.alpha = 0
        }
    }
    
    func onPlayerDidStartPlaying() {
        if self.posterImageView.alpha == 0 { return }
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.posterImageView.alpha = 0
        }
    }
}
