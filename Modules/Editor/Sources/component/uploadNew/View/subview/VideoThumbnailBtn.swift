//
//  VideoThumbnailBtn.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/6/23.
//

import Foundation
import UIKit



class VideoThumbnailBtn : UIButton {
    
    lazy private var playIcon : UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
//        let bundle = Bundle(for: type(of: self))
//        imgView.image = UIImage(named: "sl_playpreview", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        imgView.image = ShopLiveShortformEditorSDKAsset.slPlaypreview.image
        return imgView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        
    }
    
    required init(coder : NSCoder) {
        fatalError()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchRect = self.bounds
        
        if touchRect.contains(point) {
            return self
        }
        else {
            return super.hitTest(point, with: event)
        }
    }
    
}
extension VideoThumbnailBtn {
    private func setLayout() {
        self.addSubview(playIcon)
        
        NSLayoutConstraint.activate([
            playIcon.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            playIcon.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
            playIcon.widthAnchor.constraint(equalToConstant: 30),
            playIcon.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
}
