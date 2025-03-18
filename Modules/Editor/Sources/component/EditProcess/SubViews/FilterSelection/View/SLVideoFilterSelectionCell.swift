//
//  SLVideoFilterSelectionCell.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/28/23.
//

import Foundation
import UIKit
import ShopliveFilterSDK
import ShopliveSDKCommon
import GLKit


class SLVideoFilterSelectionCell : UICollectionViewCell {
    static let cellId =  "slvideofilterselectioncellId"
    
    
    private var glkView : GLKView = {
        let view = GLKView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.clearsContextBeforeDrawing = true
        view.enableSetNeedsDisplay = true
        return view
    }()
    
    lazy private var bundle = Bundle(for: type(of: self))
    lazy private var image = ShopLiveShortformEditorSDKAsset.slIcHotAirBallon.image
    lazy private var glkImageViewHandler = ShopliveFilterSDKImageViewHandler(glkView: glkView)
    private var filterConfig : String = ""

    
    private var filterNameLabel : SLLabel = {
        let label = SLLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = .clear
        label.setFont(font: .init(size: 13, weight: .regular))
        label.textColor = .black
        return label
    }()
    
    private var selectedBorderView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = 6
        return view
    }()
    
    private var isInitialzed : Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.setLayout()
        
    }
    
    required init(coder : NSCoder) {
        fatalError()
    }
    
    
    func configure(filterConfig : String,isSelected : Bool) {
        isInitialzed = false
        self.filterConfig = filterConfig
        self.selectedBorderView.isHidden = isSelected ? false : true
    }
    
    func setCellSelected(isSelected : Bool) {
        self.selectedBorderView.isHidden = isSelected ? false : true
    }
    
    func setfilterName(filterName : String) {
        self.filterNameLabel.text = filterName
        self.filterNameLabel.isHidden = true
    }
    func drawGLKView() {
        guard isInitialzed == false else { return }
        isInitialzed = true
        glkImageViewHandler?.clear()
        glkImageViewHandler = ShopliveFilterSDKImageViewHandler(glkView: glkView,with: image)
        glkImageViewHandler?.setFilterWithConfig(filterConfig)
    }
    
}
extension SLVideoFilterSelectionCell {
    private func setLayout() {
        self.addSubview(glkView)
        self.addSubview(selectedBorderView)
        self.addSubview(filterNameLabel)
        glkImageViewHandler?.setViewDisplayMode(ShopliveFilterSDKImageViewDisplayModeAspectFill)
        
        
        NSLayoutConstraint.activate([
            glkView.topAnchor.constraint(equalTo: self.topAnchor,constant: 1),
            glkView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1),
            glkView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1),
            glkView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1),
            
            
            selectedBorderView.topAnchor.constraint(equalTo: self.topAnchor, constant: 1),
            selectedBorderView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1),
            selectedBorderView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1),
            selectedBorderView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1),
            
            
            filterNameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            filterNameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            filterNameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            filterNameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
    }
    
    
    
}
