//
//  V2SideMenuViewController.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/11/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit





final class V2SideMenuViewController : UIViewController {
    
    lazy private var headerContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }()
    
    lazy private var appVersionLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.text = "App Version : 1.0.0"
        return label
    }()
    
    lazy private var sdkVersionlabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        label.text = "SDK Version : 1.0.0"
        return label
    }()
    
    lazy private var optionsButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(PlayerDemo2Strings.Menu.options, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    lazy private var couponButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(PlayerDemo2Strings.Menu.coupon, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    lazy private var exitBroadcastButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(PlayerDemo2Strings.Menu.exit, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    lazy private var deleteWebViewStorageButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(PlayerDemo2Strings.Menu.removeCache, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private let viewModel : SideMenuViewModel
    private var disposeBag : DisposeBag = .init()
    
    init(viewModel: SideMenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setLayout()
        
    }
    
    deinit {
        print("SideMenuViewController deinit")
    }
    
    private func bind() {
        //action
        let routeBtnStream = Observable.merge(
            optionsButton.rx.tap.withUnretained(self).map { owner,_ in SideMenuViewModel.Route.option },
            couponButton.rx.tap.withUnretained(self).map { owner,_ in SideMenuViewModel.Route.coupon }
        )
        
        
        //input
        let output = viewModel.transform(input: .init(routeTo: routeBtnStream.asObservable(),
                                                      exitPlayer: exitBroadcastButton.rx.tap.asObservable(),
                                                      removeWebViewStorage: deleteWebViewStorageButton.rx.tap.asObservable()))
        
        
        //output
        output.appVersion
            .observe(on: MainScheduler.instance)
            .bind(to: appVersionLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.sdkVersion
            .observe(on: MainScheduler.instance)
            .bind(to: sdkVersionlabel.rx.text)
            .disposed(by: disposeBag)
    }
    
}
extension V2SideMenuViewController {
    private func setLayout() {
        self.view.addSubview(headerContainerView)
        let headerInfoStackView = UIStackView(arrangedSubviews: [appVersionLabel,sdkVersionlabel])
        headerInfoStackView.translatesAutoresizingMaskIntoConstraints = false
        headerInfoStackView.axis = .vertical
        headerInfoStackView.spacing = 10
        headerInfoStackView.distribution = .fillEqually
        headerInfoStackView.isLayoutMarginsRelativeArrangement = true
        headerInfoStackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.view.addSubview(headerInfoStackView)
        
        let buttonStack = UIStackView(arrangedSubviews: [optionsButton,couponButton,exitBroadcastButton,deleteWebViewStorageButton])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .vertical
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually
        buttonStack.isLayoutMarginsRelativeArrangement = true
        buttonStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        self.view.addSubview(buttonStack)
        
        
        headerContainerView.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        headerInfoStackView.snp.makeConstraints{
            $0.top.equalTo(headerContainerView).offset(20)
            $0.leading.trailing.equalTo(headerContainerView)
            $0.bottom.equalTo(headerContainerView).offset(-20)
        }
        
        
        buttonStack.snp.makeConstraints {
            $0.top.equalTo(headerContainerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40 * 4 + 10 * 4)
        }
    
    }
}
