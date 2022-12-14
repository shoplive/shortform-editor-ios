//
//  VersionInfoCell.swift
//  ShopLiveSDK
//
//  Created by 김우현 on 12/12/22.
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
        
        sdkVersionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.top.equalToSuperview().offset(25)
            $0.bottom.equalToSuperview().offset(-15)
            $0.height.equalTo(30)
        }
        
        customAppVersionButton.snp.makeConstraints {
            $0.leading.equalTo(sdkVersionLabel.snp.trailing)
            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
            $0.top.bottom.equalTo(sdkVersionLabel)
        }
        
        sectionTitleLabel.snp.remakeConstraints {
            $0.width.height.equalTo(0)
        }
    }
    
    private func updateVersion() {
        customAppVersionButton.setTitle(viewModel.customAppVersionButtonTitle, for: .normal)
        customAppVersionButton.setTitle(viewModel.customAppVersionButtonTitle, for: .highlighted)
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
}
