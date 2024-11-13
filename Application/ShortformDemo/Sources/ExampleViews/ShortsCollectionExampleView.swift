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
   
    private var backBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .black
        btn.setTitle("back", for: .normal)
        return btn
    }()
    
    private var btn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .black
        btn.setTitle("next", for: .normal)
        return btn
    }()

    lazy var shortsCollectionView : ShopLiveShortsCollectionView = {
        let view = ShopLiveShortsCollectionView(requestData: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setLayout()
        
        backBtn.addTarget(self, action: #selector(backBtnTapped), for: .touchUpInside)
        btn.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
    }
    
    
    @objc
    private func backBtnTapped() {
        if self.navigationController?.viewControllers.count == 1 {
            self.dismiss(animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc
    private func nextBtnTapped() {
        let vc = ShortsCollectionExampleView()
        self.navigationController?.pushViewController(vc, animated: true)
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
        self.view.addSubview(btn)
        self.view.addSubview(backBtn)
        
        NSLayoutConstraint.activate([
            
            backBtn.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            backBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            backBtn.widthAnchor.constraint(equalToConstant: 50),
            backBtn.heightAnchor.constraint(equalToConstant: 50),
            
            btn.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            btn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            btn.widthAnchor.constraint(equalToConstant: 50),
            btn.heightAnchor.constraint(equalToConstant: 50),
            
            shortsCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor,constant: 60),
            shortsCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            shortsCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            shortsCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}
