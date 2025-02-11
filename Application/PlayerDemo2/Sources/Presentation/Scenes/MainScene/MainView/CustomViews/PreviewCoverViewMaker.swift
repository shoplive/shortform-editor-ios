//
//  PreviewCoverViewMaker.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopLiveSDK

class PreviewCoverViewMaker : NSObject {
    
    var previewViewCoverView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var previewCoverViewTagView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }()
    
    var previewCoverViewTitleView : UIButton = {
        let label = UIButton()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.setTitle(" test title", for: .normal)
        return label
    }()
    
    
    override init() {
        super.init()
        previewCoverViewTitleView.addTarget(self, action: #selector(tapped(sender: )), for: .touchUpInside)
    }
    
    @objc func tapped(sender : UIButton) {
        ShopLive.close(actionType: .onBtnTapped)
    }
    
    func setCustomerPreviewCoverView() {
        previewCoverViewTitleView.addTarget(self, action: #selector(tapped(sender: )), for: .touchUpInside)
        previewViewCoverView.addSubview(previewCoverViewTagView)
        previewViewCoverView.addSubview(previewCoverViewTitleView)
        NSLayoutConstraint.activate([
            previewCoverViewTagView.topAnchor.constraint(equalTo: previewViewCoverView.topAnchor),
            previewCoverViewTagView.trailingAnchor.constraint(equalTo: previewViewCoverView.trailingAnchor),
            previewCoverViewTagView.widthAnchor.constraint(equalToConstant: 70),
            previewCoverViewTagView.heightAnchor.constraint(equalToConstant: 30),
            
            
            previewCoverViewTitleView.bottomAnchor.constraint(equalTo: previewViewCoverView.bottomAnchor),
            previewCoverViewTitleView.leadingAnchor.constraint(equalTo: previewViewCoverView.leadingAnchor),
            previewCoverViewTitleView.trailingAnchor.constraint(equalTo: previewViewCoverView.trailingAnchor),
            previewCoverViewTitleView.heightAnchor.constraint(equalToConstant: 40),
            
        ])
        ShopLive.addSubViewToPreview(subView: previewViewCoverView)
    }
    
    
    
    

}
