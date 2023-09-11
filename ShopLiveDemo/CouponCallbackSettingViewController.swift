//
//  CouponCallbackSettingViewController.swift
//  ShopLiveSwiftSample
//
//  Created by ShopLive on 2021/11/08.
//

import UIKit
import SnapKit
#if SDK_MODULE
import ShopLiveSDK
#endif

protocol TappableTextDelegate: AnyObject {
    func didTapText(_ sender: TappableText)
}

final class TappableText: UIView {

    weak var tapDelegate: TappableTextDelegate?

    private lazy var tapButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(didTapField), for: .touchUpInside)
        return view
    }()

    private lazy var textField: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var underLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        print(title.textWithDownArrow())
        textField.attributedText = title.textWithDownArrow()
    }

    private func setupViews() {
        self.addSubviews(underLine, textField, tapButton)
        
        NSLayoutConstraint.activate([
            underLine.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            underLine.heightAnchor.constraint(equalToConstant: 1),
            underLine.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            underLine.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            textField.topAnchor.constraint(equalTo: self.topAnchor),
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            tapButton.topAnchor.constraint(equalTo: self.topAnchor),
            tapButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tapButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tapButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

//        underLine.snp.makeConstraints {
//            $0.bottom.equalToSuperview()
//            $0.height.equalTo(1)
//            $0.leading.trailing.equalToSuperview()
//        }
//        textField.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
//        tapButton.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
        self.bringSubviewToFront(tapButton)
    }

    @objc func didTapField() {
        tapDelegate?.didTapText(self)
    }
}

final class CouponCallbackSettingView: UIView, TappableTextDelegate {

    private var title: String = "" {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    private var message: String = "" {
        didSet {
            self.messageField.text = self.message
        }
    }

    private var placeHolder: String = "" {
        didSet {
            self.messageField.placeholder = placeHolder
        }
    }

    private var status: ShopLiveResultStatus = .SHOW {
        didSet {
            self.exposeField.configure(title: status.name)
        }
    }

    private var alertType: ShopLiveResultAlertType = .ALERT {
        didSet {
            self.notiField.configure(title: alertType.name)
        }
    }

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        view.font = .systemFont(ofSize: 22)
        return view
    }()

    private lazy var messageLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.text = "메시지"
        return view
    }()

    private lazy var messageField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        return view
    }()

    private lazy var exposeLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        view.text = "쿠폰노출"
        return view
    }()

    private lazy var exposeField: TappableText = {
        let view = TappableText()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tapDelegate = self
        return view
    }()

    private lazy var notiLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        view.text = "알림"
        return view
    }()

    private lazy var notiField: TappableText = {
        let view = TappableText()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tapDelegate = self
        return view
    }()

    private var presenter: UIViewController

    init(_ vc: UIViewController) {
        self.presenter = vc
        super.init(frame: .zero)
        setupViews()
        configure(title: "", message: self.message, placeHolder: "", status: self.status, alertType: self.alertType)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.backgroundColor = .lightGray
        self.addSubviews(titleLabel, messageLabel, messageField, exposeLabel, exposeField, notiLabel, notiField)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor,constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -20),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.heightAnchor.constraint(equalToConstant: 18),
            
            messageField.centerYAnchor.constraint(equalTo: messageLabel.centerYAnchor),
            messageField.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor,constant: 10),
            messageField.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -20),
            messageField.heightAnchor.constraint(equalToConstant: 18),
            
            exposeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor,constant: 12),
            exposeLabel.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
            exposeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -20),
            exposeLabel.heightAnchor.constraint(equalToConstant: 18),
            
            notiLabel.topAnchor.constraint(equalTo: exposeLabel.bottomAnchor,constant: 12),
            notiLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            notiLabel.heightAnchor.constraint(equalToConstant: 18),
            
            notiField.centerYAnchor.constraint(equalTo: notiLabel.centerYAnchor),
            notiField.leadingAnchor.constraint(greaterThanOrEqualTo: notiLabel.trailingAnchor, constant: 10),
            notiField.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -20),
            notiField.heightAnchor.constraint(equalToConstant: 18)
        
        ])

