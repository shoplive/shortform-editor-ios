//
//  CampaignCell.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

final class CampaignCell: UITableViewCell {

    private let campaignAliasLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.textAlignment = .left
        return view
    }()

    private let accessKeyLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.textAlignment = .left
        return view
    }()

    private let campaignKeyLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.textAlignment = .left
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func setupViews() {
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(campaignAliasLabel)
        self.contentView.addSubview(accessKeyLabel)
        self.contentView.addSubview(campaignKeyLabel)

        let bottomLine: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .lightGray
            return view
        }()

        self.contentView.addSubview(bottomLine)
        
        
        NSLayoutConstraint.activate([
            bottomLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1),
            
            campaignAliasLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            campaignAliasLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 15),
            campaignAliasLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),
            
            accessKeyLabel.topAnchor.constraint(equalTo: campaignAliasLabel.bottomAnchor, constant: 0),
            accessKeyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 15),
            accessKeyLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),
            
            campaignKeyLabel.topAnchor.constraint(equalTo: accessKeyLabel.bottomAnchor, constant: 0),
            campaignKeyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            campaignKeyLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),
            campaignKeyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -15)
        ])
        
//        bottomLine.snp.makeConstraints {
//            $0.leading.trailing.bottom.equalToSuperview()
//            $0.height.equalTo(1)
//        }
//        campaignAliasLabel.snp.makeConstraints {
//            $0.top.leading.equalToSuperview().offset(15)
//            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
//        }
//
//        accessKeyLabel.snp.makeConstraints {
//            $0.top.equalTo(campaignAliasLabel.snp.bottom)
//            $0.leading.equalToSuperview().offset(15)
//            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
//        }
//
//        campaignKeyLabel.snp.makeConstraints {
//            $0.top.equalTo(accessKeyLabel.snp.bottom)
//            $0.leading.equalToSuperview().offset(15)
//            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
//            $0.bottom.equalToSuperview().offset(-15)
//        }
    }

    func configure(keySet: ShopLiveKeySet) {
        self.campaignAliasLabel.text = keySet.alias
        self.accessKeyLabel.text = keySet.accessKey
        self.campaignKeyLabel.text = keySet.campaignKey
    }

}

