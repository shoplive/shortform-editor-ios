//
//  UserInfoContainerView.swift
//  PlayerDemo2
//
//  Created by Tabber on 2/6/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import ShopLiveSDK
import ShopliveSDKCommon


class UserInfoContainerView: UIView {
    
    struct Input {
        let updatedData: PublishSubject<UserInfoViewLoadData>
    }
    
    struct Output {
        let showUserInfoViewController: PublishSubject<Void>
        let updateData: PublishSubject<UserMode>
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "[\("base.section.userinfo.title".localized())]"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var userinfoTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textColor = .black
        view.text = "base.section.userinfo.none.title".localized()
        return view
    }()

    private lazy var jwtTokenTitleLabel: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textColor = .black
        view.isEditable = false
        view.isScrollEnabled = false
        return view
    }()

    private lazy var chooseButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.layer.cornerRadius = 6
        view.contentEdgeInsets = .init(top: 7, left: 9, bottom: 7, right: 9)
        view.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        view.setTitle("base.section.userinfo.button.chooseCampaign.input.title".localized(), for: .normal)
        return view
    }()
    
    private var radioGroup: [ShopLiveRadioButton] = []
    
    lazy var guestRadio: ShopLiveRadioButton = {
        let view = ShopLiveRadioButton()
        view.configure(identifier: .Guest, description: "userinfo.auth.type.guest".localized())
        view.delegate = self
        return view
    }()
    
    lazy var commonRadio: ShopLiveRadioButton = {
        let view = ShopLiveRadioButton()
        view.configure(identifier: .Common, description: "userinfo.auth.type.common".localized())
        view.delegate = self
        return view
    }()

    lazy var tokenRadio: ShopLiveRadioButton = {
        let view = ShopLiveRadioButton()
        view.configure(identifier: .Token, description: "userinfo.auth.type.jwt".localized())
        view.delegate = self
        return view
    }()
    
    lazy var authView: UIView = {
        let view = UIView()
        self.radioGroup = [guestRadio, commonRadio, tokenRadio]
        view.addSubview(guestRadio)
        view.addSubview(commonRadio)
        view.addSubview(tokenRadio)
        
        guestRadio.snp.makeConstraints {
            $0.top.equalTo(view.snp.top)
            $0.leading.equalTo(view.snp.leading)
            $0.height.equalTo(20)
        }
        
        commonRadio.snp.makeConstraints {
            $0.top.equalTo(guestRadio.snp.bottom).offset(10)
            $0.leading.equalTo(guestRadio.snp.leading)
            $0.height.equalTo(20)
        }
        
        tokenRadio.snp.makeConstraints {
            $0.top.equalTo(commonRadio.snp.bottom).offset(10)
            $0.leading.equalTo(guestRadio.snp.leading)
            $0.height.equalTo(20)
        }

        return view
    }()

    var viewModel: UserInfoContainerViewModel = .init()
    let disposeBag: DisposeBag = DisposeBag()
    
    var input: Input?
    var output: Output?
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(input: Input, output: Output) {
        self.input = input
        self.output = output
        bind()
        setLeyout()
    }
    
    private func bind() {
        
        guard let containerInput = input else { return }
        guard let containerOutput = output else { return }
        
        let input = UserInfoContainerViewModel.Input(
            updatedData: containerInput.updatedData,
            userInfoBtnTap: chooseButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        output.showUserInfoViewController
            .bind(to: containerOutput.showUserInfoViewController)
            .disposed(by: disposeBag)
        
        output.updateData
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                containerOutput.updateData.onNext(value)
                
                if value == .Guest {
                    self.userinfoTitleLabel.text = "Guest Mode"
                    self.jwtTokenTitleLabel.text = ""
                    self.chooseButton.isHidden = true
                } else {
                    self.userinfoTitleLabel.text = self.viewModel.userDescription
                    self.jwtTokenTitleLabel.text = self.viewModel.jwtText
                    self.chooseButton.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        output.updateUI
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                if data.userMode == .Guest {
                    self.userinfoTitleLabel.text = "Guest Mode"
                    self.jwtTokenTitleLabel.text = ""
                    self.chooseButton.isHidden = true
                } else {
                    self.userinfoTitleLabel.text = viewModel.userDescription
                    self.jwtTokenTitleLabel.text = data.jwt
                    self.chooseButton.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        output.isInitUI
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] mode in
                guard let self = self else { return }
                self.updateAuthType(identifier: mode)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - layout
extension UserInfoContainerView {
    func setLeyout() {
        self.backgroundColor = .white
        self.addSubview(titleLabel)
        self.addSubview(authView)
        self.addSubview(userinfoTitleLabel)
        self.addSubview(jwtTokenTitleLabel)
        self.addSubview(chooseButton)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(15)
            $0.leading.equalTo(self.snp.leading).offset(15)
            $0.height.equalTo(22)
        }
        
        authView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.top)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(5)
            $0.trailing.equalTo(self.snp.trailing).offset(-30)
            $0.height.equalTo(80)
        }
        
        userinfoTitleLabel.snp.makeConstraints {
            $0.top.equalTo(self.authView.snp.bottom).offset(15)
            $0.leading.equalTo(self.snp.leading).offset(15)
            $0.trailing.equalTo(self.chooseButton).offset(-15)
        }
        
        chooseButton.snp.makeConstraints {
            $0.top.equalTo(authView.snp.bottom).offset(5)
            $0.trailing.equalTo(self.snp.trailing).offset(-15)
            $0.width.equalTo(80)
            $0.height.equalTo(35)
        }
        
        jwtTokenTitleLabel.snp.makeConstraints {
            $0.top.equalTo(userinfoTitleLabel.snp.bottom).offset(15)
            $0.leading.equalTo(userinfoTitleLabel.snp.leading)
            $0.trailing.equalTo(self.snp.trailing).offset(-15)
            $0.bottom.equalTo(self.snp.bottom)
        }
    }
}

extension UserInfoContainerView: ShopLiveRadioButtonDelegate {

    func updateAuthType(identifier: UserMode) {
        radioGroup.forEach { radio in
            radio.updateRadio(selected: radio.identifier == identifier)
        }
    }

    func didSelectRadioButton(_ sender: ShopLiveRadioButton) {
        updateAuthType(identifier: sender.identifier)
        viewModel.updateMode( sender.identifier )
    }

    var selectedIdentifier: UserMode {
        guard let selected = radioGroup.first(where: {$0.isSelected == true}) else {
            return .Guest
        }

        return selected.identifier
    }
}
