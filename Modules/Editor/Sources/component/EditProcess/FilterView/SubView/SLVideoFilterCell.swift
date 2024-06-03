//
//  SLVideoFilterCell.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/13/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveFilterSDK
import GLKit
import ShopliveSDKCommon


class SLVideoFilterCell : UICollectionViewCell {
    private let design = EditorFilterConfig.global
    
    static let cellId = "slvideofiltercellId"
    
    lazy private var placeHolderImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = design.filterCellCornerRadius
        return imageView
    }()
    
    
    lazy private var glkView : GLKView = {
        let view = GLKView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = design.filterCellCornerRadius
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.clearsContextBeforeDrawing = true
        view.enableSetNeedsDisplay = true
        view.backgroundColor = .clear
        return view
    }()
    
    
    lazy private var selectedBorderView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 2
        view.layer.borderColor = design.selectedCellBorderColor.cgColor
        view.layer.cornerRadius = design.filterCellCornerRadius
        view.backgroundColor = .clear
        return view
    }()
    
    private var filterNameLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = .set(size: 13, weight: ._500)
        label.textColor = .white
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    
    lazy private var glkImageViewHandler = ShopliveFilterSDKImageViewHandler(glkView: glkView)
    
    private var filterConfig : String = ""
    private var isInitialzed : Bool = false
    private var thumbNailImage : UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
    }
    
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    func configure(filterConfig : String,isSelected : Bool, thumbNail : UIImage?) {
        isInitialzed = false
        self.thumbNailImage = thumbNail
        self.filterConfig = filterConfig
        placeHolderImageView.image = thumbNail
        self.selectedBorderView.isHidden = isSelected ? false : true
    }
    
    func setCellSelected(isSelected : Bool) {
        self.selectedBorderView.isHidden = isSelected ? false : true
    }
    
    func setfilterName(filterName : String) {
        self.filterNameLabel.text = filterName
    }
    func drawGLKView() {
        guard isInitialzed == false else { return }
        guard let thumbNailImage = thumbNailImage else { return }
        
        isInitialzed = true
        glkImageViewHandler?.clear()
        glkImageViewHandler = ShopliveFilterSDKImageViewHandler(glkView: glkView,with: thumbNailImage)
        glkImageViewHandler?.setViewDisplayMode(ShopliveFilterSDKImageViewDisplayModeAspectFill)
        glkImageViewHandler?.setFilterWithConfig(filterConfig)
    }
    
}
extension SLVideoFilterCell {
    private func setLayout() {
        self.addSubview(placeHolderImageView)
        self.addSubview(glkView)
        self.addSubview(selectedBorderView)
        self.addSubview(filterNameLabel)
        glkImageViewHandler?.setViewDisplayMode(ShopliveFilterSDKImageViewDisplayModeAspectFill)
        
        
        NSLayoutConstraint.activate([
            placeHolderImageView.widthAnchor.constraint(equalToConstant: 71),
            placeHolderImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
            placeHolderImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            placeHolderImageView.heightAnchor.constraint(equalToConstant: 71),
            
            glkView.widthAnchor.constraint(equalToConstant: 71),
            glkView.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
            glkView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            glkView.heightAnchor.constraint(equalToConstant: 71),
            
            selectedBorderView.topAnchor.constraint(equalTo: glkView.topAnchor),
            selectedBorderView.leadingAnchor.constraint(equalTo: glkView.leadingAnchor),
            selectedBorderView.trailingAnchor.constraint(equalTo: glkView.trailingAnchor),
            selectedBorderView.bottomAnchor.constraint(equalTo: glkView.bottomAnchor),
            
            
            filterNameLabel.topAnchor.constraint(equalTo: glkView.bottomAnchor,constant: 8),
            filterNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 0),
            filterNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            filterNameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
    }
    
    
    
    
    
}
