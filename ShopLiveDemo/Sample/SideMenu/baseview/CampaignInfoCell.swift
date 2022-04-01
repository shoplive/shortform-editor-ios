//
//  CampaignInfoCell.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/14.
//

import UIKit

final class CampaignInfoCell: SampleBaseCell {

    private lazy var guideTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textColor = .black
        view.text = "base.section.campaignInfo.campaign.none.title".localized()
        return view
    }()

    private lazy var chooseButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.layer.cornerRadius = 6
        view.contentEdgeInsets = .init(top: 7, left: 9, bottom: 7, right: 9)
        view.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        view.addTarget(self, action: #selector(didTouchButton), for: .touchUpInside)
        view.setTitle("base.section.campaignInof.button.chooseCampaign.title".localized(), for: .normal)
        return view
    }()

    private lazy var accessKeyInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.placeholder = "accessKey"
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

    lazy var campaignKeyInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.placeholder = "campaignKey"
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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        currentKeyUpdated()
        ShopLiveDemoKeyTools.shared.addKeysetObserver(observer: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupViews() {
        super.setupViews()
        self.itemView.addSubview(guideTitleLabel)
        self.itemView.addSubview(chooseButton)
        self.itemView.addSubview(accessKeyInputField)
        self.itemView.addSubview(campaignKeyInputField)
        guideTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.top.equalToSuperview().offset(15)
            $0.trailing.equalTo(chooseButton.snp.leading).offset(-15)
        }

        chooseButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-15)
            $0.top.equalToSuperview().offset(5)
            $0.height.equalTo(35)
            $0.width.equalTo(80)
        }

        accessKeyInputField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.top.equalTo(guideTitleLabel.snp.bottom).offset(10)
            $0.height.equalTo(30)
        }

        campaignKeyInputField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.top.equalTo(accessKeyInputField.snp.bottom).offset(10)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(30)
        }

        self.setSectionTitle(title: "base.section.campaignInfo.title".localized())
    }

    @objc private func didTouchButton() {
        let page = CampaignsViewController()
        page.selectKeySet = true
        self.parent?.navigationController?.pushViewController(page, animated: true)
    }
}

extension CampaignInfoCell: KeySetObserver {
    var identifier: String {
        return "CampaignInfoCell"
    }

    func keysetUpdated() {

    }

    func currentKeyUpdated() {
        if let currentKey = ShopLiveDemoKeyTools.shared.currentKey() {
            guideTitleLabel.text = currentKey.alias
            campaignKeyInputField.text = currentKey.campaignKey
            accessKeyInputField.text = currentKey.accessKey
        } else {
            guideTitleLabel.text = "base.section.campaignInfo.campaign.none.title".localized()
            campaignKeyInputField.text = "campaignKey"
            accessKeyInputField.text = "accessKey"
        }
        guideTitleLabel.sizeToFit()
    }
}

