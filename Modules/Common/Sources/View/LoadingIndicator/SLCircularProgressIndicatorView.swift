//
//  SLProgressIndicatorView.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 1/9/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol SLCircularProgressIndicatorViewDelegate: AnyObject {
    func didTapLoadingView(_ alertController: SLCircularProgressIndicatorView)
}

public class SLCircularProgressIndicatorView: UIView, UIGestureRecognizerDelegate {

    public weak var delegate: SLCircularProgressIndicatorViewDelegate?
        
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        view.cornerRadiusV_SL = 16
        return view
    }()
    
    private lazy var indicatorView: SLSLNVActivityIndicatorView = {
        let view = SLSLNVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var indicatorTitleLabel: SLLabel = {
        let view = SLLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        view.setFont(font: .init(size: 15, weight: .semibold))
        view.textColor = .white
        view.textAlignment = .center
        view.minimumScaleFactor = 0.5
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var indicatorProgressLabel: SLLabel = {
        let view = SLLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        view.setFont(font: .init(size: 15, weight: .semibold))
        view.textColor = .white
        view.textAlignment = .center
        view.isUserInteractionEnabled = false
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.setLayout()
        
        let loadingViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLoadingViewTapGesture))
        self.addGestureRecognizer(loadingViewTapGesture)
        loadingViewTapGesture.delegate = self
        loadingViewTapGesture.isEnabled = true
        
        indicatorView.startAnimating()
    }
   
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let loadingViewBounds = self.frame
        if loadingViewBounds.contains(point) && self.alpha == 1 && self.isHidden == false {
            return self
        }
        return nil
    }
    
    @objc
    private func handleLoadingViewTapGesture() {
        delegate?.didTapLoadingView(self)
    }
    
    public func setLoadingText(_ text: String) {
        indicatorProgressLabel.text = text
    }
    
    public func setTitleText(_ text: String) {
        indicatorTitleLabel.text = text
    }
    
    public func cancelLoading() {
        self.alpha = 0
    }
}
extension SLCircularProgressIndicatorView {
    private func setLayout() {
        self.addSubview(loadingView)
        loadingView.addSubview(indicatorView)
        loadingView.addSubview(indicatorProgressLabel)
        loadingView.addSubview(indicatorTitleLabel)
        
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            loadingView.heightAnchor.constraint(equalToConstant: 130),
            loadingView.widthAnchor.constraint(equalToConstant: 146),
            
            indicatorView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            indicatorView.topAnchor.constraint(equalTo: loadingView.topAnchor, constant: 20),
            indicatorView.heightAnchor.constraint(equalToConstant: 24),
            indicatorView.widthAnchor.constraint(equalToConstant: 24),
            
            indicatorTitleLabel.leftAnchor.constraint(equalTo: loadingView.leftAnchor, constant: 10),
            indicatorTitleLabel.rightAnchor.constraint(equalTo: loadingView.rightAnchor, constant: -10),
            indicatorTitleLabel.topAnchor.constraint(equalTo: indicatorView.bottomAnchor, constant: 20),
            indicatorTitleLabel.heightAnchor.constraint(equalToConstant: 16),
            
            indicatorProgressLabel.leftAnchor.constraint(equalTo: loadingView.leftAnchor, constant: 10),
            indicatorProgressLabel.rightAnchor.constraint(equalTo: loadingView.rightAnchor, constant: -10),
            indicatorProgressLabel.topAnchor.constraint(equalTo: indicatorTitleLabel.bottomAnchor, constant: 20),
            indicatorProgressLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
}
