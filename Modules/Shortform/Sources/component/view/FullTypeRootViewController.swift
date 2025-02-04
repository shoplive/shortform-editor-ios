//
//  FullTypeRootViewController.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/07/05.
//

import Foundation
import UIKit
import ShopliveSDKCommon


protocol ShortFormDetailRootViewControllerDelegate : AnyObject {
    func onStartRotation(to size : CGSize)
    func onChangingRotation(to size : CGSize)
    func onFinishedRotation(on size : CGSize)
    
}

class ShortFormDetailRootViewController : UIViewController {
    
    
    weak var delegate : ShortFormDetailRootViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.delegate?.onStartRotation(to: size)
        
        coordinator.animate { [weak self] context  in
            self?.delegate?.onChangingRotation(to : size)
        } completion: { [weak self] context in
            self?.delegate?.onFinishedRotation(on: size)
        }
       
    }
    
}
