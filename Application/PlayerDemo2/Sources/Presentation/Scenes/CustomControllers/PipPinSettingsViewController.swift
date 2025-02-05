//
//  PipPinSettingsViewController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopLiveSDK
import ShopliveSDKCommon

class PipPinSettingsViewController : UIViewController {
        
    private var stack : UIStackView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setLayout()
    }
    
    @objc private func btnTapped(sender : UIButton) {
        guard let btns = (stack?.arrangedSubviews as? [UIStackView])?.compactMap({ $0.arrangedSubviews as? [UIButton] }).flatMap({ $0 }) else { return }
        
//        var values = DemoConfiguration.shared.pipPinPosition
//        ShopLiveLogger.tempLog("[values] .topRight \(ShopLive.PipPosition.topRight.rawValue)")
//        ShopLiveLogger.tempLog("[values]  1 \(values.map{ $0.name })")
//        guard let targetPos = ShopLive.PipPosition(rawValue: sender.tag) else { return }
//        ShopLiveLogger.tempLog("[values]  targetPos \(targetPos.name)")
//        for btn in btns {
//            if btn.tag == sender.tag {
//                if btn.isSelected {
//                    btn.backgroundColor = .clear
//                    btn.isSelected = false
//                    values.removeAll(where: { $0 == targetPos })
//                    ShopLiveLogger.tempLog("[values]  2 \(values.map{ $0.name })")
//                }
//                else {
//                    btn.backgroundColor = .lightGray
//                    btn.isSelected = true
//                    values.append(targetPos)
//                    ShopLiveLogger.tempLog("[values]  3 \(values.map{ $0.name })")
//                }
//                break
//            }
//        }
//        ShopLiveLogger.tempLog("[values]  4 \(values.map{ $0.name })")
//        DemoConfiguration.shared.pipPinPosition = values
    }
    
}

extension PipPinSettingsViewController {
    
    private func setLayout() {
        let firstRow = UIStackView(arrangedSubviews: self.makeBtns(from: 1, to: 3))
        let secondRow = UIStackView(arrangedSubviews: self.makeBtns(from: 4, to: 6))
        let thirdRow = UIStackView(arrangedSubviews: self.makeBtns(from: 7, to: 9))
        
        firstRow.axis = .horizontal
        firstRow.distribution = .fillEqually
        firstRow.spacing = 10
        
        secondRow.axis = .horizontal
        secondRow.distribution = .fillEqually
        secondRow.spacing = 10
        
        thirdRow.axis = .horizontal
        thirdRow.distribution = .fillEqually
        thirdRow.spacing = 10
        
        let stack = UIStackView(arrangedSubviews: [firstRow,secondRow,thirdRow])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        self.stack = stack
        
        
        self.view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.view.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            stack.heightAnchor.constraint(equalTo: self.view.heightAnchor),
        ])
    }
    
    private func makeBtns(from : Int, to : Int) -> [UIButton] {
//        let values = DemoConfiguration.shared.pipPinPosition.map { $0.rawValue }
//        
//        return (from...to).map { tag in
//            let btn = UIButton()
//            btn.translatesAutoresizingMaskIntoConstraints = false
//            btn.isUserInteractionEnabled = true
//            btn.setTitle(String(tag), for: .normal)
//            btn.setTitleColor(.white, for: .selected)
//            btn.setTitleColor(.lightGray, for: .normal)
//            btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
//            btn.tag = tag - 1
//            btn.contentHorizontalAlignment = .center
//            btn.contentVerticalAlignment = .center
//            if values.contains(where: { $0 == (tag - 1) }) {
//                btn.isSelected = true
//                btn.backgroundColor = .lightGray
//            }
//            else {
//                btn.isSelected = false
//                btn.backgroundColor = .clear
//            }
//            
//            btn.addTarget(self, action: #selector(btnTapped(sender: )), for: .touchUpInside)
//            return btn
//        }
        return []
    }
    
    
}

