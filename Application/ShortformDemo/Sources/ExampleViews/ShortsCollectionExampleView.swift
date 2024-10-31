//
//  ShortsCollectionView.swift
//  ShortformDemo
//
//  Created by sangmin han on 10/31/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopLiveShortformSDK
import ShopliveSDKCommon




class ShortsCollectionExampleView : UIViewController {
   
    
    lazy var shortsCollectionView : ShopLiveShortsCollectionView = {
        let view = ShopLiveShortsCollectionView(requestData: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setLayout()
        
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        shortsCollectionView.action( .onStartRotation(size: size) )
        
        coordinator.animate { [weak self] context in
            self?.shortsCollectionView.action( .onChangingRotation(size: size) )
        } completion: { [weak self] context in
            self?.shortsCollectionView.action( .onFinishedRotation(size: size) )
        }
    }
    
}
extension ShortsCollectionExampleView {
    
    private func setLayout() {
        self.view.addSubview(shortsCollectionView)
        
        NSLayoutConstraint.activate([
            shortsCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            shortsCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            shortsCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            shortsCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}
