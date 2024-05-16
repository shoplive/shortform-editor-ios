//
//  SLFFmpegTextBackgroundColorCell.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 1/29/24.
//

import Foundation
import UIKit



class SLFFmpegTextBackgroundColorCell : UICollectionViewCell {
    
    
    static let cellId = "slffmpegtextbackgroundcolorcellid"
    private var colorBackground : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    
    
    override var isSelected: Bool {
        didSet {
            colorBackground.transform = isSelected ? .init(scaleX: 0.8, y: 0.8) : .init(scaleX: 0.5, y: 0.5)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorBackground.layer.cornerRadius = 20
        //colorBackground.frame.height / 2
    }
    
    func setColor(color : UIColor) {
        self.colorBackground.backgroundColor = color
    }
    
}
extension SLFFmpegTextBackgroundColorCell {
    private func setLayout() {
        self.addSubview(colorBackground)
        
        colorBackground.transform = .init(scaleX: 0.5, y: 0.5)
        
        NSLayoutConstraint.activate([
            colorBackground.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            colorBackground.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            colorBackground.widthAnchor.constraint(equalTo: self.widthAnchor),
            colorBackground.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
    }
    
}