//        titleLabel.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(10)
//            $0.leading.equalToSuperview().offset(20)
//            $0.trailing.equalToSuperview().offset(-20)
//            $0.height.equalTo(20)
//        }
//
//        messageLabel.snp.makeConstraints {
//            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
//            $0.leading.equalTo(titleLabel)
//            $0.height.equalTo(18)
//        }
//
//        messageField.snp.makeConstraints {
//            $0.centerY.equalTo(messageLabel)
//            $0.leading.equalTo(messageLabel.snp.trailing).offset(10)
//            $0.trailing.equalToSuperview().offset(-20)
//            $0.height.equalTo(18)
//        }
//
//        exposeLabel.snp.makeConstraints {
//            $0.top.equalTo(messageLabel.snp.bottom).offset(12)
//            $0.leading.equalTo(messageLabel)
//            $0.height.equalTo(18)
//        }
//
//        exposeField.snp.makeConstraints {
//            $0.centerY.equalTo(exposeLabel)
//            $0.leading.greaterThanOrEqualTo(exposeLabel.snp.trailing).offset(10)
//            $0.trailing.equalToSuperview().offset(-20)
//            $0.height.equalTo(18)
//        }
//
//        notiLabel.snp.makeConstraints {
//            $0.top.equalTo(exposeLabel.snp.bottom).offset(12)
//            $0.leading.equalTo(titleLabel)
//            $0.height.equalTo(18)
//        }
//
//        notiField.snp.makeConstraints {
//            $0.centerY.equalTo(notiLabel)
//            $0.leading.greaterThanOrEqualTo(notiLabel.snp.trailing).offset(10)
//            $0.trailing.equalToSuperview().offset(-20)
//            $0.height.equalTo(18)
//        }

    }

    func configure(title: String, message: String, placeHolder: String, status: ShopLiveResultStatus, alertType: ShopLiveResultAlertType) {
        self.title = title
        self.message = message
        self.placeHolder = placeHolder
        self.status = status
        self.alertType = alertType
    }

    func getSettingValues() -> (message: String, status: ShopLiveResultStatus, alertType: ShopLiveResultAlertType) {
        return (self.messageField.text ?? "", self.status, self.alertType)
    }

    func didTapText(_ sender: TappableText) {
        switch sender {
        case exposeField:
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            ShopLiveResultStatus.allCases.forEach { status in
                let action = UIAlertAction(title: status.name, style: .default) { [weak self] alertAction in
                    guard let self = self else { return }
                    self.status = status
                    self.exposeField.configure(title: status.name)
                }
                sheet.addAction(action)
            }
            sheet.addAction(.init(title: "취소", style: .cancel, handler: nil))
            self.presenter.present(sheet, animated: true, completion: nil)
            break
        case notiField:
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            ShopLiveResultAlertType.allCases.forEach { alertType in
                let action = UIAlertAction(title: alertType.name, style: .default) { [weak self] alertAction in
                    guard let self = self else { return }
                    self.alertType = alertType
                    self.notiField.configure(title: alertType.name)
                }
                sheet.addAction(action)
            }
            sheet.addAction(.init(title: "취소", style: .cancel, handler: nil))
            self.presenter.present(sheet, animated: true, completion: nil)
            break
        default:
            break
        }
    }

}

final class CouponCallbackSettingViewController: UIViewController {

    private lazy var saveButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("저장", for: .normal)
        view.setTitleColor(.black, for: .normal)
        view.addTarget(self, action: #selector(save), for: .touchUpInside)
        return view
    }()

    private lazy var closeButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(named: "close")!, for: .normal)
        view.addTarget(self, action: #selector(close), for: .touchUpInside)
        return view
    }()

    private lazy var successSettingView: CouponCallbackSettingView = {
        let view = CouponCallbackSettingView(self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var failedSettingView: CouponCallbackSettingView = {
        let view = CouponCallbackSettingView(self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        setupViews()
        setupSettings()
    }

    private func setupViews() {
        self.view.backgroundColor = .white
        self.view.addSubviews(closeButton, saveButton, successSettingView, failedSettingView)
        
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo:self.view.leadingAnchor,constant: 10),
            closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 10),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            saveButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -10),
            saveButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,constant: 10),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
            
            successSettingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20),
            successSettingView.topAnchor.constraint(equalTo: closeButton.bottomAnchor,constant: 10),
            successSettingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            successSettingView.heightAnchor.constraint(greaterThanOrEqualToConstant: 130),
            
            failedSettingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20),
            failedSettingView.topAnchor.constraint(equalTo: successSettingView.bottomAnchor,constant: 20),
            failedSettingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -20),
            failedSettingView.heightAnchor.constraint(greaterThanOrEqualToConstant: 130)
        
        ])

