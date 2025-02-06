//
//  V2OptionButtonCell.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/29/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit

final class OptionRoutingCell : UITableViewCell {
    
    static let cellId = "v2optionbuttoncellId"
    
    private lazy var optionTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.textColor = .black
        view.font = .systemFont(ofSize: 15, weight: .regular)
        return view
    }()

    private lazy var optionDescriptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.textColor = .lightGray
        view.font = .systemFont(ofSize: 14, weight: .regular)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .gray
        setLayout()
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title : String, description : String) {
        self.optionTitleLabel.text = title
        self.optionDescriptionLabel.text = description
    }
}
extension OptionRoutingCell {
    func setLayout() {
        contentView.backgroundColor = .white
        contentView.addSubview(optionTitleLabel)
        contentView.addSubview(optionDescriptionLabel)
       
        optionTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-10)
            $0.height.equalTo(20)
        }
        
        optionDescriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-10)
            $0.top.equalTo(optionTitleLabel.snp.bottom).offset(4)
            $0.height.greaterThanOrEqualTo(20)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-10)
        }
        
    }
}
