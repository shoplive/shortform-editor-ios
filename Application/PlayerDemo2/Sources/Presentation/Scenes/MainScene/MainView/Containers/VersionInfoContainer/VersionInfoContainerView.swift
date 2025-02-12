//
//  VersionInfoContainerView.swift
//  PlayerDemo2
//
//  Created by Tabber on 2/10/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ShopliveSDKCommon
import ShopLiveSDK
import SnapKit

class VersionInfoButton: UIButton {
    var type: VersionInfoButtonType
    
    init(type: VersionInfoButtonType) {
        self.type = type
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class VersionInfoContainerView: UIView {
    
    struct Input {
        let setData: PublishSubject<SDKConfiguration>
    }
    
    struct Output {
        let saveButton: PublishSubject<(VersionInfoButtonType, String)>
    }
    
    private var input: Input?
    private var output: Output?
    
    private var viewModel: VersionInfoContainerViewModel
    private var disposeBag: DisposeBag = DisposeBag()
    
    private lazy var stackView = UIStackView()
    
    private lazy var sdkVersionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.font = .systemFont(ofSize: 18, weight: .semibold)
        view.textAlignment = .left
        view.textColor = .black
        return view
    }()
    
    private lazy var customAppVersionButton: VersionInfoButton = {
        let view = VersionInfoButton(type: .AppVersion)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.black, for: .normal)
        view.setTitleColor(.black, for: .highlighted)
        return view
    }()
    
