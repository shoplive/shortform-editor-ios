//
//  SLPhotoCollectionViewCell.swift
//  SLPhotosPicker
//
//  Created by wade.hawk on 2017. 5. 3..
//  Copyright © 2017년 wade.hawk. All rights reserved.
//

import UIKit
import PhotosUI
import ShopLiveSDKCommon

open class SLPlayerView: UIView {
    @objc open var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    @objc open var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override open class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

open class SLPhotoCollectionViewCell: UICollectionViewCell {
    private var observer: NSObjectProtocol?
    @IBOutlet open var imageView: UIImageView?
    @IBOutlet open var playerView: SLPlayerView?
    @IBOutlet open var livePhotoView: PHLivePhotoView?
    @IBOutlet open var liveBadgeImageView: UIImageView?
    @IBOutlet open var durationView: UIView?
    @IBOutlet open var durationLabel: UILabel?
    @IBOutlet open var indicator: UIActivityIndicatorView?
    @IBOutlet open var selectedView: UIView?
    @IBOutlet open var selectedHeight: NSLayoutConstraint?
    @IBOutlet open var orderLabel: UILabel?
    @IBOutlet open var orderBgView: UIView?
    
    var configure = SLPhotosPickerConfigure() {
        didSet {
            self.selectedView?.layer.borderColor = self.configure.selectedColor.cgColor
            self.orderBgView?.backgroundColor = self.configure.selectedColor
            self.orderBgView?.isHidden = self.configure.singleSelectedMode
            self.orderLabel?.isHidden = self.configure.singleSelectedMode
        }
    }
    
    open internal(set) var asset: PHAsset?
    
    @objc open var isCameraCell = false
    
    open var duration: TimeInterval? {
        didSet {
            guard let duration = self.duration else { return }
            self.selectedHeight?.constant = -10
            self.durationLabel?.text = timeFormatted(timeInterval: duration)
        }
    }
    
    @objc open var selectedAsset: Bool = false {
        willSet(newValue) {
//            self.selectedView?.isHidden = !newValue
//            self.durationView?.backgroundColor = newValue ? self.configure.selectedColor : UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            if !newValue {
                self.orderLabel?.text = ""
            }
        }
    }
    
    @objc open func timeFormatted(timeInterval: TimeInterval) -> String {
        let seconds: Int = Int(timeInterval)
        var hour: Int = 0
        var minute: Int = Int(seconds/60)
        let second: Int = seconds % 60
        if minute > 59 {
            hour = minute / 60
            minute = minute % 60
            return String(format: "%d:%d:%02d", hour, minute, second)
        } else {
            return String(format: "%d:%02d", minute, second)
        }
    }
    
    @objc open func popScaleAnim() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
    }
    
    @objc open func update(with phAsset: PHAsset) {
        
    }
    
    @objc open func selectedCell() {
        
    }
    
    @objc open func willDisplayCell() {
        
    }
    
    @objc open func endDisplayingCell() {
        
    }
    
    deinit {
//        print("deinit SLPhotoCollectionViewCell")
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.imageView?.translatesAutoresizingMaskIntoConstraints = false
        self.imageView?.clipsToBounds = true
        
        self.playerView?.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.livePhotoView?.isHidden = true
        self.durationView?.isHidden = true
        self.durationView?.layer.cornerRadius = 7
        self.selectedView?.isHidden = true
        self.selectedView?.layer.borderWidth = 10
        self.selectedView?.layer.cornerRadius = 15
        self.orderBgView?.layer.cornerRadius = 2
        if #available(iOS 11.0, *) {
            self.imageView?.accessibilityIgnoresInvertColors = true
            self.playerView?.accessibilityIgnoresInvertColors = true
            self.livePhotoView?.accessibilityIgnoresInvertColors = true
        }
        
        self.layer.cornerRadius = 6
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        self.durationView?.isHidden = true
        self.durationView?.backgroundColor = .white//UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        self.selectedHeight?.constant = 10
        self.selectedAsset = false
        self.updateImage()
    }
    
    
    lazy private var fullTypeImageViewConstraints : [NSLayoutConstraint] = {
        guard let imageView = self.imageView else { return [] }
        let leading = imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0)
        let trailing = imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
        let top = imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
        let bottom = imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        return [leading,trailing,top,bottom]
    }()
    
    lazy private var cameraCellImageViewConstraints : [NSLayoutConstraint] = {
        guard let imageView = self.imageView else { return [] }
         let centx = imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0)
         let centy = imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
         let widthA = imageView.widthAnchor.constraint(equalToConstant: 35)
         let heightA = imageView.heightAnchor.constraint(equalToConstant: 35)
        return [centx,centy,widthA,heightA]
    }()
    
    open func updateImage() {
        self.imageView?.clearConstraints_SL()
        if self.isCameraCell {
            self.backgroundColor = UIColor(red: 225/255, green: 227/255, blue: 230/255, alpha: 1.0)
            NSLayoutConstraint.activate(cameraCellImageViewConstraints)
            NSLayoutConstraint.deactivate(fullTypeImageViewConstraints)
            self.imageView?.contentMode = .scaleAspectFit
        }
        else {
            NSLayoutConstraint.deactivate(cameraCellImageViewConstraints)
            NSLayoutConstraint.activate(fullTypeImageViewConstraints)
            self.imageView?.contentMode = .scaleToFill
        }
    }
}
