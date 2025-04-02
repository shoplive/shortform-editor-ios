//
//  SLVideoEditorTrimFrameCell.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/8/23.
//

import Foundation
import UIKit



class SLVideoEditorTrimFrameCell : UICollectionViewCell {
    
    static let cellId = "slvideoEditortrimframcecellId"
    private var frameImage : UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .clear
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        self.backgroundColor = .clear
    }
    
    required init(coder : NSCoder) {
        fatalError()
    }
    
    func setImage(image : UIImage){
        self.frameImage.image = image
    }
}
extension SLVideoEditorTrimFrameCell {
    private func setLayout(){
        self.addSubview(frameImage)
        
        NSLayoutConstraint.activate([
            frameImage.topAnchor.constraint(equalTo: self.topAnchor),
            frameImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            frameImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            frameImage.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}



