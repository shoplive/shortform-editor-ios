//
//  FilterAddBtn.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 1/2/24.
//

import Foundation
import UIKit
import ShopliveSDKCommon



class OptionBtnContainer : UIView, SLReactor {
    var resultHandler: ((Result) -> ())?
    
    enum Action {
        
    }
    
    enum Result {
        case filterBtnTapped
    }
    
    lazy private var filterBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(ShopLiveShortformEditorSDKAsset.slIcFilter.image.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.imageView?.tintColor = .white
        btn.imageView?.contentMode = .scaleAspectFit
        return btn
    }()
    
    private var openAndCloseBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .red
        return btn
    }()
    private var stackView : UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    var isClosed : Bool = true
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .init(white: 0, alpha: 0.3)
        self.layer.cornerRadius = 10
        self.setLayout()
        
        openAndCloseBtn.addTarget(self, action: #selector(openAndCloseBtnTapped(sender: )), for: .touchUpInside)
        filterBtn.addTarget(self, action: #selector(filterBtnTapped(sender: )), for: .touchUpInside)
    }
    
    required init(coder : NSCoder) {
        fatalError()
    }
    
    func action(_ action: Action) { /* no - op */ }
    
    @objc func openAndCloseBtnTapped(sender : UIButton) {
        isClosed = !isClosed
        for i in 0..<stackView.arrangedSubviews.count {
            if i > 4 {
                stackView.arrangedSubviews[i].isHidden = isClosed
            }
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.layoutIfNeeded()
        }
    }
    
    @objc func filterBtnTapped(sender : UIButton) {
        resultHandler?( .filterBtnTapped )
    }
}
extension OptionBtnContainer {
    private func setLayout() {
        self.addSubview(stackView)
        self.addSubview(openAndCloseBtn)
        
        stackView.addArrangedSubview(filterBtn)
        
        for i in 0...10 {
            let btn = UIButton()
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.backgroundColor = .white
            btn.heightAnchor.constraint(equalToConstant: 20).isActive = true
            btn.isHidden = i > 4
            stackView.addArrangedSubview(btn)
        }
        
        
        NSLayoutConstraint.activate([
            filterBtn.heightAnchor.constraint(equalToConstant: 20),
            
            stackView.topAnchor.constraint(equalTo: self.topAnchor,constant: 10),
            stackView.widthAnchor.constraint(equalToConstant: 20),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -5),
            stackView.bottomAnchor.constraint(equalTo: openAndCloseBtn.topAnchor,constant: -10),
            
            
            openAndCloseBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: -10),
            openAndCloseBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            openAndCloseBtn.widthAnchor.constraint(equalToConstant: 20),
            openAndCloseBtn.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}