//        closeButton.snp.makeConstraints {
//            $0.leading.equalToSuperview().offset(10)
//            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
//            $0.width.height.equalTo(40)
//        }
//
//        saveButton.snp.makeConstraints {
//            $0.trailing.equalToSuperview().offset(-10)
//            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
//            $0.height.equalTo(40)
//        }
//
//        successSettingView.snp.makeConstraints {
//            $0.leading.equalToSuperview().offset(20)
//            $0.top.equalTo(closeButton.snp.bottom).offset(10)
//            $0.trailing.equalToSuperview().offset(-20)
//            $0.height.greaterThanOrEqualTo(130)
//        }
//
//        failedSettingView.snp.makeConstraints {
//            $0.leading.equalToSuperview().offset(20)
//            $0.top.equalTo(successSettingView.snp.bottom).offset(20)
//            $0.trailing.equalToSuperview().offset(-20)
//            $0.height.greaterThanOrEqualTo(130)
//        }

    }

    func setupSettings() {
        self.successSettingView.configure(title: "성공시 액션 설정", message: SDKSettings.downloadCouponSuccessMessage, placeHolder: "쿠폰 다운로드에 성공하였습니다.", status: SDKSettings.downloadCouponSuccessStatus, alertType: SDKSettings.downloadCouponSuccessAlertType)
        self.failedSettingView.configure(title: "실패시 액션 설정", message: SDKSettings.downloadCouponFailedMessage, placeHolder: "쿠폰 다운로드에 실패하였습니다.", status: SDKSettings.downloadCouponFailedStatus, alertType: SDKSettings.downloadCouponFailedAlertType)
    }

    @objc
    func save() {
        let successSettings = self.successSettingView.getSettingValues()
        let failedSettings = self.failedSettingView.getSettingValues()

        SDKSettings.downloadCouponSuccessMessage = successSettings.message
        SDKSettings.downloadCouponSuccessStatus = successSettings.status
        SDKSettings.downloadCouponSuccessAlertType = successSettings.alertType

        SDKSettings.downloadCouponFailedMessage = failedSettings.message
        SDKSettings.downloadCouponFailedStatus = failedSettings.status
        SDKSettings.downloadCouponFailedAlertType = failedSettings.alertType
        close()
    }

    @objc
    private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}

#if SDK_MODULE
extension String {
    func textWithDownArrow() -> NSAttributedString {
        let downArrow = UIImage(named: "down_arrow")

        let attrText: NSMutableAttributedString = .init(string: "\(self) ")
        guard let downArrowImage = downArrow else {
            return attrText
        }

        attrText.append(.init(attachment: downArrowImage.toNSTextAttachment(yPos: 3)))
        return attrText
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { view in
            self.addSubview(view)
        }
    }
}

extension UIImage {
    func toNSTextAttachment(_ width: CGFloat? = nil, _ height: CGFloat? = nil, _ yPos: CGFloat = -8) -> NSTextAttachment {
        let imageAttachment = NSTextAttachment()
        imageAttachment.bounds = CGRect(x: 0, y: yPos, width: width ?? self.size.width, height: height ?? self.size.height)
        imageAttachment.image = self
        return imageAttachment
    }

    func toNSTextAttachment(yPos: CGFloat = -8) -> NSTextAttachment {
        let imageAttachment = NSTextAttachment()
        imageAttachment.bounds = CGRect(x: 0, y: yPos, width:  self.size.width, height: self.size.height)
        imageAttachment.image = self
        return imageAttachment
    }
}
#endif
