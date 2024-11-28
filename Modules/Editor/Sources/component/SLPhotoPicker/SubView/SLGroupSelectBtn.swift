//
//  SLGroupSelectBtn.swift
//  CustomImagePicker
//
//  Created by sangmin han on 5/3/24.
//

import Foundation
import UIKit

class SLPhotosPickerGroupSelectBtn : UIButton {
    
    
    private var label : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .set(size: 18, weight: ._600)
        label.text = ShopLiveShortformEditorSDKStrings.Editor.Folder.All.shoplive
        label.textColor = .white
        return label
    }()
    
    
    private var icon : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = ShopLiveShortformEditorSDKAsset.slIcDownarrow.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        
    }
    
    required init(coder : NSCoder?) {
        fatalError()
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchrect = self.bounds
        
        if touchrect.contains(point) {
            return self
        }
        else {
            return nil
        }
    }
    
    func setTitle(title : String) {
        label.text = title
    }
    
    
}
extension SLPhotosPickerGroupSelectBtn {
    private func setLayout() {
        let stack = UIStackView(arrangedSubviews: [label,icon])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 2
        self.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stack.heightAnchor.constraint(equalTo: self.heightAnchor),
            stack.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            stack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            
            self.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 1),
            
            
            icon.widthAnchor.constraint(equalToConstant: 24),
        ])
        
    }
}
