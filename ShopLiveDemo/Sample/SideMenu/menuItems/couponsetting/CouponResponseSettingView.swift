//
//  CouponResponseSettingView.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/18.
//

import UIKit
#if SDK_MODULE
import ShopLiveSDK
#endif

final class CouponResponseSettingView: UIView {

    private var isSuccess: Bool
    var resultMessage: String = ""
    var resultStatus: ShopLiveResultStatus = .SHOW
    var resultAlertType: ShopLiveResultAlertType = .ALERT

    var showRadioGroup: [ShopLiveRadioButton] = []
    var alertRadioGroup: [ShopLiveRadioButton] = []

    weak var radioDelegate: ShopLiveRadioButtonDelegate? {
        didSet {
            showRadioGroup.forEach {
                $0.delegate = radioDelegate
            }
            alertRadioGroup.forEach {
                $0.delegate = radioDelegate
            }
        }
    }

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 16, weight: .heavy)
        view.textColor = .black
        view.text = self.isSuccess ? "couponresponse.success.title".localized() : "couponresponse.failed.title".localized()
        return view
    }()

    private lazy var messageTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.textColor = .black
        view.text = "couponresponse.msg.message".localized()
        return view
    }()

    private lazy var showTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.textColor = .black
        view.text = "couponresponse.msg.show".localized()
        return view
    }()

    private lazy var alertTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.numberOfLines = 1
        view.textColor = .black
        view.text = "couponresponse.msg.alert".localized()
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
        view.placeholder = isSuccess ? "couponresponse.success.default".localized() : "couponresponse.failed.default".localized()
        view.setPlaceholderColor(.darkGray)
        return view
    }()

    lazy var couponShowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let showRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: ShopLiveResultStatus.SHOW.name +  (self.isSuccess ? "s": "f"), description: ShopLiveResultStatus.SHOW.name)
            view.updateRadio(selected: true)
            view.delegate = radioDelegate
            return view
        }()

        let hideRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: ShopLiveResultStatus.HIDE.name +  (self.isSuccess ? "s": "f"), description: ShopLiveResultStatus.HIDE.name)
            view.delegate = radioDelegate
            return view
        }()

        let keepRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: ShopLiveResultStatus.KEEP.name +  (self.isSuccess ? "s": "f"), description: ShopLiveResultStatus.KEEP.name)
            view.delegate = radioDelegate
            return view
        }()

        self.showRadioGroup = [showRadio, hideRadio, keepRadio]
        view.addSubview(showRadio)
        view.addSubview(hideRadio)
        view.addSubview(keepRadio)
        
        NSLayoutConstraint.activate([
            showRadio.topAnchor.constraint(equalTo: view.topAnchor),
            showRadio.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            showRadio.heightAnchor.constraint(equalToConstant: 20),
            
            hideRadio.topAnchor.constraint(equalTo: view.topAnchor),
            hideRadio.leadingAnchor.constraint(equalTo: showRadio.trailingAnchor, constant: 15),
            hideRadio.heightAnchor.constraint(equalToConstant: 20),
            
            keepRadio.topAnchor.constraint(equalTo: view.topAnchor),
            keepRadio.leadingAnchor.constraint(equalTo: hideRadio.trailingAnchor, constant: 15),
            keepRadio.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            keepRadio.heightAnchor.constraint(equalToConstant: 20)
        ])

//        showRadio.snp.makeConstraints {
//            $0.top.equalToSuperview()
//            $0.leading.equalToSuperview()
//            $0.height.equalTo(20)
//        }
//
//        hideRadio.snp.makeConstraints {
//            $0.top.equalToSuperview()
//            $0.leading.equalTo(showRadio.snp.trailing).offset(15)
//            $0.height.equalTo(20)
//        }
//
//        keepRadio.snp.makeConstraints {
//            $0.top.equalToSuperview()
//            $0.leading.equalTo(hideRadio.snp.trailing).offset(15)
//            $0.trailing.lessThanOrEqualToSuperview()
//            $0.height.equalTo(20)
//        }

        return view
    }()

    lazy var couponAlertView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let alertRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: ShopLiveResultAlertType.ALERT.name +  (self.isSuccess ? "s": "f"), description: ShopLiveResultAlertType.ALERT.name)
            view.updateRadio(selected: true)
            view.delegate = radioDelegate
            return view
        }()

        let toastRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: ShopLiveResultAlertType.TOAST.name +  (self.isSuccess ? "s": "f"), description: ShopLiveResultAlertType.TOAST.name)
            view.delegate = radioDelegate
            return view
        }()

        self.alertRadioGroup = [alertRadio, toastRadio]
        view.addSubview(alertRadio)
        view.addSubview(toastRadio)
        
        NSLayoutConstraint.activate([
            alertRadio.topAnchor.constraint(equalTo: view.topAnchor),
            alertRadio.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            alertRadio.heightAnchor.constraint(equalToConstant: 20),
            
            toastRadio.topAnchor.constraint(equalTo: view.topAnchor),
            toastRadio.leadingAnchor.constraint(equalTo: alertRadio.trailingAnchor, constant: 15),
            toastRadio.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: 0),
            toastRadio.heightAnchor.constraint(equalToConstant: 20)
        ])

