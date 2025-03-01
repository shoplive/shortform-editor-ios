//
//  CouponResponseSettingViewController.swift
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




final class CouponResponseSettingViewController : UIViewController {
    
    private lazy var successSettingView: CouponResponseSettingContainer = {
        let view = CouponResponseSettingContainer()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var failedSettingView:  CouponResponseSettingContainer = {
        let view = CouponResponseSettingContainer()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let viewModel : CouponResponseSettingViewModel
    private let saveButtonTapSubject : PublishSubject<Void> = .init()
    private let viewDidLoadSubject : PublishSubject<Void> = .init()
    private var disposeBag : DisposeBag = .init()
    
    required init(viewModel : CouponResponseSettingViewModel) {
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
        setupNaviItems()
        setLayout()
        
        viewDidLoadSubject.onNext(())
        
    }
    
    @objc private func saveButtonTapped() {
        saveButtonTapSubject.onNext(())
        self.navigationController?.popViewController(animated: true)
    }
    
    private func bind() {
        //action
       
        //input
        //subView
        let successContentsSubject : PublishSubject<CouponResponseSettingContainerUIData> = .init()
        let successUpdateRadioButtonSubject : PublishSubject<CouponResponseSettingContainer.RadioType?> = .init()
        let successOutput = successSettingView.transform(input: .init(setContents: successContentsSubject,
                                                                      updateRadioButtonState: successUpdateRadioButtonSubject))
        
        
        let failedContentsSubject : PublishSubject<CouponResponseSettingContainerUIData> = .init()
        let failedUpdateRadioButtonSubject : PublishSubject<CouponResponseSettingContainer.RadioType?> = .init()
        let failedOutput = failedSettingView.transform(input: .init(setContents: failedContentsSubject,
                                                                      updateRadioButtonState: failedUpdateRadioButtonSubject))
        
        //main
        let successRadioTypeSubject : PublishSubject<CouponResponseSettingContainer.RadioType> = .init()
        let successMessageSubject : PublishSubject<String> = .init()
        let failedRadioTypeSubject : PublishSubject<CouponResponseSettingContainer.RadioType> = .init()
        let failedMessageSubject : PublishSubject<String> = .init()
        let output = viewModel.transform(input: .init(viewDidLoad: viewDidLoadSubject,
                                                      save: saveButtonTapSubject,
                                                      successRadioType: successRadioTypeSubject.asObservable(),
                                                      failedRadioType: failedRadioTypeSubject.asObservable(),
                                                      successMessage: successMessageSubject.asObservable(),
                                                      failedMessage: failedMessageSubject.asObservable()))
        
        
        //output
        //subView
        successOutput.radioButtonTapped
            .bind(to: successRadioTypeSubject)
            .disposed(by: disposeBag)
        
        successOutput.message
            .bind(to: successMessageSubject)
            .disposed(by: disposeBag)
        
        failedOutput.radioButtonTapped
            .bind(to: failedRadioTypeSubject)
            .disposed(by: disposeBag)
        
        failedOutput.message
            .bind(to: failedMessageSubject)
            .disposed(by: disposeBag)
        
        //main
        output.successContents
            .bind(to: successContentsSubject)
            .disposed(by: disposeBag)
        
        output.failureContents
            .bind(to: failedContentsSubject)
            .disposed(by: disposeBag)
        
        output.successRadioType
            .bind(to: successUpdateRadioButtonSubject)
            .disposed(by: disposeBag)
        
        output.failedRadioType
            .bind(to: failedUpdateRadioButtonSubject)
            .disposed(by: disposeBag)
    }
}
extension CouponResponseSettingViewController {
    func setupNaviItems() {
        let save = UIBarButtonItem(title: PlayerDemo2Strings.Sdk.User.save, style: .plain, target: self, action: #selector(saveButtonTapped))
        save.tintColor = .white
        self.navigationItem.rightBarButtonItem = save
    }
    
    private func setLayout() {
        self.view.addSubview(successSettingView)
        self.view.addSubview(failedSettingView)
        
        successSettingView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        failedSettingView.snp.makeConstraints {
            $0.top.equalTo(successSettingView.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }
    
}
