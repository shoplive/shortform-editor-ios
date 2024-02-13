//
//  SLVideoEditoTrimFrameFooterView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/9/23.
//

import Foundation
import UIKit

class SLVideoEditorFooterView : UICollectionReusableView {
    
    static let viewId = "slvideoeditorfooterviewId"
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
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(image : UIImage){
        self.frameImage.image = image
    }
    
}
extension SLVideoEditorFooterView {
    private func setLayout(){
        self.addSubview(frameImage)
        
        NSLayoutConstraint.activate([
            frameImage.topAnchor.constraint(equalTo: self.topAnchor),
            frameImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            frameImage.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -28),
            frameImage.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
