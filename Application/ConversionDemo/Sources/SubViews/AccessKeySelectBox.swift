//
//  AccessKeySelectBox.swift
//  ConversionTrackingDemo
//
//  Created by sangmin han on 4/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit

protocol AccessKeySelectBoxDelegate : NSObjectProtocol {
    func segmentSelected(index : Int)
}

class AccessKeySelectBox : UIView {
    
    let segmentControl : UISegmentedControl = {
        let control = UISegmentedControl(items: ["DEV","QA","CUSTOM"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        return control
    }()
    
    weak var delegate : AccessKeySelectBoxDelegate?
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        
        segmentControl.addTarget(self, action: #selector(segmentValueChanged(sender: )), for: .valueChanged)
        
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    @objc func segmentValueChanged(sender : UISegmentedControl) {
        delegate?.segmentSelected(index: sender.selectedSegmentIndex)
    }
    
    
}
extension AccessKeySelectBox {
    private func setLayout() {
        self.addSubview(segmentControl)
        
        NSLayoutConstraint.activate([
            segmentControl.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            segmentControl.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            segmentControl.widthAnchor.constraint(equalToConstant: 150),
            segmentControl.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
}
