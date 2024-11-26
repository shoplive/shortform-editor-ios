//
//  ShopLivePreviewTestView.swift
//  PlayerDemo
//
//  Created by sangmin han on 9/9/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopLiveSDK
import ShopliveSDKCommon




class ShopLivePreviewSampleView : UIViewController {
    
   
    lazy private var cv : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(ShopLivePreviewSampleCell.self, forCellWithReuseIdentifier: "cellId")
        cv.isPagingEnabled = true
        return cv
    }()
    
    private var playOnLaunch : Bool = true
    
    private var accessKey : String = ""
    private var campaignKey : String = ""
    
    init(accessKey : String, campaignkey : String) {
        super.init(nibName: nil, bundle: nil)
        self.accessKey = accessKey
        self.campaignKey = campaignkey
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setLayout()
        
        
        
    }
    
}
extension ShopLivePreviewSampleView {
    private func setLayout() {
        self.view.addSubview(cv)
        
        NSLayoutConstraint.activate([
            cv.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            cv.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            cv.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            cv.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}
extension ShopLivePreviewSampleView : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ShopLivePreviewSampleCellDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! ShopLivePreviewSampleCell
        
        cell.setPreview(accessKey: accessKey, campaignKey: campaignKey)

        cell.delegate = self
        cell.indexPath = indexPath
        return cell
    }        

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: collectionView.frame.height - 40 )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ShopLivePreviewSampleCell else { return } 
        cell.pause()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yContentOffset = scrollView.contentOffset.y
        let currentIndex = Int((yContentOffset) / scrollView.frame.height)
        for cell in cv.visibleCells as! [ShopLivePreviewSampleCell] {
            if let indexPath = cell.indexPath, indexPath.row == currentIndex {
                cell.play()
            }
            else {
                cell.pause()
            }
        }
    }
    
    func isCellOnWindow(indexPath : IndexPath?) -> Bool {
        guard let indexPath = indexPath else {
            return false
        }
        let yContentOffset = cv.contentOffset.y
        let currentIndex = Int((yContentOffset) / cv.frame.height)
        if currentIndex == indexPath.row {
            return true 
        }
        else {
            return false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let yContentOffset = scrollView.contentOffset.y
        let currentIndex = Int((yContentOffset) / scrollView.frame.height)
        for cell in cv.visibleCells as! [ShopLivePreviewSampleCell] {
            if let indexPath = cell.indexPath, indexPath.row == currentIndex {
                cell.play()
            }
            else {
                cell.pause()
            }
        }
    }
    
}
