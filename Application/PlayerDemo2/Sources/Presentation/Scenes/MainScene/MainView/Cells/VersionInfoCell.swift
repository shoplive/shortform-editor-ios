//
//  VersionInfoCell.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
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
//            guard let appVersion = DemoConfiguration.shared.customAppVersion, !appVersion.isEmpty else {
//                return baseString + "미입력"
//            }
            
            return baseString + "v)"
        }

        var customReferrerButtonTitle: String {
//            guard let referrer = DemoConfiguration.shared.customReferrer, !referrer.isEmpty else {
//                return "Referrer 미입력"
//            }
            
            return "Referrer"
        }
        
        var customAnonIdButtonTitle : String {
//            guard let anonId = DemoConfiguration.shared.anonId, !anonId.isEmpty else {
//                return "anonId 미입력"
//            }
            return "anonId: "
        }
        
        var customAdIdButtonTitle: String {
//            guard let referrer = DemoConfiguration.shared.adId, !referrer.isEmpty else {
//                return "adId: 미입력"
//            }
            
            return "adId: "
        }
        
        var utmSourceTitle : String {
           
            return "utmSource:"
        }
        
        
        var utmContentTitle : String {
            
            return "utmContent:"
        }
        
        var utmCampaignTitle : String {
            
            return "utmCampaign :"
        }
        
        var utmMediumTitle : String {
            return "utmMedium:"
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
        view.addTarget(self, action: #selector(didTapUtmBtns(sender :)), for: .touchUpInside)
        view.tag = 5
        return view
    }()


    private lazy var utmSourceBtn : UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.black, for: .normal)
        view.setTitleColor(.black, for: .highlighted)
        view.setTitle(viewModel.utmSourceTitle, for: .normal)
        view.setTitle(viewModel.utmSourceTitle, for: .highlighted)
        view.addTarget(self, action: #selector(didTapUtmBtns(sender :)), for: .touchUpInside)
        view.tag = 0
        return view
    }()
    
    
    private lazy var utmCampaignBtn : UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.black, for: .normal)
        view.setTitleColor(.black, for: .highlighted)
        view.setTitle(viewModel.utmCampaignTitle, for: .normal)
        view.setTitle(viewModel.utmCampaignTitle, for: .highlighted)
        view.addTarget(self, action: #selector(didTapUtmBtns(sender :)), for: .touchUpInside)
        view.tag = 1
        return view
    }()
    
    private lazy var utmContentBtn : UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.black, for: .normal)
        view.setTitleColor(.black, for: .highlighted)
        view.setTitle(viewModel.utmContentTitle, for: .normal)
        view.setTitle(viewModel.utmContentTitle, for: .highlighted)
        view.addTarget(self, action: #selector(didTapUtmBtns(sender :)), for: .touchUpInside)
        view.tag = 2
        return view
    }()
    
    private lazy var utmMediumBtn : UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.black, for: .normal)
        view.setTitleColor(.black, for: .highlighted)
        view.setTitle(viewModel.utmMediumTitle, for: .normal)
        view.setTitle(viewModel.utmMediumTitle, for: .highlighted)
        view.addTarget(self, action: #selector(didTapUtmBtns(sender :)), for: .touchUpInside)
        view.tag = 3
        return view
    }()
    
    private lazy var customAnonIdButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        view.setTitleColor(.black, for: .normal)
        view.setTitleColor(.black, for: .highlighted)
        view.setTitle(viewModel.customAnonIdButtonTitle, for: .normal)
        view.setTitle(viewModel.customAnonIdButtonTitle, for: .highlighted)
        view.addTarget(self, action: #selector(didTapUtmBtns(sender :)), for: .touchUpInside)
        view.tag = 4
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
        self.contentView.addSubview(customAnonIdButton)
        self.contentView.addSubview(customAdIdButton)
        self.contentView.addSubview(utmSourceBtn)
        self.contentView.addSubview(utmContentBtn)
        self.contentView.addSubview(utmCampaignBtn)
        self.contentView.addSubview(utmMediumBtn)
        
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
            customAdIdButton.heightAnchor.constraint(equalToConstant: 30),
//            customAdIdButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
            utmSourceBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            utmSourceBtn.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),
            utmSourceBtn.topAnchor.constraint(equalTo: customAdIdButton.bottomAnchor, constant: 10),
//            utmContentBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            utmSourceBtn.heightAnchor.constraint(equalToConstant: 30),
            
            
            utmContentBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            utmContentBtn.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),
            utmContentBtn.topAnchor.constraint(equalTo: utmSourceBtn.bottomAnchor, constant: 10),
//            utmContentBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            utmContentBtn.heightAnchor.constraint(equalToConstant: 30),
            
            utmCampaignBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            utmCampaignBtn.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),
            utmCampaignBtn.topAnchor.constraint(equalTo: utmContentBtn.bottomAnchor, constant: 10),
//            utmCampaignBtn.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            utmCampaignBtn.heightAnchor.constraint(equalToConstant: 30),
            
            utmMediumBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            utmMediumBtn.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),
            utmMediumBtn.topAnchor.constraint(equalTo: utmCampaignBtn.bottomAnchor, constant: 10),
            utmMediumBtn.heightAnchor.constraint(equalToConstant: 30),
            
            customAnonIdButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            customAnonIdButton.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),
            customAnonIdButton.topAnchor.constraint(equalTo: utmMediumBtn.bottomAnchor, constant: 10),
            customAnonIdButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
            
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
        
        
        utmSourceBtn.setTitle(viewModel.utmSourceTitle, for: .normal)
        utmSourceBtn.setTitle(viewModel.utmSourceTitle, for: .highlighted)
        
        utmContentBtn.setTitle(viewModel.utmContentTitle, for: .normal)
        utmContentBtn.setTitle(viewModel.utmContentTitle, for: .highlighted)
        
        utmCampaignBtn.setTitle(viewModel.utmCampaignTitle, for: .normal)
        utmCampaignBtn.setTitle(viewModel.utmCampaignTitle, for: .highlighted)
        
        utmMediumBtn.setTitle(viewModel.utmMediumTitle, for: .normal)
        utmMediumBtn.setTitle(viewModel.utmMediumTitle, for: .highlighted)
        
        customAnonIdButton.setTitle(viewModel.customAnonIdButtonTitle, for: .normal)
        customAnonIdButton.setTitle(viewModel.customAnonIdButtonTitle, for: .highlighted)
        
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
    private func didTapUtmBtns(sender : UIButton) {
        let vc = CustomUtmSourceAlertController(completion: { [weak self] in
                self?.updateAdId()
                self?.baseDelegate?.updateDatas()
        })
        
        switch sender.tag {
        case 0:
            vc.utmType = .source
        case 1:
            vc.utmType = .campaign
        case 2:
            vc.utmType = .content
        case 3:
            vc.utmType = .medium
        case 4:
            vc.utmType = .anonId
        case 5:
            vc.utmType = .adId
        default:
            break
        }
        
        vc.modalPresentationStyle = .overCurrentContext
        parent?.present(vc, animated: false, completion: nil)
    }
}

