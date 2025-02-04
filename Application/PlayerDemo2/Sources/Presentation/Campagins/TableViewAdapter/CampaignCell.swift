//
//  CampaignCell.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import SnapKit

final class CampaignCell: UITableViewCell {

    static let cellId = "campaignCellId"
    
    private lazy var campaignAliasLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.textAlignment = .left
        return view
    }()

    private lazy var accessKeyLabel: UILabel = {
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
    
    private lazy var bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(keySet: ShopLiveKeySet) {
        self.campaignAliasLabel.text = keySet.alias
        self.accessKeyLabel.text = keySet.accessKey
        self.campaignKeyLabel.text = keySet.campaignKey
    }
}

extension CampaignCell {
    private func setLayout() {
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(campaignAliasLabel)
        self.contentView.addSubview(accessKeyLabel)
        self.contentView.addSubview(campaignKeyLabel)
        self.contentView.addSubview(bottomLine)
        
        bottomLine.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
            $0.leading.equalTo(contentView.snp.leading)
            $0.trailing.equalTo(contentView.snp.trailing)
            $0.height.equalTo(1)
        }
        
        campaignAliasLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).offset(15)
            $0.leading.equalTo(contentView.snp.leading).offset(15)
            $0.trailing.lessThanOrEqualTo(contentView.snp.trailing).inset(15)
        }
        
        accessKeyLabel.snp.makeConstraints {
            $0.top.equalTo(campaignAliasLabel.snp.bottom)
            $0.leading.equalTo(contentView.snp.leading).offset(15)
            $0.trailing.lessThanOrEqualTo(contentView.snp.trailing).inset(15)
        }
        
        campaignKeyLabel.snp.makeConstraints {
            $0.top.equalTo(accessKeyLabel.snp.bottom)
            $0.leading.equalTo(contentView.snp.leading).offset(15)
            $0.trailing.lessThanOrEqualTo(contentView.snp.trailing).inset(15)
            $0.bottom.equalTo(contentView.snp.bottom).inset(15)
        }
    }
}