    private lazy var customReferrerButton: VersionInfoButton = {
        let view = VersionInfoButton(type: .Referrer)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.black, for: .normal)
        view.setTitleColor(.black, for: .highlighted)
        return view
    }()
    
    private lazy var customAdIdButton: VersionInfoButton = {
        let view = VersionInfoButton(type: .AdId)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.black, for: .normal)
        view.setTitleColor(.black, for: .highlighted)
        return view
    }()


    private lazy var utmSourceBtn : VersionInfoButton = {
        let view = VersionInfoButton(type: .UtmSource)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.black, for: .normal)
        view.setTitleColor(.black, for: .highlighted)
        return view
    }()
    
    
    private lazy var utmCampaignBtn : VersionInfoButton = {
        let view = VersionInfoButton(type: .UtmCampaign)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.black, for: .normal)
        view.setTitleColor(.black, for: .highlighted)
        return view
    }()
    
    private lazy var utmContentBtn : VersionInfoButton = {
        let view = VersionInfoButton(type: .UtmContent)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.black, for: .normal)
        view.setTitleColor(.black, for: .highlighted)
        return view
    }()
    
    private lazy var utmMediumBtn : VersionInfoButton = {
        let view = VersionInfoButton(type: .UtmMedium)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.black, for: .normal)
        view.setTitleColor(.black, for: .highlighted)
        return view
    }()
    
    private lazy var customAnonIdButton: VersionInfoButton = {
        let view = VersionInfoButton(type: .AnonId)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.black, for: .normal)
        view.setTitleColor(.black, for: .highlighted)
        return view
    }()
    
    
    override init(frame: CGRect) {
        self.viewModel = .init()
        super.init(frame: .zero)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        
        let horizontalStackView = UIStackView()
        
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 0
        
        stackView.axis = .vertical
        stackView.alignment = .leading
        
        self.addSubview(stackView)
        
        horizontalStackView.addArrangedSubview(sdkVersionLabel)
        horizontalStackView.addArrangedSubview(customAppVersionButton)
         
        stackView.addArrangedSubview(horizontalStackView)
        stackView.addArrangedSubview(customReferrerButton)
        stackView.addArrangedSubview(customAnonIdButton)
        stackView.addArrangedSubview(customAdIdButton)
        stackView.addArrangedSubview(utmSourceBtn)
        stackView.addArrangedSubview(utmContentBtn)
        stackView.addArrangedSubview(utmCampaignBtn)
        stackView.addArrangedSubview(utmMediumBtn)
        
        stackView.spacing = 10
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(15)
            $0.leading.equalTo(self.snp.leading).offset(15)
            $0.trailing.equalTo(self.snp.trailing).offset(-15)
            $0.bottom.equalTo(self.snp.bottom)
        }
    }
    
    
    func configureContent(input: VersionInfoContainerView.Input, output: VersionInfoContainerView.Output) {
        self.input = input
        self.output = output
        bind()
    }
    
    private func bind() {
        
        // action
        let btns = Observable.merge([
            customAppVersionButton.rx.tap.withUnretained(self).map({ owner, _ in owner.customAppVersionButton.type }),
            customReferrerButton.rx.tap.withUnretained(self).map({ owner, _ in owner.customReferrerButton.type }),
            customAnonIdButton.rx.tap.withUnretained(self).map({ owner, _ in owner.customAnonIdButton.type }),
            customAdIdButton.rx.tap.withUnretained(self).map({ owner, _ in owner.customAdIdButton.type }),
            utmSourceBtn.rx.tap.withUnretained(self).map({ owner, _ in owner.utmSourceBtn.type }),
            utmContentBtn.rx.tap.withUnretained(self).map({ owner, _ in owner.utmContentBtn.type }),
            utmCampaignBtn.rx.tap.withUnretained(self).map({ owner, _ in owner.utmCampaignBtn.type }),
            utmMediumBtn.rx.tap.withUnretained(self).map({ owner, _ in owner.utmMediumBtn.type })
        ])
        
        btns
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                if let presentData = self?.viewModel.getCurrentData(value) {
                    self?.showAlertController(type: value, presentData: presentData)
                }
        })
            .disposed(by: disposeBag)
        
        // input
        let input = VersionInfoContainerViewModel.Input(setData: input?.setData ?? .init())
        
        // output
        let output = viewModel.transform(input: input)
        
        output.presentData
            .subscribe(onNext: { [weak self] data in
                
                let appVersion = data.customerAppVersion ?? ""
                let referrer = data.referrer ?? ""
                let anonId = data.anonId ?? ""
                let adId = data.adId ?? ""
                let utmSource = data.utmSource ?? ""
                let utmContent = data.utmContent ?? ""
                let utmCampaign = data.utmCampaign ?? ""
                let utmMedium = data.utmMedium ?? ""
                
                let emptyText = "미입력"
                
                self?.sdkVersionLabel.text = "SDK v\(ShopLive.sdkVersion)"
                self?.customAppVersionButton.setTitle(", 고객사 앱 버전: \(appVersion == "" ? emptyText : "v"+appVersion)", for: .normal)
                self?.customReferrerButton.setTitle("Referrer: \(referrer == "" ? emptyText : referrer)", for: .normal)
                self?.customAnonIdButton.setTitle("anonId: \(anonId == "" ? emptyText : anonId)", for: .normal)
                self?.customAdIdButton.setTitle("adId: \(adId == "" ? emptyText : adId)", for: .normal)
                self?.utmSourceBtn.setTitle("utmSource: \(utmSource == "" ? emptyText : utmSource)", for: .normal)
                self?.utmContentBtn.setTitle("utmContent: \(utmContent == "" ? emptyText : utmContent)", for: .normal)
                self?.utmCampaignBtn.setTitle("utmCampaign: \(utmCampaign == "" ? emptyText : utmCampaign)", for: .normal)
                self?.utmMediumBtn.setTitle("utmMedium: \(utmMedium == "" ? emptyText : utmMedium)", for: .normal)
            })
            .disposed(by: disposeBag)
    }
    
    private func showAlertController(type: VersionInfoButtonType, presentData: String) {
        if let rootViewController = UIApplication.topWindow?.rootViewController {
            let alert = UIAlertController(title: "입력", message: nil, preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: { textField in
                textField.text = presentData
                textField.placeholder = "예) shoplive"
            })
            
            let delete = UIAlertAction(title: "alert.msg.delete".localized(), style: .default, handler: { [weak self] _ in
                self?.output?.saveButton.onNext((type, ""))
            })
            delete.setValue(UIColor.systemRed, forKey: "titleTextColor")
            
            let apply = UIAlertAction(title: "alert.msg.confirm".localized(), style: .default, handler: { [weak self] _ in
                self?.output?.saveButton.onNext((type, alert.textFields?.first?.text ?? ""))
            })
            
            alert.addAction(delete)
            alert.addAction(apply)
            
            
            rootViewController.present(alert, animated: true)
        }
    }
}
