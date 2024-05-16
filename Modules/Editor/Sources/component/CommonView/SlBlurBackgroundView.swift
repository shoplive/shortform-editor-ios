//
//  SlBlurBackgroundView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/8/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit


class SlBlurBackgroundView : UIView {
    
    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    lazy var blurEffectView = UIVisualEffectView(effect: blurEffect)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
}