//        alertRadio.snp.makeConstraints {
//            $0.top.equalToSuperview()
//            $0.leading.equalToSuperview()
//            $0.height.equalTo(20)
//        }
//
//        toastRadio.snp.makeConstraints {
//            $0.top.equalToSuperview()
//            $0.leading.equalTo(alertRadio.snp.trailing).offset(15)
//            $0.trailing.lessThanOrEqualToSuperview()
//            $0.height.equalTo(20)
//        }

        return view
    }()

    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
        super.init(frame: .zero)
        setupViews()
        updateDatas()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateDatas() {
        let config = DemoConfiguration.shared
        resultMessage = isSuccess ? config.downloadCouponSuccessMessage : config.downloadCouponFailedMessage
        resultAlertType = isSuccess ? config.downloadCouponSuccessAlertType : config.downloadCouponFailedAlertType
        resultStatus = isSuccess ? config.downloadCouponSuccessStatus : config.downloadCouponFailedStatus

        messageTextField.text = resultMessage
        
        let tag = isSuccess ? "s" : "f"
        let statusIdentifier = resultStatus.name + tag
        let alertIdentifier = resultAlertType.name + tag

        updateShowRadio(identifier: statusIdentifier)
        updateAlertRadio(identifier: alertIdentifier)
    }

    private func setupViews() {
        self.addSubview(titleLabel)
        self.addSubview(messageTitleLabel)
        self.addSubview(messageTextField)
        self.addSubview(showTitleLabel)
        self.addSubview(alertTitleLabel)
        self.addSubview(couponShowView)
        self.addSubview(couponAlertView)
        
        let couponShowViewTopAnc = couponShowView.topAnchor.constraint(greaterThanOrEqualTo: showTitleLabel.topAnchor)
        couponShowViewTopAnc.priority = UILayoutPriority(rawValue: 999)
        let couponShowViewBottomAnc = couponShowView.bottomAnchor.constraint(lessThanOrEqualTo: showTitleLabel.bottomAnchor)
        couponShowViewBottomAnc.priority = UILayoutPriority(rawValue: 999)
        let couponShowViewCentYAnc = couponShowView.centerYAnchor.constraint(equalTo: showTitleLabel.centerYAnchor)
        couponShowViewCentYAnc.priority = UILayoutPriority(rawValue: 1000)
        
        
        let couponAlertViewTopAnc = couponAlertView.topAnchor.constraint(greaterThanOrEqualTo: alertTitleLabel.topAnchor)
        couponAlertViewTopAnc.priority = UILayoutPriority(rawValue: 999)
        let couponAlertViewBottomAnc = couponAlertView.bottomAnchor.constraint(lessThanOrEqualTo: alertTitleLabel.bottomAnchor)
        couponAlertViewBottomAnc.priority = UILayoutPriority(rawValue: 999)
        let couponAlertViewCentYAnc = couponAlertView.centerYAnchor.constraint(equalTo: alertTitleLabel.centerYAnchor)
        couponAlertViewCentYAnc.priority = UILayoutPriority(rawValue: 1000)
        
        
        
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 15),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -10),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            messageTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 15),
            messageTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor ,constant: 15),
            messageTitleLabel.widthAnchor.constraint(equalToConstant: 120),
            messageTitleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            showTitleLabel.topAnchor.constraint(equalTo: messageTitleLabel.bottomAnchor, constant: 15),
            showTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            showTitleLabel.widthAnchor.constraint(equalToConstant: 120),
            showTitleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            alertTitleLabel.topAnchor.constraint(equalTo: showTitleLabel.bottomAnchor, constant: 15),
            alertTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            alertTitleLabel.widthAnchor.constraint(equalToConstant: 120),
            alertTitleLabel.heightAnchor.constraint(equalToConstant: 30),
            alertTitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15),
            
            messageTextField.topAnchor.constraint(equalTo: messageTitleLabel.topAnchor),
            messageTextField.bottomAnchor.constraint(equalTo: messageTitleLabel.bottomAnchor),
            messageTextField.leadingAnchor.constraint(equalTo: messageTitleLabel.trailingAnchor),
            messageTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -15),
            
            couponShowViewTopAnc,
            couponShowViewBottomAnc,
            couponShowViewCentYAnc,
            couponShowView.leadingAnchor.constraint(equalTo: showTitleLabel.trailingAnchor),
            couponShowView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -15),
            
            couponAlertViewTopAnc,
            couponAlertViewBottomAnc,
            couponAlertViewCentYAnc,
            couponAlertView.leadingAnchor.constraint(equalTo: alertTitleLabel.trailingAnchor),
            couponAlertView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -15)
            
        ])

