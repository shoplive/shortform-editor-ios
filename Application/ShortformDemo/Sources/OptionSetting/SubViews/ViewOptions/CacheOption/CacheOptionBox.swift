//
//  CacheOptionBox.swift
//  ShortformDemo
//
//  Created by sangmin han on 3/25/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon

class CacheOptionBox : UIView {
    
    private let cacheTypeBox = CacheTypeOptionBox()
    
    private let removeCacheLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        let cacheSize = ShopliveMP4CachingManager.shared.getCachedSize()
        label.text = "MP4 Cache 용량/삭제"
        return label
    }()
    
    private let cacheSizeLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        let cacheSize = ShopliveMP4CachingManager.shared.getCachedSize()
        label.text = "(\(cacheSize ?? "0.0"))"
        return label
    }()
    
    private let removeCacheBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("캐시 삭제", for: .normal)
        btn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
        btn.layer.borderWidth = 1
        btn.tag = 1
        return btn
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        
        
        removeCacheBtn.addTarget(self, action: #selector(removeCacheBtnTapped(sender: )), for: .touchUpInside)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func removeCacheBtnTapped(sender : UIButton) {
        ShopliveMP4CachingManager.shared.removeCaches()
        let cacheSize = ShopliveMP4CachingManager.shared.getCachedSize()
        cacheSizeLabel.text = "(\(cacheSize ?? "0.0"))"
    }
    
    func reloadCacheSize() {
        let cacheSize = ShopliveMP4CachingManager.shared.getCachedSize()
        cacheSizeLabel.text = "(\(cacheSize ?? "0.0"))"
        let type = ShopliveMP4CachingManager.shared.getCurrentCacheType()
        cacheTypeBox.setCacheTypeOnInit(type: type)
    }
}
extension CacheOptionBox {
    private func setLayout() {
        
        let innerCacheStack = UIStackView(arrangedSubviews: [cacheSizeLabel,removeCacheBtn])
        innerCacheStack.translatesAutoresizingMaskIntoConstraints = false
        innerCacheStack.isLayoutMarginsRelativeArrangement = true
        innerCacheStack.layoutMargins = UIEdgeInsets(top: 3, left: 0, bottom: 3, right: 0)
        innerCacheStack.axis = .horizontal
        innerCacheStack.spacing = 10
        
        let cacheStack = UIStackView(arrangedSubviews: [removeCacheLabel, innerCacheStack])
        cacheStack.translatesAutoresizingMaskIntoConstraints = false
        cacheStack.axis = .horizontal
        cacheStack.distribution = .equalSpacing
    
        let stack = UIStackView(arrangedSubviews: [
            cacheTypeBox,
            cacheStack
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        self.addSubview(stack)
        
        NSLayoutConstraint.activate([
            removeCacheBtn.widthAnchor.constraint(equalToConstant: 60),
            cacheStack.heightAnchor.constraint(equalToConstant: 40),
            
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.heightAnchor.constraint(lessThanOrEqualToConstant: 5000),
            
            self.bottomAnchor.constraint(equalTo: stack.bottomAnchor)
        ])
    }
    
    
}
