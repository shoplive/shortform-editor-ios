//
//  CouponResponseSettingContainer.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/11/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift




final class CouponResponseSettingContainer : UIView {
    
    enum RadioType {
        case show
        case hide
        case keep
        case alert
        case toast
    }
    
    struct Input {
        let setContents : Observable<CouponResponseSettingContainerUIData>
        let updateRadioButtonState : Observable<RadioType?>
    }
    
    struct Output {
        let radioButtonTapped : Observable<RadioType>
        let message : Observable<String>
    }
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 16, weight: .heavy)
        view.textColor = .black
        view.text = PlayerDemo2Strings.Couponresponse.Success.title
        return view
    }()
    
    
    private lazy var messageTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.textColor = .black
        view.text = PlayerDemo2Strings.Couponresponse.Msg.message
        return view
    }()

    private lazy var showTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.textColor = .black
        view.text = PlayerDemo2Strings.Couponresponse.Msg.show
        return view
    }()

    private lazy var alertTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.numberOfLines = 1
        view.textColor = .black
        view.text = PlayerDemo2Strings.Couponresponse.Msg.alert
        return view
    }()

    private lazy var messageTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        return view
    }()
    
    private lazy var showRadio: ShopLiveRxRadioButton = {
        let view = ShopLiveRxRadioButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var hideRadio: ShopLiveRxRadioButton = {
        let view = ShopLiveRxRadioButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var keepRadio: ShopLiveRxRadioButton = {
        let view = ShopLiveRxRadioButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var alertRadio: ShopLiveRxRadioButton = {
        let view = ShopLiveRxRadioButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var toastRadio: ShopLiveRxRadioButton = {
        let view = ShopLiveRxRadioButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private var disposeBag : DisposeBag = .init()
    
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        setLayout()
        
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    func transform(input : Input) -> Output {
        input.setContents
            .withUnretained(self)
            .subscribe(onNext : { owner, contents in
                owner.titleLabel.text = contents.title
                owner.messageTextField.placeholder = contents.messagePlaceHolder
                owner.messageTextField.text = contents.message
                owner.showRadio.descriptionLabel.text = contents.showRadioDescription
                owner.hideRadio.descriptionLabel.text = contents.hideRadioDescription
                owner.keepRadio.descriptionLabel.text = contents.keepRadioDescription
                owner.alertRadio.descriptionLabel.text = contents.alertRadioDescription
                owner.toastRadio.descriptionLabel.text = contents.toastRadioDescription
            })
            .disposed(by: disposeBag)
        
        input.updateRadioButtonState
            .withUnretained(self)
            .subscribe(onNext  : { owner , type in
                guard let type = type else {
                    return
                }
                if [RadioType.show,RadioType.hide,RadioType.keep].contains(where: { $0 == type }) {
                    owner.showRadio.isSelected = type == .show
                    owner.hideRadio.isSelected = type == .hide
                    owner.keepRadio.isSelected = type == .keep
                }
                else {
                    owner.alertRadio.isSelected = type == .alert
                    owner.toastRadio.isSelected = type == .toast
                }
            })
            .disposed(by: disposeBag)
        
        let radioTapStream = Observable.merge(
            showRadio.rx.tap.map{ RadioType.show },
            hideRadio.rx.tap.map{ RadioType.hide },
            keepRadio.rx.tap.map{ RadioType.keep },
            alertRadio.rx.tap.map{ RadioType.alert },
            toastRadio.rx.tap.map{ RadioType.toast }
        )
        
        return .init(radioButtonTapped: radioTapStream.asObservable(),
                     message: messageTextField.rx.text.orEmpty.asObservable())
    }
    
}
extension CouponResponseSettingContainer {
    private func setLayout() {
        self.addSubview(titleLabel)
        self.addSubview(messageTitleLabel)
        self.addSubview(messageTextField)
        self.addSubview(showTitleLabel)
        self.addSubview(alertTitleLabel)
        
        let couponShowView = UIView()
        couponShowView.addSubview(showRadio)
        couponShowView.addSubview(hideRadio)
        couponShowView.addSubview(keepRadio)
        self.addSubview(couponShowView)
        
        let couponAlertView = UIView()
        couponAlertView.addSubview(alertRadio)
        couponAlertView.addSubview(toastRadio)
        self.addSubview(couponAlertView)
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(15)
            $0.trailing.lessThanOrEqualToSuperview().offset(-10)
            $0.height.equalTo(30)
        }

        messageTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(15)
            $0.width.equalTo(120)
            $0.height.equalTo(30)
        }

        showTitleLabel.snp.makeConstraints {
            $0.top.equalTo(messageTitleLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(15)
            $0.width.equalTo(120)
            $0.height.equalTo(30)
        }

        alertTitleLabel.snp.makeConstraints {
            $0.top.equalTo(showTitleLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(15)
            $0.width.equalTo(120)
            $0.height.equalTo(30)
            $0.bottom.equalToSuperview().offset(-15)
        }

        messageTextField.snp.makeConstraints {
            $0.top.bottom.equalTo(messageTitleLabel)
            $0.leading.equalTo(messageTitleLabel.snp.trailing)
            $0.trailing.equalToSuperview().offset(-15)
        }
        
        showRadio.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        hideRadio.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(showRadio.snp.trailing).offset(15)
            $0.height.equalTo(20)
        }
        
        keepRadio.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(hideRadio.snp.trailing).offset(15)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(20)
        }

        couponShowView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(showTitleLabel).priority(999)
            $0.bottom.lessThanOrEqualTo(showTitleLabel).priority(999)
            $0.centerY.equalTo(showTitleLabel).priority(1000)
            $0.leading.equalTo(showTitleLabel.snp.trailing)
            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
        }
        
        alertRadio.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
        }

        toastRadio.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(alertRadio.snp.trailing).offset(15)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(20)
        }

        couponAlertView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(alertTitleLabel).priority(999)
            $0.bottom.lessThanOrEqualTo(alertTitleLabel).priority(999)
            $0.centerY.equalTo(alertTitleLabel).priority(1000)
            $0.leading.equalTo(alertTitleLabel.snp.trailing)
            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
        }
        
    }
}