//
//        titleLabel.snp.makeConstraints {
//            $0.top.leading.equalToSuperview().offset(15)
//            $0.trailing.lessThanOrEqualToSuperview().offset(-10)
//            $0.height.equalTo(30)
//        }
//
//        messageTitleLabel.snp.makeConstraints {
//            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
//            $0.leading.equalToSuperview().offset(15)
//            $0.width.equalTo(120)
//            $0.height.equalTo(30)
//        }
//
//        showTitleLabel.snp.makeConstraints {
//            $0.top.equalTo(messageTitleLabel.snp.bottom).offset(15)
//            $0.leading.equalToSuperview().offset(15)
//            $0.width.equalTo(120)
//            $0.height.equalTo(30)
//        }
//
//        alertTitleLabel.snp.makeConstraints {
//            $0.top.equalTo(showTitleLabel.snp.bottom).offset(15)
//            $0.leading.equalToSuperview().offset(15)
//            $0.width.equalTo(120)
//            $0.height.equalTo(30)
//            $0.bottom.equalToSuperview().offset(-15)
//        }
//
//        messageTextField.snp.makeConstraints {
//            $0.top.bottom.equalTo(messageTitleLabel)
//            $0.leading.equalTo(messageTitleLabel.snp.trailing)
//            $0.trailing.equalToSuperview().offset(-15)
//        }
//
//        couponShowView.snp.makeConstraints {
//            $0.top.greaterThanOrEqualTo(showTitleLabel).priority(999)
//            $0.bottom.lessThanOrEqualTo(showTitleLabel).priority(999)
//            $0.centerY.equalTo(showTitleLabel).priority(1000)
//            $0.leading.equalTo(showTitleLabel.snp.trailing)
//            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
//        }
//
//        couponAlertView.snp.makeConstraints {
//            $0.top.greaterThanOrEqualTo(alertTitleLabel).priority(999)
//            $0.bottom.lessThanOrEqualTo(alertTitleLabel).priority(999)
//            $0.centerY.equalTo(alertTitleLabel).priority(1000)
//            $0.leading.equalTo(alertTitleLabel.snp.trailing)
//            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
//        }
    }

    private func updateShowRadio(identifier: String) {
        showRadioGroup.forEach { radio in
            radio.updateRadio(selected: radio.identifier == identifier)
        }
    }

    private func updateAlertRadio(identifier: String) {
        alertRadioGroup.forEach { radio in
            radio.updateRadio(selected: radio.identifier == identifier)
        }
    }
}

extension CouponResponseSettingView {
    func updateShowSetting(identifier: String) {
        resultStatus = ShopLiveResultStatus.allCases.first(where: { $0.name == identifier.dropLast()}) ?? (isSuccess ? DemoConfiguration.shared.downloadCouponSuccessStatus : DemoConfiguration.shared.downloadCouponFailedStatus)

        updateShowRadio(identifier: identifier)
    }

    func updateAlertSetting(identifier: String) {
        resultAlertType = ShopLiveResultAlertType.allCases.first(where: { $0.name == identifier.dropLast()}) ?? (isSuccess ? DemoConfiguration.shared.downloadCouponSuccessAlertType : DemoConfiguration.shared.downloadCouponFailedAlertType)

        updateAlertRadio(identifier: identifier)
    }

    func getSetting() -> (message: String, resultStatus: ShopLiveResultStatus, resultalertType: ShopLiveResultAlertType) {
        var message: String = resultMessage
        if let inputMessage = messageTextField.text, !message.isEmpty {
            message = inputMessage
        }
        return (message, resultStatus, resultAlertType)
    }
}
