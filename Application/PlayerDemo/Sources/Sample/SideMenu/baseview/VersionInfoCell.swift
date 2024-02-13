//
//  VersionInfoCell.swift
//  ShopLiveSDK
//
//  Created by Vincent on 12/12/22.
//

import Foundation
import UIKit
import ShopLiveSDK

final class VersionInfoCell: SampleBaseCell {
    
    class VersionInfoCellViewModel {
        var sdkVersionLabelTitle: String {
            "SDK v\(ShopLive.sdkVersion) , "
        }
        
        var customAppVersionButtonTitle: String {
            let baseString: String = "고객사 앱 버전: "
            guard let appVersion = DemoConfiguration.shared.customAppVersion, !appVersion.isEmpty else {
                return baseString + "미입력"
            }
            
            return baseString + "v\(appVersion)"
        }

        var customReferrerButtonTitle: String {
            guard let referrer = DemoConfiguration.shared.customReferrer, !referrer.isEmpty else {
                return "Referrer 미입력"
            }
            
            return "Referrer: \(referrer)"
        }
        
        var customAdIdButtonTitle: String {
            guard let referrer = DemoConfiguration.shared.utmSource, !referrer.isEmpty else {
                return "utmSource 미입력"
            }
            
            return "utmSource: \(referrer)"
        }
    }
    
    private let viewModel = VersionInfoCellViewModel()
    
    private lazy var sdkVersionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.font = .systemFont(ofSize: 18, weight: .semibold)
        view.text = viewModel.sdkVersionLabelTitle
        view.textAlignment = .left
        view.textColor = .black
        return view
    }()
    
    private lazy var customAppVersionButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.black, for: .normal)
        view.setTitleColor(.black, for: .highlighted)
        view.setTitle(viewModel.customAppVersionButtonTitle, for: .normal)
        view.setTitle(viewModel.customAppVersionButtonTitle, for: .highlighted)
        view.addTarget(self, action: #selector(didTapVersionSetup), for: .touchUpInside)
        
        return view
    }()
    
    private lazy var customReferrerButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.black, for: .normal)
        view.setTitleColor(.black, for: .highlighted)
        view.setTitle(viewModel.customReferrerButtonTitle, for: .normal)
        view.setTitle(viewModel.customReferrerButtonTitle, for: .highlighted)
        view.addTarget(self, action: #selector(didTapReferrerSetup), for: .touchUpInside)
        
        return view
    }()
    
    private lazy var customAdIdButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.black, for: .normal)
        view.setTitleColor(.black, for: .highlighted)
        view.setTitle(viewModel.customAdIdButtonTitle, for: .normal)
        view.setTitle(viewModel.customAdIdButtonTitle, for: .highlighted)
        view.addTarget(self, action: #selector(didTapAdIdSetup), for: .touchUpInside)
        
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func setupViews() {
        super.setupViews()
        self.contentView.addSubview(sdkVersionLabel)
        self.contentView.addSubview(customAppVersionButton)
        self.contentView.addSubview(customReferrerButton)
        self.contentView.addSubview(customAdIdButton)
        
        NSLayoutConstraint.activate([
            sdkVersionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            sdkVersionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 25),
            sdkVersionLabel.heightAnchor.constraint(equalToConstant: 30),
            
            customAppVersionButton.leadingAnchor.constraint(equalTo: sdkVersionLabel.trailingAnchor),
            customAppVersionButton.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),
            customAppVersionButton.topAnchor.constraint(equalTo: sdkVersionLabel.topAnchor),
            customAppVersionButton.bottomAnchor.constraint(equalTo: sdkVersionLabel.bottomAnchor),
            
            customReferrerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            customReferrerButton.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),
            customReferrerButton.topAnchor.constraint(equalTo: customAppVersionButton.bottomAnchor,constant: 10),
            
            customAdIdButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            customAdIdButton.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),
            customAdIdButton.topAnchor.constraint(equalTo: customReferrerButton.bottomAnchor, constant: 10),
            customAdIdButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
            sectionTitleLabel.widthAnchor.constraint(equalToConstant: 0),
            sectionTitleLabel.heightAnchor.constraint(equalToConstant: 0)
        ])
        
//        sdkVersionLabel.snp.makeConstraints {
//            $0.leading.equalToSuperview().offset(15)
//            $0.top.equalToSuperview().offset(25)
//            $0.height.equalTo(30)
//        }
//        
//        customAppVersionButton.snp.makeConstraints {
//            $0.leading.equalTo(sdkVersionLabel.snp.trailing)
//            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
//            $0.top.bottom.equalTo(sdkVersionLabel)
//        }
//        
//        customReferrerButton.snp.makeConstraints {
//            $0.leading.equalToSuperview().offset(15)
//            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
//            $0.top.equalTo(customAppVersionButton.snp.bottom).offset(10)
//        }
//        
//        customAdIdButton.snp.makeConstraints {
//            $0.leading.equalToSuperview().offset(15)
//            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
//            $0.top.equalTo(customReferrerButton.snp.bottom).offset(10)
//            $0.bottom.equalToSuperview().offset(-15)
//        }
//        
//        sectionTitleLabel.snp.remakeConstraints {
//            $0.width.height.equalTo(0)
//        }
    }
    
    private func updateVersion() {
        customAppVersionButton.setTitle(viewModel.customAppVersionButtonTitle, for: .normal)
        customAppVersionButton.setTitle(viewModel.customAppVersionButtonTitle, for: .highlighted)
    }
    
    private func updateReferrer() {
        customReferrerButton.setTitle(viewModel.customReferrerButtonTitle, for: .normal)
        customReferrerButton.setTitle(viewModel.customReferrerButtonTitle, for: .highlighted)
    }
    
    private func updateAdId() {
        customAdIdButton.setTitle(viewModel.customAdIdButtonTitle, for: .normal)
        customAdIdButton.setTitle(viewModel.customAdIdButtonTitle, for: .highlighted)
    }
    
    @objc
    private func didTapVersionSetup() {
        let vc = CustomAppVersionInputAlertController(completion: { [weak self] in
                self?.updateVersion()
                self?.baseDelegate?.updateDatas()
        })
        vc.modalPresentationStyle = .overCurrentContext
        parent?.present(vc, animated: false, completion: nil)
    }
    
    @objc
    private func didTapReferrerSetup() {
        let vc = CustomReferrerAlertController(completion: { [weak self] in
                self?.updateReferrer()
                self?.baseDelegate?.updateDatas()
        })
        vc.modalPresentationStyle = .overCurrentContext
        parent?.present(vc, animated: false, completion: nil)
    }
    
    @objc
    private func didTapAdIdSetup() {
        let vc = CustomUtmSourceAlertController(completion: { [weak self] in
                self?.updateAdId()
                self?.baseDelegate?.updateDatas()
        })
        vc.modalPresentationStyle = .overCurrentContext
        parent?.present(vc, animated: false, completion: nil)
    }
}
