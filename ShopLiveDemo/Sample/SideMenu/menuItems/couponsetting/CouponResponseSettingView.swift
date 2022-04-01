//
//  CouponResponseSettingView.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/18.
//

import UIKit

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

        couponShowView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(showTitleLabel).priority(999)
            $0.bottom.lessThanOrEqualTo(showTitleLabel).priority(999)
            $0.centerY.equalTo(showTitleLabel).priority(1000)
            $0.leading.equalTo(showTitleLabel.snp.trailing)
            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
        }

        couponAlertView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(alertTitleLabel).priority(999)
            $0.bottom.lessThanOrEqualTo(alertTitleLabel).priority(999)
            $0.centerY.equalTo(alertTitleLabel).priority(1000)
            $0.leading.equalTo(alertTitleLabel.snp.trailing)
            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
        }
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
