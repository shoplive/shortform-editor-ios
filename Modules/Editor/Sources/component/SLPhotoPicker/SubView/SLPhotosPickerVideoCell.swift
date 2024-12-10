//
//  SLPhotosPickerVideoCell.swift
//  CustomImagePicker
//
//  Created by sangmin han on 5/3/24.
//

import Foundation
import UIKit



class SLPhotosPickerVideoCell : UICollectionViewCell {
    private let design = ShopLiveShortformEditor.MediaPickerConfig.global
    
    static let cellId = "slphotosPickerVideoCellId"
    lazy private var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .init(red: 51, green: 51, blue: 51 )
        imageView.layer.cornerRadius = design.cellCornerRadius
        return imageView
    }()
    
    
    private var durationLabelBackground : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, aa: 0.5)
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        return view
    }()
    private var durationLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.set(size: 11, weight: ._600)
        label.textColor = .white
        label.text = " 0:00 "
        return label
    }()
    
    
    private var cameraIcon : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = ShopLiveShortformEditorSDKAsset.slCamera.image
        return imageView
    }()
    
    private var cameraLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .set(size: 13, weight: ._500)
        label.textColor = .init(white: 1, alpha: 0.4)
        label.text = ShopLiveShortformEditorSDKStrings.Editor.Photo.Picker.Camera.Cell.Btn.title
        return label
    }()
    
    private let cellSpacing : CGFloat = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        
    }
    
    required init(coder : NSCoder?) {
        fatalError()
    }
    
    func configure(image : UIImage?, duration : TimeInterval) {
        self.imageView.image = image
        self.durationLabel.text = timeFormatted(timeInterval: duration)
    }
    
    func setDurationLabelHidden(isHidden : Bool) {
        self.durationLabel.isHidden = isHidden
        self.durationLabelBackground.isHidden = isHidden
    }
    
    func showCameraContents(show : Bool) {
        self.cameraIcon.isHidden = !show
        self.cameraLabel.isHidden = !show
    }
    
    private func timeFormatted(timeInterval: TimeInterval) -> String {
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
}
extension SLPhotosPickerVideoCell {
    private func setLayout() {
        self.addSubview(imageView)
        self.addSubview(durationLabelBackground)
        self.addSubview(durationLabel)
        
        
        self.addSubview(cameraIcon)
        self.addSubview(cameraLabel)
        
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -cellSpacing),
            
            
            durationLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -10),
            durationLabel.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor,constant: -10),
            durationLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            durationLabel.heightAnchor.constraint(equalToConstant: 18),
            
            
            durationLabelBackground.centerYAnchor.constraint(equalTo: durationLabel.centerYAnchor),
            durationLabelBackground.heightAnchor.constraint(equalTo: durationLabel.heightAnchor, multiplier: 1),
            durationLabelBackground.leadingAnchor.constraint(equalTo: durationLabel.leadingAnchor,constant: -8),
            durationLabelBackground.trailingAnchor.constraint(equalTo: durationLabel.trailingAnchor, constant: 8),
            
            
            cameraIcon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            cameraIcon.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            cameraIcon.widthAnchor.constraint(equalToConstant: 30),
            cameraIcon.heightAnchor.constraint(equalToConstant: 30),
            
            cameraLabel.topAnchor.constraint(equalTo: cameraIcon.bottomAnchor, constant: 2),
            cameraLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            cameraLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            cameraLabel.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    
    
}
